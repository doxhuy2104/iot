FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /app/target/smart-watering-backend-0.0.1-SNAPSHOT.jar app.jar

# Render (and many PaaS) expose the port via $PORT
ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["sh", "-c", "java -jar -Dserver.port=${PORT} app.jar"]


