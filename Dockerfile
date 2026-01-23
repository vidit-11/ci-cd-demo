# --- Stage 1: Build the React frontend ---
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend/. ./
RUN npm run build

# --- Stage 2: Build the Spring Boot backend ---
# We use a JDK image to build the Java application
FROM maven:3.8.7-eclipse-temurin-17 AS backend-build
WORKDIR /app
# Copy the React build output into the Spring Boot static resources directory
COPY --from=frontend-build /app/frontend/build/ ./src/main/resources/static/
COPY pom.xml ./
COPY src ./src
RUN mvn clean package -DskipTests -Dskip.installnodenpm -Dskip.npm
# The above command creates a JAR file in the target directory

# --- Stage 3: Final runtime image (minimal JRE) ---
# Use a JRE-only image for the smallest possible runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Copy only the final JAR artifact from the backend-build stage
COPY --from=backend-build /app/target/*.jar app.jar
# Expose the port your Spring Boot app runs on (default is 8080)
EXPOSE 8080
# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
