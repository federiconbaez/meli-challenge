#!/usr/bin/env bash

# Colores y estilos
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # Sin color

# Función de registro de eventos
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
        *)
            echo -e "${NC}[LOG] ${timestamp}: ${message}"
            ;;
    esac
}

# Detectar sistema operativo
detect_os() {
    local os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
    local os_version=""
    
    case "$os_name" in
        linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                os_name=$ID
                os_version=$VERSION_ID
            fi
            ;;
        darwin*)
            os_name="macos"
            os_version=$(sw_vers -productVersion)
            ;;
        msys*|mingw*|cygwin*)
            os_name="windows"
            ;;
    esac
    
    echo "$os_name:$os_version"
}

# Instalar git si no está presente
install_git() {
    if ! command -v git &> /dev/null; then
        log "WARNING" "Git no está instalado. Instalando..."
        case "$(detect_os | cut -d: -f1)" in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y git
                ;;
            fedora|centos|rhel)
                sudo dnf install -y git
                ;;
            macos)
                brew install git
                ;;
            *)
                log "ERROR" "No se puede instalar git automáticamente en este sistema"
                return 1
                ;;
        esac
    fi
}

# Clonar repositorio
clone_repository() {
    local repo_url="$1"
    local project_dir="$2"

    install_git || return 1

    # Ir al directorio del proyecto
    mkdir -p "$project_dir"
    cd "$project_dir"

    if [ ! "$(ls -A .)" ]; then  # Verificar si el directorio está vacío
        log "INFO" "Clonando repositorio: $repo_url"
        git clone "$repo_url" .  # Clonar directamente en el directorio actual
        
        if [ $? -ne 0 ]; then
            log "ERROR" "Error al clonar el repositorio"
            return 1
        fi
    else
        log "INFO" "Directorio de proyecto no está vacío. Verificando repositorio..."
        if [ -d .git ]; then
            log "INFO" "Actualizando repositorio existente..."
            git pull
        else
            log "ERROR" "El directorio no está vacío y no parece ser un repositorio Git"
            return 1
        fi
    fi
}

# Crear un nuevo proyecto desde plantilla
create_project_from_template() {
    local template_dir="$1"
    local project_name="$2"
    local project_dir="$3"

    log "INFO" "Creando nuevo proyecto $project_name desde plantilla"
    
    # Copiar plantilla
    cp -R "$template_dir" "$project_dir"
    
    # Renombrar y actualizar archivos según sea necesario
    find "$project_dir" -type f -name "*.example" -exec rename 's/\.example$//' {} \;
    
    log "SUCCESS" "Proyecto $project_name creado exitosamente"
}
