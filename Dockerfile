FROM openjdk:17-jdk-slim-buster AS builder

ARG APP_NAME=registry
ARG APP_VERSION=0.0.1-SNAPSHOT

COPY ./ /app
WORKDIR /app
RUN chmod +x ./mvnw

RUN ./mvnw clean package

From eclipse-temurin:17.0.3_7-jre

ENV ARTIFACT_NAME=registry-0.0.1-SNAPSHOT \
    JAVA_TOOL_OPTIONS=-Duser.timezone="Europe/Madrid" \
    TZ=CET-1CEST,M3.5.0,M10.5.0/3

COPY --from=builder /app/target/registry-0.0.1-SNAPSHOT.jar /app/registry-0.0.1-SNAPSHOT.jar

RUN addgroup app_registry \
    && adduser --system --shell /bin/sh --no-create-home --ingroup app_registry app_registry \
    && mkdir /logs \
    && chown app_registry:app_registry /logs \
    && chmod a+rw /logs

RUN chown app_registry:app_registry -R /app

USER app_registry

WORKDIR /app

EXPOSE 8761

ENTRYPOINT java -jar ./registry-0.0.1-SNAPSHOT.jar