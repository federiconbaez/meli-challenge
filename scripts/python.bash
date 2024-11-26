#!/usr/bin/env bash

# Importar utilidades comunes
source "$(dirname "$0")/scripts/common.bash"

# Fail on any error
set -euo pipefail

# Verificar dependencias para Python
check_python_dependencies() {
    local os_name=$(detect_os | cut -d: -f1)

    log "INFO" "Verificando dependencias de Python"

    # Verificar Python y pip
    if ! command -v python3 &> /dev/null; then
        log "WARNING" "Python 3 no está instalado"
        case "$os_name" in
            ubuntu|debian)
                log "INFO" "Instalando Python para Ubuntu/Debian"
                sudo apt-get update
                sudo apt-get install -y python3 python3-pip python3-venv
                ;;
            fedora|centos|rhel)
                log "INFO" "Instalando Python para Fedora/CentOS/RHEL"
                sudo dnf install -y python3 python3-pip python3-virtualenv
                ;;
            macos)
                log "INFO" "Instalando Python para macOS"
                if ! command -v brew &> /dev/null; then
                    log "ERROR" "Homebrew no está instalado. Por favor, instale Homebrew primero."
                    return 1
                fi
                brew install python
                ;;
            *)
                log "ERROR" "Sistema operativo no soportado. No se puede instalar Python automáticamente."
                return 1
                ;;
        esac
    fi

    # Verificar versión de Python
    local python_version=$(python3 --version | cut -d' ' -f2)
    local min_version="3.8.0"
    if [ "$(printf '%s\n' "$min_version" "$python_version" | sort -V | head -n1)" != "$min_version" ]; then
        log "WARNING" "Versión de Python $(python3 --version) es menor que la versión mínima requerida $min_version"
        return 1
    fi
}

# Configurar entorno virtual de Python
setup_python_venv() {
    local project_dir="$1"
    local venv_path="$project_dir/venv"

    # Cambiar al directorio del proyecto
    cd "$project_dir" || { log "ERROR" "No se pudo cambiar al directorio $project_dir"; return 1; }

    if [ ! -d "$venv_path" ]; then
        log "INFO" "Creando entorno virtual Python"
        python3 -m venv "$venv_path" || { log "ERROR" "Fallo al crear entorno virtual"; return 1; }
    fi

    # Activar entorno virtual
    # shellcheck disable=SC1090
    source "$venv_path/bin/activate" || { log "ERROR" "No se pudo activar el entorno virtual"; return 1; }

    # Actualizar pip
    pip install --upgrade pip setuptools wheel || { log "ERROR" "Fallo al actualizar herramientas de pip"; return 1; }

    log "SUCCESS" "Entorno virtual de Python configurado"
}

# Instalar dependencias de Python
install_python_dependencies() {
    local project_dir="$1"
    local requirements_file="$project_dir/requirements.txt"

    cd "$project_dir" || { log "ERROR" "No se pudo cambiar al directorio $project_dir"; return 1; }

    if [ -f "$requirements_file" ]; then
        log "INFO" "Instalando dependencias de Python"
        pip install -r "$requirements_file" || { 
            log "ERROR" "Fallo al instalar dependencias de requirements.txt"
            return 1
        }
    else
        log "WARNING" "No se encontró requirements.txt"
        return 0  # No es un error crítico
    fi
}

# Ejecutar pruebas de Python
run_python_tests() {
    local project_dir="$1"

    cd "$project_dir" || { log "ERROR" "No se pudo cambiar al directorio $project_dir"; return 1; }

    # Verificar si pytest está instalado
    if ! pip freeze | grep -q pytest; then
        log "INFO" "Instalando pytest"
        pip install pytest || { log "ERROR" "Fallo al instalar pytest"; return 1; }
    fi

    if [ -d "tests" ]; then
        log "INFO" "Ejecutando pruebas de Python"
        python3 -m pytest tests/ || { 
            log "ERROR" "Pruebas de Python fallaron"
            return 1
        }
    else
        log "WARNING" "No se encontró directorio de pruebas"
        return 0  # No es un error crítico
    fi
}

# Función principal de configuración de Python
setup_python_project() {
    local repo_url="${1:-}"
    local project_name="${2:-meli_challenge_python}"
    local base_dir="$(cd "$(dirname "$0")/.." && pwd)"
    local project_dir="$base_dir/$project_name"

    # Definir trampas para limpieza en caso de error
    trap 'log "ERROR" "Error en la configuración del proyecto"' ERR

    # Verificar dependencias
    check_python_dependencies || return 1

    # Crear proyecto desde plantilla o clonar
    #if [ -z "$repo_url" ]; then
    #    create_project_from_template "$base_dir" "$project_name" "$project_dir" || return 1
    #else
    #    clone_repository "$repo_url" "$project_dir" || return 1
    #fi

    # Configurar entorno virtual
    setup_python_venv "$project_dir" || return 1

    # Instalar dependencias
    install_python_dependencies "$project_dir" || return 1

    # Ejecutar pruebas
    run_python_tests "$project_dir" || return 1

    # Limpiar trampa de error
    trap - ERR

    log "SUCCESS" "Proyecto Python configurado exitosamente"
}

# Ejecutar configuración si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_python_project "$@"
fi
