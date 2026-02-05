-- ==============================================================================
-- INICIALIZACIÓN BASE DE DATOS MYSQL - SISTEMA IIoT
-- ==============================================================================
-- Este script crea las tablas y datos de ejemplo para el sistema IIoT
-- Demuestra conceptos de bases de datos relacionales: ACID, constraints, JOINs
--
-- Curso: Uso de Bases de Datos en Tecnologías de Operación (IIoT)
-- Christian Spana
-- ==============================================================================

-- Usar la base de datos creada automáticamente
USE iiot_db;

-- ==============================================================================
-- TABLA: production_lines
-- Propósito: Almacenar información de las líneas de producción
-- Conceptos: Clave primaria, ENUM, timestamps
-- ==============================================================================

CREATE TABLE IF NOT EXISTS production_lines (
    line_id INT PRIMARY KEY AUTO_INCREMENT,
    line_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(150),
    capacity_units_per_hour INT,
    status ENUM(
        'active',
        'maintenance',
        'offline'
    ) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_line_name (line_name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = 'Líneas de producción de la planta';

-- ==============================================================================
-- TABLA: production_batches
-- Propósito: Registrar lotes de producción
-- Conceptos: Foreign Key, CHECK constraints, integridad referencial
-- ==============================================================================

CREATE TABLE IF NOT EXISTS production_batches (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    line_id INT NOT NULL,
    batch_code VARCHAR(50) UNIQUE NOT NULL,
    product_type VARCHAR(100),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    target_quantity INT NOT NULL,
    actual_quantity INT DEFAULT 0,
    status ENUM('in_progress', 'completed', 'rejected', 'paused') DEFAULT 'in_progress',

-- 🎓 CONSTRAINT: Foreign Key - Integridad Referencial
-- No se puede crear un batch para una línea que no existe
CONSTRAINT fk_batch_line FOREIGN KEY (line_id) REFERENCES production_lines (line_id) ON DELETE RESTRICT -- No permite borrar línea si tiene batches
ON UPDATE CASCADE, -- Si cambia ID de línea, actualiza automáticamente

-- 🎓 CONSTRAINT: CHECK - Validación de Datos
-- Cantidad producida no puede ser negativa
CONSTRAINT chk_actual_quantity CHECK (actual_quantity >= 0),

-- Cantidad producida no puede exceder el 110% del objetivo (margen de error)
CONSTRAINT chk_quantity_limit CHECK (
    actual_quantity <= target_quantity * 1.1
),

-- Objetivo debe ser positivo


CONSTRAINT chk_target_positive 
        CHECK (target_quantity > 0),
    
    INDEX idx_batch_status (status),
    INDEX idx_batch_date (start_time),
    INDEX idx_batch_code (batch_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Lotes de producción';

-- ==============================================================================
-- TABLA: quality_inspections
-- Propósito: Registrar inspecciones de calidad
-- Conceptos: Columnas generadas (computed), CASCADE
-- ==============================================================================

CREATE TABLE IF NOT EXISTS quality_inspections (
    inspection_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT NOT NULL,
    inspection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inspector_name VARCHAR(100),
    quality_score DECIMAL(4,2) NOT NULL,

-- 🎓 COLUMNA GENERADA: Calculada automáticamente
-- passed = true si quality_score >= 7.0
passed BOOLEAN GENERATED ALWAYS AS (quality_score >= 7.0) STORED,
defects_found INT DEFAULT 0,
notes TEXT,

-- 🎓 CONSTRAINT: Foreign Key con CASCADE
-- Si se borra un batch, se borran automáticamente sus inspecciones
CONSTRAINT fk_inspection_batch FOREIGN KEY (batch_id) REFERENCES production_batches (batch_id) ON DELETE CASCADE ON UPDATE CASCADE,

-- Score debe estar entre 0 y 10


CONSTRAINT chk_quality_score 
        CHECK (quality_score BETWEEN 0 AND 10),
    
    CONSTRAINT chk_defects_positive 
        CHECK (defects_found >= 0),
    
    INDEX idx_quality_time (inspection_time),
    INDEX idx_quality_passed (passed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Inspecciones de calidad';

-- ==============================================================================
-- TABLA: production_events
-- Propósito: Audit trail de eventos de producción
-- Conceptos: Logging, trazabilidad, historical data
-- ==============================================================================

CREATE TABLE IF NOT EXISTS production_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT NOT NULL,
    event_type ENUM(
        'start',
        'pause',
        'resume',
        'stop',
        'quality_check',
        'maintenance',
        'error'
    ) NOT NULL,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity_at_event INT,
    operator_id VARCHAR(50),
    event_description TEXT,
    CONSTRAINT fk_event_batch FOREIGN KEY (batch_id) REFERENCES production_batches (batch_id) ON DELETE CASCADE,
    INDEX idx_event_type (event_type),
    INDEX idx_event_time (event_time),
    INDEX idx_event_operator (operator_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = 'Registro de eventos de producción';

-- ==============================================================================
-- TABLA: system_alerts
-- Propósito: Almacenar alertas generadas por el sistema (Polyglot Integration)
-- Conceptos: Integración MQTT → InfluxDB → MySQL
-- ==============================================================================

CREATE TABLE IF NOT EXISTS system_alerts (
    alert_id INT PRIMARY KEY AUTO_INCREMENT,
    alert_source ENUM(
        'mqtt',
        'scheduled',
        'manual',
        'sensor'
    ) DEFAULT 'mqtt',
    alert_type ENUM(
        'high_temperature',
        'high_pressure',
        'low_quality',
        'equipment_failure',
        'other'
    ) NOT NULL,
    severity ENUM(
        'low',
        'medium',
        'high',
        'critical'
    ) DEFAULT 'medium',
    mqtt_topic VARCHAR(200),
    sensor_id VARCHAR(100),
    alert_value DECIMAL(10, 2),
    threshold_value DECIMAL(10, 2),
    alert_message TEXT,
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by VARCHAR(100),
    acknowledged_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_alert_source (alert_source),
    INDEX idx_alert_severity (severity),
    INDEX idx_alert_ack (acknowledged),
    INDEX idx_alert_time (created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = 'Alertas del sistema IIoT';

-- ==============================================================================
-- TABLA: sensor_metadata
-- Propósito: Metadatos de configuración de sensores
-- Conceptos: Datos de referencia, configuración
-- ==============================================================================

CREATE TABLE IF NOT EXISTS sensor_metadata (
    sensor_id VARCHAR(100) PRIMARY KEY,
    sensor_type ENUM(
        'temperature',
        'pressure',
        'vibration',
        'flow',
        'level',
        'other'
    ) NOT NULL,
    location VARCHAR(200),
    line_id INT,
    unit_of_measure VARCHAR(20),
    min_value DECIMAL(10, 2),
    max_value DECIMAL(10, 2),
    calibration_date DATE,
    next_calibration_date DATE,
    status ENUM(
        'active',
        'maintenance',
        'faulty',
        'offline'
    ) DEFAULT 'active',
    notes TEXT,
    CONSTRAINT fk_sensor_line FOREIGN KEY (line_id) REFERENCES production_lines (line_id) ON DELETE SET NULL,
    INDEX idx_sensor_type (sensor_type),
    INDEX idx_sensor_status (status)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = 'Metadatos y configuración de sensores';

-- ==============================================================================
-- TABLA: mqtt_messages_log (Opcional - para auditoría)
-- Propósito: Log de mensajes MQTT críticos para auditoría
-- Conceptos: Logging selectivo, compliance
-- ==============================================================================

CREATE TABLE IF NOT EXISTS mqtt_messages_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    topic VARCHAR(300) NOT NULL,
    payload JSON,
    qos TINYINT,
    retained BOOLEAN DEFAULT FALSE,
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_log_topic (topic),
    INDEX idx_log_time (received_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = 'Log de mensajes MQTT para auditoría';

-- ==============================================================================
-- INSERTAR DATOS DE EJEMPLO
-- ==============================================================================

-- Líneas de Producción
INSERT INTO
    production_lines (
        line_name,
        location,
        capacity_units_per_hour,
        status
    )
VALUES (
        'Línea Ensamblaje A',
        'Planta Principal - Piso 1',
        150,
        'active'
    ),
    (
        'Línea Empaque B',
        'Planta Principal - Piso 2',
        200,
        'active'
    ),
    (
        'Línea Control Calidad',
        'Planta Principal - Piso 1',
        100,
        'active'
    );

-- Batches de Producción
INSERT INTO
    production_batches (
        line_id,
        batch_code,
        product_type,
        start_time,
        end_time,
        target_quantity,
        actual_quantity,
        status
    )
VALUES (
        1,
        'BATCH_2026_001',
        'Producto A',
        '2026-02-01 08:00:00',
        '2026-02-01 16:00:00',
        1000,
        1005,
        'completed'
    ),
    (
        1,
        'BATCH_2026_002',
        'Producto A',
        '2026-02-02 08:00:00',
        '2026-02-02 16:00:00',
        1000,
        998,
        'completed'
    ),
    (
        2,
        'BATCH_2026_003',
        'Producto B',
        '2026-02-01 08:00:00',
        '2026-02-01 14:00:00',
        1200,
        1195,
        'completed'
    ),
    (
        2,
        'BATCH_2026_004',
        'Producto B',
        '2026-02-02 08:00:00',
        NULL,
        1200,
        450,
        'in_progress'
    ),
    (
        3,
        'BATCH_2026_005',
        'Producto C',
        '2026-02-01 09:00:00',
        '2026-02-01 17:00:00',
        800,
        650,
        'rejected'
    ),
    (
        1,
        'BATCH_2026_006',
        'Producto A',
        '2026-02-03 08:00:00',
        NULL,
        1000,
        320,
        'in_progress'
    ),
    (
        2,
        'BATCH_2026_007',
        'Producto B',
        '2026-02-03 08:00:00',
        '2026-02-03 12:00:00',
        1200,
        1198,
        'completed'
    ),
    (
        3,
        'BATCH_2026_008',
        'Producto C',
        '2026-02-03 10:00:00',
        NULL,
        800,
        0,
        'paused'
    );

-- Inspecciones de Calidad
INSERT INTO
    quality_inspections (
        batch_id,
        inspection_time,
        inspector_name,
        quality_score,
        defects_found,
        notes
    )
VALUES (
        1,
        '2026-02-01 16:30:00',
        'María González',
        9.2,
        3,
        'Calidad excelente, defectos menores'
    ),
    (
        2,
        '2026-02-02 16:30:00',
        'Juan Pérez',
        8.5,
        8,
        'Buena calidad, algunos ajustes necesarios'
    ),
    (
        3,
        '2026-02-01 14:30:00',
        'María González',
        8.9,
        5,
        'Muy buena calidad'
    ),
    (
        4,
        '2026-02-02 12:00:00',
        'Carlos Ruiz',
        7.8,
        12,
        'Calidad aceptable, monitorear próximo batch'
    ),
    (
        5,
        '2026-02-01 17:30:00',
        'María González',
        5.5,
        45,
        'Calidad inaceptable, batch rechazado'
    ),
    (
        5,
        '2026-02-01 17:45:00',
        'Supervisor García',
        5.2,
        50,
        'Confirmado: batch rechazado, investigar causa raíz'
    ),
    (
        7,
        '2026-02-03 12:30:00',
        'Juan Pérez',
        9.5,
        2,
        'Excelente calidad, proceso optimizado'
    );

-- Eventos de Producción
INSERT INTO
    production_events (
        batch_id,
        event_type,
        event_time,
        quantity_at_event,
        operator_id,
        event_description
    )
VALUES (
        1,
        'start',
        '2026-02-01 08:00:00',
        0,
        'OP001',
        'Inicio de batch'
    ),
    (
        1,
        'quality_check',
        '2026-02-01 12:00:00',
        500,
        'QC001',
        'Inspección intermedia - OK'
    ),
    (
        1,
        'stop',
        '2026-02-01 16:00:00',
        1005,
        'OP001',
        'Batch completado exitosamente'
    ),
    (
        2,
        'start',
        '2026-02-02 08:00:00',
        0,
        'OP002',
        'Inicio de batch'
    ),
    (
        2,
        'pause',
        '2026-02-02 10:30:00',
        350,
        'OP002',
        'Pausa para mantenimiento preventivo'
    ),
    (
        2,
        'resume',
        '2026-02-02 11:00:00',
        350,
        'OP002',
        'Reanudación después de mantenimiento'
    ),
    (
        2,
        'stop',
        '2026-02-02 16:00:00',
        998,
        'OP002',
        'Batch completado'
    ),
    (
        5,
        'start',
        '2026-02-01 09:00:00',
        0,
        'OP003',
        'Inicio de batch'
    ),
    (
        5,
        'error',
        '2026-02-01 14:00:00',
        500,
        'OP003',
        'Error en proceso - calidad fuera de especificación'
    ),
    (
        5,
        'stop',
        '2026-02-01 17:00:00',
        650,
        'OP003',
        'Batch detenido y rechazado'
    ),
    (
        6,
        'start',
        '2026-02-03 08:00:00',
        0,
        'OP001',
        'Inicio de batch'
    ),
    (
        8,
        'start',
        '2026-02-03 10:00:00',
        0,
        'OP003',
        'Inicio de batch'
    ),
    (
        8,
        'pause',
        '2026-02-03 10:30:00',
        0,
        'OP003',
        'Pausado - falta de materia prima'
    );

-- Metadatos de Sensores
INSERT INTO
    sensor_metadata (
        sensor_id,
        sensor_type,
        location,
        line_id,
        unit_of_measure,
        min_value,
        max_value,
        calibration_date,
        next_calibration_date,
        status
    )
VALUES (
        'TEMP_001',
        'temperature',
        'Línea Ensamblaje A - Zona 1',
        1,
        '°C',
        0,
        150,
        '2026-01-15',
        '2026-07-15',
        'active'
    ),
    (
        'PRESS_001',
        'pressure',
        'Sistema Hidráulico - Línea A',
        1,
        'bar',
        0,
        300,
        '2026-01-20',
        '2026-07-20',
        'active'
    ),
    (
        'VIB_001',
        'vibration',
        'Motor Principal - Línea A',
        1,
        'mm/s',
        0,
        20,
        '2026-01-10',
        '2026-07-10',
        'active'
    ),
    (
        'TEMP_002',
        'temperature',
        'Línea Empaque B - Zona 2',
        2,
        '°C',
        0,
        150,
        '2026-01-15',
        '2026-07-15',
        'active'
    ),
    (
        'FLOW_001',
        'flow',
        'Sistema Neumático - Línea B',
        2,
        'L/min',
        0,
        500,
        '2026-01-25',
        '2026-07-25',
        'active'
    );

-- Alertas de Ejemplo
INSERT INTO
    system_alerts (
        alert_source,
        alert_type,
        severity,
        mqtt_topic,
        sensor_id,
        alert_value,
        threshold_value,
        alert_message,
        acknowledged
    )
VALUES (
        'mqtt',
        'high_temperature',
        'high',
        'iiot/sensors/temperature',
        'TEMP_001',
        95.5,
        90.0,
        'Temperatura excede umbral en Línea A',
        FALSE
    ),
    (
        'mqtt',
        'high_pressure',
        'medium',
        'iiot/sensors/pressure',
        'PRESS_001',
        235.8,
        230.0,
        'Presión ligeramente elevada en sistema hidráulico',
        TRUE
    ),
    (
        'scheduled',
        'low_quality',
        'critical',
        NULL,
        NULL,
        5.5,
        7.0,
        'Calidad de BATCH_2026_005 por debajo del umbral',
        TRUE
    );

-- ==============================================================================
-- VISTAS ÚTILES PARA CONSULTAS COMUNES
-- ==============================================================================

-- Vista: Resumen de Producción por Línea
CREATE OR REPLACE VIEW v_production_summary AS
SELECT
    pl.line_name,
    pl.status AS line_status,
    COUNT(DISTINCT pb.batch_id) AS total_batches,
    SUM(pb.actual_quantity) AS total_units_produced,
    AVG(qi.quality_score) AS avg_quality_score,
    COUNT(
        CASE
            WHEN pb.status = 'completed' THEN 1
        END
    ) AS completed_batches,
    COUNT(
        CASE
            WHEN pb.status = 'rejected' THEN 1
        END
    ) AS rejected_batches
FROM
    production_lines pl
    LEFT JOIN production_batches pb ON pl.line_id = pb.line_id
    LEFT JOIN quality_inspections qi ON pb.batch_id = qi.batch_id
GROUP BY
    pl.line_id,
    pl.line_name,
    pl.status;

-- Vista: Alertas Pendientes
CREATE OR REPLACE VIEW v_pending_alerts AS
SELECT
    alert_id,
    alert_type,
    severity,
    sensor_id,
    alert_value,
    threshold_value,
    alert_message,
    created_at,
    TIMESTAMPDIFF(MINUTE, created_at, NOW()) AS minutes_since_alert
FROM system_alerts
WHERE
    acknowledged = FALSE
ORDER BY severity DESC, created_at DESC;

-- ==============================================================================
-- PROCEDIMIENTO ALMACENADO: Ejemplo de Transacción ACID
-- ==============================================================================

DELIMITER $$

CREATE PROCEDURE sp_create_batch_with_validation(
    IN p_line_id INT,
    IN p_batch_code VARCHAR(50),
    IN p_product_type VARCHAR(100),
    IN p_target_quantity INT,
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 🎓 ROLLBACK: Si hay error, deshacer todos los cambios
        ROLLBACK;
        SET p_result = 'ERROR: Transaction rolled back';
    END;
    
    -- 🎓 START TRANSACTION: Inicio de transacción ACID
    START TRANSACTION;
    
    -- Validar que la línea existe y está activa
    IF NOT EXISTS (SELECT 1 FROM production_lines WHERE line_id = p_line_id AND status = 'active') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Línea no existe o no está activa';
    END IF;
    
    -- Insertar batch
    INSERT INTO production_batches (line_id, batch_code, product_type, target_quantity, status)
    VALUES (p_line_id, p_batch_code, p_product_type, p_target_quantity, 'in_progress');
    
    -- Registrar evento de inicio
    INSERT INTO production_events (batch_id, event_type, quantity_at_event, event_description)
    VALUES (LAST_INSERT_ID(), 'start', 0, CONCAT('Batch ', p_batch_code, ' iniciado automáticamente'));
    
    -- 🎓 COMMIT: Si todo OK, confirmar cambios permanentemente
    COMMIT;
    SET p_result = CONCAT('SUCCESS: Batch ', p_batch_code, ' created with ID ', LAST_INSERT_ID());
END$$

DELIMITER;

-- ==============================================================================
-- COMENTARIOS FINALES
-- ==============================================================================

-- Este esquema demuestra conceptos clave de bases de datos relacionales:
--
-- 1. ACID PROPERTIES:
--    - Atomicity: Transacciones completas o nada (ver stored procedure)
--    - Consistency: Constraints aseguran datos válidos
--    - Isolation: Múltiples usuarios sin interferencia
--    - Durability: Datos persisten después de commit
--
-- 2. INTEGRIDAD REFERENCIAL:
--    - Foreign Keys previenen datos huérfanos
--    - CASCADE mantiene consistencia automática
--    - RESTRICT previene borrados problemáticos
--
-- 3. VALIDACIÓN DE DATOS:
--    - CHECK constraints validan valores
--    - ENUM limita opciones
--    - Columnas generadas calculan valores automáticamente
--
-- 4. OPTIMIZACIÓN:
--    - Índices en columnas frecuentemente consultadas
--    - Vistas para queries comunes
--    - Procedimientos almacenados para lógica reutilizable
--
-- Para más información, consultar README.md del proyecto

-- 🎓 Mensaje para estudiantes:
SELECT '¡Esquema de base de datos creado exitosamente!' AS mensaje, 'Ahora puedes ejecutar consultas de ejemplo en CONSULTAS-EJEMPLO.md' AS siguiente_paso;