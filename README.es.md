> [🇺🇸 English](README.md) | 🇪🇸 **Español**


# Sistema IIoT - Bases de Datos Relacionales y No Relacionales

**Curso**: Uso de Bases de Datos en Tecnologías de Operación (IIoT)  
**Duración**: 1 hora (60 minutos)
**Instructor**: Christian Spana

## 📋 Descripción del Proyecto

Este proyecto proporciona un entorno Docker completo para enseñar y demostrar el uso de bases de datos relacionales (MySQL) y no relacionales (InfluxDB) en contextos de Industrial Internet of Things (IIoT).

### Objetivos de Aprendizaje

1. Comprender las diferencias entre bases de datos SQL y NoSQL
2. Identificar cuándo usar cada tipo de base de datos en IIoT
3. Implementar el concepto de **Polyglot Persistence** (persistencia políglota)
4. Trabajar con MQTT como protocolo de comunicación IIoT
5. Visualizar datos en tiempo real con Grafana
6. Aplicar conceptos de ACID en transacciones relacionales

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                  SENSORES / SIMULADORES                     │
│  Node-RED (simuladores) | Factory I/O | Scripts Python      │
└────────────────┬────────────────────────────────────────────┘
                 │ MQTT Publish
                 ▼
┌─────────────────────────────────────────────────────────────┐
│              MOSQUITTO BROKER (Puerto 1883)                 │
│              Centro de Comunicaciones MQTT                  │
└────────────────┬────────────────────────────────────────────┘
                 │ MQTT Subscribe
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                NODE-RED (Puerto 1880)                       │
│          Procesamiento, Validación, Enrutamiento            │
└───────┬─────────────────────────────────────────┬───────────┘
        │                                         │
        ▼                                         ▼
┌──────────────────┐                    ┌──────────────────┐
│  INFLUXDB (8086) │                    │  MYSQL (3306)    │
│  Time-Series DB  │                    │  Relational DB   │
│                  │                    │                  │
│ • Temperatura    │                    │ • Producción     │
│ • Presión        │                    │ • Calidad        │
│ • Vibración      │                    │ • Alertas        │
│ Alta Frecuencia  │                    │ Transacciones    │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         └──────────────┬────────────────────────┘
                        │ Read Queries
                        ▼
              ┌──────────────────┐
              │ GRAFANA (3000)   │
              │  Visualización   │
              │  Dashboards      │
              └──────────────────┘
```

## 🚀 Inicio Rápido

### Prerrequisitos

- **Docker Desktop** 20.10+ instalado ([Descargar aquí](https://www.docker.com/products/docker-desktop))
- **Docker Compose** incluido con Docker Desktop
- **8GB RAM** mínimo (16GB recomendado)
- **10GB espacio en disco** disponible
- **Factory I/O** (opcional, solo para integración avanzada Windows)

### Instalación

1. **Clonar o descargar el proyecto**
   ```bash
   # Si tienes git:
   git clone git@github.com:lukaswarce/iiot-relational-nosql-system.git
   cd resources
   
   # O descargar ZIP y extraer
   ```

2. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   ```
   
   Opcionalmente, editar `.env` para cambiar credenciales (por defecto son educativas).

3. **Iniciar el sistema**
   ```bash
   docker compose up -d
   ```
   
   Este comando:
   - Descarga las imágenes Docker necesarias (~2-3 GB)
   - Crea los contenedores
   - Inicia todos los servicios
   - Tiempo estimado primera vez: 5-10 minutos

4. **Verificar servicios**
   ```bash
   docker compose ps
   ```
   
   Todos los servicios deben mostrar status `Up (healthy)`.

5. **Esperar inicialización** (60-90 segundos)
   
   Los servicios necesitan tiempo para inicializar completamente:
   - MySQL: Crear base de datos y tablas
   - InfluxDB: Configurar organización y buckets
   - Node-RED: Cargar flujos
   - Grafana: Configurar datasources

## 🌐 Acceso a los Servicios

