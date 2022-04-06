FROM openjdk:8-jdk-alpine as builder

RUN apk add --no-cache curl tar bash
ARG MAVEN_VERSION=3.5.4
RUN mkdir -p /usr/share/maven && \
  curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
  ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY pom.xml .
RUN mvn compile dependency:go-offline

COPY src /usr/src/app/src

RUN mvn package

FROM openjdk:8-alpine

COPY --from=builder /usr/src/app/target/demo-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]