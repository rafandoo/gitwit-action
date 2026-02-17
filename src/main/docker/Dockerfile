FROM eclipse-temurin:21.0.10_7-jre

WORKDIR /app

RUN apt-get update  \
    && apt-get install -y curl jq  \
    && rm -rf /var/lib/apt/lists/*

ARG GITWIT_VERSION=1.1.0-RC1

RUN curl -L -o gitwit.jar https://github.com/rafandoo/gitwit/releases/download/v${GITWIT_VERSION}/gitwit-${GITWIT_VERSION}-aio.jar

COPY src/main/resources/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]