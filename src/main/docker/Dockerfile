FROM eclipse-temurin:24.0.2_12-jre

ENV DEBIAN_FRONTEND=noninteractive

ENV GITWIT_ENV=ci

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG GITWIT_VERSION=1.1.0-RC2

RUN curl -fsSL \
    -o gitwit.jar \
    https://github.com/rafandoo/gitwit/releases/download/v${GITWIT_VERSION}/gitwit-${GITWIT_VERSION}-aio.jar

COPY src/main/resources/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh \
    && useradd -m gitwit \
    && chown -R gitwit:gitwit /app

USER gitwit

ENTRYPOINT ["/app/entrypoint.sh"]