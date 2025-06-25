FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/hello-world-app-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
