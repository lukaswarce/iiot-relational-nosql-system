# 📝 Query Examples - MySQL vs InfluxDB

> [🇺🇸 **English**] | [🇪🇸 Español](../es/CONSULTAS-EJEMPLO.md)

## 🎯 Objective

This document provides **practical, executable queries** to understand:
1. Fundamental differences between SQL (MySQL) and Flux (InfluxDB)
2. When to use each database in IIoT contexts
3. Performance patterns and trade-offs

Each example includes:
- ✅ Pedagogical goal
- 📖 Line-by-line explanation
- 💡 Key concepts
- ⚡ Performance notes (when relevant)

---

## 🗂️ MySQL Queries (SQL)

### 1. Basic SELECT (Structure)

**Pedagogical Goal**: Understand SELECT anatomy

```sql
-- Get all production lines ordered by name
SELECT 
    id,
    line_name,
    location,
    status,
    created_at
FROM production_lines
ORDER BY line_name ASC;
```

**Explanation**:
- `SELECT`: Columns to retrieve (projection)
- `FROM`: Source table
- `ORDER BY`: Sort result (ASC = ascending, DESC = descending)

**Expected Result**:
```
id | line_name | location    | status | created_at
---|-----------|-------------|--------|-------------------
1  | Line A    | Factory 01  | active | 2026-01-15 08:00:00
2  | Line B    | Factory 02  | active | 2026-01-20 10:30:00
```

**Key Concept**: SELECT = relational projection - extract columns from rows.

---

### 2. JOIN (Relationships)

**Pedagogical Goal**: Materialize foreign key relationships

```sql
-- List batches with their production line name
SELECT 
    pb.batch_code,
    pb.product_name,
    pb.actual_quantity,
    pl.line_name,
    pb.status
FROM production_batches pb
INNER JOIN production_lines pl ON pb.line_id = pl.id
WHERE pb.status = 'completed'
ORDER BY pb.start_time DESC
LIMIT 10;
```

**Explanation**:
- `INNER JOIN`: Combine rows where FK = PK
- `ON pb.line_id = pl.id`: Join condition (FK ↔ PK)
- Table aliases (`pb`, `pl`): Avoid repeating full names
- `WHERE`: Filter after join
- `LIMIT 10`: Only first 10 results

**Visual Concept**:
```
production_lines (PK)        production_batches (FK)
┌────┬───────────┐      ┌────┬─────────┬─────────┐
│ id │ line_name │      │ id │ line_id │ batch_..│
├────┼───────────┤      ├────┼─────────┼─────────┤
│ 1  │ Line A    │ ←────┤ 1  │    1    │ ...     │
│ 2  │ Line B    │      │ 2  │    1    │ ...     │
└────┴───────────┘      │ 3  │    2    │ ...     │
                        └────┴─────────┴─────────┘
                             │
                             └─ FK points to PK
```

**Key Concept**: JOIN materializes relationships defined by Foreign Keys.

---

### 3. Aggregation with GROUP BY

**Pedagogical Goal**: Understand aggregations and grouping

```sql
-- Production summary by line
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

**Explanation**:
- `COUNT(pb.id)`: Count batches per line
- `SUM(pb.actual_quantity)`: Total units sum
- `AVG()`: Average units per batch
- `GROUP BY`: Group rows by line before aggregating
- `LEFT JOIN`: Include lines without batches (vs INNER JOIN)

**Expected Result**:
```
line_name | total_batches | total_units_produced | avg_units_per_batch | first_batch         | last_batch
----------|---------------|----------------------|---------------------|---------------------|-------------------
Line A    | 5             | 7500                 | 1500.00             | 2026-02-01 06:00:00 | 2026-02-03 08:00:00
Line B    | 3             | 4000                 | 1333.33             | 2026-02-01 14:00:00 | 2026-02-03 10:00:00
```

**Key Concept**: Aggregations transform multiple rows into summary values.

---

### 4. Subquery

**Pedagogical Goal**: Nested queries for complex logic

```sql
-- Batches with quality above general average
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

