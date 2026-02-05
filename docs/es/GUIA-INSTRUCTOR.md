# Guía del Instructor - Bases de Datos en IIoT

**Curso**: Uso de Bases de Datos Relacionales y No Relacionales en Tecnologías de Operación (IIoT)  
**Duración**: 60 minutos  
**Público**: Estudiantes 7mo año - Ingeniería Electrónica  
**Universidad**: Ecuador

---

## 🎯 Introducción para el Instructor

Esta guía proporciona todo lo necesario para impartir una clase efectiva sobre bases de datos en IIoT, incluyendo:

- ✅ Estructura cronológica detallada (60 minutos)
- ✅ Contenido sugerido para 15-20 diapositivas
- ✅ Notas pedagógicas por sección
- ✅ Analogías probadas para conceptos complejos
- ✅ Script de demostración en vivo (15 min)
- ✅ Manejo de preguntas frecuentes
- ✅ Troubleshooting durante presentación
- ✅ Material de evaluación

### Objetivos de Aprendizaje

Al finalizar esta clase, los estudiantes podrán:

1. **Identificar** las diferencias entre bases de datos SQL y NoSQL
2. **Explicar** el concepto de Polyglot Persistence y su aplicación en IIoT
3. **Seleccionar** el tipo de base de datos apropiado según características de los datos
4. **Comprender** las propiedades ACID y su importancia en sistemas transaccionales
5. **Aplicar** MQTT como protocolo de comunicación en arquitecturas IIoT

---

## 📅 Preparación Pre-Clase

### 1-2 Días Antes

- [ ] Revisar esta guía completa
- [ ] Descargar/clonar proyecto Docker
- [ ] Ejecutar `docker compose up -d` para test inicial
- [ ] Verificar acceso a todos servicios (Node-RED, Grafana, Adminer, InfluxDB UI)
- [ ] Familiarizarse con flujos de Node-RED
- [ ] Probar queries de ejemplo en MySQL y InfluxDB
- [ ] Preparar presentación desde diapositivas sugeridas (PowerPoint/Google Slides)
- [ ] Preparar computadora: abrir tabs en navegador, clipboard con queries

### 30 Minutos Antes de Clase

- [ ] Iniciar sistema Docker: `docker compose up -d`
- [ ] Verificar todos servicios healthy: `docker compose ps`
- [ ] Abrir en navegador:
  - Node-RED: http://localhost:1880
  - Grafana: http://localhost:3000 (login admin/admin)
  - Adminer: http://localhost:8080
  - InfluxDB UI: http://localhost:8086
- [ ] Abrir terminal con `mosquitto_sub` listo
- [ ] Tener queries de ejemplo en clipboard/notepad
- [ ] Proyector/pantalla conectado y probado
- [ ] Audio funcionando (si hay videos)

### Plan de Contingencia

**Si demo falla:**
- Usar screenshots pre-capturados
- Mostrar videos cortos pre-grabados
- Walkthrough de código sin ejecución
- Extender sección teórica y Q&A

---

## ⏱️ Estructura de Clase (60 minutos)

### Plan A - Ideal (60 min disponibles)

| Tiempo | Sección | Contenido | Slides |
|--------|---------|-----------|--------|
| 0-5 min | **Introducción** | Contexto IIoT, Industria 4.0, objetivos | 1-3 |
| 5-20 min | **SQL** | Modelo relacional, ACID, cuándo usar | 4-8 |
| 20-35 min | **NoSQL** | Tipos, TSDB, cuándo usar | 9-13 |
| 35-40 min | **Polyglot** | Arquitectura híbrida, MQTT | 14-16 |
| 40-55 min | **Demo LIVE** | 🔴 Sistema funcionando en tiempo real | - |
| 55-60 min | **Q&A** | Preguntas y cierre | 17-20 |

### Plan B - Ajustado (55 min efectivos)

Si SQL/NoSQL se extienden:

| Tiempo | Sección | Ajuste |
|--------|---------|--------|
| 0-5 min | Intro | Mantener |
| 5-17 min | SQL | Reducir ejemplos (-3 min) |
| 17-29 min | NoSQL | Focus solo TSDB (-3 min) |
| 29-32 min | Polyglot | Más conciso (-2 min) |
| 32-50 min | Demo | **PRIORIDAD** - extender (+3 min) |
| 50-55 min | Q&A | Mantener |

### Plan C - Emergencia (demo falla)

- 0-40 min: Teoría completa (slides con screenshots)
- 40-50 min: Videos pre-grabados (2-3 min c/u)
- 50-60 min: Q&A extendido

---

## 📊 Contenido Diapositivas Sugeridas

### **SLIDE 1: Portada**

```
┌─────────────────────────────────────────┐
│  Uso de Bases de Datos Relacionales    │
│   y No Relacionales en Tecnologías     │
│     de Operación (IIoT)                 │
│                                         │
│  Universidad Ecuador                    │
│  7mo Año - Ingeniería Electrónica      │
│                                         │
│  [Logo Universidad]                     │
│                                         │
│  Instructor: [Nombre]                   │
│  Fecha: [DD/MM/YYYY]                    │
└─────────────────────────────────────────┘
```

**Nota Instructor**: Presentarse brevemente (30 seg). Mencionar experiencia en IIoT si aplica.

