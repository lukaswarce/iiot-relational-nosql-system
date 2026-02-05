#!/bin/bash
# =============================================================================
# IIoT System Health Check / Verificación de Salud del Sistema IIoT
# =============================================================================
#
# English:
# --------
# Checks the health status of all Docker services in the IIoT system.
# Verifies containers are running, ports are accessible, and services respond.
#
# Usage:
#     ./scripts/health_check.sh
#
# Español:
# --------
# Verifica el estado de salud de todos los servicios Docker en el sistema IIoT.
# Verifica que los contenedores estén corriendo, puertos accesibles y servicios respondan.
#
# Uso:
#     ./scripts/health_check.sh
#
# =============================================================================

set -e  # Exit on error / Salir en error

# Colors for output / Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color / Sin color

# Service configuration / Configuración de servicios
declare -A SERVICES=(
    ["mosquitto"]="1883"
    ["node-red"]="1880"
    ["mysql"]="3306"
    ["influxdb"]="8086"
    ["grafana"]="3000"
    ["adminer"]="8080"
)

# Container prefix / Prefijo de contenedor
CONTAINER_PREFIX="iiot-"

# =============================================================================
# UTILITY FUNCTIONS / FUNCIONES DE UTILIDAD
# =============================================================================

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}  IIoT System Health Check / Verificación de Salud IIoT${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
}

print_section() {
    echo -e "\n${BLUE}[$1]${NC}"
    echo "------------------------------------------------------------"
}

check_success() {
    echo -e "${GREEN}✓${NC} $1"
}

check_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_error() {
    echo -e "${RED}✗${NC} $1"
}

# =============================================================================
# CHECK FUNCTIONS / FUNCIONES DE VERIFICACIÓN
# =============================================================================

check_docker() {
    print_section "Docker Status / Estado de Docker"
    
    if ! command -v docker &> /dev/null; then
        check_error "Docker not found / Docker no encontrado"
        echo "   Install Docker Desktop / Instalar Docker Desktop:"
        echo "   https://www.docker.com/products/docker-desktop"
        return 1
    fi
    
    check_success "Docker installed / Docker instalado"
    
    if ! docker info &> /dev/null; then
        check_error "Docker daemon not running / Docker daemon no está corriendo"
        echo "   Start Docker Desktop / Iniciar Docker Desktop"
        return 1
    fi
    
    check_success "Docker daemon running / Docker daemon corriendo"
    
    # Check Docker Compose / Verificar Docker Compose
    if ! command -v docker compose &> /dev/null; then
        check_error "Docker Compose not found / Docker Compose no encontrado"
        return 1
    fi
    
    check_success "Docker Compose installed / Docker Compose instalado"
    return 0
}

check_containers() {
    print_section "Container Status / Estado de Contenedores"
    
    local all_running=true
    
    for service in "${!SERVICES[@]}"; do
        local container_name="${CONTAINER_PREFIX}${service}"
        
        if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
            local status=$(docker inspect --format='{{.State.Status}}' "$container_name")
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "none")
            
            if [ "$status" = "running" ]; then
                if [ "$health" = "healthy" ]; then
                    check_success "$service (healthy / saludable)"
                elif [ "$health" = "none" ]; then
                    check_success "$service (running / corriendo)"
                else
                    check_warning "$service (running but unhealthy / corriendo pero no saludable)"
                    all_running=false
                fi
            else
                check_error "$service (status: $status)"
                all_running=false
            fi
        else
            check_error "$service (not found / no encontrado)"
            all_running=false
        fi
    done
    
    if $all_running; then
        return 0
    else
        return 1
    fi
}

check_ports() {
    print_section "Port Accessibility / Accesibilidad de Puertos"
    
    local all_accessible=true
    
    for service in "${!SERVICES[@]}"; do
        local port="${SERVICES[$service]}"
        
        if nc -z localhost "$port" 2>/dev/null || timeout 1 bash -c "echo > /dev/tcp/localhost/$port" 2>/dev/null; then
            check_success "$service on port / en puerto $port"
        else
            check_error "$service on port / en puerto $port (not accessible / no accesible)"
            all_accessible=false
        fi
    done
    
    if $all_accessible; then
        return 0
    else
        return 1
    fi
}

