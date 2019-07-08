FROM maven:3.6.0-jdk-8 as build-stage

WORKDIR /app
COPY ./sources/ /app/
COPY ./tools/maven/settings.xml ${MAVEN_CONFIG}/
RUN mvn clean install -P zafira

FROM tomcat:7-jre8

ARG SERVICE_VER=1.0-SNAPSHOT
ARG CLIENT_VER=1.0-SNAPSHOT

ENV ZAFIRA_SERVICE_VERSION=${SERVICE_VER}
ENV ZAFIRA_CLIENT_VERSION=${CLIENT_VER}
ENV ZAFIRA_MULTITENANT=false
ENV ZAFIRA_URL=http://localhost:8080
ENV ZAFIRA_WS_URL=
ENV ZAFIRA_WEB_URL=
ENV ZAFIRA_USER=qpsdemo
ENV ZAFIRA_PASS=qpsdemo
ENV ZAFIRA_GROUP="Super admins"
ENV ZAFIRA_JDBC_URL=jdbc:postgresql://localhost:5432/postgres
ENV ZAFIRA_JDBC_USER=postgres
ENV ZAFIRA_JDBC_PASS=postgres
ENV ZAFIRA_JDBC_POOL_SIZE=50

ENV ZAFIRA_DEBUG_MODE=false
ENV ZAFIRA_ARTIFACTS_USE_PROXY=false

ENV ZAFIRA_JWT_TOKEN=AUwMLdWFBtUHVgvjFfMmAEadXqZ6HA4dKCiCmjgCXxaZ4ZO8od
ENV ZAFIRA_CRYPTO_SALT=TDkxalR4T3EySGI0T0YyMitScmkxWDlsUXlPV2R4OEZ1b2kyL1VJeFVHST0=

ENV ZAFIRA_REDIS_HOST=redis
ENV ZAFIRA_REDIS_PORT=6379

ENV ZAFIRA_RABBITMQ_ENABLED=false
ENV ZAFIRA_RABBITMQ_HOST=localhost
ENV ZAFIRA_RABBITMQ_PORT=5672
ENV ZAFIRA_RABBITMQ_USER=guest
ENV ZAFIRA_RABBITMQ_PASS=guest
ENV ZAFIRA_RABBITMQ_STOMP_HOST=rabbitmq
ENV ZAFIRA_RABBITMQ_STOMP_PORT=61613

ENV ZAFIRA_LDAP_ENABLED=false
ENV ZAFIRA_LDAP_PROTOCOL=ldap
ENV ZAFIRA_LDAP_SERVER=localhost
ENV ZAFIRA_LDAP_PORT=389
ENV ZAFIRA_LDAP_DN=ou=People,dc=qaprosoft,dc=com
ENV ZAFIRA_LDAP_SEARCH_FILTER=uid
ENV ZAFIRA_LDAP_USER=
ENV ZAFIRA_LDAP_PASSWORD=

ENV ZAFIRA_NEWRELIC_ENABLED=false
ENV ZAFIRA_NEWRELIC_KEY=
ENV ZAFIRA_NEWRELIC_APP=zafira
ENV ZAFIRA_NEWRELIC_AUDIT_MODE=false
ENV ZAFIRA_NEWRELIC_LOG_LEVEL=info

ENV ZAFIRA_ELASTICSEARCH_URL=

ENV ZAFIRA_GITHUB_CLIENT_ID=
ENV ZAFIRA_GITHUB_CLIENT_SECRET=

RUN apt-get update && apt-get install zip
RUN mkdir ${CATALINA_HOME}/shared

COPY --from=build-stage /app/zafira-ws/target/zafira-ws.war ${CATALINA_HOME}/temp/
COPY tools/newrelic.zip ${CATALINA_HOME}/temp/
COPY entrypoint.sh /

EXPOSE 8080

ENTRYPOINT /entrypoint.sh
