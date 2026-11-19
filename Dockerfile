# Build stage: Maven + Temurin 26 JDK
# Etapa 1: Compilación del proyecto con Maven
FROM maven:3-eclipse-temurin-26-alpine AS build
WORKDIR /app

# Copiar archivos de definición de dependencias y código fuente
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
COPY src ./src

# Compilar y empaquetar el JAR
RUN mvn clean package -DskipTests

# Etapa 2: Imagen final de ejecución
FROM eclipse-temurin:26-jre-alpine
WORKDIR /app

# Copiar el JAR generado desde la etapa de compilación
COPY --from=build /app/target/*.jar app.jar

# Puerto por defecto de Spring Boot
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]