---

### **SLIDE 2: Agenda**

```
📋 Agenda (60 minutos)

1. Introducción: IIoT e Industria 4.0 (5 min)
2. Bases de Datos Relacionales (15 min)
   • Modelo SQL
   • Propiedades ACID
   • Casos de uso en IIoT
3. Bases de Datos NoSQL (15 min)
   • Tipos de NoSQL
   • Time-Series Databases
   • Ventajas para IIoT
4. Polyglot Persistence (5 min)
   • Arquitectura híbrida
   • MQTT en IIoT
5. Demostración en Vivo (15 min) 🔴
6. Preguntas y Respuestas (5 min)
```

**Nota Instructor**: "Tendremos demostración LIVE de un sistema IIoT real funcionando. La parte más importante es ver cómo trabajan juntas estas tecnologías."

---

### **SLIDE 3: Contexto - Industria 4.0 e IIoT**

```
🏭 La Revolución de los Datos Industriales

INDUSTRIA 4.0
┌──────────────────────────────────────┐
│ Mundo Físico + Mundo Digital        │
│                                      │
│ • Fábricas inteligentes              │
│ • Mantenimiento predictivo           │
│ • Optimización en tiempo real        │
│ • Gemelos digitales                  │
└──────────────────────────────────────┘

IIoT: Industrial Internet of Things
• 75 mil millones de dispositivos para 2025
• Millones de sensores generando datos 24/7
• Desafío: ¿Cómo almacenar y analizar?

💡 Esta clase: Soluciones prácticas de BD
```

**Imagen sugerida**: Fábrica con sensores destacados, conexiones de red

**Nota Instructor**: 
- Mencionar ejemplos locales Ecuador: agricultura inteligente, monitoreo ambiental Galápagos, industria petrolera
- Conectar con realidad: "Sus celulares tienen sensores (acelerómetro, GPS). Multipliquen eso x 1000 en una fábrica."
- Pregunta retórica: "¿Cuántos datos genera una fábrica en un día? Miles de millones de registros."

---

### **SLIDE 4: Tipos de Datos Industriales**

```
📊 Clasificación de Datos en IIoT

┌──────────────────┬─────────────────┬──────────────────┐
│ TIPO DE DATOS    │ EJEMPLOS        │ CARACTERÍSTICAS  │
├──────────────────┼─────────────────┼──────────────────┤
│ Series de Tiempo │ Temperatura     │ • Alta frecuencia│
│ (Time-Series)    │ Presión         │ • Dependen tiempo│
│                  │ Vibración       │ • Gran volumen   │
│                  │ Corriente       │ • Continuo       │
├──────────────────┼─────────────────┼──────────────────┤
│ Transaccionales  │ Producción      │ • Baja frecuencia│
│ Estructurados    │ Lotes           │ • Estructura fija│
│                  │ Calidad         │ • Integridad ACID│
│                  │ Eventos         │ • Discreto       │
├──────────────────┼─────────────────┼──────────────────┤
│ Configuración    │ Sensores        │ • Pocos cambios  │
│ Metadatos        │ Máquinas        │ • Jerárquico     │
│                  │ Recetas         │ • Referencia     │
└──────────────────┴─────────────────┴──────────────────┘

🎯 Cada tipo requiere diferente estrategia de almacenamiento
```

**Nota Instructor**:
- "Imaginen termómetro: registra temperatura cada segundo. Eso es time-series."
- "Ahora imaginen orden de producción: se crea una vez, tiene número único, estado. Eso es transaccional."
- Preguntar a clase: "¿Qué tipo de dato es la ubicación de un sensor? [Respuesta: Configuración/Metadata]"

---

### **SLIDE 5: Bases de Datos Relacionales - Modelo SQL**

```
🗄️ Bases de Datos Relacionales (SQL)

CARACTERÍSTICAS CLAVE
┌─────────────────────────────────────┐
│ ✓ Modelo: Tablas, Filas, Columnas  │
│ ✓ Esquema: Rígido, definido        │
│ ✓ Relaciones: Foreign Keys (JOINs) │
│ ✓ Integridad: Propiedades ACID     │
│ ✓ Escalabilidad: Vertical (↑ RAM)  │
└─────────────────────────────────────┘

EJEMPLOS POPULARES
MySQL • PostgreSQL • SQL Server • Oracle

APLICACIÓN EN IIoT
• Datos de producción (lotes, unidades)
• Información maestra (máquinas, usuarios)
• Eventos transaccionales (inicio/fin)
• Gestión de calidad (inspecciones)
```

**Diagrama sugerido**: Tabla SQL simple con FK visual

**Nota Instructor**:
- "SQL lleva 50+ años. Es maduro, confiable, probado."
- "Como una hoja Excel pero con superpoderes: validaciones automáticas, relaciones garantizadas."
- Mencionar: "En Ecuador, bancos usan SQL. ¿Por qué? Necesitan garantías de que su dinero no desaparece."

---

### **SLIDE 6-7: ACID - El Corazón de SQL**

