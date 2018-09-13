
FROM node:8.11 as node-builder

# Hacky workaround for installing @angular/cli
RUN chmod a+w /usr/local/lib/node_modules && chmod a+w /usr/local/bin
USER node
RUN npm i -g @angular/cli@latest

# Build front end resources
USER root
ARG UI_PATH=/opt/simple-vote/ui
COPY ui ${UI_PATH}
WORKDIR ${UI_PATH}

ARG ENDPOINT_NAME=http://localhost:4567
RUN echo "ENDPOINT_NAME is ${ENDPOINT_NAME}"
RUN echo "export const environment = {production: true,endpoint: '${ENDPOINT_NAME}/',websocket: 'ws`echo ${ENDPOINT_NAME}|cut -b 5-999`/poll'};" > src/environments/environment.prod.ts
RUN cat src/environments/environment.prod.ts
RUN yarn
RUN ng build --prod --aot


FROM maven:3.5.4-jdk-8-slim as java-builder

COPY service /opt/simple-vote/service
COPY --from=node-builder /opt/simple-vote/ui/dist /opt/simple-vote/service/src/main/resources

WORKDIR /opt/simple-vote/service
RUN mvn clean install -DskipTests -Dliquibase.skip


FROM openjdk:8-slim

COPY --from=java-builder /opt/simple-vote/service/target/simplevote.jar /opt/simplevote.jar
COPY run.sh /run.sh

# Expose our web port
EXPOSE 4567

# Run the start script
CMD ['/bin/bash','/run.sh']
