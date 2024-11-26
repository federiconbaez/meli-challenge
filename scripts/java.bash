#!/usr/bin/env bash

# Importar utilidades comunes
source "$(dirname "$0")/scripts/common.bash"

# Verificar dependencias de Java
check_java_dependencies() {
    local os_name=$(detect_os | cut -d: -f1)

    log "INFO" "Verificando dependencias de Java"

    # Verificar Java
    if ! command -v java &> /dev/null; then
        log "WARNING" "Java no está instalado"
        case "$os_name" in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y openjdk-17-jdk maven
                ;;
            fedora|centos|rhel)
                sudo dnf install -y java-17-openjdk-devel maven
                ;;
            macos)
                brew install openjdk maven
                ;;
            *)
                log "ERROR" "No se puede instalar Java automáticamente"
                return 1
                ;;
        esac
    fi

    # Verificar Maven
    if ! command -v mvn &> /dev/null; then
        log "ERROR" "Maven no está instalado"
        return 1
    fi
}

# Compilar proyecto Java
build_java_project() {
    local project_dir="$1"

    cd "$project_dir"

    log "INFO" "Compilando proyecto Java con Maven"
    mvn clean package

    if [ $? -ne 0 ]; then
        log "ERROR" "Error en la compilación del proyecto"
        return 1
    fi

    log "SUCCESS" "Proyecto Java compilado"
}

# Ejecutar pruebas de Java
run_java_tests() {
    local project_dir="$1"

    cd "$project_dir"

    log "INFO" "Ejecutando pruebas de Java con Maven"
    mvn test
}

# Función principal de configuración de Java
setup_java_project() {
    local repo_url="${1:-}"
    local project_name="${2:-meli_challenge_java}"
    local base_dir="$(cd "$(dirname "$0")" && pwd)"
    local project_dir="$base_dir/$project_name"

    # Verificar dependencias
    check_java_dependencies || return 1

    # Crear proyecto desde plantilla o clonar
    #if [ -z "$repo_url" ]; then
    #    create_project_from_template "$base_dir" "$project_name" "$project_dir"
    #else
    #    clone_repository "$repo_url" "$project_dir"
    #fi

    # Compilar proyecto
    build_java_project "$project_dir"

    # Ejecutar pruebas
    run_java_tests "$project_dir"

    log "SUCCESS" "Proyecto Java configurado exitosamente"
}

# Ejecutar configuración si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_java_project "$@"
fi