```
💳 Propiedades ACID - Garantías Transaccionales

╔═══════════════════════════════════════════════════╗
║ A - ATOMICIDAD (Atomicity)                        ║
╠═══════════════════════════════════════════════════╣
║ Todo o Nada                                       ║
║ Ejemplo: Transferencia bancaria                   ║
║   ✓ Débito Cuenta A + Crédito Cuenta B           ║
║   ✗ Si falla crédito → Rollback completo         ║
╚═══════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════╗
║ C - CONSISTENCIA (Consistency)                    ║
╠═══════════════════════════════════════════════════╣
║ Reglas siempre válidas                           ║
║ Ejemplo: Saldo no puede ser negativo             ║
║   ✓ Constraints previenen estados inválidos      ║
║   ✗ DELETE bloqueado si viola Foreign Key        ║
╚═══════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════╗
║ I - AISLAMIENTO (Isolation)                       ║
╠═══════════════════════════════════════════════════╣
║ Transacciones no interfieren                     ║
║ Ejemplo: 2 personas en ATM simultáneos           ║
║   ✓ Cada uno ve su propia transacción            ║
╚═══════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════╗
║ D - DURABILIDAD (Durability)                      ║
╠═══════════════════════════════════════════════════╣
║ COMMIT = Permanente                              ║
║ Ejemplo: Apagón después de COMMIT                ║
║   ✓ Datos sobreviven fallo eléctrico             ║
╚═══════════════════════════════════════════════════╝
```

**SLIDE 7: ACID en Producción Industrial**

```
🏭 ACID en IIoT - Ejemplo Práctico

ESCENARIO: Registro de Lote de Producción

START TRANSACTION;
  
  -- 1. Crear lote
  INSERT INTO production_batches (line_id, batch_code, ...)
  VALUES (1, 'BATCH_2026_010', ...);
  
  -- 2. Registrar evento de inicio
  INSERT INTO production_events (batch_id, event_type, ...)
  VALUES (LAST_INSERT_ID(), 'start', ...);
  
  -- 3. Si quality_check FALLA...
  IF quality_score < 7.0 THEN
    ROLLBACK;  -- ⬅️ ATOMICIDAD: Deshacer TODO
  ELSE
    COMMIT;    -- ✅ Guardar permanentemente
  END IF;

🎯 Sin ACID: Podríamos tener lotes sin eventos
               o eventos sin lotes = CAOS
```

**Nota Instructor**:
- **Analogía estrella**: "Pagar cuenta en restaurante con amigos, dividir proporcional. Si un amigo no puede pagar su parte, TODA la transacción se cancela. Eso es Atomicidad."
- Luego preguntar: "¿Qué pasaría sin ACID en producción? Caos: órdenes huérfanas, inventario inconsistente, auditorías imposibles."
- **Demo micro**: "En la demostración verán esto en acción con botón 'Bad Transaction'."

---

### **SLIDE 8: Cuándo Usar SQL en IIoT**

```
✅ USAR SQL CUANDO...

1. Datos Transaccionales
   • Lotes de producción
   • Órdenes de trabajo
   • Inspecciones de calidad

2. Relaciones Complejas
   • Línea → Lotes → Inspecciones → Eventos
   • Foreign Keys garantizan integridad

3. Integridad Crítica
   • Auditorías (trazabilidad)
   • Compliance regulatorio
   • Reportes financieros

4. Consultas Relacionales
   • JOINs entre múltiples tablas
   • Agregaciones con GROUP BY
   • Reportes complejos

❌ NO ÓPTIMO PARA...
   • Alta frecuencia (>100 writes/segundo)
   • Series temporales puras
   • Datos no estructurados
```

**Nota Instructor**: "Regla práctica: Si necesitan hacer ROLLBACK, probablemente necesitan SQL."

---

### **SLIDE 9: Bases de Datos NoSQL**

```
🌐 NoSQL: Not Only SQL

CARACTERÍSTICAS
• Flexibilidad: Esquema dinámico
• Escalabilidad: Horizontal (+ servidores)
• Variedad: Múltiples modelos de datos
• Performance: Optimizado para casos específicos

4 TIPOS PRINCIPALES DE NoSQL

┌─────────────────┬──────────────────────────────┐
│ TIPO            │ USO EN IIoT                  │
├─────────────────┼──────────────────────────────┤
│ 🗝️ CLAVE-VALOR  │ Cache rápido (Redis)         │
│                 │ Sesiones, configuración      │
├─────────────────┼──────────────────────────────┤
│ 📄 DOCUMENTOS   │ Recetas variables (MongoDB)  │
│                 │ Logs no estructurados        │
├─────────────────┼──────────────────────────────┤
│ 🕸️ GRAFOS       │ Red de dispositivos (Neo4j)  │
│                 │ Relaciones complejas         │
├─────────────────┼──────────────────────────────┤
│ ⏰ TIME-SERIES  │ Sensores IIoT (InfluxDB)     │
│   ⭐ ESTRELLA    │ ← Más importante para IIoT   │
└─────────────────┴──────────────────────────────┘
```

**Nota Instructor**: "NoSQL NO significa No-SQL, significa Not-ONLY-SQL. Es complemento, no reemplazo."

---

### **SLIDE 10-11: Time-Series Databases - Estrella de IIoT**

