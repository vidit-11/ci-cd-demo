# --- Stage 1: Build (Java + React) ---
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# --- Stage 2: Tomcat Runtime ---
FROM tomcat:9.0-jdk17-temurin-alpine
# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy the war file from build stage to Tomcat webapps
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
