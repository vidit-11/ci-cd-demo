# --- Stage 1: Build & Test ---
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy pom.xml and download dependencies (cached layer)
# This stays the same, but will now pull Spring Boot parent and starters 
COPY pom.xml .
RUN mvn dependency:go-offline [cite: 12]

# Copy source code and build the JAR
COPY src ./src

# We removed -DskipTests so that 'mvn package' runs your new MockMvc web tests 
RUN mvn clean package

# --- Stage 2: Tiny Runtime ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the specific Spring Boot executable JAR
# Using the specific name from your pom.xml is safer than *.jar 
COPY --from=build /app/target/ci-cd-demo-1.0-SNAPSHOT.jar app.jar

# Spring Boot defaults to port 8080 
EXPOSE 8080

# Run the 'fat jar' which contains the embedded Tomcat server
ENTRYPOINT ["java", "-jar", "app.jar"]
