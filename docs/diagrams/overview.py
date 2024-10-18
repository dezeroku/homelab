from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.network import Internet
from diagrams.onprem.security import Vault
from diagrams.onprem.network import Nginx
from diagrams.onprem.auth import Oauth2Proxy
from diagrams.onprem.certificates import CertManager
from diagrams.onprem.certificates import LetsEncrypt
from diagrams.oci.connectivity import VPN
from diagrams.aws.network import Route53
from diagrams.aws.storage import S3
from diagrams.generic.storage import Storage

with Diagram("Overview", show=False, outformat=["png"], direction="TB"):
    internet = Internet("Outside World")
    vpn = VPN("VPN")
    lets_encrypt = LetsEncrypt()
    route53 = Route53()

    with Cluster("homeserver"):
        ingress_nginx = Nginx("ingress-nginx")
        oauth2_proxy = Oauth2Proxy()
        cert_manager = CertManager()
        vault = Vault()
        longhorn = Storage("longhorn")

    with Cluster("homeserver_backup"):
        minio_backup = S3("minio")
        ingress_nginx_backup = Nginx("ingress-nginx")
        cert_manager_backup = CertManager()
        longhorn_backup = Storage("longhorn")

    ingress_nginx >> oauth2_proxy >> Edge(label="oidc") << vault
    ingress_nginx_backup >> oauth2_proxy

    internet >> vpn >> ingress_nginx
    internet >> vpn >> ingress_nginx_backup

    longhorn >> Edge(label="daily backups") >> minio_backup

    cert_manager >> lets_encrypt >> route53
    cert_manager_backup >> lets_encrypt >> route53
    cert_manager >> route53
    cert_manager_backup >> route53
