# Stage 1: Build Java + React
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY . .
# Run build as root here to avoid permission issues during the internal npm install
RUN mvn clean package -DskipTests

# Stage 2: Tiny Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Limit Java memory to 256MB so it doesn't crash the 1GB t2.micro
ENTRYPOINT ["java", "-Xmx300m", "-Xms128m", "-jar", "app.jar"]
