# Technical Glossary / Glosario Técnico

> 🇺🇸 **English** | 🇪🇸 **Español**

This glossary lists technical terms that should **NOT be translated** when working with this project. These terms are industry-standard and should remain in English even in Spanish documentation.

Este glosario lista términos técnicos que **NO deben traducirse** al trabajar con este proyecto. Estos términos son estándar en la industria y deben permanecer en inglés incluso en documentación en español.

---

## 🔧 Technologies / Tecnologías

| Term | Spanish Context | Notes |
|------|-----------------|-------|
| Docker | usar Docker | Container platform |
| Docker Compose | archivo docker-compose.yml | Orchestration tool |
| MySQL | base de datos MySQL | Relational database |
| InfluxDB | almacenar en InfluxDB | Time-series database |
| Grafana | crear dashboard en Grafana | Visualization platform |
| Node-RED | flujo de Node-RED | Flow-based programming |
| Mosquitto | broker Mosquitto | MQTT broker implementation |
| Adminer | interfaz web Adminer | Database management tool |

## 📡 MQTT Protocol / Protocolo MQTT

| Term | Spanish Context | Explanation ES | Explanation EN |
|------|-----------------|----------------|----------------|
| MQTT | protocolo MQTT | Message Queuing Telemetry Transport | Message Queuing Telemetry Transport |
| Broker | conectar al broker | Servidor central de mensajería | Central message server |
| Publisher | actuar como publisher | Publicador de mensajes | Message publisher |
| Subscriber | registrarse como subscriber | Suscriptor a tópicos | Topic subscriber |
| Topic | publicar en un topic | Canal de comunicación | Communication channel |
| Payload | contenido del payload | Datos del mensaje | Message data |
| QoS | nivel de QoS | Quality of Service (0, 1, 2) | Quality of Service (0, 1, 2) |
| Retained Message | mensaje retained | Mensaje persistente | Persistent message |
| Last Will and Testament (LWT) | mensaje LWT | Último mensaje del cliente | Client's last message |
| Wildcard | usar wildcard | Comodín en topics (+, #) | Topic pattern (+, #) |

## 🗄️ Database Terms / Términos de Bases de Datos

### SQL Keywords (Keep in English / Mantener en inglés)

| Keyword | Spanish Context | Usage |
|---------|-----------------|-------|
| SELECT | consulta SELECT | Query data |
| FROM | tabla FROM | Specify table |
| WHERE | condición WHERE | Filter rows |
| JOIN | hacer JOIN | Combine tables |
| INNER JOIN | usar INNER JOIN | Inner join |
| LEFT JOIN | aplicar LEFT JOIN | Left outer join |
| GROUP BY | agrupar con GROUP BY | Aggregate data |
| ORDER BY | ordenar con ORDER BY | Sort results |
| HAVING | filtro HAVING | Filter groups |
| INSERT INTO | comando INSERT INTO | Add data |
| UPDATE | sentencia UPDATE | Modify data |
| DELETE | usar DELETE | Remove data |
| CREATE TABLE | crear tabla con CREATE TABLE | Define table |
| ALTER TABLE | modificar con ALTER TABLE | Change structure |
| PRIMARY KEY | definir PRIMARY KEY | Primary key constraint |
| FOREIGN KEY | agregar FOREIGN KEY | Foreign key constraint |
| INDEX | crear INDEX | Index for performance |
| VIEW | definir VIEW | Virtual table |
| STORED PROCEDURE | procedimiento STORED PROCEDURE | Stored procedure |
| TRIGGER | disparador TRIGGER | Database trigger |
| TRANSACTION | iniciar TRANSACTION | Transaction block |
| COMMIT | ejecutar COMMIT | Commit changes |
| ROLLBACK | hacer ROLLBACK | Undo changes |
| START TRANSACTION | comenzar con START TRANSACTION | Begin transaction |

### Flux Functions (Keep in English / Mantener en inglés)

| Function | Spanish Context | Purpose |
|----------|-----------------|---------|
| from() | función from() | Data source |
| range() | filtrar con range() | Time range |
| filter() | aplicar filter() | Row filtering |
| aggregateWindow() | usar aggregateWindow() | Time-based aggregation |
| mean() | calcular mean() | Average value |
| sum() | sumar con sum() | Total sum |
| count() | contar con count() | Count rows |
| min() | obtener min() | Minimum value |
| max() | obtener max() | Maximum value |
| yield() | retornar con yield() | Return results |
| group() | agrupar con group() | Group data |
| pivot() | pivotear con pivot() | Reshape data |
| map() | transformar con map() | Transform rows |
| reduce() | reducir con reduce() | Aggregate rows |
| join() | combinar con join() | Merge tables |
| \|> | operador pipe \|> | Pipe operator |

## 🏭 IIoT Concepts / Conceptos IIoT

| Term | Spanish Context | Explanation ES | Explanation EN |
|------|-----------------|----------------|----------------|
| IIoT | sistema IIoT | Industrial Internet of Things | Industrial Internet of Things |
| Sensor | datos del sensor | Dispositivo de medición | Measurement device |
| Time-Series | datos time-series | Serie temporal | Time-ordered data |
| Polyglot Persistence | arquitectura polyglot persistence | Múltiples bases de datos | Multiple database types |
| ACID | propiedades ACID | Atomicity, Consistency, Isolation, Durability | Atomicity, Consistency, Isolation, Durability |
| Downsampling | aplicar downsampling | Reducción de resolución | Reduce data resolution |
| Retention Policy | política retention | Tiempo de retención | Data retention time |
| Bucket | almacenar en bucket | Contenedor de datos InfluxDB | InfluxDB data container |
| Measurement | definir measurement | Tabla en InfluxDB | InfluxDB table equivalent |
| Tag | usar tag | Índice en InfluxDB | InfluxDB index |
| Field | campo field | Valor en InfluxDB | InfluxDB value |

## 🐳 Docker Terms / Términos Docker

| Term | Spanish Context | Usage |
|------|-----------------|-------|
| Container | iniciar container | Isolated environment |
| Image | descargar image | Container template |
| Volume | persistir con volume | Persistent storage |
| Network | red network | Container networking |
| Service | levantar service | Composed application unit |
| Compose | archivo compose | Multi-container definition |
| docker compose up | ejecutar docker compose up | Start services |
| docker compose down | ejecutar docker compose down | Stop services |
| docker exec | usar docker exec | Run command in container |
| docker logs | ver docker logs | View logs |
| docker ps | listar con docker ps | List containers |

## 📊 Data Terms / Términos de Datos

| Term | Spanish Context | Explanation ES | Explanation EN |
|------|-----------------|----------------|----------------|
| Schema | definir schema | Estructura de base de datos | Database structure |
| Table | crear table | Tabla relacional | Relational table |
| Column | agregar column | Columna de tabla | Table column |
| Row | insertar row | Fila de datos | Data row |
| Index | optimizar con index | Índice de búsqueda | Search index |
| Constraint | aplicar constraint | Restricción de integridad | Integrity constraint |
| Timestamp | agregar timestamp | Marca temporal | Time mark |
| Query | ejecutar query | Consulta de datos | Data query |
| Dashboard | crear dashboard | Panel de visualización | Visualization panel |
| Panel | agregar panel | Componente de dashboard | Dashboard component |

## 🛠️ Commands / Comandos

These commands should **always** remain in English:

Estos comandos deben **siempre** permanecer en inglés:

```bash
# Docker commands / Comandos Docker
docker compose up -d
docker compose down
docker compose ps
docker compose logs
docker exec -it

# MQTT commands / Comandos MQTT
mosquitto_pub
mosquitto_sub

# MySQL commands / Comandos MySQL
mysql -u root -p
SHOW DATABASES;
USE database_name;
DESCRIBE table_name;

# InfluxDB commands / Comandos InfluxDB
influx
buckets()
measurements()
```

## 📁 File Names / Nombres de Archivos

| File Type | Example | Keep As-Is |
|-----------|---------|------------|
| Configuration | docker-compose.yml | ✅ Yes |
| Configuration | mosquitto.conf | ✅ Yes |
| Flows | flows.json | ✅ Yes |
| Credentials | flows_cred.json | ✅ Yes |
| Schema | schema.sql | ✅ Yes |
| Init Script | init.sql | ✅ Yes |
| Dockerfile | Dockerfile | ✅ Yes |
| Environment | .env | ✅ Yes |
| Gitignore | .gitignore | ✅ Yes |
| README | README.md | ✅ Yes |

## 🌐 Network Terms / Términos de Red

| Term | Spanish Context | Explanation |
|------|-----------------|-------------|
| localhost | conectar a localhost | Local machine address (127.0.0.1) |
| host.docker.internal | usar host.docker.internal | Docker host from container |
| Port | puerto 3306 | Network port number |
| Endpoint | llamar al endpoint | API endpoint |
| URL | acceder a la URL | Uniform Resource Locator |
| HTTP | protocolo HTTP | Hypertext Transfer Protocol |
| WebSocket | conexión WebSocket | Bidirectional communication |

## 🔐 Security Terms / Términos de Seguridad

| Term | Spanish Context | Notes |
|------|-----------------|-------|
| Username | ingresar username | User identifier |
| Password | configurar password | Authentication secret |
| Token | usar token | Authentication token |
| Authentication | configurar authentication | User verification |
| Authorization | permisos de authorization | Access control |
| TLS/SSL | habilitar TLS | Encryption protocol |
| Anonymous | acceso anonymous | No authentication |

## 📝 Best Practices / Mejores Prácticas

### When writing documentation / Al escribir documentación:

✅ **DO / HACER:**
- Keep technical terms in English / Mantener términos técnicos en inglés
- Translate explanations / Traducir explicaciones
- Keep code examples unchanged / Mantener ejemplos de código sin cambios
- Preserve command syntax / Preservar sintaxis de comandos

❌ **DON'T / NO HACER:**
- Translate SQL keywords / Traducir palabras clave SQL
- Translate Flux functions / Traducir funciones Flux
- Translate service names / Traducir nombres de servicios
- Translate file extensions / Traducir extensiones de archivo

### Examples / Ejemplos:

✅ **Correct / Correcto:**
- "Ejecuta el comando `docker compose up -d` para iniciar los servicios"
- "Use the `SELECT` statement to query data from MySQL"

❌ **Incorrect / Incorrecto:**
- "Ejecuta el comando `componedor de docker arriba -d` para iniciar los servicios"
- "Usa la sentencia `SELECCIONAR` para consultar datos de MySQL"

---

## 🤝 Contributing / Contribuir

When contributing translations, always refer to this glossary. If you find a term that should be added, please submit a pull request.

Al contribuir traducciones, siempre consulta este glosario. Si encuentras un término que debería agregarse, por favor envía un pull request.

---

**Last Updated / Última Actualización**: February 5, 2026  
**Maintained by / Mantenido por**: Christian Spana & LukasWarCE
