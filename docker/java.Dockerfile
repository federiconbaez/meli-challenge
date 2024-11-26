# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src

# Install Maven
RUN apt-get update &&     apt-get install -y maven &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

# Build the application
RUN mvn clean package -DskipTests

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app/target/meli_challenge_java-1.0-SNAPSHOT.jar"]
