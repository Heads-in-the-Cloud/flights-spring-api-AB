FROM maven:3-openjdk-11 AS maven

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN mvn package

FROM adoptopenjdk/openjdk11:alpine-jre

ARG JAR_FILE=utopia-flights-api-0.0.1-SNAPSHOT.war

WORKDIR /opt/app

COPY --from=maven /usr/src/app/target/${JAR_FILE} /opt/app/

ENTRYPOINT ["java","-jar","utopia-flights-api-0.0.1-SNAPSHOT.war"]