| Servicio | URL | Usuario | Contraseña | Propósito |
|----------|-----|---------|------------|-----------|
| **Node-RED** | http://localhost:1880 | - | - | Orquestación de flujos IIoT |
| **InfluxDB UI** | http://localhost:8086 | admin | admin123 | Interface web InfluxDB |
| **Grafana** | http://localhost:3000 | admin | admin | Dashboards y visualización |
| **Adminer** | http://localhost:8080 | - | - | Inspector web para MySQL |
| **MySQL** | localhost:3306 | student | student123 | Base de datos relacional |
| **Mosquitto** | mqtt://localhost:1883 | - | - | Broker MQTT |

### Configuración Adminer (MySQL Web UI)

1. Abrir http://localhost:8080
2. Configurar:
   - **Sistema**: MySQL
   - **Servidor**: `mysql`
   - **Usuario**: `student`
   - **Contraseña**: `student123`
   - **Base de datos**: `iiot_db`
3. Click **Ingresar**

## 💻 Acceso a Bases de Datos por Consola

### MySQL

**Opción 1: Desde el contenedor**
```bash
docker exec -it iiot-mysql mysql -u student -pstudent123 iiot_db
```

**Opción 2: Cliente MySQL externo**
```bash
mysql -h localhost -P 3306 -u student -pstudent123 iiot_db
```

**Comandos útiles MySQL:**
```sql
-- Ver todas las bases de datos
SHOW DATABASES;

-- Usar la base de datos del proyecto
USE iiot_db;

-- Ver todas las tablas
SHOW TABLES;

-- Describir estructura de una tabla
DESCRIBE production_batches;

-- Ver primeros registros
SELECT * FROM production_batches LIMIT 5;

-- Ver resumen de producción
SELECT * FROM v_production_summary;

-- Salir
EXIT;
```

### InfluxDB

**Acceso por CLI:**
```bash
docker exec -it iiot-influxdb influx
```

**Comandos útiles InfluxDB:**
```flux
// Listar buckets
> influx bucket list

// Query básico Flux
> from(bucket: "iiot_sensors")
    |> range(start: -1h)
    |> filter(fn: (r) => r._measurement == "temperature_sensor")
    |> limit(n: 10)

// Ver últimos 10 registros
> from(bucket: "iiot_sensors")
    |> range(start: -24h)
    |> tail(n: 10)

// Salir
> exit
```

**Opción Web UI**: 
- Abrir http://localhost:8086
- Login: admin / admin123
- Click **Data Explorer** para ejecutar queries

## 🔍 ¿Por Qué Polyglot Persistence?

En IIoT, diferentes tipos de datos requieren diferentes tipos de almacenamiento:

### 📊 Datos de Series Temporales → InfluxDB

**Características:**
- Alta frecuencia (1-1000 lecturas/segundo)
- Dependientes del tiempo
- Consultas basadas en rangos temporales
- Ejemplos: temperatura, presión, vibración, corriente

**Por qué InfluxDB:**
- ✅ Almacenamiento columnar optimizado para tiempo
- ✅ Compresión 10-20x vs SQL tradicional
- ✅ Queries 10-100x más rápidas para time-series
- ✅ Retention policies automáticas
- ✅ Downsampling y agregación eficiente

**Ejemplo:**
```
Temperatura cada 1 segundo = 86,400 registros/día
InfluxDB: 150 KB/día comprimido
MySQL: 1.2 MB/día sin comprimir + overhead índices
```

### 🗄️ Datos Transaccionales → MySQL

**Características:**
- Baja-media frecuencia
- Relaciones complejas entre entidades
- Requiere integridad referencial
- Ejemplos: lotes de producción, inspecciones de calidad, alertas

**Por qué MySQL:**
- ✅ Propiedades ACID (Atomicidad, Consistencia, Aislamiento, Durabilidad)
- ✅ Foreign Keys y constraints
- ✅ Transacciones con ROLLBACK
- ✅ JOINs complejos entre múltiples tablas
- ✅ Madurez y ecosistema amplio

