# IIoT System - Relational and Non-Relational Databases

> 🇺🇸 **English** | [🇪🇸 Español](README.es.md)

**Course**: Using Databases in Industrial IoT Operational Technologies  
**Duration**: 1 hour (60 minutes)  
**Instructor**: **Christian Spana**

## 📋 Project Overview

This project provides a complete Docker environment for teaching and demonstrating the use of relational (MySQL) and non-relational (InfluxDB) databases in Industrial Internet of Things (IIoT) contexts.

### Learning Objectives

1. Understand differences between SQL and NoSQL databases
2. Identify when to use each database type in IIoT
3. Implement **Polyglot Persistence** concept
4. Work with MQTT as IIoT communication protocol
5. Visualize real-time data with Grafana
6. Apply ACID concepts in relational transactions

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  SENSORS / SIMULATORS                       │
│  Node-RED (simulators) | Factory I/O | Python Scripts       │
└────────────────┬────────────────────────────────────────────┘
                 │ MQTT Publish
                 ▼
┌─────────────────────────────────────────────────────────────┐
│              MOSQUITTO BROKER (Port 1883)                   │
│              MQTT Communication Hub                         │
└────────────────┬────────────────────────────────────────────┘
                 │ MQTT Subscribe
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                NODE-RED (Port 1880)                         │
│          Processing, Validation, Routing                    │
└───────┬─────────────────────────────────────────┬───────────┘
        │                                         │
        ▼                                         ▼
