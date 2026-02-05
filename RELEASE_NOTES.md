# Release Notes v1.0.0 / Notas de Lanzamiento v1.0.0

> 🇺🇸 **English** | 🇪🇸 **Español**

**Release Date / Fecha de Lanzamiento**: February 5, 2026  
**Version**: 1.0.0

---

## 🎉 Initial Release / Lanzamiento Inicial

First stable release of the IIoT educational system demonstrating polyglot persistence with MySQL and InfluxDB.

Primer lanzamiento estable del sistema educativo IIoT que demuestra persistencia políglota con MySQL e InfluxDB.

---

## ✨ Features / Características

### 🏗️ Architecture / Arquitectura

- **6 Docker Services / 6 Servicios Docker**:
  - Mosquitto (MQTT Broker)
  - Node-RED (Data Orchestration / Orquestación de Datos)
  - MySQL (Relational Database / Base de Datos Relacional)
  - InfluxDB (Time-Series Database / Base de Datos de Series Temporales)
  - Grafana (Visualization / Visualización)
  - Adminer (MySQL Web Interface / Interfaz Web MySQL)

- **One-Command Startup / Inicio con Un Comando**: `docker compose up -d`
- **Persistent Data / Datos Persistentes**: Docker volumes for all services / Volúmenes Docker para todos los servicios
- **Custom Network / Red Personalizada**: Isolated `iiot-network` for inter-service communication / Red `iiot-network` aislada para comunicación entre servicios

### 📚 Documentation / Documentación

#### 🌍 Bilingual Support / Soporte Bilingüe
- **English** and **Spanish** versions of all documentation / Versiones en **inglés** y **español** de toda la documentación
- Language selector on all pages / Selector de idioma en todas las páginas
- Technical glossary for translation consistency / Glosario técnico para consistencia de traducciones

#### 📖 Comprehensive Guides / Guías Comprensivas
- **README**: Quick start and system overview / Inicio rápido y vista general del sistema
- **MQTT Quick Guide**: Protocol fundamentals and practical examples / Fundamentos del protocolo y ejemplos prácticos
- **Query Examples**: 10+ SQL and 10+ Flux query examples / 10+ ejemplos SQL y 10+ ejemplos Flux
- **Exercises**: 4 structured assignments with rubrics / 4 actividades estructuradas con rúbricas
- **Troubleshooting**: Common issues and solutions / Problemas comunes y soluciones

### 🗄️ Database Features / Características de Bases de Datos

#### MySQL (Relational / Relacional)
- 7 tables demonstrating industrial data model / 7 tablas demostrando modelo de datos industrial
- Foreign keys and referential integrity / Llaves foráneas e integridad referencial
- 2 views for common queries / 2 vistas para consultas comunes
- 1 stored procedure with ACID transactions / 1 procedimiento almacenado con transacciones ACID
- Sample data for 5 production lines / Datos de muestra para 5 líneas de producción

#### InfluxDB (Time-Series / Series Temporales)
- Pre-configured bucket: `iiot_sensors`
- Measurements: temperature, pressure, vibration / Mediciones: temperatura, presión, vibración
- Tag-based indexing for fast queries / Indexación basada en tags para consultas rápidas
- Infinite retention for educational use / Retención infinita para uso educativo

### 🔧 Automation & Tools / Automatización y Herramientas

- **GitHub Actions**:
  - Translation sync checker / Verificador de sincronización de traducciones
  - Markdown link checker / Verificador de enlaces markdown
  - Automatic issue creation / Creación automática de issues

- **Helper Scripts / Scripts de Ayuda**:
  - `scripts/generate_data.py`: MQTT test data generator / Generador de datos de prueba MQTT
  - `scripts/health_check.sh`: System health monitor / Monitor de salud del sistema

### 📊 Visualization / Visualización

- Pre-configured Grafana datasources / Fuentes de datos pre-configuradas en Grafana
- Dashboard templates and examples / Plantillas y ejemplos de dashboards
- Real-time monitoring capabilities / Capacidades de monitoreo en tiempo real

---

## 🎓 Educational Features / Características Educativas

### For Students / Para Estudiantes

