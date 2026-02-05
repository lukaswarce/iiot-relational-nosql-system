#!/bin/bash
# ==============================================================================
# INFLUXDB INITIALIZATION SCRIPT
# ==============================================================================
# Este script configura InfluxDB 2.x con buckets y tasks
# Se ejecuta automáticamente al iniciar el contenedor por primera vez
#
# Nota: InfluxDB 2.x ya está configurado via variables de entorno en
# docker-compose.yml, este script es para configuración adicional opcional
# ==============================================================================

echo "=================================="
echo "InfluxDB Initialization - IIoT Project"
echo "=================================="

# Esperar a que InfluxDB esté completamente iniciado
echo "Esperando a que InfluxDB esté listo..."
sleep 10

# Variables de entorno (deben coincidir con docker-compose.yml)
INFLUX_ORG="${DOCKER_INFLUXDB_INIT_ORG:-iiot-class}"
INFLUX_BUCKET="${DOCKER_INFLUXDB_INIT_BUCKET:-iiot_sensors}"
INFLUX_TOKEN="${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN:-my-super-secret-auth-token}"

echo "Configuración:"
echo "  Organización: $INFLUX_ORG"
echo "  Bucket principal: $INFLUX_BUCKET"

# Nota: El bucket principal y la organización ya se crean automáticamente
# via DOCKER_INFLUXDB_INIT_* environment variables

# Crear bucket adicional para datos agregados (opcional)
echo "Verificando buckets adicionales..."

# Este comando se ejecutaría si necesitamos crear buckets adicionales:
# influx bucket create \
#   --name iiot_aggregated \
#   --org $INFLUX_ORG \
#   --retention 8760h \
#   --token $INFLUX_TOKEN

echo "=================================="
echo "Inicialización completada"
echo "=================================="
echo ""
echo "📊 Acceso a InfluxDB UI:"
echo "   URL: http://localhost:8086"
echo "   Usuario: ${DOCKER_INFLUXDB_INIT_USERNAME:-admin}"
echo "   Password: ${DOCKER_INFLUXDB_INIT_PASSWORD:-admin123}"
echo "   Token: $INFLUX_TOKEN"
echo ""
echo "🔧 Para crear buckets adicionales desde Node-RED:"
echo "   Usar el token proporcionado arriba"
echo "   Bucket: $INFLUX_BUCKET"
echo "   Org: $INFLUX_ORG"
echo ""
echo "📝 Ejemplo de query Flux:"
echo '   from(bucket: "iiot_sensors")'
echo '     |> range(start: -1h)'
echo '     |> filter(fn: (r) => r._measurement == "temperature")'
echo ""

# ==============================================================================
# NOTAS PARA ESTUDIANTES
# ==============================================================================
#
# ESTRUCTURA DE DATOS EN INFLUXDB:
# ---------------------------------
# Bucket: Contenedor de datos (como "database" en SQL)
# Measurement: Tipo de métrica (como "tabla" en SQL)
# Tag: Metadatos indexados (sensor_id, location, etc.)
# Field: Valores medidos (temperature, pressure, etc.)
# Timestamp: Marca de tiempo automática
#
# EJEMPLO DE ESCRITURA DESDE NODE-RED:
# -------------------------------------
# msg.payload = {
#     temperature: 25.5,
#     humidity: 60.2
# };
# msg.measurement = "climate_sensor";
# msg.tags = {
#     sensor_id: "TEMP_001",
#     location: "Linea_A"
# };
#
# RETENCIÓN DE DATOS:
# -------------------
# Bucket por defecto: Sin límite de retención
# Para producción: Configurar retention policies apropiadas
# Ejemplo: 30 días para datos crudos, 1 año para agregados
#
# DOWNSAMPLING (AGREGACIÓN):
# --------------------------
# Usar Tasks de InfluxDB para crear promedios/máximos/mínimos
# Reduce almacenamiento y mejora rendimiento de queries
#
# ==============================================================================