```
⏰ Time-Series Databases (TSDB)

¿QUÉ SON?
Bases de datos optimizadas para datos indexados por tiempo

ESTRUCTURA DE DATOS
┌─────────────────────────────────────────┐
│ Measurement: "temperature"              │
│                                         │
│ Time                Value   Sensor_ID   │
│ ────────────────   ─────   ─────────    │
│ 2026-02-03 10:00   65.2°C  TEMP_001     │
│ 2026-02-03 10:01   65.5°C  TEMP_001     │
│ 2026-02-03 10:02   66.1°C  TEMP_001     │
│ ...                                     │
│ (86,400 lecturas/día a 1 lectura/seg)  │
└─────────────────────────────────────────┘

EJEMPLOS: InfluxDB, TimescaleDB, Prometheus
```

**SLIDE 11: TSDB vs SQL - Comparación**

```
⚔️ Eficiencia: TSDB vs SQL Tradicional

ESCENARIO: Sensor temperatura cada 1 segundo

┌──────────────────┬──────────┬──────────┬────────────┐
│                  │  MySQL   │ InfluxDB │ VENTAJA    │
├──────────────────┼──────────┼──────────┼────────────┤
│ Registros/hora   │  3,600   │  3,600   │ Igual      │
│ Almacenamiento   │  1.2 MB  │  0.15 MB │ 8x menor   │
│ Query: Avg 1h    │  500 ms  │  50 ms   │ 10x rápido │
│ Compresión       │  Manual  │  Auto    │ Built-in   │
│ Downsampling     │  Complex │  Nativo  │ Fácil      │
└──────────────────┴──────────┴──────────┴────────────┘

ANATOMÍA DE LA EFICIENCIA
┌────────────────────────────────────────────┐
│ MYSQL (Row-Store)                          │
│ Row 1: [id, timestamp, temp, sensor, ...]  │
│ Row 2: [id, timestamp, temp, sensor, ...]  │
│ ↑ Cada row tiene overhead completo         │
└────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│ INFLUXDB (Column-Store)                    │
│ timestamps: [t1, t2, t3, ...]              │
│ values: [65.2, 65.5, 66.1, ...]            │
│ ↑ Columnas comprimen mejor (valores similar│
└────────────────────────────────────────────┘

🎯 A escala anual: 1.3 GB vs 10.4 GB
```

**Nota Instructor**:
- **Analogía**: "MySQL es como biblioteca organizando libros por autor/título completo. TSDB es como termómetro que solo guarda temperaturas en orden. ¿Cuál más eficiente para histórico temperatura? Obvio."
- "Mostrar query speed en demo live."
- Mencionar: "En demo veremos 3,600 registros en ~50ms."

---

### **SLIDE 12: Cuándo Usar TSDB en IIoT**

```
✅ USAR TIME-SERIES DB CUANDO...

1. Alta Frecuencia de Escritura
   • >10 lecturas/segundo por sensor
   • Múltiples sensores simultáneos
   • Ej: Vibración motor 1000 Hz

2. Consultas Basadas en Tiempo
   • "Temperatura última hora"
   • "Promedio diario último mes"
   • "Detectar anomalías en ventana temporal"

3. Retención Diferenciada
   • Datos crudos: 30 días
   • Agregados horarios: 1 año
   • Agregados diarios: 5 años

4. Downsampling Automático
   • 1 seg → 1 min → 1 hora → 1 día
   • Reduce almacenamiento 99%+

SENSORES IDEALES PARA TSDB
🌡️ Temperatura | 💨 Presión | 📊 Vibración
⚡ Corriente   | 🌊 Flujo   | 📏 Nivel
```

**Nota Instructor**: "Si el dato tiene timestamp como atributo principal, probablemente va en TSDB."

---

### **SLIDE 13: Polyglot Persistence**

```
🔄 Polyglot Persistence: Mejor de Ambos Mundos

CONCEPTO
Usar múltiples tipos de bases de datos en una sola
aplicación, eligiendo la mejor herramienta para cada
tipo de dato.

ANALOGÍA: Caja de Herramientas
┌──────────────────────────────────────┐
│ 🔨 Martillo → Clavos                 │
│ 🪛 Destornillador → Tornillos        │
│ 🪚 Sierra → Cortar madera            │
│                                      │
│ ❌ NO todo con martillo               │
│ ✅ Herramienta correcta para cada trabajo  │
└──────────────────────────────────────┘

ARQUITECTURA IIoT TÍPICA
┌──────────────────────────────────────┐
│ Sensor → MQTT → Procesador           │
│                    ↓                  │
│            ┌───────┴───────┐         │
│            ↓               ↓         │
│       InfluxDB          MySQL        │
│      (time-series)  (transacciones)  │
│            ↓               ↓         │
│            └───────┬───────┘         │
│                    ↓                  │
│                 Grafana               │
│            (visualización)            │
└──────────────────────────────────────┘
```

**Nota Instructor**: "No es competencia, es colaboración. Como tener Excel Y Word, no Excel O Word."

---

### **SLIDE 14: MQTT - El Lenguaje de IIoT**