┌──────────────────┐                    ┌──────────────────┐
│  INFLUXDB (8086) │                    │  MYSQL (3306)    │
│  Time-Series DB  │                    │  Relational DB   │
│                  │                    │                  │
│ • Temperature    │                    │ • Production     │
│ • Pressure       │                    │ • Quality        │
│ • Vibration      │                    │ • Alerts         │
│ High Frequency   │                    │ Transactions     │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         └──────────────┬────────────────────────┘
                        │ Read Queries
                        ▼
              ┌──────────────────┐
              │ GRAFANA (3000)   │
              │  Visualization   │
              │  Dashboards      │
              └──────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** 20.10+ installed ([Download here](https://www.docker.com/products/docker-desktop))
- **Docker Compose** included with Docker Desktop
- **8GB RAM** minimum (16GB recommended)
- **10GB disk space** available
- **Factory I/O** (optional, for advanced Windows integration only)

### Installation

1. **Clone or download the project**
   ```bash
   # If you have git:
   git clone git@github.com:lukaswarce/iiot-relational-nosql-system.git
   cd iiot-relational-nosql-system
   
   # Or download ZIP and extract
   ```

2. **Configure environment variables** (optional)
   ```bash
   cp .env.example .env
   # Edit .env to change credentials if needed (defaults are for educational use)
   ```

3. **Start the system**
   ```bash
   docker compose up -d
   ```
   
   This command:
   - Downloads required Docker images (~2-3 GB)
   - Creates containers
   - Starts all services
   - Estimated time (first run): 5-10 minutes

4. **Verify services**
   ```bash
   docker compose ps
   ```
   
   All services should show status **`Up`**.

## 🌐 Access Services

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| **Grafana** | http://localhost:3000 | `admin` / `admin` | Data visualization & dashboards |
| **Node-RED** | http://localhost:1880 | No auth | Data flow orchestration |
| **InfluxDB UI** | http://localhost:8086 | `admin` / `adminpassword` | Time-series database console |
| **Adminer** | http://localhost:8080 | See MySQL below | MySQL web interface |
| **MySQL** | `localhost:3306` | `root` / `rootpassword` | Relational database |
| **Mosquitto** | `localhost:1883` | Anonymous | MQTT broker |

### MySQL Access via Adminer

1. Open http://localhost:8080
2. Fill in:
   - **System**: MySQL
   - **Server**: `mysql` (internal Docker network name)
   - **Username**: `root`
   - **Password**: `rootpassword`
   - **Database**: `iiot_system`

## 📊 What is Polyglot Persistence?

**Polyglot Persistence** means using different database technologies optimized for specific data types and access patterns within the same system.

### Why Use Multiple Databases?

| Aspect | MySQL (Relational) | InfluxDB (Time-Series) |
|--------|-------------------|------------------------|
| **Data Type** | Transactional, structured | Time-stamped sensor data |
| **Query Pattern** | Complex JOINs, relations | Time range aggregations |
| **Write Volume** | Medium (100s/sec) | High (1000s-10000s/sec) |
| **Data Retention** | Long-term storage | Downsampling + retention policies |
| **ACID** | Full ACID guarantees | Eventual consistency |
| **Best For** | Orders, users, inventory | Temperature, pressure, metrics |

### In This Project

- **MySQL stores**: Production batches, quality inspections, alerts, events (transactional data)
- **InfluxDB stores**: Temperature, pressure, vibration readings (time-series sensor data)

## 📚 Documentation

Comprehensive documentation available in both languages:

### 🇺🇸 English Documentation
- [MQTT Quick Guide](docs/en/MQTT-QUICK-GUIDE.md) - Learn MQTT protocol basics
- [Query Examples](docs/en/QUERY-EXAMPLES.md) - SQL and Flux practical examples
- [Exercises](docs/en/EXERCISES.md) - Hands-on assignments with rubrics
- [Troubleshooting Guide](#-troubleshooting) - Common issues and solutions

### 🇪🇸 Documentación en Español
- [Guía Rápida MQTT](docs/es/MQTT-GUIA-RAPIDA.md) - Fundamentos del protocolo MQTT
- [Ejemplos de Consultas](docs/es/CONSULTAS-EJEMPLO.md) - Ejemplos prácticos SQL y Flux
- [Ejercicios](docs/es/EJERCICIOS.md) - Actividades prácticas con rúbricas
- [Solución de Problemas](#-solución-de-problemas) - Problemas comunes y soluciones

### Additional Resources
- [Technical Glossary](GLOSSARY.md) - Bilingual technical terms reference
- [Contributing Guide](CONTRIBUTING.md) - How to contribute (includes translation workflow)
- **Instructor Guides**: Available in private `instructor` branch

## 🎯 Recommended Learning Path

1. **Start services** - Follow Quick Start above
2. **Explore MQTT** - Read [MQTT Quick Guide](docs/en/MQTT-QUICK-GUIDE.md) and test with `mosquitto_pub`/`mosquitto_sub`
3. **Inspect databases** - Connect to MySQL via Adminer and InfluxDB UI
4. **Practice queries** - Try examples from [Query Examples](docs/en/QUERY-EXAMPLES.md)
5. **Create dashboards** - Build Grafana visualizations
6. **Complete exercises** - Work through [Exercises](docs/en/EXERCISES.md)

## 🛠️ Useful Commands

### Docker Management
```bash
# Start all services
docker compose up -d

# Stop all services (data persists)
docker compose stop

# View logs
docker compose logs -f [service_name]

# Restart a service
docker compose restart [service_name]

# Remove all containers and volumes (DELETES ALL DATA)
docker compose down -v
```

### MQTT Testing
```bash
# Subscribe to all topics
docker exec -it mosquitto mosquitto_sub -h localhost -t '#' -v

# Publish test message
docker exec -it mosquitto mosquitto_pub -h localhost -t 'iiot/factory/line1/temp' -m '{"value": 75.5}'

# Monitor specific sensor
docker exec -it mosquitto mosquitto_sub -h localhost -t 'iiot/factory/+/temp' -v
```

### Database Console Access
```bash
# MySQL CLI
docker exec -it mysql mysql -uroot -prootpassword iiot_system

# InfluxDB CLI
docker exec -it influxdb influx
```

## 🔧 Troubleshooting

<details>
<summary><strong>Services not starting / Port conflicts</strong></summary>

Check if ports are already in use:
```bash
# macOS/Linux
lsof -i :3000,1880,8086,3306,1883,8080

# Windows
netstat -ano | findstr "3000 1880 8086 3306 1883 8080"
```

Solution: Stop conflicting applications or modify ports in `docker-compose.yml`.
</details>

<details>
<summary><strong>Cannot connect to databases</strong></summary>

1. Verify containers are running: `docker compose ps`
2. Check logs: `docker compose logs mysql` or `docker compose logs influxdb`
3. Wait 30 seconds after startup for initialization
4. Verify Docker network: `docker network inspect iiot-network`
</details>

<details>
<summary><strong>No data in InfluxDB</strong></summary>

1. Check Node-RED flows are deployed (http://localhost:1880)
2. Verify MQTT messages arriving: 
   ```bash
   docker exec -it mosquitto mosquitto_sub -h localhost -t '#' -v
   ```
3. Check Node-RED logs: `docker compose logs node-red`
4. Generate test data using `scripts/generate_data.py`
</details>

<details>
<summary><strong>Grafana dashboards empty</strong></summary>

1. Verify datasources configured: Grafana → Configuration → Data Sources
2. Test datasource connections
3. Check data exists in databases (MySQL via Adminer, InfluxDB via UI)
4. Use dashboard templates from `grafana/provisioning/dashboards/`
</details>

## 📁 Project Structure

```
.
├── docker-compose.yml          # Service orchestration
├── README.md                   # This file (English)
├── README.es.md                # Versión en español
├── GLOSSARY.md                 # Technical terms bilingual reference
├── LICENSE                     # MIT License
├── CONTRIBUTING.md             # Contribution guidelines
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore rules
├── docs/
│   ├── en/                     # English documentation
│   │   ├── MQTT-QUICK-GUIDE.md
│   │   ├── QUERY-EXAMPLES.md
│   │   └── EXERCISES.md
│   └── es/                     # Documentación en español
│       ├── MQTT-GUIA-RAPIDA.md
│       ├── CONSULTAS-EJEMPLO.md
│       └── EJERCICIOS.md
├── scripts/
│   ├── generate_data.py        # MQTT test data generator
│   └── health_check.sh         # System health checker
├── mysql/
│   └── init/
│       ├── init.sql            # Schema + sample data
│       └── schema.sql          # Database schema only
├── influxdb/
│   └── init/
│       └── init.sh             # InfluxDB initialization
├── mosquitto/
│   └── config/
│       └── mosquitto.conf      # MQTT broker configuration
├── nodered/
│   ├── Dockerfile              # Custom Node-RED image
│   ├── flows.json              # Pre-configured flows
│   └── README.md               # Flow documentation
├── grafana/
│   └── provisioning/
│       ├── datasources/        # Auto-configured datasources
│       └── dashboards/         # Dashboard templates
└── diagramas/                  # Architecture diagrams (HTML)
```

## 🎓 About the Instructor

**Christian Spana** is the course instructor specializing in Industrial IoT, database systems, and operational technology. This project was developed as an educational resource for teaching polyglot persistence patterns in industrial contexts.

**Contact**: For course-related questions, contact through your institution's learning management system.

## 🤝 Contributing

Contributions are welcome! This is an educational project and we encourage:

- Bug fixes and improvements
- Translation corrections (Spanish ↔ English)
- Additional exercises or examples
- Documentation enhancements

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines, including the translation workflow.

## 📜 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

**Educational Use**: This project is designed for academic purposes. For production IIoT deployments, implement proper security measures (authentication, TLS/SSL, network isolation, access controls).

## 🙏 Credits

- **Instructor & Author**: Christian Spana
- **Repository Maintainer**: LukasWarCE
- **Course**: Using Databases in Industrial IoT Operational Technologies
- **Technologies**: Docker, MySQL, InfluxDB, MQTT (Mosquitto), Node-RED, Grafana

## 📞 Support

- **Documentation**: Check [docs/en/](docs/en/) for detailed guides
- **Issues**: Report bugs via [GitHub Issues](https://github.com/lukaswarce/iiot-relational-nosql-system/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/lukaswarce/iiot-relational-nosql-system/discussions) for Q&A
- **Wiki**: Visit the [GitHub Wiki](https://github.com/lukaswarce/iiot-relational-nosql-system/wiki) for additional tutorials

---

** [View in Spanish 🇪🇸](README.es.md)
