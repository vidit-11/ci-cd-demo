FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# This takes the JAR already built by the Jenkins 'Build & Package' stage
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