```
📡 MQTT: Message Queuing Telemetry Transport

¿POR QUÉ MQTT?
• Ligero: Headers 2 bytes (vs 200+ HTTP)
• Bidireccional: Push real-time
• Desacoplado: Publishers ≠ Subscribers
• QoS Levels: Garantías de entrega
• Standard: ISO/IEC 20922

ARQUITECTURA PUB/SUB
┌────────────────────────────────────────┐
│         🏭 PUBLISHERS                   │
│    (Sensores, PLCs, Dispositivos)      │
│         ↓   ↓   ↓   ↓                  │
│         └───┴───┴───┘                  │
│              ↓                          │
│      ☁️ BROKER (Mosquitto)              │
│              ↓                          │
│         ┌───┬───┬───┐                  │
│         ↓   ↓   ↓   ↓                  │
│        📊  🖥️  📱  💾                   │
│    SUBSCRIBERS                         │
│  (Apps, Databases, Dashboards)         │
└────────────────────────────────────────┘

VENTAJA: Sensores no saben quién consume
         Consumidores no saben quién publica
```

**Nota Instructor**:
- **Analogía radio**: "Radio 95.5 FM transmite (publish). Múltiples carros sintonizan (subscribe). Radio no sabe quiénes escuchan. Carros no se conocen entre sí. Apagar radio → carros esperan o usan última info (retained). Exactamente MQTT."

---

### **SLIDE 15: Arquitectura del Sistema de Demostración**

```
🏗️ Sistema IIoT Completo - Lo que Veremos

FLUJO DE DATOS
┌────────────────────────────────────────────┐
│ 1️⃣ GENERACIÓN                              │
│    Node-RED simula sensores                │
│    Temp: 1/seg | Presión: 2/seg           │
└──────────────────┬─────────────────────────┘
                   ↓ Publish MQTT
┌────────────────────────────────────────────┐
│ 2️⃣ COMUNICACIÓN                            │
│    Mosquitto Broker (Puerto 1883)          │
│    Topics: iiot/sensors/*                  │
└──────────────────┬─────────────────────────┘
                   ↓ Subscribe
┌────────────────────────────────────────────┐
│ 3️⃣ PROCESAMIENTO                           │
│    Node-RED                                │
│    Valida, transforma, enruta              │
└─────────┬──────────────────────┬───────────┘
          ↓                      ↓
┌──────────────────┐   ┌──────────────────┐
│ 4️⃣ ALMACENAMIENTO│   │ 4️⃣ ALMACENAMIENTO│
│    InfluxDB      │   │    MySQL         │
│    Temp/Presión  │   │    Producción    │
│    Alta Frec.    │   │    Calidad       │
└─────────┬────────┘   └────────┬─────────┘
          └───────┬──────────────┘
                  ↓ Read
┌────────────────────────────────────────────┐
│ 5️⃣ VISUALIZACIÓN                           │
│    Grafana Dashboards                      │
│    Datos tiempo real unificados            │
└────────────────────────────────────────────┘

✨ TODO corriendo en Docker en este momento
```

**Nota Instructor**: "Este slide es mapa de lo que verán. Referenciar durante demo: 'Aquí estamos en paso 3, procesamiento...'"

---

### **SLIDE 16: Transición a Demo**

```
🎬 Demostración en Vivo

QUÉ VERÁN (15 minutos):

✅ Sistema IIoT real funcionando
✅ Datos fluyendo en tiempo real via MQTT
✅ Node-RED orquestando todo
✅ Escritura simultánea a InfluxDB y MySQL
✅ Queries comparativas (velocidad)
✅ Demostración ACID (transacciones)
✅ Grafana visualizando ambas BDs

🎯 OBJETIVO
Ver con sus propios ojos por qué necesitamos
MÚLTIPLES bases de datos en IIoT

📝 Tomen notas de lo que les parezca interesante
   para preguntar después

[PAUSA PARA SETUP DE PANTALLA]
```

---

### **SLIDE 17: Ejercicios para Estudiantes**

```
📝 Ejercicios Prácticos

EJERCICIO 1: Selección de BD (3 min)
5 escenarios → Elegir MySQL o InfluxDB

EJERCICIO 2: Consultas (Tarea)
• 3 queries SQL (MySQL)
• 3 queries Flux (InfluxDB)

EJERCICIO 3: Diseño (Avanzado)
Diseñar esquema para planta embotelladora

EJERCICIO 4: Node-RED (Bonus)
Crear flujo cross-database

EJERCICIO 5: Python MQTT (Bonus)
Script publicador de datos

📂 Todos en carpeta /ejercicios del proyecto
🎯 Evaluación: Ver rúbricas en EJERCICIOS.md
```

---

### **SLIDE 18: Recursos Adicionales**

```
📚 Recursos para Profundizar

DOCUMENTACIÓN
• Docker: docs.docker.com
• InfluxDB: docs.influxdata.com
• MySQL: dev.mysql.com/doc
• MQTT: mqtt.org
• Grafana: grafana.com/docs

TUTORIALES
• InfluxDB University (gratis)
• MySQL Tutorial (w3schools)
• MQTT Essentials (HiveMQ)

PROYECTO COMPLETO
• Repositorio con todo el código
• README con instrucciones paso a paso
• Scripts de ejemplo en Python
• Queries de ejemplo comentadas

OPCIONAL AVANZADO
• Factory I/O (simulador industrial)
• Integración con OPC-UA
• Ver documentación en proyecto
```

---

### **SLIDE 19: Preguntas y Discusión**

