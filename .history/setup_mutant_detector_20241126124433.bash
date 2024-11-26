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
    local python_dir="$base_dir/meli_challenge_python"

    # Crear directorios
    mkdir -p "$python_dir/src" "$python_dir/tests"

    # Crear __init__.py
    touch "$python_dir/src/__init__.py" "$python_dir/tests/__init__.py"

    # Crear dna_analysis.py
    cat > "$python_dir/src/dna_analysis.py" << EOL
# -----------------------------------------------------------------------------------------------------
# @ dna_analysis.py (DNA Analysis Logic)
# -----------------------------------------------------------------------------------------------------
from typing import List
import sqlite3

# -----------------------------------------------------------------------------------------------------
# @ Helper Function Section
# -----------------------------------------------------------------------------------------------------
def check_sequence(sequence: str) -> bool:
    """
    Checks if there is a sequence of four identical letters in a string.
    
    :param sequence: A string representing a sequence of DNA bases.
    :return: True if a sequence of four identical letters is found, False otherwise.
    """
    return any(sequence[i] == sequence[i + 1] == sequence[i + 2] == sequence[i + 3] for i in range(len(sequence) - 3))

# -----------------------------------------------------------------------------------------------------
# @ Diagonal Extraction Section
# -----------------------------------------------------------------------------------------------------
def extract_diagonals(dna: List[str]) -> List[str]:
    """
    Extracts all diagonals (both from top-left to bottom-right and top-right to bottom-left) from the DNA matrix.
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: List of strings representing all diagonals.
    """
    n = len(dna)
    diagonals = []

    # Top-left to bottom-right diagonals
    for d in range(-n + 1, n):
        diagonals.append(''.join([dna[i][i - d] for i in range(max(d, 0), min(n + d, n))]))

    # Top-right to bottom-left diagonals
    for d in range(-n + 1, n):
        diagonals.append(''.join([dna[i][n - i - 1 - d] for i in range(max(d, 0), min(n + d, n))]))
    
    return diagonals

# -----------------------------------------------------------------------------------------------------
# @ Main Function Section
# -----------------------------------------------------------------------------------------------------
def is_mutant(dna: List[str]) -> bool:
    """
    Determines if the given DNA sequence belongs to a mutant by looking for more than one sequence
    of four identical letters in any direction (horizontal, vertical, diagonal).
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: True if mutant, False otherwise.
    """
    # Error Handling
    if not dna or not all(isinstance(row, str) for row in dna):
        raise ValueError("DNA must be a list of strings.")
    n = len(dna)
    if any(len(row) != n for row in dna):
        raise ValueError("DNA must be a square matrix of NxN.")
    if any(char not in "ATCG" for row in dna for char in row):
        raise ValueError("DNA can only contain characters A, T, C, G.")

    sequences_found = 0

    # Horizontal and Vertical Checks
    for row in dna:
        if check_sequence(row):
            sequences_found += 1
            if sequences_found > 1:
                return True
    
    for col in range(n):
        column_str = ''.join([dna[row][col] for row in range(n)])
        if check_sequence(column_str):
            sequences_found += 1
            if sequences_found > 1:
                return True

    # Diagonal Check
    diagonals = extract_diagonals(dna)
    for diagonal in diagonals:
        if check_sequence(diagonal):
            sequences_found += 1
            if sequences_found > 1:
                return True

    return False

# -----------------------------------------------------------------------------------------------------
# @ Database Section
# -----------------------------------------------------------------------------------------------------
def init_db():
    conn = sqlite3.connect('dna_records.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS dna_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dna TEXT NOT NULL UNIQUE,
            is_mutant BOOLEAN NOT NULL
        )
    ''')
    conn.commit()
    conn.close()
EOL

    # Crear api.py
    cat > "$python_dir/src/api.py" << EOL
from flask import Flask, request, jsonify
import sqlite3
from dna_analysis import is_mutant, init_db

app = Flask(__name__)

@app.route('/mutant/', methods=['POST'])
def mutant():
    try:
        data = request.get_json()
        if 'dna' not in data:
            return jsonify({'error': 'Missing DNA data'}), 400

        dna = data['dna']
        if not isinstance(dna, list) or not all(isinstance(row, str) for row in dna):
            return jsonify({'error': 'DNA must be a list of strings'}), 400

        is_mutant_flag = is_mutant(dna)

        # Store the DNA record in the database
        conn = sqlite3.connect('dna_records.db')
        cursor = conn.cursor()
        cursor.execute('''
            INSERT OR IGNORE INTO dna_records (dna, is_mutant) VALUES (?, ?)
        ''', (','.join(dna), is_mutant_flag))
        conn.commit()
        conn.close()

        if is_mutant_flag:
            return jsonify({'message': 'Mutant DNA detected'}), 200
        else:
            return jsonify({'message': 'Human DNA detected'}), 403
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

@app.route('/stats', methods=['GET'])
def stats():
    conn = sqlite3.connect('dna_records.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT COUNT(*) FROM dna_records WHERE is_mutant = 1
    ''')
    count_mutant_dna = cursor.fetchone()[0]

    cursor.execute('''
        SELECT COUNT(*) FROM dna_records
    ''')
    count_human_dna = cursor.fetchone()[0]

    conn.close()

    ratio = count_mutant_dna / count_human_dna if count_human_dna > 0 else 0
    return jsonify({
        'count_mutant_dna': count_mutant_dna,
        'count_human_dna': count_human_dna,
        'ratio': ratio
    })

