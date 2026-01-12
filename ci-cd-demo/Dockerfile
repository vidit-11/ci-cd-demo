# Use a tiny version of Java (Alpine Linux)
FROM eclipse-temurin:17-jre-alpine

# Set the working directory
WORKDIR /i-cd-demo

# Copy your JAR file into the container
COPY target/*.jar app.jar

# Run the app with "Lean" memory settings
ENTRYPOINT ["java", "-Xms128m", "-Xmx200m", "-jar", "app.jar"]
