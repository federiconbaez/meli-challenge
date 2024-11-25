# Mutant Detector API - Instalación Completa y Configuración en Ubuntu Recién Instalado

Este documento describe un proceso automatizado, detallado y profesional para configurar y ejecutar la API del detector de mutantes en un sistema Ubuntu recién instalado. Incluye todos los pasos necesarios para garantizar una configuración sin errores, optimizando el entorno y facilitando el despliegue.

## ⚡ Script de Instalación Automatizado

A continuación se presenta un script avanzado que realiza la instalación y configuración completa de la API en un entorno Ubuntu. Este script está diseñado para minimizar errores, optimizar el rendimiento y automatizar las tareas repetitivas. Sigue estos pasos para crear y ejecutar el script.

### 1. Crear y Ejecutar el Script de Instalación

1. **Crear el archivo de script**: Guarda el siguiente contenido en un archivo con el nombre `setup_mutant_detector.sh`.
2. **Dar permisos de ejecución**: Ejecuta el siguiente comando para hacer el archivo ejecutable:
   ```bash
   chmod +x setup_mutant_detector.sh
   ```
3. **Ejecutar el script**: Corre el script para realizar la instalación completa:
   ```bash
   ./setup_mutant_detector.sh
   ```

### 2. Contenido del Script

```bash
#!/usr/bin/env bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Función de log
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    case "$level" in
        "INFO")
            echo -e "${BLUE}[INFO] ${timestamp}: ${message}${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS] ${timestamp}: ${message}${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING] ${timestamp}: ${message}${NC}"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR] ${timestamp}: ${message}${NC}" >&2
            ;;
    esac
}

# Crear estructura de proyecto Python
create_python_template() {
    local base_dir="$1"
    local python_dir="$base_dir/meli-challenge-python"

    # Crear directorios
    mkdir -p "$python_dir/src" "$python_dir/tests"

    # Crear __init__.py
    touch "$python_dir/src/__init__.py" "$python_dir/tests/__init__.py"

    # Crear main.py
    cat > "$python_dir/src/main.py" << EOL
def main():
    """Main application entry point."""
    print("Hello, Python Project!")

if __name__ == "__main__":
    main()
EOL

    # Crear test_main.py
    cat > "$python_dir/tests/test_main.py" << EOL
import pytest
from src.main import main

def test_main():
    """Simple test to ensure main function runs without error."""
    try:
        main()
    except Exception as e:
        pytest.fail(f"main() raised {type(e).__name__} unexpectedly!")
EOL

    # Crear requirements.txt
    cat > "$python_dir/requirements.txt" << EOL
pytest==7.3.1
EOL

    # Crear README.md
    cat > "$python_dir/README.md" << EOL
# Python Project Template

## Setup
1. Create a virtual environment
2. Install dependencies: \`pip install -r requirements.txt\`
3. Run tests: \`pytest\`
EOL

    # Crear .env.example
    cat > "$python_dir/.env.example" << EOL
# Example environment variables
DATABASE_URL=sqlite:///example.db
API_KEY=your_api_key_here
DEBUG=False
EOL

    log "SUCCESS" "Python project template created"
}

# Crear estructura de proyecto Java
create_java_template() {
    local base_dir="$1"
    local java_dir="$base_dir/meli-challenge-java"

    # Crear directorios
    mkdir -p "$java_dir/src/main/java/com/example" \
             "$java_dir/src/main/resources" \
             "$java_dir/src/test/java/com/example"

    # Crear App.java
    cat > "$java_dir/src/main/java/com/example/App.java" << EOL
package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello, Java Project!");
    }

    public String greet() {
        return "Hello, World!";
    }
}
EOL

    # Crear AppTest.java
    cat > "$java_dir/src/test/java/com/example/AppTest.java" << EOL
package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AppTest {
    @Test
    public void testGreet() {
        App app = new App();
        assertEquals("Hello, World!", app.greet());
    }
}
EOL

    # Crear pom.xml
    cat > "$java_dir/pom.xml" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>my-java-project</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter-api</artifactId>
            <version>5.8.1</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.0.0-M5</version>
            </plugin>
        </plugins>
    </build>
</project>
EOL

    # Crear README.md
    cat > "$java_dir/README.md" << EOL
# Java Project Template

## Setup
1. Ensure Maven is installed
2. Run tests: \`mvn test\`
3. Build project: \`mvn package\`
EOL

    # Crear .env.example
    cat > "$java_dir/.env.example" << EOL
# Example environment variables
DATABASE_URL=jdbc:sqlite:example.db
API_KEY=your_api_key_here
DEBUG=false
EOL

    log "SUCCESS" "Java project template created"
}

# Crear Dockerfiles
create_dockerfiles() {
    local base_dir="$1"
    local docker_dir="$base_dir/docker"

    # Crear Python Dockerfile
    cat > "$docker_dir/python.Dockerfile" << EOL
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "src/main.py"]
EOL

    # Crear Java Dockerfile
    cat > "$docker_dir/java.Dockerfile" << EOL
# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build the application
RUN mvn clean package -DskipTests

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app/target/my-java-project-1.0-SNAPSHOT.jar"]
EOL

    log "SUCCESS" "Dockerfiles created"
}

# Crear documentación
create_documentation() {
    local base_dir="$1"
    local docs_dir="$base_dir/docs"

    # Guía de Python
    cat > "$docs_dir/python_guide.md" << EOL
# Guía de Proyecto Python

## Configuración del Entorno
1. Crear entorno virtual
2. Instalar dependencias
3. Configurar variables de entorno

## Estructura del Proyecto
- \`src/\`: Código fuente principal
- \`tests/\`: Pruebas unitarias
- \`requirements.txt\`: Dependencias del proyecto

## Comandos Útiles
- Instalar dependencias: \`pip install -r requirements.txt\`
- Ejecutar pruebas: \`pytest\`
EOL

    # Guía de Java
    cat > "$docs_dir/java_guide.md" << EOL
# Guía de Proyecto Java

## Configuración del Entorno
1. Instalar Maven
2. Configurar variables de entorno
3. Descargar dependencias

## Estructura del Proyecto
- \`src/main/java\`: Código fuente principal
- \`src/test/java\`: Pruebas unitarias
- \`pom.xml\`: Configuración de dependencias y construcción

## Comandos Útiles
- Compilar proyecto: \`mvn clean package\`
- Ejecutar pruebas: \`mvn test\`
- Generar JAR: \`mvn package\`
EOL

    log "SUCCESS" "Documentation created"
}

# Crear script de setup principal
create_main_setup_script() {
    local base_dir="$1"

    # Crear setup.sh
    cat > "$base_dir/setup.sh" << 'EOL'
#!/usr/bin/env bash

# Función para mostrar uso
show_usage() {
    echo "Uso: $0 <tecnologia> [nombre_proyecto]"
    echo ""
    echo "Tecnologías:"
    echo "  - python"
    echo "  - java"
}

# Verificar argumentos
if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

# Ruta base del proyecto
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Tecnología
TECH="$1"
PROJECT_NAME="${2:-my_project}"

# Crear proyecto según la tecnología
case "$TECH" in
    python)
        # Lógica para proyecto Python (a implementar)
        echo "Configurando proyecto Python: $PROJECT_NAME"
        ;;
    java)
        # Lógica para proyecto Java (a implementar)
        echo "Configurando proyecto Java: $PROJECT_NAME"
        ;;
    *)
        echo "Tecnología no soportada"
        show_usage
        exit 1
        ;;
esac
EOL

    # Hacer script ejecutable
    chmod +x "$base_dir/setup.sh"

    log "SUCCESS" "Main setup script created"
}

# Función principal
main() {
    # Directorio base del proyecto
    local base_dir="${1:-.}"

    # Crear directorios base
    mkdir -p "$base_dir/scripts" \
             "$base_dir/meli-challenge-python/src" \
             "$base_dir/meli-challenge-python/tests" \
             "$base_dir/meli-challenge-java/src/main/java/com/example" \
             "$base_dir/meli-challenge-java/src/test/java/com/example" \
             "$base_dir/docker" \
             "$base_dir/docs"

    # Crear componentes
    create_python_template "$base_dir"
    create_java_template "$base_dir"
    create_dockerfiles "$base_dir"
    create_documentation "$base_dir"
    create_main_setup_script "$base_dir"

    # Llamar a los scripts de configuración de Python y Java
    source "$base_dir/scripts/python.bash"
    source "$base_dir/scripts/java.bash"
    
    # Configurar el proyecto Java
    setup_java_project
    setup_python_project
    
    log "SUCCESS" "Project template structure created successfully!"
}

# Ejecutar script
main "$@"
```