if __name__ == "__main__":
    init_db()
    app.run(debug=True)
EOL

    # Crear main.py
    cat > "$python_dir/src/main.py" << EOL
# -----------------------------------------------------------------------------------------------------
# @ Import Section
# -----------------------------------------------------------------------------------------------------
from typing import List

# -----------------------------------------------------------------------------------------------------
# @ Helper Function Section
# -----------------------------------------------------------------------------------------------------
def check_sequence(sequence: str) -> bool:
    """
    Checks if there is a sequence of four identical letters in a string.
    
    :param sequence: A string representing a sequence of DNA bases.
    :return: True if a sequence of four identical letters is found, False otherwise.
    """
    return any(sequence[i] == sequence[i + 1] == sequence[i + 2] == sequence[i + 3] for i in range(len(sequence) - 3))

# -----------------------------------------------------------------------------------------------------
# @ Diagonal Extraction Section
# -----------------------------------------------------------------------------------------------------
def extract_diagonals(dna: List[str]) -> List[str]:
    """
    Extracts all diagonals (both from top-left to bottom-right and top-right to bottom-left) from the DNA matrix.
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: List of strings representing all diagonals.
    """
    n = len(dna)
    diagonals = []

    # Top-left to bottom-right diagonals
    for k in range(-(n-1), n):
        diagonal = []
        for i in range(n):
            j = i - k
            if 0 <= j < n:
                diagonal.append(dna[i][j])
        if len(diagonal) >= 4:
            diagonals.append(''.join(diagonal))

    # Top-right to bottom-left diagonals
    for k in range(-(n-1), n):
        diagonal = []
        for i in range(n):
            j = n - 1 - i - k
            if 0 <= j < n:
                diagonal.append(dna[i][j])
        if len(diagonal) >= 4:
            diagonals.append(''.join(diagonal))

    return diagonals

# -----------------------------------------------------------------------------------------------------
# @ Main Function Section
# -----------------------------------------------------------------------------------------------------
def is_mutant(dna: List[str]) -> bool:
    """
    Determines if the given DNA sequence belongs to a mutant by looking for more than one sequence
    of four identical letters in any direction (horizontal, vertical, diagonal).
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: True if mutant, False otherwise.
    """
    # Error Handling
    if not dna or not all(isinstance(row, str) for row in dna):
        raise ValueError("DNA must be a list of strings.")
    n = len(dna)
    if any(len(row) != n for row in dna):
        raise ValueError("DNA must be a square matrix of NxN.")
    if any(char not in "ATCG" for row in dna for char in row):
        raise ValueError("DNA can only contain characters A, T, C, G.")

    sequences_found = 0

    # Horizontal and Vertical Checks
    for row in dna:
        if check_sequence(row):
            sequences_found += 1
            if sequences_found > 1:
                return True
    
    for col in range(n):
        column_str = ''.join([dna[row][col] for row in range(n)])
        if check_sequence(column_str):
            sequences_found += 1
            if sequences_found > 1:
                return True

    # Diagonal Check
    diagonals = extract_diagonals(dna)
    for diagonal in diagonals:
        if check_sequence(diagonal):
            sequences_found += 1
            if sequences_found > 1:
                return True

    return False

def main():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    print(is_mutant(dna_sample))  # Expected output: True

# -----------------------------------------------------------------------------------------------------
# @ Entry Point Section
# -----------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    try:
        dna_sample = [
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        ]
        
        print(is_mutant(dna_sample))  # Expected output: True
    except ValueError as e:
        print(f"Input Error: {e}")
EOL

    # Crear test_main.py
    cat > "$python_dir/tests/test_main.py" << EOL
import pytest
import pytest
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))
from main import main
from main import is_mutant

def test_main():
    """Simple test to ensure main function runs without error."""
    try:
        main()
    except Exception as e:
        pytest.fail(f"main() raised {type(e).__name__} unexpectedly!")