**Ejemplo:**
```sql
-- Crear batch de producción con evento en una sola transacción
START TRANSACTION;
  INSERT INTO production_batches (...) VALUES (...);
  INSERT INTO production_events (...) VALUES (...);
COMMIT; -- O ROLLBACK si hay error
```

### 🔄 Arquitectura Híbrida

```
Sensor → MQTT → Node-RED → InfluxDB (datos crudos)
                     ↓
              (agregación horaria)
                     ↓
              MySQL (alertas/eventos)
```

**Ventajas:**
1. **Rendimiento**: Cada BD optimizada para su caso de uso
2. **Escalabilidad**: Escalar InfluxDB independiente de MySQL
3. **Flexibilidad**: Agregar nuevas BDs según necesidad
4. **Costos**: Retención diferenciada (30 días crudo, 1 año agregado)

## 📡 MQTT en este Proyecto

### ¿Qué es MQTT?

**MQTT** (Message Queuing Telemetry Transport) es un protocolo de mensajería ligero publish/subscribe diseñado para IIoT/IoT.

**Ventajas sobre HTTP:**
- Bajo ancho de banda (headers de 2 bytes vs 200+ bytes)
- Bidireccional (push en lugar de polling)
- Desacoplamiento (publishers no conocen subscribers)
- QoS levels (garantías de entrega)
- Retained messages (último estado conocido)

### Topics en este Proyecto

```
iiot/
├── sensors/
│   ├── temperature       # Datos de temperatura
│   ├── pressure          # Datos de presión
│   └── vibration         # Datos de vibración
├── production/
│   └── counter           # Eventos de producción
├── alerts/
│   ├── high_temperature  # Alertas temperatura
│   └── high_pressure     # Alertas presión
└── factory_io/           # Datos Factory I/O (opcional)
    └── ...
```

### Probar MQTT

**Publicar mensaje de prueba:**
```bash
docker exec -it iiot-mosquitto mosquitto_pub \
  -t "iiot/sensors/test" \
  -m '{"value":25.5,"unit":"°C"}'
```

**Suscribirse a todos los mensajes:**
```bash
docker exec -it iiot-mosquitto mosquitto_sub \
  -t 'iiot/#' -v
```

**Wildcards:**
- `+` = un nivel (ej: `iiot/sensors/+` escucha temperature, pressure, etc.)
- `#` = múltiples niveles (ej: `iiot/#` escucha todo bajo iiot/)

### Clientes MQTT Recomendados

- **MQTT Explorer** (GUI): http://mqtt-explorer.com/
- **MQTTX** (GUI): https://mqttx.app/
- **mosquitto_pub/sub** (CLI): Incluido en contenedor
- **Node-RED**: Ya configurado en el proyecto

## 📊 Grafana - Visualización

### Primera Configuración

1. Abrir http://localhost:3000
2. Login: `admin` / `admin`
3. (Opcional) Cambiar contraseña o skip
4. Los datasources ya están configurados:
   - InfluxDB_IIoT (por defecto)
   - MySQL_IIoT

### Crear Dashboard

Ver guía completa en: `/docs/grafana/provisioning/dashboards/README.md`

**Ejemplo Panel Temperatura (InfluxDB):**
1. Click **+ → Dashboard → Add visualization**
2. Seleccionar **InfluxDB_IIoT**
3. Query:
   ```flux
   from(bucket: "iiot_sensors")
     |> range(start: -1h)
     |> filter(fn: (r) => r._measurement == "temperature_sensor")
     |> filter(fn: (r) => r._field == "value")
     |> aggregateWindow(every: 1m, fn: mean)
   ```
4. Visualization: **Time series**
5. **Apply** → **Save**

**Ejemplo Panel Producción (MySQL):**
1. Add visualization → **MySQL_IIoT**
2. Query:
   ```sql
   SELECT 
     line_name,
     SUM(actual_quantity) as total_production
   FROM production_lines pl
   JOIN production_batches pb ON pl.line_id = pb.line_id
   WHERE pb.status = 'completed'
   GROUP BY line_name
   ```
