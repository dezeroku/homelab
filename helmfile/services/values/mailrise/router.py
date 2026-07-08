# Copied over from https://github.com/YoRyan/mailrise/blob/main/src/mailrise/simple_router.py
# "Forked" from commit 60d485e2ae22ae09ddeac25565c48e3455a8c1a7 (Nov 8, 2025)
# Keep the original mechanics, while allowing config strings to be templated
# This allow proper rerouting via SES handler
"""
This is the YAML-based router for Mailrise.
"""

from email.utils import parseaddr
from fnmatch import fnmatchcase
from logging import Logger
from string import Template
import asyncio
import html as html_lib
import os
import re
import shutil
import tempfile
import typing as typ

import apprise
import yaml

from mailrise.router import AppriseNotification, EmailAttachment, EmailMessage, Router


# Keep strong references to detached delivery tasks so the event loop does not
# garbage-collect them mid-flight. Discarded via a done callback (see below).
_DELIVERY_TASKS: typ.Set["asyncio.Task[None]"] = set()


async def _deliver(
    logger: Logger,
    config: str,
    title: str,
    body: str,
    body_format: typ.Optional[apprise.NotifyFormat],
    notify_type: apprise.NotifyType,
    attachments: typ.List[EmailAttachment],
    recipient: str,
) -> None:
    """Send an Apprise notification independently of the SMTP connection.

    Mailrise normally sends the notification synchronously inside the SMTP DATA
    handler, so a client that hangs up before delivery finishes (e.g. immich,
    which closes the connection right after the message body) gets the handler
    task - and the in-flight notification - cancelled by aiosmtpd. Running the
    send as a detached task decouples it from the connection lifetime, so the
    push is delivered even when the sender does not wait for our 250 ack.
    """
    tmpdir: typ.Optional[str] = None
    try:
        ap_config = apprise.AppriseConfig()
        ap_config.add_config(config, format="yaml")
        ap = apprise.Apprise(ap_config)

        attach: typ.Optional[apprise.AppriseAttachment] = None
        if attachments:
            # apprise 1.4.x has no in-memory attachment type, so spool each
            # attachment to a temp file and add it by path (mirrors mailrise's
            # own _AttachMailrise). Cleaned up in the finally block.
            tmpdir = tempfile.mkdtemp(prefix="mailrise-router-")
            attach = apprise.AppriseAttachment()
            for item in attachments:
                name = os.path.basename(item.filename) or "attachment"
                path = os.path.join(tmpdir, name)
                with open(path, "wb") as fobj:
                    fobj.write(item.data)
                attach.add(path)

        ok = await ap.async_notify(
            title=title,
            body=body,
            body_format=body_format,
            notify_type=notify_type,
            attach=attach,
        )
        if ok:
            logger.info("Delivered notification to %s", recipient)
        else:
            logger.warning("Notification to %s failed to send", recipient)
    except Exception:  # pylint: disable=broad-except
        # Never let a background task die silently; this is our only feedback
        # since the SMTP client is long gone by the time we run.
        logger.exception("Error delivering notification to %s", recipient)
    finally:
        if tmpdir is not None:
            shutil.rmtree(tmpdir, ignore_errors=True)


