#!/bin/bash

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con formato
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        print_message "$RED" "❌ Error: $1"
        exit 1
    fi
}

# Función para crear directorios y archivos básicos
create_basic_structure() {
    local project_name=$1
    
    # Crear directorio principal del proyecto
    mkdir -p "$project_name"
    cd "$project_name" || exit
    
    # Crear estructura de directorios
    mkdir -p src/{main/{java,python,resources},test/{java,python,resources}}
    mkdir -p docs
    mkdir -p scripts
    mkdir -p config
    
    print_message "$GREEN" "✅ Estructura básica creada"
}

# Función para crear archivos de configuración
create_config_files() {
    # Crear .gitignore
    cat > .gitignore << EOL
# IDEs
.idea/
.vscode/
*.iml

# Python
__pycache__/
*.py[cod]
*$py.class
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Java
*.class
*.jar
*.war
*.ear
target/
bin/

# Virtual Environment
venv/
env/
EOL

    # Crear README.md
    cat > README.md << EOL
# Mutant Detector

Este proyecto implementa un detector de mutantes basado en secuencias de ADN.

## Estructura del Proyecto

\`\`\`
.
├── src/
│   ├── main/
│   │   ├── java/
│   │   ├── python/
│   │   └── resources/
│   └── test/
│       ├── java/
│       ├── python/
│       └── resources/
├── docs/
├── scripts/
└── config/
\`\`\`

## Requisitos

- Python 3.8+
- Java 11+

## Instalación

1. Clonar el repositorio
2. Configurar el entorno virtual (Python)
3. Instalar dependencias

## Uso

Descripción de cómo usar el proyecto...

## Tests

Instrucciones para ejecutar los tests...
EOL

    # Crear requirements.txt para Python
    cat > requirements.txt << EOL
pytest==7.4.0
coverage==7.2.7
flake8==6.0.0
black==23.3.0
EOL

    # Crear pom.xml básico para Java
    cat > pom.xml << EOL
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.mutantdetector</groupId>
    <artifactId>mutant-detector</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <junit.version>5.8.2</junit.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>\${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
EOL

    print_message "$GREEN" "✅ Archivos de configuración creados"
}

# Función para crear archivos de código fuente básicos
create_source_files() {
    # Crear archivo Python principal
    cat > src/main/python/mutant_detector.py << EOL
def is_mutant(dna: list[str]) -> bool:
    """
    Determina si un ADN corresponde a un mutante.
    
    Args:
        dna: Lista de strings que representan cada fila de una tabla de (NxN)
             con la secuencia del ADN
    
    Returns:
        bool: True si es mutante, False si no lo es
    """
    def check_sequence(row: int, col: int, dx: int, dy: int) -> bool:
        if not (0 <= row + 3*dx < len(dna) and 0 <= col + 3*dy < len(dna[0])):
            return False
        
        letter = dna[row][col]
        for i in range(1, 4):
            if dna[row + i*dx][col + i*dy] != letter:
                return False
        return True
    
    sequences_found = 0
    
    for i in range(len(dna)):
        for j in range(len(dna[0])):
            if check_sequence(i, j, 0, 1) or \\
               check_sequence(i, j, 1, 0) or \\
               check_sequence(i, j, 1, 1) or \\
               check_sequence(i, j, 1, -1):
                sequences_found += 1
                if sequences_found > 1:
                    return True
    
    return False
EOL

    # Crear archivo de test Python
    cat > src/test/python/test_mutant_detector.py << EOL
import pytest
from src.main.python.mutant_detector import is_mutant

def test_is_mutant_with_mutant_dna():
    mutant_dna = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    assert is_mutant(mutant_dna) == True

def test_is_mutant_with_human_dna():
    human_dna = [
        "ATGCGA",
        "CAGTGC",
        "TTATTT",
        "AGACGG",
        "GCGTCA",
        "TCACTG"
    ]
    assert is_mutant(human_dna) == False
EOL

    # Crear clase Java principal
    mkdir -p src/main/java/com/mutantdetector
    cat > src/main/java/com/mutantdetector/MutantDetector.java << EOL
package com.mutantdetector;

public class MutantDetector {
    public static boolean isMutant(String[] dna) {
        int sequencesFound = 0;
        
        for (int i = 0; i < dna.length; i++) {
            for (int j = 0; j < dna[i].length(); j++) {
                if (checkSequence(dna, i, j, 0, 1) ||
                    checkSequence(dna, i, j, 1, 0) ||
                    checkSequence(dna, i, j, 1, 1) ||
                    checkSequence(dna, i, j, 1, -1)) {
                    sequencesFound++;
                    if (sequencesFound > 1) {
                        return true;
                    }
                }
            }
        }
        
        return false;
    }
    
    private static boolean checkSequence(String[] dna, int row, int col, int dx, int dy) {
        if (!(0 <= row + 3*dx && row + 3*dx < dna.length &&
              0 <= col + 3*dy && col + 3*dy < dna[0].length())) {
            return false;
        }
        
        char letter = dna[row].charAt(col);
        for (int i = 1; i < 4; i++) {
            if (dna[row + i*dx].charAt(col + i*dy) != letter) {
                return false;
            }
        }
        return true;
    }
}
EOL

    # Crear clase Java de test
    mkdir -p src/test/java/com/mutantdetector
    cat > src/test/java/com/mutantdetector/MutantDetectorTest.java << EOL
package com.mutantdetector;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class MutantDetectorTest {
    @Test
    void testIsMutantWithMutantDNA() {
        String[] mutantDna = {
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        };
        assertTrue(MutantDetector.isMutant(mutantDna));
    }

    @Test
    void testIsMutantWithHumanDNA() {
        String[] humanDna = {
            "ATGCGA",
            "CAGTGC",
            "TTATTT",
            "AGACGG",
            "GCGTCA",
            "TCACTG"
        };
        assertFalse(MutantDetector.isMutant(humanDna));
    }
}
EOL

    print_message "$GREEN" "✅ Archivos de código fuente creados"
}

# Función principal
main() {
    local project_name=$1

    if [ -z "$project_name" ]; then
        print_message "$RED" "❌ Debe proporcionar un nombre para el proyecto"
        exit 1
    fi

    print_message "$BLUE" "🚀 Creando proyecto: $project_name"

    create_basic_structure "$project_name"
    check_error "Error al crear la estructura básica"

    create_config_files
    check_error "Error al crear los archivos de configuración"

    create_source_files
    check_error "Error al crear los archivos de código fuente"

    print_message "$GREEN" "✅ Proyecto creado exitosamente"
    print_message "$BLUE" "
Para comenzar:
1. cd $project_name
2. git init
3. Para Python:
   - python -m venv venv
   - source venv/bin/activate (Linux/Mac) o venv\\Scripts\\activate (Windows)
   - pip install -r requirements.txt
4. Para Java:
   - mvn clean install
"
}

# Ejecutar script
main "$1"