**Explanation**:
- Subquery in SELECT: Calculates avg_quality per batch
- Subquery in WHERE with EXISTS: Filters batches with inspections above average
- Nested subquery: Calculates overall quality average
- Evaluation: Subqueries execute for each row (correlated)

**Key Concept**: Subqueries enable multi-level logic but can be slow.

---

### 5. COMMIT Transaction (ACID)

**Pedagogical Goal**: Demonstrate Atomicity and Durability

```sql
-- Register complete batch with events
START TRANSACTION;

-- Step 1: Create batch
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

-- Capture newly created batch ID
SET @new_batch_id = LAST_INSERT_ID();

-- Step 2: Register start event
INSERT INTO production_events (
    batch_id,
    event_type,
    event_time,
    description
) VALUES (
    @new_batch_id,
    'start',
    NOW(),
    'Batch started automatically'
);

-- If all OK, save permanently
COMMIT;

-- Verify ALL was saved
SELECT * FROM production_batches WHERE batch_code = 'BATCH_2026_200';
SELECT * FROM production_events WHERE batch_id = @new_batch_id;
```

**Explanation**:
- `START TRANSACTION`: Begins atomic block
- `LAST_INSERT_ID()`: Captures auto-generated ID
- `COMMIT`: Makes changes permanent and durable
- If any INSERT fails → everything is automatically discarded

**Key Concept**: ALL or NOTHING. Cannot have batch without event or event without batch.

**ACID Demonstrated**:
- ✅ **A**tomicity: 2 INSERTs are indivisible unit
- ✅ **C**onsistency: Foreign keys remain valid
- ✅ **D**urability: Post-COMMIT, data survives power failure

---

### 6. ROLLBACK Transaction (Error Handling)

**Pedagogical Goal**: Demonstrate error recovery

```sql
-- Transaction that will FAIL intentionally
START TRANSACTION;

-- Step 1: Valid INSERT
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

-- Step 2: INSERT that VIOLATES constraint (quality > 10)
INSERT INTO quality_inspections (
    batch_id,
    inspector_name,
    quality_score,  -- ❌ Try to put 15 (max is 10)
    inspection_time
) VALUES (
    @fail_batch_id,
    'Inspector Test',
    15.0,  -- ❌ INVALID
    NOW()
);

-- This COMMIT will never be reached due to previous error
COMMIT;
```

**What Happens**:
```
ERROR 3819 (HY000): Check constraint 'quality_inspections_chk_1' is violated.
```

**After Error**:
```sql
-- Verify: batch does NOT exist (automatic ROLLBACK)
SELECT * FROM production_batches WHERE batch_code = 'BATCH_2026_FAIL';
-- Result: 0 rows
```

**Key Concept**: Error → automatic ROLLBACK. System prevents data corruption.

---

### 7. Foreign Key Constraint Violation

**Pedagogical Goal**: Understand referential integrity

```sql
-- Try to delete production line with dependent batches
DELETE FROM production_lines WHERE id = 1;
```

**Expected Error**:
```
ERROR 1451 (23000): Cannot delete or update a parent row: 
a foreign key constraint fails (`iiot_db`.`production_batches`, 
CONSTRAINT `production_batches_ibfk_1` FOREIGN KEY (`line_id`) 
REFERENCES `production_lines` (`id`))
```

**Visual Explanation**:
```
production_lines (PARENT)          production_batches (CHILD)
┌────┬───────────┐                 ┌────┬─────────┐
│ 1  │ Line A    │ ← FK ─────────┤ ...│    1    │
└────┴───────────┘                 └────┴─────────┘
     ↑                                   │
     └─ CANNOT DELETE              Has
        while references           dependencies
        exist
```

