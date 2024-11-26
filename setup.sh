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