- **Progressive Learning / Aprendizaje Progresivo**: Concepts build from simple to advanced / Conceptos construyen de simple a avanzado
- **Hands-On Practice / Práctica Práctica**: Executable examples in all guides / Ejemplos ejecutables en todas las guías
- **Real-World Scenarios / Escenarios del Mundo Real**: Industrial IoT use cases / Casos de uso de IoT Industrial
- **Comprehensive Exercises / Ejercicios Comprensivos**: 4 assignments with clear rubrics / 4 actividades con rúbricas claras

### For Instructors / Para Instructores

- **Private Branch / Rama Privada**: `instructor` branch for sensitive materials / Rama `instructor` para materiales sensibles
- **Demonstration Guides / Guías de Demostración**: Step-by-step teaching materials / Materiales de enseñanza paso a paso
- **Assessment Tools / Herramientas de Evaluación**: Rubrics and grading criteria / Rúbricas y criterios de calificación
- **Extensible / Extensible**: Easy to add custom exercises / Fácil agregar ejercicios personalizados

---

## 🔐 Security & Best Practices / Seguridad y Mejores Prácticas

- **Educational Defaults / Valores Predeterminados Educativos**: Simple credentials for learning / Credenciales simples para aprendizaje
- **Security Warnings / Advertencias de Seguridad**: Clear notes on production considerations / Notas claras sobre consideraciones de producción
- **MIT License**: Open source with educational use notice / Código abierto con aviso de uso educativo
- **Contributing Guidelines**: Clear process for community contributions / Proceso claro para contribuciones de la comunidad

---

## 📦 What's Included / Qué Está Incluido

```
iiot-relational-nosql-system/
├── README.md & README.es.md      # Bilingual documentation
├── LICENSE                        # MIT License
├── CONTRIBUTING.md                # Contribution guidelines
├── CONTRIBUTORS.md                # Credits
├── GLOSSARY.md                    # Technical terms reference
├── .github/workflows/             # CI/CD automation
├── docs/
│   ├── en/                        # English documentation
│   └── es/                        # Documentación en español
├── scripts/                       # Helper tools
├── docker-compose.yml             # Service orchestration
├── mysql/init/                    # Database schemas
├── influxdb/init/                 # InfluxDB setup
├── mosquitto/config/              # MQTT broker config
├── nodered/                       # Pre-configured flows
├── grafana/provisioning/          # Datasources & dashboards
└── diagramas/                     # Architecture diagrams
```

---

## 🚀 Getting Started / Primeros Pasos

### Prerequisites / Prerrequisitos
- Docker Desktop 20.10+
- 8GB RAM (16GB recommended / recomendado)
- 10GB disk space / espacio en disco

### Installation / Instalación
```bash
git clone git@github.com:lukaswarce/iiot-relational-nosql-system.git
cd iiot-relational-nosql-system
docker compose up -d
```

### Access / Acceso
- Grafana: http://localhost:3000
- Node-RED: http://localhost:1880
- InfluxDB: http://localhost:8086
- Adminer: http://localhost:8080

---

## 🙏 Credits / Créditos

- **Instructor & Author / Instructor y Autor**: Christian Spana
- **Repository Maintainer / Mantenedor del Repositorio**: LukasWarCE
- **Course / Curso**: Using Databases in Industrial IoT Operational Technologies

---

## 📞 Support / Soporte

- **Documentation / Documentación**: [docs/en/](docs/en/) | [docs/es/](docs/es/)
- **Issues**: https://github.com/lukaswarce/iiot-relational-nosql-system/issues
- **Discussions**: https://github.com/lukaswarce/iiot-relational-nosql-system/discussions
- **Wiki**: https://github.com/lukaswarce/iiot-relational-nosql-system/wiki

---

## 🔮 Future Plans / Planes Futuros

- Additional language support / Soporte para idiomas adicionales
- Video tutorials / Tutoriales en video
- Advanced exercises / Ejercicios avanzados
- Factory I/O integration guide / Guía de integración Factory I/O
- Performance benchmarking tools / Herramientas de benchmarking de rendimiento
- Cloud deployment guides / Guías de despliegue en la nube

---

## 📜 License / Licencia

MIT License - See [LICENSE](LICENSE) for details / Ver [LICENSE](LICENSE) para detalles

**Educational Use**: This project is designed for academic purposes. Production deployments require additional security measures.

**Uso Educativo**: Este proyecto está diseñado para propósitos académicos. Despliegues en producción requieren medidas de seguridad adicionales.