**Correct Solution**:
```sql
-- Option 1: Delete dependencies first
DELETE FROM production_batches WHERE line_id = 1;
DELETE FROM production_lines WHERE id = 1;

-- Option 2: Use CASCADE (if FK was defined with ON DELETE CASCADE)
-- Would delete line AND batches automatically

-- Option 3: UPDATE instead of DELETE
UPDATE production_batches SET line_id = 2 WHERE line_id = 1;
DELETE FROM production_lines WHERE id = 1;
```

**Key Concept**: Database is security guard that prevents orphans.

---

### 8. Stored Procedure (Complex Logic)

**Pedagogical Goal**: Encapsulate business logic in DB

```sql
-- Call existing stored procedure
CALL sp_create_batch_with_validation(
    1,                    -- line_id
    'BATCH_2026_300',     -- batch_code
    'Widget Deluxe',      -- product_name  
    2500,                 -- target_quantity
    8.0                   -- quality_threshold
);
```

**View procedure definition** (optional, to understand internals):
```sql
SHOW CREATE PROCEDURE sp_create_batch_with_validation;
```

**What It Does Internally**:
1. Validates that `line_id` exists
2. Validates that `batch_code` is not duplicated
3. Validates that `quality_threshold` is between 0-10
4. If all OK: INSERT batch + INSERT event in transaction
5. If any validation fails: ROLLBACK with error message

**Advantages**:
- ✅ Centralized logic (no repetition in each app)
- ✅ Performance (executes server-side)
- ✅ Security (users only execute procedure, no direct access)

**Key Concept**: Stored procedures = functions that live in the DB.

---

### 9. VIEW (Virtual Table)

**Pedagogical Goal**: Simplify recurring complex queries

```sql
-- Use pre-defined view
SELECT * FROM v_production_summary;
```

**Result**:
```
batch_code       | line_name | product_name | status      | total_quantity | inspections_count | avg_quality
-----------------|-----------|--------------|-------------|----------------|-------------------|-------------
BATCH_2026_001   | Line A    | Widget A     | completed   | 1500           | 2                 | 8.50
BATCH_2026_002   | Line A    | Widget B     | in_progress | 750            | 1                 | 9.00
...
```

**View definition**:
```sql
SHOW CREATE VIEW v_production_summary;
```

**Internally**:
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

**Key Concept**: VIEW = saved query as if it were a table. Doesn't store data, executes query each time.

---

### 10. Query with JSON Parsing (MQTT Logs)

**Pedagogical Goal**: Handle semi-structured data in SQL