check_services() {
    print_section "Service Health / Salud de Servicios"
    
    local all_healthy=true
    
    # Grafana HTTP check / Verificación HTTP Grafana
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health | grep -q "200"; then
        check_success "Grafana API responding / API de Grafana respondiendo"
    else
        check_warning "Grafana API not responding / API de Grafana no responde"
        all_healthy=false
    fi
    
    # InfluxDB HTTP check / Verificación HTTP InfluxDB
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8086/health | grep -q "200"; then
        check_success "InfluxDB API responding / API de InfluxDB respondiendo"
    else
        check_warning "InfluxDB API not responding / API de InfluxDB no responde"
        all_healthy=false
    fi
    
    # Node-RED HTTP check / Verificación HTTP Node-RED
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:1880 | grep -q "200"; then
        check_success "Node-RED responding / Node-RED respondiendo"
    else
        check_warning "Node-RED not responding / Node-RED no responde"
        all_healthy=false
    fi
    
    # MySQL connection check / Verificación conexión MySQL
    if docker exec iiot-mysql mysqladmin ping -h localhost -u root -prootpassword &>/dev/null; then
        check_success "MySQL accepting connections / MySQL aceptando conexiones"
    else
        check_warning "MySQL not accepting connections / MySQL no acepta conexiones"
        all_healthy=false
    fi
    
    if $all_healthy; then
        return 0
    else
        return 1
    fi
}

check_data() {
    print_section "Data Verification / Verificación de Datos"
    
    # Check MySQL data / Verificar datos MySQL
    local mysql_tables=$(docker exec iiot-mysql mysql -uroot -prootpassword iiot_system -e "SHOW TABLES;" 2>/dev/null | wc -l)
    if [ "$mysql_tables" -gt 1 ]; then
        check_success "MySQL database initialized / Base de datos MySQL inicializada ($((mysql_tables - 1)) tables/tablas)"
    else
        check_warning "MySQL database may not be initialized / Base de datos MySQL puede no estar inicializada"
    fi
    
    # Check InfluxDB buckets / Verificar buckets InfluxDB
    if docker exec iiot-influxdb influx bucket list &>/dev/null; then
        check_success "InfluxDB buckets accessible / Buckets de InfluxDB accesibles"
    else
        check_warning "InfluxDB buckets not accessible / Buckets de InfluxDB no accesibles"
    fi
}

print_summary() {
    print_section "Summary / Resumen"
    
    echo "Service URLs / URLs de Servicios:"
    echo "  • Grafana:    http://localhost:3000 (admin/admin)"
    echo "  • Node-RED:   http://localhost:1880"
    echo "  • InfluxDB:   http://localhost:8086 (admin/adminpassword)"
    echo "  • Adminer:    http://localhost:8080 (MySQL web interface)"
    echo ""
    echo "Useful Commands / Comandos Útiles:"
    echo "  • View logs / Ver logs:          docker compose logs -f [service]"
    echo "  • Restart service / Reiniciar:   docker compose restart [service]"
    echo "  • Stop all / Detener todo:       docker compose stop"
    echo "  • Start all / Iniciar todo:      docker compose up -d"
    echo ""
}

# =============================================================================
# MAIN EXECUTION / EJECUCIÓN PRINCIPAL
# =============================================================================

main() {
    print_header
    
    local exit_code=0
    
    # Run all checks / Ejecutar todas las verificaciones
    check_docker || exit_code=1
    check_containers || exit_code=1
    check_ports || exit_code=1
    check_services || exit_code=1
    check_data
    
    print_summary
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ All systems operational / Todos los sistemas operativos${NC}\n"
    else
        echo -e "${YELLOW}⚠ Some issues detected / Algunos problemas detectados${NC}"
        echo -e "  Run 'docker compose logs' for details / Ejecuta 'docker compose logs' para detalles\n"
    fi
    
    exit $exit_code
}

# Run main function / Ejecutar función principal
main
