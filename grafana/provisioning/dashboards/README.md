# Grafana Dashboards - Sistema IIoT

## 📊 Dashboard Pre-Configurado

Este directorio contiene la configuración para dashboards de Grafana que visualizan datos del sistema IIoT.

## Estructura

```
grafana/
├── provisioning/
│   ├── datasources/
│   │   └── datasources.yml         # Configuración InfluxDB + MySQL
│   └── dashboards/
│       ├── dashboards.yml          # Configuración de provisioning
│       └── iiot-dashboard.json     # Dashboard principal (crear manualmente)
```

## Crear Dashboard Manualmente

Dado que los dashboards JSON son muy grandes y específicos, se recomienda crearlos manualmente en Grafana UI:

### 1. Acceder a Grafana
- URL: http://localhost:3000
- Usuario: `admin`
- Password: `admin`

### 2. Crear Nuevo Dashboard

Click en **+ → Dashboard → Add new panel**

### 3. Paneles Recomendados

#### Panel 1: Temperatura en Tiempo Real (InfluxDB)
```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature_sensor" or r._measurement == "iiot/sensors/temperature")
  |> filter(fn: (r) => r._field == "value" or r._field == "temperature")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```
- Visualization: **Time series**
- Unit: **Celsius (°C)**
- Refresh: **5s**

#### Panel 2: Presión por Sensor (InfluxDB)
```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "pressure_sensor" or r._measurement == "iiot/sensors/pressure")
  |> filter(fn: (r) => r._field == "value" or r._field == "pressure")
  |> group(columns: ["sensor_id"])
```
- Visualization: **Time series**
- Unit: **Pressure (bar)**

#### Panel 3: Producción Total por Línea (MySQL)
```sql
SELECT 
    pl.line_name AS metric,
    SUM(pb.actual_quantity) AS value,
    NOW() AS time
FROM production_lines pl
LEFT JOIN production_batches pb ON pl.line_id = pb.line_id
WHERE pb.status = 'completed'
GROUP BY pl.line_name
ORDER BY value DESC
```
- Visualization: **Bar gauge**
- Unit: **Units**

#### Panel 4: Calidad Promedio (MySQL)
```sql
SELECT 
    pl.line_name,
    AVG(qi.quality_score) AS avg_quality,
    COUNT(qi.inspection_id) AS total_inspections
FROM production_lines pl
LEFT JOIN production_batches pb ON pl.line_id = pb.line_id
LEFT JOIN quality_inspections qi ON pb.batch_id = qi.batch_id
WHERE qi.inspection_time > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY pl.line_name
```
- Visualization: **Bar chart**

#### Panel 5: Alertas Activas (MySQL)
```sql
SELECT 
    alert_type,
    severity,
    sensor_id,
    alert_message,
    created_at
FROM system_alerts
WHERE acknowledged = FALSE
ORDER BY severity DESC, created_at DESC
LIMIT 10
```
- Visualization: **Table**

#### Panel 6: Estadísticas del Sistema (Stat Panels)
```sql
-- Total Batches Completados
SELECT COUNT(*) as value 
FROM production_batches 
WHERE status = 'completed';

-- Calidad Promedio General
SELECT AVG(quality_score) as value 
FROM quality_inspections;

-- Alertas Pendientes
SELECT COUNT(*) as value 
FROM system_alerts 
WHERE acknowledged = FALSE;
```
- Visualization: **Stat**

### 4. Variables de Dashboard (Opcional)

Crear variables para filtrar datos dinámicamente:

**Variable: line_id**
- Type: Query
- Data source: MySQL_IIoT
- Query: `SELECT line_id AS __value, line_name AS __text FROM production_lines`

**Variable: sensor_id**
- Type: Query
- Data source: MySQL_IIoT
- Query: `SELECT DISTINCT sensor_id FROM sensor_metadata WHERE status = 'active'`

### 5. Guardar Dashboard

1. Click en **Save dashboard** (icono disquete)
2. Nombre: `IIoT - Monitoreo en Tiempo Real`
3. Click **Save**

## Exportar Dashboard

Para compartir el dashboard con otros:

1. Click en **Settings** (icono engranaje)
2. Click en **JSON Model**
3. Copiar el JSON completo
4. Guardar como `iiot-dashboard.json` en este directorio
5. Restart Grafana: `docker-compose restart grafana`

## Importar Dashboard

Si ya tienes un archivo `iiot-dashboard.json`:

1. Click en **+ → Import**
2. Upload JSON file o pegar contenido
3. Seleccionar datasources (InfluxDB_IIoT, MySQL_IIoT)
4. Click **Import**

## Alerting (Opcional)

Configurar alertas en Grafana para notificaciones:

1. En cualquier panel, click **Alert** tab
2. Create alert rule
3. Definir condición (ej: temperatura > 90°C)
4. Configurar contacto (email, webhook, etc.)

**Nota**: Para emails reales, configurar SMTP en docker-compose.yml

## Recursos Adicionales

- [Grafana Documentation](https://grafana.com/docs/)
- [Flux Language Guide](https://docs.influxdata.com/flux/)
- [Grafana Dashboards Gallery](https://grafana.com/grafana/dashboards/)

## Troubleshooting

### No aparecen datos en paneles

1. Verificar que Node-RED esté escribiendo datos:
   - Abrir Node-RED debug panel
   - Verificar mensajes MQTT

2. Test datasource:
   - Configuration → Data Sources → Test

3. Query correcta:
   - Usar **Explore** para probar queries
   - Ver logs: `docker-compose logs grafana`

### Credenciales incorrectas

Verificar en `.env`:
- `INFLUXDB_TOKEN`
- `MYSQL_PASSWORD`

Deben coincidir con `datasources.yml`