def _strip_html(markup: str) -> str:
    """Best-effort HTML -> plain text for text-only targets.

    We convert here rather than let apprise do it because apprise 1.4.5's
    html_to_text converter crashes (AttributeError in handle_starttag) on some
    real-world HTML, such as immich's notification emails.
    """
    text = re.sub(r"(?is)<(script|style|head)\b.*?</\1>", "", markup)
    text = re.sub(r"(?i)<br\s*/?>", "\n", text)
    text = re.sub(r"(?i)</(p|div|tr|h[1-6]|li)>", "\n", text)
    text = re.sub(r"(?s)<[^>]+>", "", text)
    text = html_lib.unescape(text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n[ \t]+", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def _plain_text_body(email: EmailMessage) -> str:
    """Return a plain-text body suitable for text-only notification targets."""
    # Prefer a genuine text/plain alternative from the original message.
    try:
        part = email.email_message.get_body(preferencelist=("plain",))
        if part is not None:
            content = part.get_content()
            if content and content.strip():
                return content.strip()
    except Exception:  # pylint: disable=broad-except
        # Falls through to stripping the (possibly HTML) body below.
        pass
    if email.body_format == apprise.NotifyFormat.HTML or "<" in email.body:
        return _strip_html(email.body)
    return email.body


class _Key(typ.NamedTuple):
    """A unique identifier for a sender target.

    Attributes:
        user: The user portion of the recipient address.
        domain: The domain portion of the recipient address, which defaults
            to "mailrise.xyz".
    """

    user: str
    domain: str = "mailrise.xyz"

    def __str__(self) -> str:
        return f"{self.user}@{self.domain}"

    def as_configured(self) -> str:
        """Drop the domain part of this identifier if it is 'mailrise.xyz'."""
        return self.user if self.domain == "mailrise.xyz" else str(self)


class _Recipient(typ.NamedTuple):
    """The routing information encoded into a recipient address.

    Attributes:
        key: An index into the dictionary of senders.
        notify_type: The type of notification to send.
    """

    key: _Key
    notify_type: apprise.NotifyType


def _parsercpt(addr: str) -> _Recipient:
    _, rcpt = parseaddr(addr)
    user, domain = _parseaddrparts(rcpt)
    if not user or not domain:
        raise ValueError
    match = re.search(r"(.*)\.(info|success|warning|failure)$", user, re.IGNORECASE)
    ntype = apprise.NotifyType.INFO
    if match is not None:
        user = match.group(1)
        ntypes = match.group(2)
        if ntypes == "info":
            pass
        elif ntypes == "success":
            ntype = apprise.NotifyType.SUCCESS
        elif ntypes == "warning":
            ntype = apprise.NotifyType.WARNING
        elif ntypes == "failure":
            ntype = apprise.NotifyType.FAILURE
    return _Recipient(key=_Key(user=user, domain=domain.lower()), notify_type=ntype)


def _parseaddrparts(email: str) -> typ.Tuple[str, str]:
    """Parses an email address into its component user and domain parts."""
    match = re.search(r'(?:"([^"@]*)"|([^@]*))@([^@]*)$', email)
    if match is None:
        return "", ""
    quoted = match.group(1) is not None
    user = match.group(1) if quoted else match.group(2)
    domain = match.group(3)
    return user, domain


class _SimpleSender(typ.NamedTuple):
    """A configured target for Apprise notifications.

    Attributes:
        config_template: The template for YAML configuration for Apprise.
        title_template: The template string for notification title texts.
        body_template: The template string for notification body texts.
        body_format: The content type for notifications. If None, this will be
            auto-detected from the body parts of emails.
    """

    config_template: Template
    title_template: Template
    body_template: Template
    body_format: typ.Optional[apprise.NotifyFormat]


class SimpleRouter(Router):  # pylint: disable=too-few-public-methods
    """A router that uses the rules in the YAML configuration file.

    Attributes:
        senders: A list of notification targets, each with a [key, sender]
            tuple, where key contains username and domain patterns that can be
            matched by fnmatch and sender is the Sender instance itself.
    """

    senders: typ.List[typ.Tuple[_Key, _SimpleSender]]

    def __init__(self, senders: typ.List[typ.Tuple[_Key, _SimpleSender]]):
        super().__init__()
        self.senders = senders

    async def email_to_apprise(
        self, logger: Logger, email: EmailMessage, auth_data: typ.Any, **kwargs
    ) -> typ.AsyncGenerator[AppriseNotification, None]:
        for addr in email.to:
            try:
                rcpt = _parsercpt(addr)
            except ValueError:
                logger.error("Not a valid Mailrise address: %s", addr)
                continue
            sender = self.get_sender(rcpt.key)
            if sender is None:
                logger.error("Recipient is not configured: %s", addr)
                continue

            # Extract just the email address from the from field (strips name part)
            _, from_addr = parseaddr(email.from_)
            mapping = {
                "subject": email.subject,
                "from": from_addr or email.from_,
                "body": email.body,
                "to": str(rcpt.key),
                "config": rcpt.key.as_configured(),
                "type": rcpt.notify_type,
            }
            config = sender.config_template.safe_substitute(mapping)
            # Mailrise itself only logs failures, so announce every routing
            # decision here. Log the target URL scheme(s) only, never the full
            # URL, which embeds credentials.
            schemes = re.findall(r"\b([a-z][a-z0-9+.-]*)://", config, re.IGNORECASE)
            logger.info(
                "Forwarding email from %s to %s (subject: %r) via %s",
                from_addr or email.from_,
                str(rcpt.key),
                email.subject,
                ", ".join(schemes) or "unknown target",
            )

            # Only the SES catch-all forwards real mail: it must keep the
            # original HTML body and attachments. Push notifications (Pushover)
            # are text-only - send plain text and drop attachments. Sending
            # plain text also sidesteps apprise 1.4.5's crashing HTML->text
            # converter, which chokes on real-world HTML like immich's emails.
            is_ses = any(scheme.lower() == "ses" for scheme in schemes)
            if is_ses:
                body_format = sender.body_format or email.body_format
                attachments = email.attachments
            else:
                mapping["body"] = _plain_text_body(email)
                body_format = apprise.NotifyFormat.TEXT
                attachments = []

            task = asyncio.create_task(
                _deliver(
                    logger,
                    config,
                    sender.title_template.safe_substitute(mapping),
                    sender.body_template.safe_substitute(mapping),
                    body_format,
                    rcpt.notify_type,
                    attachments,
                    str(rcpt.key),
                )
            )
            _DELIVERY_TASKS.add(task)
            task.add_done_callback(_DELIVERY_TASKS.discard)

        # We deliver notifications ourselves in detached tasks (see _deliver),
        # so we hand nothing back to mailrise's connection-bound send loop. The
        # unreachable yield keeps this a (now empty) async generator, which is
        # the interface mailrise iterates over.
        return
        yield  # type: ignore[unreachable]  # pragma: no cover

    def get_sender(self, key: _Key) -> _SimpleSender | None:
        """Find a sender by recipient key."""
        return next(
            (
                sender
                for (pattern_key, sender) in self.senders
                if fnmatchcase(key.user, pattern_key.user)
                and fnmatchcase(key.domain, pattern_key.domain)
            ),
            None,
        )


def load_from_yaml(logger: Logger, configs_node: dict[str, typ.Any]) -> SimpleRouter:
    """Load a simple router from the YAML configs node."""
    if not isinstance(configs_node, dict):
        logger.critical("The configs node is not a YAML mapping")
        raise SystemExit(1)
    router = SimpleRouter(
        senders=[
            (_parse_simple_key(logger, key), _load_simple_sender(logger, key, config))
            for key, config in configs_node.items()
        ]
    )
    if len(router.senders) < 1:
        logger.critical("No Apprise targets are configured")
        raise SystemExit(1)
    logger.info("Loaded configuration with %d recipient(s)", len(router.senders))
    return router


def _parse_simple_key(logger: Logger, key: str) -> _Key:
    def fatal():
        logger.critical(
            "Invalid config key '%s'; should be a string or an email address "
            "without periods in the username",
            key,
        )
        raise SystemExit(1)

    if "@" in key:
        user, domain = _parseaddrparts(key)
        if not user or not domain or "." in user:
            fatal()
        return _Key(user=user, domain=domain.lower())
    if "." in key:
        fatal()

    return _Key(user=key)


def _load_simple_sender(
    logger: Logger, key: str, config: dict[str, typ.Any]
) -> _SimpleSender:
    if not isinstance(config, dict):
        logger.critical("YAML config node '%s' is not a mapping", key)
        raise SystemExit(1)

    # Extract Mailrise-specific values.
    mr_config = config.get("mailrise", {})
    config.pop("mailrise", None)
    title_template = mr_config.get("title_template", "$subject ($from)")
    body_template = mr_config.get("body_template", "$body")
    body_format = mr_config.get("body_format", None)
    if not any(
        body_format == c
        for c in (
            None,
            apprise.NotifyFormat.TEXT,
            apprise.NotifyFormat.HTML,
            apprise.NotifyFormat.MARKDOWN,
        )
    ):
        logger.critical("Invalid Apprise notification format: %s", body_format)
        raise SystemExit(1)

    return _SimpleSender(
        config_template=Template(yaml.safe_dump(config)),
        title_template=Template(title_template),
        body_template=Template(body_template),
        body_format=body_format,
    )


# Module-level router instance for import_code compatibility.
# Mailrise expects a 'router' attribute that is an INSTANCE, not a class.
def _create_module_router() -> SimpleRouter:
    """Create the router by reading the config file at import time."""
    import logging
    import os

    # Custom YAML loader that handles !env_var tags
    class _EnvVarLoader(yaml.SafeLoader):
        pass

    def _env_var_constructor(loader: yaml.Loader, node: yaml.Node) -> str:
        """Substitute environment variable."""
        var_name = loader.construct_scalar(node)
        return os.environ.get(var_name, "")

    _EnvVarLoader.add_constructor("!env_var", _env_var_constructor)

    # Read and parse the mailrise config file
    config_path = os.environ.get("MAILRISE_CONF", "/etc/mailrise.conf")
    with open(config_path, "r") as f:
        config = yaml.load(f, Loader=_EnvVarLoader)

    logger = logging.getLogger("mailrise.custom_router")
    logger.setLevel(logging.DEBUG)
    configs = config.get("configs", {})
    return load_from_yaml(logger, configs)


router = _create_module_router()
authenticator = None