```sql
-- Extract average temperature from logged MQTT messages
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

**Explanation**:
- `JSON_EXTRACT(payload, '$.value')`: Extracts 'value' field from JSON
- `CAST(... AS DECIMAL)`: Converts text to number
- Groups by day for daily summary

**Result**:
```
date       | topic                    | message_count | avg_value | min_value | max_value
-----------|--------------------------|---------------|-----------|-----------|----------
2026-02-03 | iiot/sensors/temperature | 86400         | 65.34     | 20.15     | 99.87
2026-02-02 | iiot/sensors/temperature | 86400         | 64.92     | 20.45     | 98.34
```

**Key Concept**: SQL can handle JSON but not optimal (vs document DB). Useful for logs/audit.

---

## ⏰ InfluxDB Queries (Flux)

### 1. Basic Time-Series Query

**Pedagogical Goal**: Basic Flux structure

```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
```

**Line-by-Line Explanation**:
- `from(bucket: ...)`: Data source (equivalent to FROM table)
- `|>`: Pipe operator - passes result to next function
- `range(start: -1h)`: Temporal filter (last hour)
- `filter()`: Additional filters (measurement = sensor type, field = column)

**Result**:
```
_time                _measurement  _field  _value  sensor_id
-------------------  ------------  ------  ------  ----------
2026-02-03T09:00:00Z temperature   value   65.2    TEMP_001
2026-02-03T09:00:01Z temperature   value   65.5    TEMP_001
2026-02-03T09:00:02Z temperature   value   66.1    TEMP_001
... (3,600 rows)
```

**Key Concept**: Flux is functional - pipeline of chained transformations.

---

### 2. Temporal Aggregation (Mean)

**Pedagogical Goal**: Summarize data in temporal window

```flux
from(bucket: "iiot_sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> mean()
```

**Result**:
```
_value
------
65.34
```

**Explanation**:
- `mean()`: Average of ALL values in range
- Without `group()`: Aggregates everything into single value
- Processes ~86,400 records (1/sec x 24h) in milliseconds

**Variations**:
```flux
// Other aggregations
|> max()  // Maximum
|> min()  // Minimum
|> count()  // Record count
|> sum()  // Total sum
|> median()  // Median
|> stddev()  // Standard deviation
```

**Key Concept**: Simple aggregations very fast by columnar design.

---

### 3. Aggregated Windows (Downsampling)

**Pedagogical Goal**: Reduce temporal resolution

```flux
from(bucket: "iiot_sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
```

**Explanation**:
- `aggregateWindow(every: 5m)`: Groups into 5-minute windows
- `fn: mean`: Calculates average of each window
- `createEmpty: false`: Omits windows without data

**Result**:
```
_time                _value
-------------------  ------
2026-02-03T09:00:00Z 65.2
2026-02-03T09:05:00Z 65.8
2026-02-03T09:10:00Z 64.9
... (288 rows for 24h)
```

**Reduction**: 86,400 records → 288 records (300x less)

**Real Use**: Long historical charts without saturating frontend

**Key Concept**: Downsampling = sacrifice detail for performance.

---

### 4. Multiple Sensors (Group By)

**Pedagogical Goal**: Handle multiple time series

```flux
from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature" or r["_measurement"] == "pressure")
  |> filter(fn: (r) => r["_field"] == "value")
  |> group(columns: ["_measurement", "sensor_id"])
  |> mean()
```

**Result**:
```
_measurement  sensor_id    _value
------------  ----------   ------
temperature   TEMP_001     65.34
pressure      PRES_001     3.42
```

**Explanation**:
- `group()`: Groups by measurement and sensor before aggregating
- Without `group()`: Would mix temperatures and pressures (invalid)

**Key Concept**: Time series are independent, group for correct operations.

---

### 5. Anomaly Detection (Threshold)

**Pedagogical Goal**: Threshold-based alerts

```flux
from(bucket: "iiot_sensors")
  |> range(start: -15m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["_value"] > 80.0)  // 🚨 Critical threshold
  |> count()
```

**Result**:
```
_value
------
15  // 15 readings over 80°C in last 15 min
```

**Real Use**: Alert trigger

**Variation - List All Anomalies**:
```flux
from(bucket: "iiot_sensors")
  |> range(start: -15m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["_value"] > 80.0)
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 10)
```

**Key Concept**: Post-aggregation filtering for pattern detection.

---

### 6. Derivative (Rate of Change)

**Pedagogical Goal**: Detect abrupt changes

```flux
from(bucket: "iiot_sensors")
  |> range(start: -30m)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> derivative(unit: 1m, nonNegative: false)
  |> filter(fn: (r) => r["_value"] > 5.0 or r["_value"] < -5.0)
```

**Explanation**:
- `derivative()`: Calculates rate of change (°C per minute)
- `nonNegative: false`: Allows negative values (cooling)
- Final filter: Only changes >5°C/min (abrupt)

**Real Use**: Detect sensor failures or abnormal events (open doors, leaks)

**Result**:
```
_time                _value
-------------------  ------
2026-02-03T09:15:32Z  7.2   // ⚠️ Rapid rise
2026-02-03T09:23:15Z -6.8   // ⚠️ Rapid drop
```

**Key Concept**: TSDB facilitates mathematical trend analysis.

---

### 7. Join Multiple Measurements

**Pedagogical Goal**: Correlate different sensors

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

**Result**:
```
_time                temp_value  pressure_value
-------------------  ----------  --------------
2026-02-03T09:00:00Z 65.2        3.42
2026-02-03T09:01:00Z 65.8        3.45
...
```

**Real Use**: Correlation analysis (e.g., high temp + low pressure = leak)

**Key Concept**: Temporal join - align series by timestamp.

---

### 8. Retention and Automatic Downsampling (Task)

**Pedagogical Goal**: Configure automatic aggregation

```flux
// This is a TASK that runs periodically
option task = {name: "downsample_hourly", every: 1h}

from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> aggregateWindow(every: 1m, fn: mean)
  |> to(bucket: "iiot_sensors_hourly")  // Write to long-retention bucket
```

**Explanation**:
- Task executes every hour
- Downsample raw data (1/sec → 1/min)
- Store in separate bucket with retention >1 year
- Original bucket can have short retention (30 days)

**Typical Retention Strategy**:
```
iiot_sensors (raw)          → 30 days   → 1 reading/sec
iiot_sensors_hourly         → 1 year    → 1 reading/min
iiot_sensors_daily          → 5 years   → 1 reading/hour
```

**Key Concept**: Automatic downsampling reduces storage costs 95%+.

---

### 9. Percentiles (Statistical Analysis)

**Pedagogical Goal**: Understand data distribution

```flux
from(bucket: "iiot_sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> quantile(q: 0.95)  // 95th percentile
```

**Result**:
```
_value
------
87.3  // 95% of readings are below 87.3°C
```

**Real Use**: SLA monitoring (e.g., "99% of time, temp < 90°C")

**Variations**:
```flux
|> quantile(q: 0.50)  // Median (50th percentile)
|> quantile(q: 0.99)  // 99th percentile (outliers)
```

**Key Concept**: Percentiles more representative than average for SLAs.

---

### 10. Previous Period Comparison (Time Shift)

**Pedagogical Goal**: Trend analysis

```flux
current = from(bucket: "iiot_sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> mean()

previous = from(bucket: "iiot_sensors")
  |> range(start: -2h, stop: -1h)  // Previous hour
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> mean()

// Compare manually or with join
union(tables: [current, previous])
```

**Result**:
```
_value  _start               _stop
------  -------------------  -------------------
65.3    2026-02-03T08:00:00Z 2026-02-03T09:00:00Z  // Current
64.8    2026-02-03T07:00:00Z 2026-02-03T08:00:00Z  // Previous
```

**Calculate % Change** (requires map):
```flux
// Difference: 65.3 - 64.8 = +0.5°C (+0.77%)
```

**Key Concept**: Time shift to detect ascending/descending trends.

---

## ⚖️ Performance Comparisons

### Scenario: Average of 1 Hour of Data

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

**Benchmark** (3,600 records):
```
┌──────────────┬────────────┬──────────────┐
│ Metric       │ MySQL      │ InfluxDB     │
├──────────────┼────────────┼──────────────┤
│ Query Time   │ 450-800 ms │ 30-80 ms     │
│ CPU Used     │ High       │ Low          │
│ Rows Scanned │ 3,600      │ 3,600        │
│ Storage      │ ~1.2 MB    │ ~0.15 MB     │
└──────────────┴────────────┴──────────────┘

🏆 InfluxDB: 6-10x faster
```

**Why InfluxDB Wins**:
- Columnar compression (consecutive similar values)
- Optimized temporal index (B-tree for timestamps)
- No relational overhead (no JOINs, no FK checks)
- Storage designed for append-only

---

### Scenario: Downsampling 1 Year → 1 Day

**MySQL** (complex):
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

**InfluxDB** (native):
```flux
from(bucket: "iiot_sensors")
  |> range(start: -1y)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> aggregateWindow(every: 1d, fn: mean)
```

**Benchmark** (~31 million records):
```
┌──────────────┬────────────┬──────────────┐
│ Metric       │ MySQL      │ InfluxDB     │
├──────────────┼────────────┼──────────────┤
│ Query Time   │ 30-60 sec  │ 1-3 sec      │
│ Rows Output  │ 365        │ 365          │
│ Complexity   │ High       │ Low          │
└──────────────┴────────────┴──────────────┘

🏆 InfluxDB: 10-20x faster
```

---

### Scenario: Relational JOIN

**MySQL** (strong):
```sql
SELECT pb.batch_code, pl.line_name, COUNT(qi.id) as inspections
FROM production_batches pb
JOIN production_lines pl ON pb.line_id = pl.id
LEFT JOIN quality_inspections qi ON pb.id = qi.batch_id
GROUP BY pb.id, pb.batch_code, pl.line_name;
```

**InfluxDB** (weak - not designed for this):
```flux
// Requires multiple queries and manual join - awkward
```

**Conclusion**:
```
🏆 MySQL: Designed for relational JOINs
   InfluxDB: Possible but not idiomatic
```

---

## 📚 Practice Exercises

### Exercise 1: Basic SQL

**Statement**: Get all events of type 'error' or 'warning' from `system_alerts` table, ordered by severity (highest first).

<details>
<summary>View Solution</summary>

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

### Exercise 2: SQL JOIN

**Statement**: List all batches with more than 2 quality inspections, showing batch_code, inspection count, and average quality.

<details>
<summary>View Solution</summary>

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

### Exercise 3: Flux Aggregation

**Statement**: Calculate maximum, minimum, and average pressure in the last 2 hours.

<details>
<summary>View Solution</summary>

```flux
from(bucket: "iiot_sensors")
  |> range(start: -2h)
  |> filter(fn: (r) => r["_measurement"] == "pressure")
  |> filter(fn: (r) => r["_field"] == "value")
  |> group()
  |> mean()

// For max and min, replace mean() with:
// |> max()
// |> min()

// Or all at once:
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

### Exercise 4: SQL Transaction

**Statement**: Create a transaction that registers a new batch AND its first quality event, ensuring atomicity.

<details>
<summary>View Solution</summary>

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

-- Verify
SELECT * FROM production_batches WHERE batch_code = 'BATCH_EXERCISE';
SELECT * FROM quality_inspections WHERE batch_id = @batch_id;
```
</details>

---

### Exercise 5: Flux Anomaly Detection

**Statement**: Detect all moments in last 30 minutes where temperature changed more than 10°C in 1 minute.

<details>
<summary>View Solution</summary>

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

## 🎯 Final Comparative Summary

| Feature | MySQL | InfluxDB |
|---------|-------|----------|
| **Best for** | Transactions, relationships | Time series |
| **ACID** | ✅ Complete | ⚠️ Eventual consistency |
| **JOINs** | ✅ Excellent | ❌ Limited |
| **Temporal Aggregations** | ⚠️ Slow | ✅ Very fast |
| **Schema** | Rigid | Flexible (schema-less) |
| **Compression** | Manual | Automatic (8-10x) |
| **Query Language** | SQL (mature) | Flux (modern) |
| **Scalability** | Vertical | Horizontal |
| **IIoT Use** | Masters, transactions | Sensors, telemetry |

---

## 📖 Additional Resources

### Official Documentation
- **MySQL**: https://dev.mysql.com/doc/
- **InfluxDB**: https://docs.influxdata.com/
- **Flux**: https://docs.influxdata.com/flux/

### Interactive Tutorials
- **InfluxDB University**: https://university.influxdata.com/ (free)
- **MySQL Tutorial**: https://www.mysqltutorial.org/
- **SQL Zoo**: https://sqlzoo.net/

### Practice Tools
- **Adminer**: Visual MySQL explorer
- **InfluxDB UI**: Integrated Data Explorer
- **Grafana**: Query visualization

---

**Practice these queries in the Docker environment! 🚀**

_The best way to learn is by executing and experimenting._


---
**Version**: 1.0  
**Last Updated**: February 2026  
**Instructor**: Christian Spana