def test_is_mutant_with_mutant_dna():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    assert is_mutant(dna_sample) == True

def test_is_mutant_with_non_mutant_dna():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATTT",
        "AGACGG",
        "GCGTCA",
        "TCACTG"
    ]
    assert is_mutant(dna_sample) == False

def test_is_mutant_with_invalid_dna_non_square():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA"
    ]
    with pytest.raises(ValueError, match="DNA must be a square matrix of NxN."):
        is_mutant(dna_sample)

def test_is_mutant_with_invalid_dna_non_string():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        123456,
        "CCCCTA",
        "TCACTG"
    ]
    with pytest.raises(ValueError, match="DNA must be a list of strings."):
        is_mutant(dna_sample)

def test_is_mutant_with_invalid_dna_invalid_characters():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCXTA",
        "TCACTG"
    ]
    with pytest.raises(ValueError, match="DNA can only contain characters A, T, C, G."):
        is_mutant(dna_sample)
EOL

    # Crear requirements.txt
    cat > "$python_dir/requirements.txt" << EOL
pytest==7.3.1
flask==2.1.1
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
    local java_dir="$base_dir/meli_challenge_java"

    # Crear directorios
    mkdir -p "$java_dir/src/main/java/com/mercadolibre" \
             "$java_dir/src/main/resources" \
             "$java_dir/src/test/java/com/mercadolibre"

    # Crear MutantDetector.java
    cat > "$java_dir/src/main/java/com/mercadolibre/MutantDetector.java" << EOL
package com.mercadolibre;

public class MutantDetector {

    private String[] dna;
    private int size;

    public MutantDetector(String[] dna) {
        this.dna = dna;
        this.size = dna.length;
    }

    public boolean isMutant() {
        int sequencesFound = 0;

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (checkSequence(i, j, 0, 1) ||  // Horizontal
                    checkSequence(i, j, 1, 0) ||  // Vertical
                    checkSequence(i, j, 1, 1) ||  // Diagonal hacia abajo a la derecha
                    checkSequence(i, j, 1, -1)) { // Diagonal hacia abajo a la izquierda
                    sequencesFound++;
                    if (sequencesFound > 1) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private boolean checkSequence(int row, int col, int dx, int dy) {
        if (row + 3 * dx >= size || row + 3 * dx < 0 || col + 3 * dy >= size || col + 3 * dy < 0) {
            return false;
        }

        char letter = dna[row].charAt(col);
        for (int i = 1; i < 4; i++) {
            if (dna[row + i * dx].charAt(col + i * dy) != letter) {
                return false;
            }
        }
        return true;
    }

    public static void main(String[] args) {
        String[] adn = {
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        };
        MutantDetector detector = new MutantDetector(adn);
        boolean esMutante = detector.isMutant();
        System.out.println("¿Es mutante? " + esMutante);
    }
}
EOL

    # Crear MutantDetectorTest.java
    cat > "$java_dir/src/test/java/com/mercadolibre/MutantDetectorTest.java" << EOL
package com.mercadolibre;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

public class MutantDetectorTest {

    @Test
    public void testIsMutantWithMutantDNA() {
        String[] dna = {
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        };
        MutantDetector detector = new MutantDetector(dna);
        assertTrue(detector.isMutant(), "The DNA should be identified as mutant");
    }

    @Test
    public void testIsMutantWithNonMutantDNA() {
        String[] dna = {
            "ATGCGA",
            "CAGTGC",
            "TTATTT",
            "AGACGG",
            "GCGTCA",
            "TCACTG"
        };
        MutantDetector detector = new MutantDetector(dna);
        assertFalse(detector.isMutant(), "The DNA should not be identified as mutant");
    }

    @Test
    public void testIsMutantWithEmptyDNA() {
        String[] dna = {};
        MutantDetector detector = new MutantDetector(dna);
        assertFalse(detector.isMutant(), "Empty DNA should not be identified as mutant");
    }

    @Test
    public void testIsMutantWithSingleElementDNA() {
        String[] dna = {"A"};
        MutantDetector detector = new MutantDetector(dna);
        assertFalse(detector.isMutant(), "Single element DNA should not be identified as mutant");
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

    <groupId>com.mercadolibre</groupId>
    <artifactId>meli_challenge_java</artifactId>
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
ENTRYPOINT ["java", "-jar", "/app/target/meli_challenge_java-1.0-SNAPSHOT.jar"]
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
             "$base_dir/meli_challenge_python/src" \
             "$base_dir/meli_challenge_python/tests" \
             "$base_dir/meli_challenge_java/src/main/java/com/mercadolibre" \
             "$base_dir/meli_challenge_java/src/test/java/com/mercadolibre" \
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