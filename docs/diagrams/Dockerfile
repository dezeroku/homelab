# Use python:3.10 to just install wheels for dependencies instead of compiling
FROM python:3.10 AS build

WORKDIR /app

RUN apt update && apt install -y \
        graphviz

RUN pip install diagrams==0.23.3

RUN mkdir created

COPY *.py .
RUN for x in $(ls *.py); do python $x; done; mv ./*.png created;

FROM scratch AS output
COPY --from=build /app/created/* .