3. Visualization: **Bar gauge**
4. **Apply** → **Save**

## 🐳 Comandos Útiles Docker

### Gestión de Servicios

```bash
# Ver status de todos los servicios
docker compose ps

# Ver logs de todos los servicios
docker compose logs -f

# Ver logs de un servicio específico
docker compose logs -f nodered

# Reiniciar un servicio
docker compose restart nodered

# Detener todos los servicios
docker compose down

# Iniciar servicios detenidos
docker compose up -d

# Reiniciar completamente (sin borrar datos)
docker compose restart
```

### Resetear Sistema Completamente

⚠️ **ADVERTENCIA**: Este comando **borra todos los datos** y vuelve al estado inicial.

```bash
# Detener servicios y eliminar volúmenes (datos)
docker compose down -v

# Reiniciar desde cero
docker compose up -d
```

**Útil para:**
- Iniciar nueva sesión de clase
- Resetear después de experimentación
- Resolver problemas de datos corruptos
- Múltiples grupos de estudiantes usando mismo ambiente

### Inspección y Troubleshooting

```bash
# Ver recursos usados
docker stats

# Entrar a un contenedor
docker exec -it iiot-nodered /bin/bash

# Ver redes Docker
docker network ls

# Ver volúmenes
docker volume ls

# Limpiar recursos no usados (cuidado)
docker system prune
```

## 🔧 Solución de Problemas Comunes

### Puerto Ocupado

**Error**: `Bind for 0.0.0.0:1880 failed: port is already allocated`

**Solución**:
```bash
# Ver qué proceso usa el puerto
lsof -i :1880  # macOS/Linux
netstat -ano | findstr :1880  # Windows

# Cambiar puerto en docker compose.yml
# Ejemplo: cambiar "1880:1880" a "1881:1880"
```

### Servicio No Inicia

**Síntomas**: `docker compose ps` muestra estado `Restarting` o `Unhealthy`

**Diagnóstico**:
```bash
# Ver logs del servicio problem ático
docker compose logs servicioName

# Verificar espacio en disco
df -h  # Linux/macOS
```

**Soluciones comunes**:
- Reiniciar Docker Desktop
- Aumentar recursos en Docker Desktop Settings
- Verificar que no hay conflictos de puertos

### Cannot Connect to Database

**Desde Node-RED/Grafana**:

1. Verificar servicios corriendo: `docker compose ps`
2. Usar nombres de servicio (no `localhost`):
   - ✅ `mysql:3306`
   - ✅ `influxdb:8086`
   - ❌ `localhost:3306`
3. Verificar credenciales en `.env`
4. Reiniciar servicio: `docker compose restart serviceName`

### Node-RED Flows No Cargan

```bash
# Verificar que flows.json existe
ls -la nodered/

# Ver logs de Node-RED
docker compose logs nodered

# Resetear Node-RED data (borra flows personalizados!)
docker compose down
docker volume rm iiot-nodered-data
docker compose up -d
```

### Performance Lento

**Causas**:
- Docker Desktop con pocos recursos
- Muchos contenedores corriendo
- Disco lleno

**Soluciones**:
```bash
# Aumentar RAM/CPU en Docker Desktop Settings
# Recomendado: 4 CPU, 8GB RAM

# Limpiar imágenes no usadas
docker image prune -a

# Verificar espacio
docker system df
```

## 📁 Estructura del Proyecto

```
/
├── docker compose.yml          # Orquestación de servicios
├── .env.example                # Template variables de entorno
├── .env                        # Variables de entorno (crear desde .example)
├── .gitignore                  # Archivos ignorados por git
│
├── mosquitto/                  # Configuración MQTT Broker
│   └── config/
│       ├── mosquitto.conf      # Configuración principal
│       └── acl.conf            # Control de acceso (ejemplo)
│
├── nodered/                    # Node-RED
│   ├── Dockerfile              # Imagen custom con paquetes IIoT
│   ├── flows.json              # Flujos pre-configurados
│   └── README.md               # Documentación flujos
│
├── mysql/                      # MySQL
│   └── init/
│       └── init.sql            # Schema y datos de ejemplo
│
├── influxdb/                   # InfluxDB
│   └── init/
│       └── init.sh             # Script de inicialización
│
├── grafana/                    # Grafana
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml # Config datasources automáticas
│       └── dashboards/
│           ├── dashboards.yml  # Config provisioning dashboards
│           └── README.md       # Guía crear dashboards
│
└──README.md                   # Este archivo
```

