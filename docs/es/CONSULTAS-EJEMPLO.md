# Consultas de Ejemplo - SQL y Flux

**Colección de Queries Comentadas con Propósito Pedagógico**

---

## 📋 Índice

1. [Consultas MySQL (SQL)](#consultas-mysql-sql)
   - Básicas SELECT
   - JOINs y Relaciones
   - Agregaciones y GROUP BY
   - Transacciones
   - Violaciones de Constraints
2. [Consultas InfluxDB (Flux)](#consultas-influxdb-flux)
   - Consultas Básicas Time-Series
   - Agregaciones Temporales
   - Downsampling
   - Detección de Anomalías
   - Window Functions
3. [Comparaciones de Rendimiento](#comparaciones-de-rendimiento)
4. [Ejercicios de Práctica](#ejercicios-de-práctica)

---

## 🗄️ Consultas MySQL (SQL)

### 1. SELECT Básico con WHERE

**Objetivo Pedagógico**: Entender filtrado básico y estructura SELECT

```sql
-- Obtener todos los batches en progreso
SELECT 
    batch_code,
    product_name,
    status,
    target_quantity,
    actual_quantity,
    start_time
FROM production_batches
WHERE status = 'in_progress'
ORDER BY start_time DESC;
```

**Explicación**:
- `SELECT`: Especifica columnas a retornar
- `FROM`: Tabla fuente de datos
- `WHERE`: Filtro condicional (solo batches en progreso)
- `ORDER BY DESC`: Ordena por fecha más reciente primero

**Resultado Esperado**:
```
batch_code       | product_name | status      | target_quantity | actual_quantity | start_time
-----------------|--------------|-------------|-----------------|-----------------|-------------------
BATCH_2026_008   | Widget B     | in_progress | 1000            | 750             | 2026-02-03 08:00:00
BATCH_2026_007   | Widget A     | in_progress | 1500            | 1200            | 2026-02-03 06:00:00
```

**Concepto Clave**: SQL es declarativo - dices QUÉ quieres, no CÓMO obtenerlo.

---

### 2. JOIN - Relacionar Tablas

**Objetivo Pedagógico**: Entender relaciones Foreign Key y JOIN operations

```sql
-- Obtener batches con información de la línea de producción
SELECT 
    pl.line_name,
    pl.location,
    pb.batch_code,
    pb.product_name,
    pb.status,
    pb.actual_quantity,
    pb.start_time
FROM production_batches pb
INNER JOIN production_lines pl ON pb.line_id = pl.id
WHERE pb.status = 'in_progress'
ORDER BY pl.line_name, pb.start_time;
```

**Explicación**:
- `INNER JOIN`: Combina filas cuando hay match en ambas tablas
- `ON pb.line_id = pl.id`: Condición de unión (Foreign Key)
- Prefijos `pb.` y `pl.`: Alias para evitar ambigüedad
- Resultado: Una "tabla virtual" combinando datos de ambas fuentes

**Visualización Mental**:
```
production_lines         production_batches
┌────┬───────────┐      ┌────┬─────────┬─────────┐
│ id │ line_name │      │ id │ line_id │ batch_..│
├────┼───────────┤      ├────┼─────────┼─────────┤
│ 1  │ Line A    │ ←────┤ 1  │    1    │ ...     │
│ 2  │ Line B    │      │ 2  │    1    │ ...     │
└────┴───────────┘      │ 3  │    2    │ ...     │
                        └────┴─────────┴─────────┘
                             │
                             └─ FK apunta a PK
```

**Concepto Clave**: JOIN materializa relaciones definidas por Foreign Keys.

---

### 3. Agregación con GROUP BY

**Objetivo Pedagógico**: Entender agregaciones y agrupamiento

```sql
-- Resumen de producción por línea
SELECT 
    pl.line_name,
    COUNT(pb.id) as total_batches,
    SUM(pb.actual_quantity) as total_units_produced,
    AVG(pb.actual_quantity) as avg_units_per_batch,
    MIN(pb.start_time) as first_batch,
    MAX(pb.start_time) as last_batch
FROM production_lines pl
LEFT JOIN production_batches pb ON pl.id = pb.line_id
GROUP BY pl.id, pl.line_name
ORDER BY total_units_produced DESC;
```

**Explicación**:
- `COUNT(pb.id)`: Cuenta batches por línea
- `SUM(pb.actual_quantity)`: Suma total de unidades
- `AVG()`: Promedio de unidades por batch
- `GROUP BY`: Agrupa filas por línea antes de agregar
- `LEFT JOIN`: Incluye líneas sin batches (vs INNER JOIN)

**Resultado Esperado**:
```
line_name | total_batches | total_units_produced | avg_units_per_batch | first_batch         | last_batch
----------|---------------|----------------------|---------------------|---------------------|-------------------
Line A    | 5             | 7500                 | 1500.00             | 2026-02-01 06:00:00 | 2026-02-03 08:00:00
Line B    | 3             | 4000                 | 1333.33             | 2026-02-01 14:00:00 | 2026-02-03 10:00:00
```

**Concepto Clave**: Agregaciones transforman múltiples filas en valores sumarios.

---

### 4. Subconsulta (Subquery)

**Objetivo Pedagógico**: Queries anidadas para lógica compleja

```sql
-- Batches con calidad superior al promedio general
SELECT 
    batch_code,
    product_name,
    actual_quantity,
    (SELECT AVG(quality_score) 
     FROM quality_inspections qi 
     WHERE qi.batch_id = pb.id) as avg_quality
FROM production_batches pb
WHERE EXISTS (
    SELECT 1 
    FROM quality_inspections qi2 
    WHERE qi2.batch_id = pb.id 
      AND qi2.quality_score > (
          SELECT AVG(quality_score) 
          FROM quality_inspections
      )
)
ORDER BY avg_quality DESC;
```

**Explicación**:
- Subquery en SELECT: Calcula avg_quality por batch
- Subquery en WHERE con EXISTS: Filtra batches con inspecciones sobre promedio
- Subquery anidada: Calcula promedio general de calidad
- Evaluación: Subqueries se ejecutan por cada fila (correlacionadas)

**Concepto Clave**: Subqueries permiten lógica multi-nivel pero pueden ser lentas.

---

### 5. Transacción COMMIT (ACID)

**Objetivo Pedagógico**: Demostrar Atomicidad y Durabilidad

```sql
-- Registrar lote completo con eventos
START TRANSACTION;

-- Paso 1: Crear batch
INSERT INTO production_batches (
    line_id, 
    batch_code, 
    product_name, 
    target_quantity, 
    status,
    start_time
) VALUES (
    1,
    'BATCH_2026_200',
    'Widget Premium',
    2000,
    'in_progress',
    NOW()
);

-- Capturar ID del batch recién creado
SET @new_batch_id = LAST_INSERT_ID();

-- Paso 2: Registrar evento de inicio
INSERT INTO production_events (
    batch_id,
    event_type,
    event_time,
    description
) VALUES (
    @new_batch_id,
    'start',
    NOW(),
    'Batch iniciado automáticamente'
);

-- Si todo OK, guardar permanentemente
COMMIT;

-- Verificar que TODO se guardó
SELECT * FROM production_batches WHERE batch_code = 'BATCH_2026_200';
SELECT * FROM production_events WHERE batch_id = @new_batch_id;
```

**Explicación**:
- `START TRANSACTION`: Inicia bloque atómico
- `LAST_INSERT_ID()`: Captura ID auto-generado
- `COMMIT`: Hace cambios permanentes y durables
- Si falla cualquier INSERT → todo se descarta automáticamente

**Concepto Clave**: TODO o NADA. No puede quedar batch sin evento o evento sin batch.

**ACID Demostrado**:
- ✅ **A**tomicidad: 2 INSERTs son unidad indivisible
- ✅ **C**onsistencia: Foreign keys se mantienen válidos
- ✅ **D**urabilidad: Post-COMMIT, datos sobreviven fallo eléctrico

---

### 6. Transacción ROLLBACK (Error Handling)

**Objetivo Pedagógico**: Demostrar recuperación de errores

```sql
-- Transacción que FALLARÁ intencionalmente
START TRANSACTION;

-- Paso 1: INSERT válido
INSERT INTO production_batches (
    line_id, 
    batch_code, 
    product_name, 
    target_quantity, 
    status,
    start_time
) VALUES (
    1,
    'BATCH_2026_FAIL',
    'Widget Test',
    1000,
    'in_progress',
    NOW()
);

SET @fail_batch_id = LAST_INSERT_ID();

-- Paso 2: INSERT que VIOLA constraint (quality > 10)
INSERT INTO quality_inspections (
    batch_id,
    inspector_name,
    quality_score,  -- ❌ Intentar poner 15 (máximo es 10)
    inspection_time
) VALUES (
    @fail_batch_id,
    'Inspector Test',
    15.0,  -- ❌ INVÁLIDO
    NOW()
);

-- Este COMMIT nunca se alcanzará porque error anterior
COMMIT;
```

**Lo Que Pasa**:
```
ERROR 3819 (HY000): Check constraint 'quality_inspections_chk_1' is violated.
```

**Después del Error**:
```sql
-- Verificar: el batch NO existe (ROLLBACK automático)
SELECT * FROM production_batches WHERE batch_code = 'BATCH_2026_FAIL';
-- Resultado: 0 rows
```

**Concepto Clave**: Error → ROLLBACK automático. Sistema previene corrupción de datos.

---

### 7. Violación Foreign Key Constraint

**Objetivo Pedagógico**: Entender integridad referencial

```sql
-- Intentar borrar línea de producción con batches dependientes
DELETE FROM production_lines WHERE id = 1;
```

**Error Esperado**:
```
ERROR 1451 (23000): Cannot delete or update a parent row: 
a foreign key constraint fails (`iiot_db`.`production_batches`, 
CONSTRAINT `production_batches_ibfk_1` FOREIGN KEY (`line_id`) 
REFERENCES `production_lines` (`id`))
```

**Explicación Visual**:
```
production_lines (PARENT)          production_batches (CHILD)
┌────┬───────────┐                 ┌────┬─────────┐
│ 1  │ Line A    │ ← FK ─────────┤ ...│    1    │
└────┴───────────┘                 └────┴─────────┘
     ↑                                   │
     └─ NO PUEDES BORRAR              Tiene
        mientras existan              dependencias
        referencias
```

**Solución Correcta**:
```sql
-- Opción 1: Borrar dependencias primero
DELETE FROM production_batches WHERE line_id = 1;
DELETE FROM production_lines WHERE id = 1;

-- Opción 2: Usar CASCADE (si FK fue definido con ON DELETE CASCADE)
-- Borraría línea Y batches automáticamente

-- Opción 3: UPDATE en vez de DELETE
UPDATE production_batches SET line_id = 2 WHERE line_id = 1;
DELETE FROM production_lines WHERE id = 1;
```

**Concepto Clave**: Base de datos es guardia de seguridad que previene huérfanos.

---

### 8. Stored Procedure (Lógica Compleja)

**Objetivo Pedagógico**: Encapsular lógica de negocio en BD

```sql
-- Llamar stored procedure existente
CALL sp_create_batch_with_validation(
    1,                    -- line_id
    'BATCH_2026_300',     -- batch_code
    'Widget Deluxe',      -- product_name  
    2500,                 -- target_quantity
    8.0                   -- quality_threshold
);
```

**Ver definición del procedure** (opcional, para entender internals):
```sql
SHOW CREATE PROCEDURE sp_create_batch_with_validation;
```

**Lo Que Hace Internamente**:
1. Valida que `line_id` existe
2. Valida que `batch_code` no está duplicado
3. Valida que `quality_threshold` está entre 0-10
4. Si todo OK: INSERT batch + INSERT evento en transacción
5. Si cualquier validación falla: ROLLBACK con mensaje error

**Ventajas**:
- ✅ Lógica centralizada (no repetir en cada app)
- ✅ Performance (ejecuta server-side)
- ✅ Seguridad (users solo ejecutan procedure, no acceso directo)

**Concepto Clave**: Stored procedures = funciones que viven en la BD.

---

### 9. VIEW (Tabla Virtual)

**Objetivo Pedagógico**: Simplificar queries complejas recurrentes

```sql
-- Usar view pre-definida
SELECT * FROM v_production_summary;
```

**Resultado**:
```
batch_code       | line_name | product_name | status      | total_quantity | inspections_count | avg_quality
-----------------|-----------|--------------|-------------|----------------|-------------------|-------------
BATCH_2026_001   | Line A    | Widget A     | completed   | 1500           | 2                 | 8.50
BATCH_2026_002   | Line A    | Widget B     | in_progress | 750            | 1                 | 9.00
...
```

**Ver definición de la view**:
```sql
SHOW CREATE VIEW v_production_summary;
```

**Internamente**:
```sql
CREATE VIEW v_production_summary AS
SELECT 
    pb.batch_code,
    pl.line_name,
    pb.product_name,
    pb.status,
    pb.actual_quantity as total_quantity,
    COUNT(qi.id) as inspections_count,
    AVG(qi.quality_score) as avg_quality
FROM production_batches pb
JOIN production_lines pl ON pb.line_id = pl.id
LEFT JOIN quality_inspections qi ON pb.id = qi.batch_id
GROUP BY pb.id, pb.batch_code, pl.line_name, pb.product_name, pb.status, pb.actual_quantity;
```

**Concepto Clave**: VIEW = query guardada como si fuera tabla. No almacena datos, ejecuta query cada vez.

---

### 10. Query con Parsing JSON (MQTT Logs)

**Objetivo Pedagógico**: Manejar datos semi-estructurados en SQL

```sql
-- Extraer temperatura promedio de mensajes MQTT loggeados
SELECT 
    DATE(timestamp) as date,
    topic,
    COUNT(*) as message_count,
    AVG(CAST(JSON_EXTRACT(payload, '$.value') AS DECIMAL(10,2))) as avg_value,
    MIN(CAST(JSON_EXTRACT(payload, '$.value') AS DECIMAL(10,2))) as min_value,
    MAX(CAST(JSON_EXTRACT(payload, '$.value') AS DECIMAL(10,2))) as max_value
FROM mqtt_messages_log
WHERE topic = 'iiot/sensors/temperature'
  AND timestamp >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY DATE(timestamp), topic
ORDER BY date DESC;
```

**Explicación**:
- `JSON_EXTRACT(payload, '$.value')`: Extrae campo 'value' del JSON
- `CAST(... AS DECIMAL)`: Convierte texto a número
- Agrupa por día para resumen diario

**Resultado**:
```
date       | topic                    | message_count | avg_value | min_value | max_value
-----------|--------------------------|---------------|-----------|-----------|----------
2026-02-03 | iiot/sensors/temperature | 86400         | 65.34     | 20.15     | 99.87
2026-02-02 | iiot/sensors/temperature | 86400         | 64.92     | 20.45     | 98.34
```

**Concepto Clave**: SQL puede manejar JSON pero no es óptimo (vs document DB). Útil para logs/auditoría.

---

## ⏰ Consultas InfluxDB (Flux)

### 1. Query Básica Time-Series

**Objetivo Pedagógico**: Estructura básica Flux

```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
```

**Explicación Línea por Línea**:
- `from(bucket: ...)`: Fuente de datos (equivalente a FROM tabla)
- `|>`: Pipe operator - pasa resultado a siguiente función
- `range(start: -1h)`: Filtro temporal (última hora)
- `filter()`: Filtros adicionales (measurement = tipo de sensor, field = columna)

**Resultado**:
```
_time                _measurement  _field  _value  sensor_id
-------------------  ------------  ------  ------  ----------
2026-02-03T09:00:00Z temperature   value   65.2    TEMP_001
2026-02-03T09:00:01Z temperature   value   65.5    TEMP_001
2026-02-03T09:00:02Z temperature   value   66.1    TEMP_001
... (3,600 filas)
```

**Concepto Clave**: Flux es funcional - pipeline de transformaciones encadenadas.

---

### 2. Agregación Temporal (Mean)

**Objetivo Pedagógico**: Resumir datos en ventana temporal

```flux
from(bucket: "iiot_sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> mean()
```

**Resultado**:
```
_value
------
65.34
```

**Explicación**:
- `mean()`: Promedio de TODOS los valores en el rango
- Sin `group()`: Agrega todo en un solo valor
- Procesa ~86,400 registros (1/seg x 24h) en milisegundos

**Variaciones**:
```flux
// Otras agregaciones
|> max()  // Máximo
|> min()  // Mínimo
|> count()  // Cantidad de registros
|> sum()  // Suma total
|> median()  // Mediana
|> stddev()  // Desviación estándar
```

**Concepto Clave**: Agregaciones simples muy rápidas por diseño columnar.

---

### 3. Aggregated Windows (Downsampling)

**Objetivo Pedagógico**: Reducir resolución temporal

```flux
from(bucket: "iiot_sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
```

**Explicación**:
- `aggregateWindow(every: 5m)`: Agrupa en ventanas de 5 minutos
- `fn: mean`: Calcula promedio de cada ventana
- `createEmpty: false`: Omite ventanas sin datos

**Resultado**:
```
_time                _value
-------------------  ------
2026-02-03T09:00:00Z 65.2
2026-02-03T09:05:00Z 65.8
2026-02-03T09:10:00Z 64.9
... (288 filas para 24h)
```

**Reducción**: 86,400 registros → 288 registros (300x menos)

**Uso Real**: Gráficos históricos largos sin saturar frontend

**Concepto Clave**: Downsampling = sacrificar detalle por performance.

---

### 4. Multiple Sensors (Group By)

**Objetivo Pedagógico**: Manejar múltiples series temporales

```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature" or r["_measurement"] == "pressure")
  |> filter(fn: (r) => r["_field"] == "value")
  |> group(columns: ["_measurement", "sensor_id"])
  |> mean()
```

**Resultado**:
```
_measurement  sensor_id    _value
------------  ----------   ------
temperature   TEMP_001     65.34
pressure      PRES_001     3.42
```

**Explicación**:
- `group()`: Agrupa por measurement y sensor antes de agregar
- Sin `group()`: mezclaría temperaturas y presiones (inválido)

**Concepto Clave**: Series temporales son independientes, agrupar para operaciones correctas.

---

### 5. Detección de Anomalías (Threshold)

**Objetivo Pedagógico**: Alertas basadas en umbrales

```flux
from(bucket: "iiot_sensors")
  |> range(start: -15m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["_value"] > 80.0)  // 🚨 Umbral crítico
  |> count()
```

**Resultado**:
```
_value
------
15  // 15 lecturas sobre 80°C en últimos 15 min
```

**Uso Real**: Trigger para alertas

**Variación - Listar Todas las Anomalías**:
```flux
from(bucket: "iiot_sensors")
  |> range(start: -15m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["_value"] > 80.0)
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 10)
```

**Concepto Clave**: Filtrado post-agregación para detección de patrones.

---

### 6. Derivada (Rate of Change)

**Objetivo Pedagógico**: Detectar cambios bruscos

```flux
from(bucket: "iiot_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> derivative(unit: 1m, nonNegative: false)
  |> filter(fn: (r) => r["_value"] > 5.0 or r["_value"] < -5.0)
```

**Explicación**:
- `derivative()`: Calcula tasa de cambio (°C por minuto)
- `nonNegative: false`: Permite valores negativos (enfriamiento)
- Filtro final: Solo cambios >5°C/min (bruscos)

**Uso Real**: Detectar fallos de sensor o eventos anormales (puertas abiertas, fugas)

**Resultado**:
```
_time                _value
-------------------  ------
2026-02-03T09:15:32Z  7.2   // ⚠️ Subida rápida
2026-02-03T09:23:15Z -6.8   // ⚠️ Caída rápida
```

**Concepto Clave**: TSDB facilita análisis matemático de tendencias.

---

### 7. Join de Múltiples Measurements

**Objetivo Pedagógico**: Correlacionar sensores diferentes

```flux
temp = from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1m, fn: mean)

pressure = from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "pressure")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1m, fn: mean)

join(tables: {temp: temp, pressure: pressure}, on: ["_time"])
```

**Resultado**:
```
_time                temp_value  pressure_value
-------------------  ----------  --------------
2026-02-03T09:00:00Z 65.2        3.42
2026-02-03T09:01:00Z 65.8        3.45
...
```

**Uso Real**: Análisis de correlación (ej: temperatura alta + presión baja = fuga)

**Concepto Clave**: Join temporal - alinear series por timestamp.

---

### 8. Retención y Downsampling Automático (Task)

**Objetivo Pedagógico**: Configurar agregación automática

```flux
// Esta es una TASK que corre periódicamente
option task = {name: "downsample_hourly", every: 1h}

from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> aggregateWindow(every: 1m, fn: mean)
  |> to(bucket: "iiot_sensors_hourly")  // Escribir a bucket de retención larga
```

**Explicación**:
- Task ejecuta cada hora
- Downsample datos crudos (1/seg → 1/min)
- Almacena en bucket separado con retención >1 año
- Bucket original puede tener retención corta (30 días)

**Estrategia de Retención Típica**:
```
iiot_sensors (raw)          → 30 días   → 1 lectura/seg
iiot_sensors_hourly         → 1 año     → 1 lectura/min
iiot_sensors_daily          → 5 años    → 1 lectura/hora
```

**Concepto Clave**: Downsampling automático reduce costos almacenamiento 95%+.

---

### 9. Percentiles (Análisis Estadístico)

**Objetivo Pedagógico**: Entender distribución de datos

```flux
from(bucket: "iiot_sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> quantile(q: 0.95)  // Percentil 95
```

**Resultado**:
```
_value
------
87.3  // 95% de lecturas están bajo 87.3°C
```

**Uso Real**: SLA monitoring (ej: "99% del tiempo, temp < 90°C")

**Variaciones**:
```flux
|> quantile(q: 0.50)  // Mediana (percentil 50)
|> quantile(q: 0.99)  // Percentil 99 (outliers)
```

**Concepto Clave**: Percentiles más representativos que promedio para SLAs.

---

### 10. Comparación Periodo Anterior (Time Shift)

**Objetivo Pedagógico**: Análisis de tendencias

```flux
current = from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> mean()

previous = from(bucket: "iiot_sensors")
  |> range(start: -2h, stop: -1h)  // Hora anterior
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> mean()

// Comparar manualmente o con join
union(tables: [current, previous])
```

**Resultado**:
```
_value  _start               _stop
------  -------------------  -------------------
65.3    2026-02-03T08:00:00Z 2026-02-03T09:00:00Z  // Actual
64.8    2026-02-03T07:00:00Z 2026-02-03T08:00:00Z  // Anterior
```

**Cálculo % Cambio** (requiere map):
```flux
// Diferencia: 65.3 - 64.8 = +0.5°C (+0.77%)
```

**Concepto Clave**: Time shift para detectar tendencias ascendentes/descendentes.

---

## ⚖️ Comparaciones de Rendimiento

### Escenario: Promedio de 1 Hora de Datos

**MySQL**:
```sql
SELECT AVG(CAST(JSON_EXTRACT(payload, '$.value') AS DECIMAL(10,2))) as avg_temp
FROM mqtt_messages_log
WHERE topic = 'iiot/sensors/temperature'
  AND timestamp >= DATE_SUB(NOW(), INTERVAL 1 HOUR);
```

**InfluxDB**:
```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> mean()
```

**Benchmark** (3,600 registros):
```
┌──────────────┬────────────┬──────────────┐
│ Métrica      │ MySQL      │ InfluxDB     │
├──────────────┼────────────┼──────────────┤
│ Tiempo Query │ 450-800 ms │ 30-80 ms     │
│ CPU Usado    │ Alto       │ Bajo         │
│ Rows Scanned │ 3,600      │ 3,600        │
│ Storage      │ ~1.2 MB    │ ~0.15 MB     │
└──────────────┴────────────┴──────────────┘

🏆 InfluxDB: 6-10x más rápido
```

**Por Qué InfluxDB Gana**:
- Compresión columnar (valores similares consecutivos)
- Índice temporal optimizado (B-tree para timestamps)
- Sin overhead relacional (no JOINs, no FK checks)
- Almacenamiento diseñado para append-only

---

### Escenario: Downsampling 1 Año → 1 Día

**MySQL** (complejo):
```sql
SELECT 
    DATE(timestamp) as day,
    AVG(CAST(JSON_EXTRACT(payload, '$.value') AS DECIMAL)) as avg_value
FROM mqtt_messages_log
WHERE topic = 'iiot/sensors/temperature'
  AND timestamp >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
GROUP BY DATE(timestamp)
ORDER BY day;
```

**InfluxDB** (nativo):
```flux
from(bucket: "iiot_sensors")
  |> range(start: -1y)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> aggregateWindow(every: 1d, fn: mean)
```

**Benchmark** (~31 millones de registros):
```
┌──────────────┬────────────┬──────────────┐
│ Métrica      │ MySQL      │ InfluxDB     │
├──────────────┼────────────┼──────────────┤
│ Tiempo Query │ 30-60 seg  │ 1-3 seg      │
│ Rows Output  │ 365        │ 365          │
│ Complejidad  │ Alta       │ Baja         │
└──────────────┴────────────┴──────────────┘

🏆 InfluxDB: 10-20x más rápido
```

---

### Escenario: JOIN Relacional

**MySQL** (fuerte):
```sql
SELECT pb.batch_code, pl.line_name, COUNT(qi.id) as inspections
FROM production_batches pb
JOIN production_lines pl ON pb.line_id = pl.id
LEFT JOIN quality_inspections qi ON pb.id = qi.batch_id
GROUP BY pb.id, pb.batch_code, pl.line_name;
```

**InfluxDB** (débil - no diseñado para esto):
```flux
// Requiere múltiples queries y join manual - incómodo
```

**Conclusión**:
```
🏆 MySQL: Diseñado para JOINs relacionales
   InfluxDB: Posible pero no idiomático
```

---

## 📚 Ejercicios de Práctica

### Ejercicio 1: SQL Básico

**Enunciado**: Obtener todos los eventos de tipo 'error' o 'warning' de la tabla `system_alerts`, ordenados por severity (más alto primero).

<details>
<summary>Ver Solución</summary>

```sql
SELECT 
    alert_type,
    message,
    severity,
    created_at
FROM system_alerts
WHERE alert_type IN ('error', 'warning')
ORDER BY severity DESC, created_at DESC;
```
</details>

---

### Ejercicio 2: SQL JOIN

**Enunciado**: Listar todos los batches con más de 2 inspecciones de calidad, mostrando batch_code, cantidad de inspecciones, y calidad promedio.

<details>
<summary>Ver Solución</summary>

```sql
SELECT 
    pb.batch_code,
    COUNT(qi.id) as inspection_count,
    AVG(qi.quality_score) as avg_quality
FROM production_batches pb
JOIN quality_inspections qi ON pb.id = qi.batch_id
GROUP BY pb.id, pb.batch_code
HAVING COUNT(qi.id) > 2
ORDER BY avg_quality DESC;
```
</details>

---

### Ejercicio 3: Flux Agregación

**Enunciado**: Calcular máximo, mínimo y promedio de presión en las últimas 2 horas.

<details>
<summary>Ver Solución</summary>

```flux
from(bucket: "iiot_sensors")
  |> range(start: -2h)
  |> filter(fn: (r) => r["_measurement"] == "pressure")
  |> filter(fn: (r) => r["_field"] == "value")
  |> group()
  |> mean()

// Para max y min, reemplazar mean() con:
// |> max()
// |> min()

// O todos a la vez:
from(bucket: "iiot_sensors")
  |> range(start: -2h)
  |> filter(fn: (r) => r["_measurement"] == "pressure")
  |> filter(fn: (r) => r["_field"] == "value")
  |> group()
  |> reduce(
      fn: (r, accumulator) => ({
        max: if r._value > accumulator.max then r._value else accumulator.max,
        min: if r._value < accumulator.min then r._value else accumulator.min,
        sum: accumulator.sum + r._value,
        count: accumulator.count + 1.0,
      }),
      identity: {max: -999999.0, min: 999999.0, sum: 0.0, count: 0.0}
    )
  |> map(fn: (r) => ({
      max: r.max,
      min: r.min,
      mean: r.sum / r.count
    }))
```
</details>

---

### Ejercicio 4: SQL Transacción

**Enunciado**: Crear transacción que registre un nuevo lote Y su primer evento de calidad, asegurando atomicidad.

<details>
<summary>Ver Solución</summary>

```sql
START TRANSACTION;

INSERT INTO production_batches (
    line_id, batch_code, product_name, 
    target_quantity, status, start_time
) VALUES (
    2, 'BATCH_EXERCISE', 'Widget Exercise', 
    1000, 'in_progress', NOW()
);

SET @batch_id = LAST_INSERT_ID();

INSERT INTO quality_inspections (
    batch_id, inspector_name, 
    quality_score, inspection_time
) VALUES (
    @batch_id, 'Inspector Rodriguez', 
    8.5, NOW()
);

COMMIT;

-- Verificar
SELECT * FROM production_batches WHERE batch_code = 'BATCH_EXERCISE';
SELECT * FROM quality_inspections WHERE batch_id = @batch_id;
```
</details>

---

### Ejercicio 5: Flux Detección Anomalías

**Enunciado**: Detectar todos los momentos en últimos 30 minutos donde temperatura cambió más de 10°C en 1 minuto.

<details>
<summary>Ver Solución</summary>

```flux
from(bucket: "iiot_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> derivative(unit: 1m, nonNegative: false)
  |> filter(fn: (r) => r["_value"] > 10.0 or r["_value"] < -10.0)
  |> sort(columns: ["_time"], desc: false)
```
</details>

---

## 🎯 Resumen Comparativo Final

| Característica | MySQL | InfluxDB |
|----------------|-------|----------|
| **Mejor para** | Transacciones, relaciones | Series temporales |
| **ACID** | ✅ Completo | ⚠️ Eventual consistency |
| **JOINs** | ✅ Excelente | ❌ Limitado |
| **Agregaciones Temporales** | ⚠️ Lentas | ✅ Muy rápidas |
| **Esquema** | Rígido | Flexible (schema-less) |
| **Compresión** | Manual | Automática (8-10x) |
| **Query Language** | SQL (maduro) | Flux (moderno) |
| **Escalabilidad** | Vertical | Horizontal |
| **Uso IIoT** | Maestros, transacciones | Sensores, telemetría |

---

## 📖 Recursos Adicionales

### Documentación Oficial
- **MySQL**: https://dev.mysql.com/doc/
- **InfluxDB**: https://docs.influxdata.com/
- **Flux**: https://docs.influxdata.com/flux/

### Tutoriales Interactivos
- **InfluxDB University**: https://university.influxdata.com/ (gratis)
- **MySQL Tutorial**: https://www.mysqltutorial.org/
- **SQL Zoo**: https://sqlzoo.net/

### Herramientas Práctica
- **Adminer**: Explorador visual MySQL
- **InfluxDB UI**: Data Explorer integrado
- **Grafana**: Visualización queries

---

**¡Practica estas queries en el entorno Docker! 🚀**

_La mejor forma de aprender es ejecutando y experimentando._


---
**Versión**: 1.0  
**Última Actualización**: Febrero 2026  
**Instructor**: Christian Spana