```
❓ Preguntas y Respuestas

Temas para discutir:
• Aplicaciones en proyectos reales
• Casos de uso en Ecuador
• Integración con sistemas existentes
• Costos de implementación
• Escalabilidad

💡 No hay preguntas tontas
   Solo conceptos que no han sido explicados bien

📧 Contacto para dudas post-clase:
   [email del instructor]

🔗 Links al proyecto y recursos:
   [URL repositorio/drive]
```

---

### **SLIDE 20: Cierre**

```
🎓 Resumen - Take Away Messages

1️⃣ SQL ≠ NoSQL no es competencia
   Es colaboración (Polyglot Persistence)

2️⃣ Alta frecuencia + tiempo = TSDB
   Transacciones + relaciones = SQL

3️⃣ MQTT es el standard de facto en IIoT
   Ligero, desacoplado, confiable

4️⃣ Grafana unifica visualización
   Una vista, múltiples fuentes

5️⃣ Docker facilita setup completo
   Todo el sistema en minutos

🚀 PRÓXIMOS PASOS
• Descargar proyecto
• Experimentar en casa
• Completar ejercicios
• Aplicar en proyecto final

¡Gracias por su atención!
```

---

## 📝 Notas Pedagógicas Detalladas

### Sección 1: Introducción (5 min)

**Objetivos**:
- Captar atención
- Establecer relevancia
- Crear contexto

**Puntos Clave**:
1. IIoT no es futurista, es presente
2. Ecuador tiene casos de uso reales
3. Problema: volumen masivo de datos

**Transición**: "Antes de soluciones, entendamos tipos de datos..."

**Preguntas Provocadoras**:
- "¿Cuántos sensores creen que tiene una fábrica moderna?" [Respuesta: Miles]
- "¿Cada cuánto envían datos?" [Respuesta: Segundos o menos]

**Alerta Confusión Común**: Estudiantes pueden pensar que IIoT = IoT. Aclarar que IIoT tiene requisitos más estrictos (confiabilidad, tiempo real, seguridad).

---

### Sección 2: SQL (15 min)

**Objetivos**:
- Entender modelo relacional
- Comprender ACID profundamente
- Identificar casos de uso IIoT

**Timing Interno**:
- 5 min: Modelo relacional + características
- 7 min: ACID (crítico, no apurar)
- 3 min: Casos de uso IIoT

**Enfoque ACID** (MUY IMPORTANTE):

**A - Atomicidad**:
- Analogía restaurante (dividir cuenta)
- Ejemplo código: START TRANSACTION / ROLLBACK
- En demo: Mostrar botón "Bad Transaction"

**C - Consistencia**:
- Demostrar constraint violation
- Ejemplo: Intentar DELETE con FK
- "Base de datos es guardia de seguridad"

**I - Aislamiento**:
- Opcional si hay tiempo
- Mencionar brevemente: "2 usuarios, misma fila, no interfieren"

**D - Durabilidad**:
- Más simple: "COMMIT = salvado en piedra"
- "Apagón no pierde datos post-COMMIT"

**Preguntas para Engagement**:
- "¿Qué pasa si borrar línea de producción que tiene batches?" [Respuesta: FK constraint error]
- "¿Por qué bancos usan SQL?" [Respuesta: ACID garantiza dinero no desaparece]

---

### Sección 3: NoSQL (15 min)

**Objetivos**:
- Entender flexibilidad NoSQL
- Focus en TSDB (más relevante IIoT)
- Ver ventajas rendimiento

**Timing Interno**:
- 3 min: Intro NoSQL y 4 tipos
- 9 min: TSDB (profundo)
- 3 min: Casos de uso y decisión

**TSDB - Puntos Críticos**:

1. **Estructura columnar** (clave del rendimiento):
   - Mostrar visualmente diferencia row vs column store
   - Explicar por qué columnas comprimen mejor
   - Valores similares consecutivos = alta compresión

2. **Comparación concreta**:
   - Usar números reales: 1.2 MB vs 150 KB
   - Query speed: 500ms vs 50ms (10x)
   - Escalar a un año para impacto

3. **Downsampling**:
   - 1 segundo → 1 minuto → 1 hora → 1 día
   - Reduce 86,400 records/day → 1 record/day
   - Mantiene tendencias, pierde detalle

**Analogía TSDB**:
"Termómetro médico especializado en temperatura vs libreta genérica. Obvio que termómetro es mejor para histórico temperatura."

**Preguntas**:
- "¿Cuántos registros genera sensor a 1 Hz en un día?" [86,400]
- "¿Y si son 100 sensores?" [8,640,000]
- "¿Necesitamos detalle de 1 segundo de hace 5 años?" [No]

---

### Sección 4: Polyglot Persistence + MQTT (5 min)

**Objetivos**:
- Unificar conceptos previos
- Introducir MQTT brevemente
- Preparar para demo

**Timing Interno**:
- 2 min: Concepto polyglot
- 2 min: MQTT essentials
- 1 min: Transición a demo

**Polyglot Persistence**:
- NO competencia, colaboración
- Analogía caja de herramientas (fuerte)
- Mostrar diagrama flujo datos

**MQTT**:
- No profundizar mucho (hay guía separada)
- Focus en: ligero, desacoplado, standard
- Analogía radio es perfecta

