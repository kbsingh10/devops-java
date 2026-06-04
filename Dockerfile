FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY build/libs/calculator-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]