## 🎯 Flujos de Trabajo Típicos

### Para Estudiantes

1. **Exploración Inicial** (10 min)
   - Abrir todos los servicios en navegador
   - Familiarizarse con interfaces
   - Ver datos fluyendo en Node-RED debug

2. **Consultas Básicas** (15 min)
   - Ejecutar queries de ejemplo en Adminer (MySQL)
   - Ejecutar queries en InfluxDB UI
   - Comparar resultados

3. **Crear Dashboard** (20 min)
   - Seguir guía Grafana
   - Crear panel de temperatura
   - Crear panel de producción

4. **Ejercicios** (variable)
   - Completar ejercicios en EJERCICIOS.md
   - Experimentar con Node-RED flows
   - Probar scripts Python MQTT

## 🏭 Factory I/O - Integración Opcional (Avanzado)

### ⚠️ Importante

Factory I/O es **opcional** y **no necesario** para el funcionamiento del sistema principal. El sistema tiene simuladores integrados en Node-RED.

### Requisitos

- Windows (Factory I/O es solo Windows)
- Factory I/O instalado (versión trial o educacional)
- Docker Desktop en mismo host Windows

### Configuración

1. **Instalar Factory I/O**
   - Descargar de https://factoryio.com/
   - Instalar versión Educational o Trial

2. **Habilitar OPC-UA Server**
   - Abrir Factory I/O
   - File → Drivers → OPC UA
   - Configuration → Port: 4840
   - Security: None
   - CONNECT

3. **Configurar Firewall Windows**
   ```powershell
   New-NetFirewallRule -DisplayName "Factory I/O OPC-UA" `
     -Direction Inbound -Protocol TCP -LocalPort 4840 -Action Allow
   ```

4. **Habilitar Flujo en Node-RED**
   - Abrir Node-RED: http://localhost:1880
   - Localizar pestaña "🏭 Factory I/O - OPC-UA (DESHABILITADO)"
   - Click derecho → Enable
   - Deploy

### Verificar Conectividad

```bash
# Desde Node-RED, verificar endpoint: opc.tcp://host.docker.internal:4840
# Debe mostrar "connected" (punto verde)
```

### Troubleshooting Factory I/O

Ver sección completa en documentación adicional.

## 🆘 Soporte y Recursos

### Recursos de Aprendizaje

**Docker:**
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Quickstart](https://docs.docker.com/compose/gettingstarted/)

**InfluxDB:**
- [InfluxDB Docs](https://docs.influxdata.com/influxdb/v2/)
- [Flux Language Guide](https://docs.influxdata.com/flux/v0/get-started/)

**MySQL:**
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [SQL Tutorial](https://www.w3schools.com/sql/)

**MQTT:**
- [MQTT.org](https://mqtt.org/)
- [HiveMQ MQTT Essentials](https://www.hivemq.com/mqtt-essentials/)

**Grafana:**
- [Grafana Documentation](https://grafana.com/docs/)
- [Grafana Tutorials](https://grafana.com/tutorials/)

**Node-RED:**
- [Node-RED Documentation](https://nodered.org/docs/)
- [Node-RED Cookbook](https://cookbook.nodered.org/)

### Contacto

Para dudas sobre el curso, contactar al instructor.

## 📄 Licencia

Este proyecto es material educativo para uso en curso universitario.

## 🎓 Créditos

**Versión**: 1.0  
**Última Actualización**: Febrero 2026  
**Instructor**: Christian Spana


---

**¿Listo para empezar?**

```bash
docker compose up -d
```

Luego abrir http://localhost:1880 para ver Node-RED en acción! 🚀