**Transición Crítica**:
"Suficiente teoría. Ahora... [dramaticpausa] ...veamos esto en ACCIÓN." [Switch a pantalla demo]

---

## 🎬 Script de Demostración LIVE (15 min)

Ver archivo **GUIA-DEMOSTRACION.md** para script detallado minuto-por-minuto.

**Estructura**:
1. Min 0-2: Mostrar sistema corriendo
2. Min 3-5: Flujo de datos MQTT tiempo real
3. Min 6-9: Comparación queries
4. Min 10-12: Demo ACID
5. Min 13-15: Polyglot valor integrado

**Mantra**: "No expliquen cada click, expliquen el CONCEPTO."

---

## ❓ Manejo de Preguntas Frecuentes

### Durante Presentación

**P: "¿Por qué no usar solo MySQL para todo?"**
R: "Excelente pregunta. [Mostrar slide comparación]. MySQL para 86,400 lecturas/día de un sensor = 1.2 MB/día sin comprimir. Multipliquen por 100 sensores por 365 días. InfluxDB: 8x menos espacio + 10x más rápido queries. A escala, hace diferencia entre viable e inviable económicamente."

**P: "¿MQTT es seguro?"**
R: "En este demo: no (anonymous). Producción: sí. MQTT soporta TLS/SSL, autenticación usuario/password, certificados. Como HTTP vs HTTPS. Simplicidad educativa aquí, seguridad en producción."

**P: "¿Cuánto cuesta InfluxDB?"**
R: "InfluxDB tiene versión open-source (gratis). Cloud tiene tier gratuito para proyectos pequeños. Enterprise: ~$8-10/servidor/mes. MySQL similar. No son prohibitivos."

**P: "¿Factory I/O es necesario?"**
R: "No. Sistema funciona completo sin él usando simuladores integrados. Factory I/O es opcional avanzado para quien quiera experimentar con OPC-UA real."

**P: "¿Esto se usa en industria real?"**
R: [Dar ejemplos concretos]
- Tesla usa InfluxDB para telemetría vehículos
- Amazon usa polyglot persistence (DynamoDB + RDS + Redshift)
- MQTT es standard en automotriz (Connected Cars)
- Siemens, ABB, Schneider usan estas arquitecturas

**P: "¿Por qué Node-RED y no Python directo?"**
R: "Válidas ambas. Node-RED: visual, rápido para prototipar, debugging gráfico, deployment sin código. Python: más flexible, mejor para ML, preferido por data scientists. En demo usamos Node-RED por claridad visual. Proyecto incluye scripts Python también."

**P: "¿Qué pasa si Mosquitto se cae?"**
R: "Buena preocupación de arquitectura. MQTT tiene persistent sessions. Mensajes QoS 1/2 se reenvían cuando broker vuelve. Producción: múltiples brokers (clustering), load balancing. Como tener generador de respaldo."

### Post-Clase (Email/Office Hours)

**P: "No puedo hacer correr Docker en mi laptop"**
R: Verificar:
- Docker Desktop instalado y corriendo
- Mínimo 4GB RAM asignado a Docker
- Puertos no ocupados (1880, 3306, 8086, 3000, 1883)
- Ver sección troubleshooting en README

**P: "¿Cómo aplico esto a mi proyecto final?"**
R: Guiar según su proyecto:
- Identificar tipos de datos que manejan
- Mapear a SQL o NoSQL según características
- Sugerir arquitectura específica
- Ofrecer revisar diseño en office hours

---

## 🔧 Troubleshooting Durante Presentación

### Demo Falla Completamente

**Síntomas**: Servicios no inician, pantalla en blanco

**Acción Inmediata**:
1. No entrar en pánico (mantener calma)
2. "Mientras resuelvo esto, veamos los conceptos con screenshots..."
3. Usar slides con capturas pre-hechas
4. Continuar explicación teórica
5. Intentar fix en background
6. Si no se resuelve en 2 min: seguir con screenshots/videos

**Prevención**: Tener screenshots y videos cortos pre-grabados como backup

### Puerto Ocupado

**Síntoma**: Error "port already allocated"

**Fix Rápido**:
```bash
# Terminal visible en proyector
docker compose down
docker compose up -d
```

Mientras reinicia: "Esto pasa. En producción usan health checks y auto-restart. Nos da chance de hablar de resiliencia..."

### Servicio Unhealthy

**Síntoma**: `docker compose ps` muestra Restarting

**Fix**:
```bash
docker compose logs [servicio]
# Identificar error
docker compose restart [servicio]
```

Si no se resuelve rápido: skip ese servicio y continuar con otros.

### No Aparecen Datos en Grafana

**Causa Probable**: Node-RED flows no deployed

**Fix**:
1. Abrir Node-RED
2. Click "Deploy" (botón rojo)
3. Esperar 10 segundos
4. Refresh Grafana

**Mientras espera**: "Esto demuestra importancia del estado en sistemas distribuidos. Deploy es como 'guardar cambios'..."

---

## 📊 Material de Evaluación

### Rúbrica Ejercicios

Ver archivo **EJERCICIOS.md** para rúbricas detalladas.

