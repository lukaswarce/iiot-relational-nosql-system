# Ejercicios Prácticos - Bases de Datos IIoT

**4 Ejercicios Graduados con Rúbricas de Evaluación**

---

## 📋 Índice de Ejercicios

1. **[Ejercicio 1: Selección de Base de Datos](#ejercicio-1-selección-de-base-de-datos)** (Durante clase - 3 min)
   - Dificultad: ⭐ Básica
   - Puntos: 5
   
2. **[Ejercicio 2: Consultas SQL y Flux](#ejercicio-2-consultas-sql-y-flux)** (Tarea - 2 horas)
   - Dificultad: ⭐⭐ Intermedia
   - Puntos: 15

3. **[Ejercicio 3: Diseño de Schema](#ejercicio-3-diseño-de-schema)** (Tarea - 3 horas)
   - Dificultad: ⭐⭐⭐ Avanzada
   - Puntos: 20

4. **[Ejercicio 4: Implementación Node-RED](#ejercicio-4-implementación-node-red)** (Bonus - 4 horas)
   - Dificultad: ⭐⭐⭐⭐ Expert
   - Puntos: 15 bonus

**Total Puntos**: 55 (+ 15 bonus = 70 máximo)

---

## 🎯 Ejercicio 1: Selección de Base de Datos

**Tipo**: En clase (3 minutos)  
**Modalidad**: Individual  
**Puntos**: 5  
**Objetivo**: Aplicar criterios de selección entre SQL y NoSQL para escenarios IIoT

### Instrucciones

Para cada uno de los siguientes 5 escenarios, indiquen qué tipo de base de datos usarían:
- **M** = MySQL (SQL Relacional)
- **I** = InfluxDB (Time-Series NoSQL)
- **A** = Ambas (Polyglot Persistence)

Escriban solo la letra correspondiente. No es necesario justificar.

### Escenarios

| # | Escenario | Respuesta |
|---|-----------|-----------|
| 1 | Sistema de registro de empleados con departamentos jerárquicos y nómina | ___ |
| 2 | Monitoreo de temperatura de 50 refrigeradores cada 5 segundos | ___ |
| 3 | Planta embotelladora: lotes de producción + datos de sensores de llenado | ___ |
| 4 | Dashboard tiempo real de consumo eléctrico de edificio (1 lectura/seg) | ___ |
| 5 | Sistema de órdenes de compra con inventario, proveedores y facturas | ___ |

### Rúbrica de Evaluación

| Criterio | Puntos |
|----------|--------|
| 5 respuestas correctas | 5 pts |
| 4 respuestas correctas | 4 pts |
| 3 respuestas correctas | 3 pts |
| 2 respuestas correctas | 2 pts |
| 0-1 respuestas correctas | 0 pts |

### Respuestas Correctas

<details>
<summary>👁️ Ver Respuestas</summary>

| # | Respuesta | Justificación |
|---|-----------|---------------|
| 1 | **M** | Datos transaccionales, relaciones jerárquicas (dept → empleados), baja frecuencia |
| 2 | **I** | Alta frecuencia (50 sensores × 12 lecturas/min = 600 writes/min), solo temperatura |
| 3 | **A** | Polyglot: lotes/calidad en MySQL (transaccional), sensores en InfluxDB (alta frec) |
| 4 | **I** | Tiempo real, alta frecuencia (1/seg), monitoreo continuo |
| 5 | **M** | Transacciones complejas, integridad ACID, múltiples relaciones (FK) |

</details>

---

## 📝 Ejercicio 2: Consultas SQL y Flux

**Tipo**: Tarea  
**Modalidad**: Individual  
**Tiempo Estimado**: 2 horas  
**Puntos**: 15  
**Entrega**: Archivo `ejercicio2_consultas.sql` y `ejercicio2_consultas.flux`

### Objetivo

Demostrar dominio de sintaxis SQL y Flux escribiendo consultas funcionales.

### Parte A: Consultas MySQL (9 puntos)

Escriban queries SQL para:

#### Query 1 (2 pts): Batches Críticos

Obtener todos los batches con `quality_score` promedio **menor a 7.0**, mostrando:
- `batch_code`
- `product_name`
- Promedio de calidad (alias: `avg_quality`)
- Cantidad de inspecciones (alias: `inspection_count`)

Ordenar por calidad promedio ascendente.

**Tablas necesarias**: `production_batches`, `quality_inspections`

<details>
<summary>💡 Pista</summary>

Necesitarán JOIN y GROUP BY. Filtro con HAVING para promedios.

</details>

---

#### Query 2 (3 pts): Producción por Línea y Día

Obtener resumen de producción agrupado por `line_name` y día (`DATE(start_time)`):
- `line_name`
- `production_date`
- Total de batches ese día (alias: `daily_batches`)
- Suma de unidades producidas (alias: `total_units`)

Solo incluir últimos 7 días. Ordenar por fecha descendente.

**Tablas necesarias**: `production_batches`, `production_lines`

<details>
<summary>💡 Pista</summary>

```sql
DATE(start_time) as production_date
WHERE start_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY line_name, DATE(start_time)
```

</details>

---

#### Query 3 (4 pts): Transacción con Validación

Escribir transacción que:
1. Cree un nuevo batch (valores a su elección, line_id debe existir)
2. Registre evento de inicio (`event_type = 'start'`)
3. Registre primera inspección de calidad (quality_score entre 0-10)
4. Si TODO exitoso: COMMIT
5. Incluir manejo de errores apropiado

**Requisito**: Usar variables (`@batch_id`) para capturar `LAST_INSERT_ID()`

<details>
<summary>💡 Pista</summary>

```sql
START TRANSACTION;
-- INSERT batch
SET @batch_id = LAST_INSERT_ID();
-- INSERT event
-- INSERT inspection
COMMIT;
```

</details>

---

### Parte B: Consultas InfluxDB Flux (6 puntos)

Escriban queries Flux para:

#### Query 4 (2 pts): Temperatura Máxima Últimas 3 Horas

Obtener la temperatura máxima registrada en las últimas 3 horas.

**Bucket**: `iiot_sensors`  
**Measurement**: `temperature`  
**Field**: `value`

<details>
<summary>💡 Pista</summary>

```flux
from(bucket: "iiot_sensors")
  |> range(start: -3h)
  |> filter(...)
  |> max()
```

</details>

---

#### Query 5 (2 pts): Downsampling a 10 Minutos

Obtener promedio de presión cada 10 minutos de las últimas 2 horas.

**Output esperado**: ~12 filas (2 horas / 10 min)

<details>
<summary>💡 Pista</summary>

```flux
|> aggregateWindow(every: 10m, fn: mean)
```

</details>

---

#### Query 6 (2 pts): Detección de Picos de Temperatura

Obtener todos los momentos donde temperatura superó **85°C** en últimos 30 minutos.

Ordenar por tiempo descendente, limitar a 20 resultados.

<details>
<summary>💡 Pista</summary>

```flux
|> filter(fn: (r) => r["_value"] > 85.0)
|> sort(columns: ["_time"], desc: true)
|> limit(n: 20)
```

</details>

---

### Rúbrica de Evaluación - Ejercicio 2

| Aspecto | Excelente (100%) | Bueno (75%) | Aceptable (50%) | Insuficiente (0%) |
|---------|------------------|-------------|-----------------|-------------------|
| **Sintaxis** | Sin errores, ejecuta | Errores menores | Errores mayores | No ejecuta |
| **Lógica** | Resultado correcto | Resultado parcial | Lógica incorrecta | No aborda problema |
| **Comentarios** | Bien comentado | Comentarios básicos | Sin comentarios | - |
| **Estilo** | Código limpio, indentado | Legible | Desordenado | Ilegible |

**Puntos por Query**:
- Query 1: 2 pts
- Query 2: 3 pts
- Query 3: 4 pts
- Query 4: 2 pts
- Query 5: 2 pts
- Query 6: 2 pts

**Total Parte A**: 9 pts  
**Total Parte B**: 6 pts  
**Total Ejercicio 2**: 15 pts

### Entrega

Crear archivo `ejercicio2_APELLIDO.zip` conteniendo:
- `consultas_mysql.sql` (queries 1-3)
- `consultas_flux.flux` (queries 4-6)
- `README.txt` con:
  - Nombre completo
  - Fecha
  - Instrucciones de ejecución
  - Capturas de pantalla de resultados (opcional pero recomendado)

---

## 🏗️ Ejercicio 3: Diseño de Schema

**Tipo**: Tarea  
**Modalidad**: Individual o parejas  
**Tiempo Estimado**: 3 horas  
**Puntos**: 20  
**Entrega**: Documento PDF + archivos SQL

### Escenario

Diseñen base de datos para **planta embotelladora de bebidas** con estos requisitos:

#### Requisitos Funcionales

**R1 - Líneas de Producción**:
- 3 líneas: Gaseosas, Agua, Jugos
- Cada línea tiene velocidad máxima (botellas/minuto)

**R2 - Productos**:
- Múltiples productos (Coca-Cola, Sprite, Agua, etc.)
- Cada producto: código, nombre, volumen (ml), tipo

**R3 - Lotes de Producción**:
- Registrar lotes con: fecha/hora inicio, fecha/hora fin, producto, línea, cantidad objetivo, cantidad real
- Estado: planificado, en_progreso, completado, cancelado

**R4 - Sensores IoT** (datos de alta frecuencia):
- Temperatura llenadora (1 lectura/segundo)
- Presión carbonatación (1 lectura/2 segundos)
- Nivel tanque (1 lectura/5 segundos)
- Velocidad transportador (1 lectura/segundo)

**R5 - Control de Calidad**:
- Inspecciones periódicas por lote
- Parámetros: volumen correcto (ml), sellado OK, etiquetado OK, fecha impresa OK
- Cada inspección tiene resultado (aprobado/rechazado) y observaciones

**R6 - Eventos**:
- Log de eventos: inicio lote, fin lote, parada emergencia, cambio producto, mantenimiento
- Cada evento: timestamp, tipo, descripción, usuario

### Tareas

#### Tarea 1: Modelo Entidad-Relación (6 pts)

Crear diagrama ER mostrando:
- ✅ Entidades (rectángulos)
- ✅ Atributos clave (subrayados)
- ✅ Relaciones (rombos) con cardinalidad (1:1, 1:N, N:M)
- ✅ Atributos de relaciones si aplica

**Herramientas sugeridas**: draw.io, Lucidchart, MySQL Workbench, papel y foto

---

#### Tarea 2: Schema SQL (8 pts)

Escribir `schema.sql` (mysql/schema.sql) con:

**2.1 Tablas Relacionales** (5 pts):
- `production_lines` (líneas)
- `products` (productos)
- `production_batches` (lotes)
- `quality_inspections` (inspecciones)
- `production_events` (eventos)

Requisitos:
- ✅ Primary Keys
- ✅ Foreign Keys con ON DELETE/UPDATE apropiados
- ✅ CHECK constraints para validaciones (ej: cantidad_real <= cantidad_objetivo)
- ✅ Tipos de datos apropiados (INT, VARCHAR, DECIMAL, DATETIME, ENUM)
- ✅ Comentarios explicando decisiones de diseño

**2.2 Índices** (1 pt):
- Índice en `production_batches.fecha_inicio`
- Índice en `production_events.timestamp`
- Justificar por qué estos índices

**2.3 Views** (1 pt):
- `v_produccion_actual`: Lotes en progreso con info de línea y producto
- `v_calidad_resumen`: Resumen de calidad por producto (% aprobados)

**2.4 Stored Procedure** (1 pt):
- `sp_registrar_lote_completo`: Crear lote + evento inicio en transacción

---

#### Tarea 3: Estrategia Time-Series (4 pts)

Documento explicando:

**3.1 Estructura InfluxDB** (2 pts):
- ¿Qué measurements usar?
- ¿Qué tags vs fields?
- ¿Por qué esta estructura?

**3.2 Retención de Datos** (1 pt):
- Proponer política de retención (ej: raw 30 días, downsampled 1 año)
- Justificar decisión

**3.3 Ejemplo Flux Query** (1 pt):
- Query que detecte temperatura llenadora anormal (>80°C o <5°C) en última hora

---

#### Tarea 4: Justificación Polyglot (2 pts)

Documento respondiendo:

1. ¿Por qué NO usar solo MySQL para todo?
2. ¿Por qué NO usar solo InfluxDB para todo?
3. ¿Qué ventajas aporta arquitectura híbrida?
4. ¿Qué desventajas/complejidades introduce?

**Extensión**: 1-2 páginas (500-1000 palabras)

---

### Rúbrica de Evaluación - Ejercicio 3

| Aspecto | Excelente (100%) | Bueno (75%) | Aceptable (50%) | Insuficiente (25%) |
|---------|------------------|-------------|-----------------|-------------------|
| **ER Diagram** | Completo, cardinalidades correctas | Casi completo, errores menores | Incompleto, errores mayores | Muy incompleto |
| **Schema SQL** | Todas tablas, PKs/FKs correctos, constraints | Mayormente correcto | Varios errores | Muchos errores |
| **Normalización** | 3NF, sin redundancia | Normalizado aceptable | Poca normalización | No normalizado |
| **InfluxDB Strategy** | Estructura óptima justificada | Aceptable | Subóptima | Incorrecta |
| **Justificación** | Argumentos sólidos, cita conceptos | Justificación básica | Poco elaborada | Superficial |
| **Documentación** | Muy clara, profesional | Clara | Básica | Confusa |

**Distribución de Puntos**:
- Tarea 1 (ER): 6 pts
- Tarea 2 (SQL): 8 pts
- Tarea 3 (TSDB): 4 pts
- Tarea 4 (Justificación): 2 pts

**Total**: 20 pts

### Criterios de Excelencia (Bonus +2 pts)

- ✨ Triggers para auditoría automática
- ✨ Funciones calculadas (ej: % eficiencia lote)
- ✨ Datos de ejemplo realistas (INSERT statements)
- ✨ Diagrama de arquitectura completa (incluye MQTT, Grafana)

### Entrega

Archivo `ejercicio3_APELLIDO.zip` conteniendo:
1. `diagrama_er.png` (o .pdf)
2. `schema.sql`
3. `estrategia_tsdb.pdf`
4. `justificacion_polyglot.pdf`
5. `README.txt` con instrucciones

---

## 🚀 Ejercicio 4: Implementación Node-RED (BONUS)

**Tipo**: Bonus  
**Modalidad**: Individual  
**Tiempo Estimado**: 4 horas  
**Puntos**: 15 bonus  
**Entrega**: Archivo `flows.json` + video demo

### Objetivo

Implementar flujo Node-RED funcional que demuestre **Polyglot Persistence** en acción.

### Requisitos Mínimos (10 pts)

#### Componente 1: Simulador de Sensor (3 pts)

**Implementar**:
- Inject node cada 2 segundos
- Function node que genera:
  - `temperature`: random 15-95°C
  - `pressure`: random 2.0-5.0 bar
  - `timestamp`: ISO 8601
  - `sensor_id`: "SENSOR_001"

**Salida**: JSON estructurado

---

#### Componente 2: Publicación MQTT (2 pts)

**Implementar**:
- MQTT out node conectado a `mosquitto:1883`
- Topic: `iiot/planta/sensores`
- QoS: 1
- Mensaje: JSON del simulador

---

#### Componente 3: Persistencia Dual (5 pts)

**Implementar**:
- MQTT in node suscrito a `iiot/planta/sensores`
- **Ruta 1 - InfluxDB** (2.5 pts):
  - Escribir temperatura y presión a InfluxDB
  - Measurement: `sensor_readings`
  - Tags: `sensor_id`
  - Fields: `temperature`, `pressure`
  
- **Ruta 2 - MySQL** (2.5 pts):
  - Si temperatura > 80°C → INSERT en tabla `alertas`
  - Campos: `sensor_id`, `valor`, `tipo_alerta`, `timestamp`
  - Tipo: "temperatura_alta"

---

### Requisitos Avanzados (5 pts adicionales)

#### Avanzado 1: Agregación Pre-Storage (2 pts)

- Calcular promedio móvil 5 lecturas antes de escribir a InfluxDB
- Usar node buffer/smooth

#### Avanzado 2: Dashboard (2 pts)

- UI Dashboard con gauge mostrando temperatura actual
- Gráfico histórico últimos 10 minutos

#### Avanzado 3: Correlación Cross-DB (1 pt)

- Query que lea de MySQL e InfluxDB
- Mostrar alertas (MySQL) con contexto temporal (InfluxDB)

---

### Rúbrica de Evaluación - Ejercicio 4

| Criterio | Puntos |
|----------|--------|
| Simulador funciona correctamente | 3 pts |
| MQTT publica mensajes | 2 pts |
| InfluxDB recibe datos | 2.5 pts |
| MySQL recibe alertas | 2.5 pts |
| **Subtotal Mínimo** | **10 pts** |
| Agregación pre-storage | +2 pts |
| Dashboard UI | +2 pts |
| Correlación cross-DB | +1 pt |
| **Total Máximo** | **15 pts** |

### Criterios Adicionales

| Aspecto | Deducción |
|---------|-----------|
| Flow no importa correctamente | -2 pts |
| Errores en logs Node-RED | -1 pt por error no manejado |
| Sin comentarios en function nodes | -1 pt |
| Video demo ausente o poco claro | -2 pts |

### Entrega

Archivo `ejercicio4_APELLIDO.zip` conteniendo:
1. `flows.json` (exportado desde Node-RED)
2. `video_demo.mp4` (2-3 min mostrando funcionamiento)
3. `instrucciones.md` con:
   - Dependencias (nodes adicionales si usaron)
   - Pasos para importar
   - Configuración necesaria
4. `capturas/` (screenshots de dashboards, datos en DBs)

### Video Demo Debe Mostrar

- ✅ Flow completo en Node-RED
- ✅ Inject disparando simulador
- ✅ Debug mostrando mensajes MQTT
- ✅ Datos apareciendo en InfluxDB (UI o query)
- ✅ Alertas en MySQL (Adminer o query)
- ✅ Dashboard si implementaron (opcional)

---

## 📊 Resumen de Puntuación

| Ejercicio | Dificultad | Puntos | Tipo |
|-----------|------------|--------|------|
| Ejercicio 1 | ⭐ | 5 | En clase |
| Ejercicio 2 | ⭐⭐ | 15 | Tarea |
| Ejercicio 3 | ⭐⭐⭐ | 20 | Tarea |
| Ejercicio 4 | ⭐⭐⭐⭐ | 15 | Bonus |
| **Total Base** | | **40** | |
| **Total con Bonus** | | **55** | |

### Conversión a Nota (Sobre 10)

| Puntos | Nota/10 |
|--------|---------|
| 38-40+ | 10.0 |
| 36-37 | 9.5 |
| 34-35 | 9.0 |
| 32-33 | 8.5 |
| 30-31 | 8.0 |
| 28-29 | 7.5 |
| 26-27 | 7.0 |
| 24-25 | 6.5 |
| 22-23 | 6.0 |
| <22 | <6.0 |

**Nota**: Ejercicio 4 (bonus) puede elevar nota por encima de 10 según escala.

---

## 📅 Calendario de Entregas

| Ejercicio | Fecha Asignación | Fecha Entrega | Días |
|-----------|------------------|---------------|------|
| Ejercicio 1 | Durante clase | Final de clase | 0 |
| Ejercicio 2 | Lunes post-clase | Viernes +7 días | 7 |
| Ejercicio 3 | Lunes post-clase | Viernes +14 días | 14 |
| Ejercicio 4 | Lunes post-clase | Viernes +21 días | 21 |


---

## 🆘 Recursos de Ayuda

### Documentación
- MySQL: https://dev.mysql.com/doc/
- InfluxDB: https://docs.influxdata.com/
- Node-RED: https://nodered.org/docs/
- Flux: https://docs.influxdata.com/flux/

### Ejemplos en Proyecto
- `CONSULTAS-EJEMPLO.md`: Queries comentadas
- `mysql/init/init.sql`: Schema de referencia
- `nodered/flows.json`: Flujos existentes

### Office Hours
- **Cómo**: lukaswarce@gmail.com

### Preguntas Frecuentes

**P: ¿Puedo usar otras bases de datos?**
R: No para estos ejercicios. Focus es MySQL e InfluxDB específicamente.

**P: ¿Ejercicio 3 puede ser en pareja?**
R: Sí, pero ambos deben contribuir equitativamente. Incluir declaración de contribución.

**P: ¿Qué pasa si mi Docker no funciona?**
R: Contactar inmediatamente. Pueden usar instalación local o cloud trials.

**P: ¿El ejercicio 4 es obligatorio?**
R: No, es bonus. Pueden obtener nota máxima sin él.

**P: ¿Puedo entregar antes?**
R: ¡Sí! Recibirán feedback temprano.

---

## ✅ Checklist Pre-Entrega

### Para Ejercicio 2
- [ ] Queries ejecutan sin errores
- [ ] Resultados son correctos (verificar con datos ejemplo)
- [ ] Código tiene comentarios
- [ ] Nombres de archivos correctos
- [ ] README incluido

### Para Ejercicio 3
- [ ] Diagrama ER completo y legible
- [ ] Schema SQL importa sin errores
- [ ] Constraints funcionan (probar violaciones)
- [ ] Documentos en PDF
- [ ] Zip nombrado correctamente

### Para Ejercicio 4
- [ ] Flow importa correctamente
- [ ] Todas las conexiones configuradas
- [ ] Video demo grabado y comprimido
- [ ] Instrucciones claras
- [ ] Zip nombrado correctamente

---

## 🎓 Criterios de Honestidad Académica

### Permitido ✅
- Consultar documentación oficial
- Usar ejemplos del proyecto como referencia
- Discutir conceptos generales con compañeros
- Pedir ayuda en office hours
- Usar Stack Overflow para sintaxis específica

### NO Permitido ❌
- Copiar código completo de compañeros
- Compartir soluciones completas
- Usar soluciones de años anteriores
- Contratar a terceros para hacer trabajo
- Plagio de documentación (parafrasear está OK)


---

## 🌟 Consejos para Éxito

### Gestión de Tiempo
1. **No dejar para último día** - Ejercicio 3 requiere 3 horas reales
2. **Empezar con ejercicio 2** (más directo) para ganar confianza
3. **Ejercicio 4 opcional** - Solo si tiempo y interés

### Estrategia de Resolución
1. **Leer requisitos 2 veces** antes de empezar
2. **Probar incrementalmente** - No esperar a terminar todo
3. **Usar datos de ejemplo** del proyecto para validar
4. **Documentar mientras trabajan** - No al final

### Debugging
1. **Errores SQL**: Copiar mensaje completo, googlear
2. **Errores Flux**: Verificar nombres de bucket/measurement
3. **Node-RED**: Usar debug nodes generosamente
4. **Stack Overflow es tu amigo**: Buscar mensajes de error específicos

### Presentación
1. **Código limpio**: Indentar, espacios consistentes
2. **Comentarios útiles**: Explicar POR QUÉ, no QUÉ
3. **README claro**: Alguien más debe poder ejecutar
4. **Screenshots ayudan**: Especialmente para Ejercicio 3

---

## 📧 Formato de Entrega

### Nombramiento de Archivos

```
ejercicio[N]_[APELLIDO]_[NOMBRE].zip

Ejemplos:
ejercicio2_Garcia_Maria.zip
ejercicio3_Rodriguez_Carlos.zip
ejercicio4_Lopez_Ana.zip
```

### Estructura Interna Zip

```
ejercicio2_Garcia_Maria/
├── consultas_mysql.sql
├── consultas_flux.flux
└── README.txt

ejercicio3_Rodriguez_Carlos/
├── diagrama_er.png
├── schema.sql
├── estrategia_tsdb.pdf
├── justificacion_polyglot.pdf
└── README.txt

ejercicio4_Lopez_Ana/
├── flows.json
├── video_demo.mp4
├── instrucciones.md
└── capturas/
    ├── influxdb.png
    ├── mysql.png
    └── dashboard.png
```

### Email de Entrega

**Asunto**: `[IIoT-BD] Ejercicio [N] - [Apellido]`

**Cuerpo**:
```
Nombre: [Nombre Completo]
Curso: Bases de Datos IIoT
Ejercicio: [Número]
Fecha Entrega: [DD/MM/YYYY]

Archivos adjuntos:
- ejercicio[N]_[Apellido].zip ([tamaño] MB)

Comentarios opcionales:
[Cualquier nota relevante para corrección]

Declaración de Honestidad:
Declaro que este trabajo es original y cumple con
políticas de honestidad académica del curso.

Firma: [Nombre]
```

---

## 🏆 Criterios de Excelencia

Para obtener **calificación sobresaliente** (>9.5/10):

### Técnicos
- ✨ Código excepcionalmente limpio y documentado
- ✨ Soluciones optimizadas (índices apropiados, queries eficientes)
- ✨ Manejo robusto de errores
- ✨ Implementación va más allá de requisitos mínimos

### Conceptuales
- ✨ Justificaciones demuestran comprensión profunda
- ✨ Consideraciones de escalabilidad y mantenibilidad
- ✨ Aplicación creativa de conceptos a escenarios nuevos

### Presentación
- ✨ Documentación profesional (diagramas, formato)
- ✨ README exhaustivo pero conciso
- ✨ Video demo bien editado y narrado (Ejercicio 4)

---

## 📈 Auto-Evaluación

Antes de entregar, respondan:

| Pregunta | Sí | No |
|----------|----|----|
| ¿Todas las queries ejecutan sin errores? | ☐ | ☐ |
| ¿Los resultados son correctos? | ☐ | ☐ |
| ¿El código está comentado? | ☐ | ☐ |
| ¿Probé con datos de ejemplo? | ☐ | ☐ |
| ¿La documentación es clara? | ☐ | ☐ |
| ¿Cumple requisitos mínimos? | ☐ | ☐ |
| ¿Archivos nombrados correctamente? | ☐ | ☐ |
| ¿ZIP < 50 MB? | ☐ | ☐ |

Si todas las respuestas son **Sí** → ¡Listo para entregar! 🎉

---

**¡Éxito con los ejercicios! 🚀**

_Recuerden: El objetivo no es solo completar, sino **aprender**. Si algo no entienden, pregunten. No hay preguntas tontas._

---

## 📎 Anexo: Datos de Ejemplo para Probar

### MySQL Sample Data

```sql
-- Para probar queries ejercicio 2
INSERT INTO production_batches (line_id, batch_code, product_name, target_quantity, actual_quantity, status, start_time)
VALUES 
(1, 'TEST_001', 'Widget Test', 1000, 900, 'completed', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'TEST_002', 'Widget Test', 1000, 950, 'completed', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 'TEST_003', 'Gadget Test', 500, 480, 'in_progress', NOW());

-- Verificar
SELECT * FROM production_batches WHERE batch_code LIKE 'TEST_%';
```

### InfluxDB Sample Data

```bash
# CLI InfluxDB
influx write \
  -b iiot_sensors \
  -o iiot-class \
  -p s \
  'temperature,sensor_id=TEST_001 value=85.5'

influx write \
  -b iiot_sensors \
  -o iiot-class \
  -p s \
  'temperature,sensor_id=TEST_001 value=90.2'

# Verificar
influx query 'from(bucket:"iiot_sensors") |> range(start: -1h) |> filter(fn: (r) => r.sensor_id == "TEST_001")'
```

---

**Versión**: 1.0  
**Última Actualización**: Febrero 2026  
**Instructor**: Christian Spana