**Distribución Sugerida**:
- Ejercicio 1 (Selección BD): 5 pts
- Ejercicio 2 (Queries): 15 pts
- Ejercicio 3 (Diseño): 20 pts
- Ejercicio 4 (Node-RED): 15 pts
- Ejercicio 5 (Python MQTT): 10 pts bonus

**Total**: 55 pts + 10 bonus = 65 pts max

**Conversión** a escala universidad (ejemplo sobre 10):
- 55-65 pts → 10/10
- 45-54 pts → 9/10
- 35-44 pts → 8/10
- Etc.

### Criterios de Evaluación

**Conocimiento Conceptual** (40%):
- Identifica correctamente cuándo usar SQL vs NoSQL
- Explica propiedades ACID
- Comprende arquitectura polyglot persistence

**Aplicación Práctica** (40%):
- Escribe queries funcionales
- Diseña schemas apropiados
- Implementa flujos correctamente

**Documentación** (20%):
- Justifica decisiones de diseño
- Comenta código apropiadamente
- Explica razonamiento

---

## 🎯 Tips Pedagógicos Generales

### Regla 10-20-30 de Guy Kawasaki

- **10 slides** clave (mínimo - aquí tenemos 20 total)
- **20 minutos** contenido denso máximo
- **30 pt** tamaño fuente mínimo

### Mantener Atención

- **Pregunta retórica cada 5 min**: "¿Qué pasaría si...?"
- **Cambio de medio cada 10 min**: Slide → Demo → Slide
- **Humor apropiado**: "SQL es como ex tóxico: muy estructurado, no te deja ir (foreign keys)"

### Principio de Aprendizaje Invertido

1. **Primero**: Mostrar demo (impacto visual)
2. **Luego**: Explicar teoría (ahora tiene contexto)
3. **Finalmente**: Ejercicios (aplicación)

### Conectar con Realidad

- "Esto pueden usar en su tesis"
- "Empresas en Ecuador buscan gente con estas habilidades"
- "Factory I/O opcional, pero ayuda si les interesa automatización"

### Pausas Estratégicas

Después de conceptos densos:
- "¿Hasta aquí claro?"
- "¿Alguna duda antes de continuar?"
- Esperar **3 segundos mínimo** (silencio incómodo OK)

---

## 📧 Post-Clase: Seguimiento

### Dentro de 24 horas

- [ ] Enviar email resumen con:
  - Slides en PDF
  - Link al repositorio proyecto
  - Recursos adicionales
  - Plazo entrega ejercicios

### Crear Espacio de Discusión

- Forum/thread para dudas ejercicios
- Discord/Slack opcional para comunidad
- Office hours específicas (ej: Viernes 2-4 PM)

### Clase Seguimiento (Opcional)

30 minutos "Showcase" mejores soluciones:
- Estudiantes presentan ejercicios
- Discusión de enfoques diferentes
- Feedback constructivo

### Survey Feedback

Enviar encuesta corta (5 min):
- ¿Qué fue más útil?
- ¿Qué fue confuso?
- ¿Qué agregar para futuro?
- ¿Velocidad apropiada?

Usar feedback para mejorar próxima iteración.

---

## 🚀 Extensiones para Estudiantes Avanzados

### Nivel 1 (Intermedio)
- Integrar Factory I/O completo
- Agregar Redis como cache layer
- Implementar alertas Grafana (email)

### Nivel 2 (Avanzado)
- Telegraf para métricas sistema
- Node-RED con autenticación
- Dashboard custom Flask/React

### Nivel 3 (Expert)
- Kubernetes deployment
- Kafka para event streaming
- Machine Learning con datos históricos

---

## 📚 Referencias Pedagógicas

### Papers Recomendados
- "Teaching Industrial IoT" - IEEE
- "Database Selection in Industry 4.0" - ACM

### Libros
- "Industrial Internet of Things" - Alasdair Gilchrist
- "Time Series Databases" - Ted Dunning & Ellen Friedman

### Cursos Online Complementarios
- Coursera: IoT and Data Management
- edX: Database Systems
- InfluxDB University (gratis)

---

## ✅ Checklist Final Pre-Clase

**1 Hora Antes**:
- [ ] Sistema Docker corriendo
- [ ] Todos servicios healthy
- [ ] Tabs navegador abiertos
- [ ] Terminal preparado
- [ ] Queries en clipboard
- [ ] Proyector funcionando
- [ ] Audio OK
- [ ] Agua/café disponible
- [ ] Backup plan listo

**5 Min Antes**:
- [ ] Cerrar notificaciones
- [ ] Silenciar celular
- [ ] Poner laptop en "No Molestar"
- [ ] Verificar WiFi estable
- [ ] Presentación en pantalla completa
- [ ] Abrir Node-RED en tab preview

**Durante Clase**:
- [ ] Mantener energía alta
- [ ] Pausar para preguntas
- [ ] Monitorear tiempo
- [ ] Adaptarse a audiencia
- [ ] Disfrutar enseñar! 😊

---

**¡Éxito en tu clase! 🎓**

Esta guía te prepara completamente. Recuerda: estudiantes aprenden más de tu entusiasmo que de perfección técnica. Si algo falla, es oportunidad para enseñar troubleshooting real.

_"El mejor profesor no es el que nunca se equivoca, sino el que sabe manejar los errores con gracia."_
