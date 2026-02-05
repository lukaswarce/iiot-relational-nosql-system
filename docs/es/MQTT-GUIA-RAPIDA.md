# MQTT - Guía Rápida para Estudiantes

**Protocolo de Mensajería para IIoT**

---

## 📋 ¿Qué es MQTT?

**MQTT** = Message Queuing Telemetry Transport

**Definición Simple**:
> Protocolo de mensajería ligero diseñado para dispositivos con recursos limitados y redes con ancho de banda bajo o poco confiable.

**Analogía**:
> MQTT es como una estación de radio 📻:
> - **Estación (Broker)**: Transmite señal
> - **DJ (Publisher)**: Publica contenido
> - **Oyentes (Subscribers)**: Sintonizan canal de interés
> - **Frecuencias (Topics)**: Canales específicos

---

## 🏗️ Arquitectura MQTT

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│         📱 PUBLISHERS (Publicadores)                │
│    Sensores, PLCs, Apps  que ENVÍAN mensajes        │
│                                                     │
│    ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐           │
│    │Sensor│  │Sensor│  │PLC   │  │App   │           │
│    │Temp  │  │Pres  │  │M1    │  │Web   │           │
│    └───┬──┘  └───┬──┘  └───┬──┘  └───┬──┘           │
│        │         │         │         │              │
│        └─────────┴─────────┴─────────┘              │
│                    ↓ PUBLISH                        │
│        ┌───────────────────────────┐                │
│        │   ☁️ BROKER (Mosquitto)   │                │
│        │   - Recibe mensajes       │                │
│        │   - Rutea a suscriptores  │                │
│        │   - Almacena (retained)   │                │
│        └───────────┬───────────────┘                │
│                    ↓ SUBSCRIBE                      │
│        ┌─────────┬─┴───────┬───────────┐            │
│        │         │         │           │            │
│    ┌───▼──┐  ┌───▼──┐  ┌───▼──┐    ┌───▼──┐         │
│    │DB    │  │Grafana│ │App   │    │Logger│         │
│    │Influx│  │Dash  │  │Mobile│    │File  │         │
│    └──────┘  └──────┘  └──────┘    └──────┘         │
│                                                     │
│        💾 SUBSCRIBERS (Suscriptores)                │
│    Apps, Databases que RECIBEN mensajes             │
│                                                     │
└─────────────────────────────────────────────────────┘

🔑 CLAVE: Publishers y Subscribers NO se conocen
          (Desacoplamiento total)
```

---

## 📡 Conceptos Fundamentales

### 1. Broker (Intermediario)

**Definición**: Servidor central que recibe y distribuye mensajes.

**En este proyecto**: Mosquitto (`localhost:1883`)

**Responsabilidades**:
- ✅ Aceptar conexiones de clientes
- ✅ Recibir mensajes publicados
- ✅ Filtrar por topics
- ✅ Distribuir a suscriptores apropiados
- ✅ Gestionar retained messages
- ✅ Implementar QoS (Quality of Service)

---

### 2. Topics (Temas)

**Definición**: Canales jerárquicos de comunicación.

**Estructura**:
```
nivel1/nivel2/nivel3/...

Ejemplos:
iiot/sensores/temperatura
iiot/sensores/presion
iiot/actuadores/valvula1
empresa/fabrica1/linea2/maquina5/temp
```

**Reglas**:
- ✅ Separados por `/` (slash)
- ✅ Case-sensitive: `TEMP` ≠ `temp`
- ✅ No empezar con `/`
- ✅ Máximo 65,535 caracteres
- ✅ Evitar espacios (usar `_`)

**Topics Especiales**:
- `$SYS/...`: Información del broker (reservado)
- `#`: Wildcard multinivel (debe ser último)
- `+`: Wildcard un nivel

---

### 3. Wildcards (Comodines)

#### `#` - Multinivel

Coincide con cualquier cantidad de niveles.

```bash
iiot/#
  ├── iiot/sensores/temperatura ✅
  ├── iiot/sensores/presion ✅
  ├── iiot/actuadores/valvula1 ✅
  └── iiot/linea1/maquina2/estado ✅

sensores/#
  ├── sensores/temp ✅
  ├── sensores/zona1/temp ✅
  └── iiot/sensores/temp ❌ (no empieza con sensores/)

#
  └── TODO ✅ (cualquier mensaje)
```

**Regla**: `#` debe ser último carácter en subscription.

---

#### `+` - Un Nivel

Coincide con exactamente un nivel.

```bash
iiot/+/temperatura
  ├── iiot/sensores/temperatura ✅
  ├── iiot/actuadores/temperatura ✅
  ├── iiot/linea1/temperatura ✅
  └── iiot/linea1/zona1/temperatura ❌ (más de un nivel)

iiot/+/+/estado
  ├── iiot/linea1/maquina2/estado ✅
  ├── iiot/fabrica2/linea5/estado ✅
  └── iiot/linea1/estado ❌ (menos niveles)

+/sensores/+
  ├── fabrica1/sensores/temp ✅
  ├── planta2/sensores/presion ✅
  └── sensores/temp ❌ (falta primer nivel)
```

**Múltiples `+` permitidos** en un topic.

---

### 4. QoS (Quality of Service)

Niveles de garantía de entrega.

| QoS | Nombre | Garantía | Uso Típico | Overhead |
|-----|--------|----------|------------|----------|
| **0** | At most once | Máximo 1 vez (puede perderse) | Sensores no críticos, alta frecuencia | Bajo |
| **1** | At least once | Al menos 1 vez (puede duplicarse) | Sensores importantes | Medio |
| **2** | Exactly once | Exactamente 1 vez (garantizado) | Comandos críticos, transacciones | Alto |

#### QoS 0 - Fire and Forget

```
Publisher         Broker          Subscriber
   │                │                 │
   │───PUBLISH(0)──>│                 │
   │                │──PUBLISH(0)───>│
   │                │                 │
   ✓ No confirmación                  ✓
```

**Pros**: Rápido, bajo overhead  
**Contras**: Mensajes pueden perderse  
**Uso**: Temperatura cada segundo (si se pierde uno, viene otro)

---

#### QoS 1 - At Least Once

```
Publisher         Broker          Subscriber
   │                │                 │
   │───PUBLISH(1)──>│                 │
   │<───PUBACK─────│                 │
   │                │──PUBLISH(1)───>│
   │                │<───PUBACK──────│
   ✓ Confirmado     ✓                ✓
```

**Pros**: Garantiza entrega  
**Contras**: Puede duplicar  
**Uso**: Alarmas, eventos importantes

---

#### QoS 2 - Exactly Once

```
Publisher         Broker          Subscriber
   │                │                │
   │───PUBLISH(2)──>│                │
   │<───PUBREC──────│                │
   │───PUBREL──────>│                │
   │<───PUBCOMP─────│                │
   │                │──PUBLISH(2)───>│
   │                │<───PUBREC──────│
   │                │───PUBREL────>│
   │                │<───PUBCOMP─────│
   ✓ 4-way handshake                 ✓
```

**Pros**: Garantía total, sin duplicados  
**Contras**: Más lento, más ancho de banda  
**Uso**: Comandos de control (abrir válvula), pagos

---

### 5. Retained Messages

**Definición**: Mensajes guardados por broker para nuevos suscriptores.

**Comportamiento**:
```
1. Publisher publica con flag RETAIN
   ├─> Broker guarda último mensaje del topic
   
2. Nuevo subscriber se conecta
   ├─> Recibe inmediatamente último mensaje guardado
   └─> No espera próxima publicación
```

**Ejemplo**:
```bash
# Publicar con retain
mosquitto_pub -t "iiot/estado/linea1" -m "operando" -r

# Subscriber que se conecta 10 min después
# Recibe inmediatamente "operando"
mosquitto_sub -t "iiot/estado/linea1"
# Output: operando (sin esperar)
```

**Uso Típico**:
- Estado actual de máquinas
- Configuración de sensores
- Última lectura conocida

**Borrar Retained Message**:
```bash
mosquitto_pub -t "iiot/estado/linea1" -m "" -r
# Mensaje vacío con retain = borrar
```

---

### 6. Last Will and Testament (LWT)

**Definición**: Mensaje automático enviado por broker si cliente se desconecta inesperadamente.

**Configuración** (al conectar):
```python
client.will_set(
    topic="iiot/estado/sensor_temp",
    payload="OFFLINE",
    qos=1,
    retain=True
)
```

**Funcionamiento**:
```
1. Sensor se conecta con LWT configurado
2. Sensor publica normalmente: "ONLINE"
3. Sensor pierde conexión (cable cortado, apagón)
4. Broker detecta timeout (keepalive)
5. Broker publica automáticamente: "OFFLINE"
6. Sistemas de monitoreo reciben alerta
```

**Uso Real**:
- Detectar sensores offline
- Alertas de desconexión
- Heartbeat systems

---

## 🔌 Conexión y Autenticación

### Este Proyecto (Educativo)

```
Broker: localhost (o mosquitto)
Puerto: 1883 (MQTT)
Puerto WS: 9001 (WebSockets)
Usuario: N/A (anonymous)
Password: N/A
TLS/SSL: No (desarrollo)
```

### Producción Real

```
Broker: mqtt.empresa.com
Puerto: 8883 (MQTTS - TLS)
Usuario: sensor_001
Password: p4ssw0rd_seguro
Certificado: ca.crt
```

---

## 💻 Comandos Prácticos

### Mosquitto CLI

#### Publicar Mensaje

```bash
# Básico
mosquitto_pub -h localhost -t "iiot/test" -m "Hola MQTT"

# Con QoS
mosquitto_pub -h localhost -t "iiot/test" -m "Importante" -q 1

# Con Retain
mosquitto_pub -h localhost -t "iiot/estado" -m "ONLINE" -r

# Múltiples opciones
mosquitto_pub \
  -h localhost \
  -t "iiot/sensores/temp" \
  -m '{"value": 65.5, "unit": "C"}' \
  -q 1 \
  -r
```

---

#### Suscribirse a Topic

```bash
# Un topic
mosquitto_sub -h localhost -t "iiot/sensores/temperatura"

# Wildcard
mosquitto_sub -h localhost -t "iiot/#"

# Verbose (mostrar topic)
mosquitto_sub -h localhost -t "iiot/#" -v

# Con timestamp
mosquitto_sub -h localhost -t "iiot/#" -v | while read line; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
done
```

---

### Python (paho-mqtt)

#### Publisher

```python
import paho.mqtt.client as mqtt
import json
import time

# Crear cliente
client = mqtt.Client(client_id="sensor_temp_001")

# Conectar
client.connect("localhost", 1883, 60)

# Publicar
while True:
    payload = {
        "sensor_id": "TEMP_001",
        "value": 65.5,
        "unit": "C",
        "timestamp": time.time()
    }
    
    client.publish(
        topic="iiot/sensores/temperatura",
        payload=json.dumps(payload),
        qos=1,
        retain=False
    )
    
    print(f"Publicado: {payload}")
    time.sleep(1)
```

---

#### Subscriber

```python
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Conectado con código: {rc}")
    # Suscribirse al conectar
    client.subscribe("iiot/#", qos=1)

def on_message(client, userdata, msg):
    print(f"Topic: {msg.topic}")
    print(f"Mensaje: {msg.payload.decode()}")
    print(f"QoS: {msg.qos}")
    print(f"Retained: {msg.retain}")
    print("-" * 50)

# Crear cliente
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

# Conectar y loop
client.connect("localhost", 1883, 60)
client.loop_forever()
```

---

## 🎯 Casos de Uso IIoT

### Caso 1: Sensor Simple

**Flujo**:
```
Sensor Temp ─[pub]─> iiot/fabrica1/linea2/temperatura
                            │
                            ├─[sub]─> InfluxDB (histórico)
                            ├─[sub]─> Grafana (visualización)
                            └─[sub]─> Alert System (alarmas)
```

**Topic Strategy**:
```
iiot/[fabrica]/[linea]/[sensor_tipo]
```

---

### Caso 2: Control de Actuador

**Flujo**:
```
App Control ─[pub]─> iiot/comandos/valvula1/abrir
                            │
                            └─[sub]─> PLC (ejecuta comando)

PLC ─[pub]─> iiot/estado/valvula1/abierta
        │
        └─[sub]─> App Control (confirmación)
```

**QoS**: 2 (garantía de ejecución única)

---

### Caso 3: Múltiples Sensores

**Estructura Topics**:
```
iiot/sensores/
├── zona1/
│   ├── temperatura
│   ├── presion
│   └── humedad
├── zona2/
│   ├── temperatura
│   └── nivel
└── zona3/
    └── vibration
```

**Subscriptions**:
```bash
# Todas las temperaturas
iiot/sensores/+/temperatura

# Todo de zona1
iiot/sensores/zona1/#

# Todo
iiot/sensores/#
```

---

## ⚖️ MQTT vs HTTP

| Característica | MQTT | HTTP |
|----------------|------|------|
| **Overhead** | 2 bytes header | 200+ bytes header |
| **Patrón** | Pub/Sub asíncrono | Request/Response síncrono |
| **Conexión** | Persistente | Por request (HTTP/1.1 keep-alive) |
| **Push Real-Time** | ✅ Nativo | ❌ Necesita polling/WebSockets |
| **Ancho Banda** | Muy bajo | Alto |
| **Batería** | Eficiente | Consume más |
| **Complejidad** | Requiere broker | Directo |
| **Uso IIoT** | ⭐⭐⭐⭐⭐ Ideal | ⭐⭐ API REST |

**Cuándo Usar MQTT**:
- ✅ Datos de sensores (alta frecuencia)
- ✅ Redes con limitaciones (3G, LoRa)
- ✅ Dispositivos con batería
- ✅ Push real-time necesario
- ✅ Múltiples consumidores del mismo dato

**Cuándo Usar HTTP**:
- ✅ APIs RESTful tradicionales
- ✅ Integración web directa
- ✅ Requests ocasionales
- ✅ No requiere broker adicional

---

## 🔐 Seguridad

### Desarrollo (Este Proyecto)

```
✅ Anonymous: Permitido
✅ TLS: No
✅ Firewall: localhost only
⚠️ NO usar en producción
```

### Producción

#### 1. Autenticación Usuario/Password

```bash
# Crear usuario
mosquitto_passwd -c /etc/mosquitto/passwd sensor_001

# mosquitto.conf
allow_anonymous false
password_file /etc/mosquitto/passwd
```

---

#### 2. TLS/SSL Encryption

```bash
# mosquitto.conf
listener 8883
cafile /etc/mosquitto/ca_certificates/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key
```

**Cliente Python con TLS**:
```python
client.tls_set(
    ca_certs="/path/to/ca.crt",
    certfile="/path/to/client.crt",
    keyfile="/path/to/client.key"
)
client.connect("mqtt.empresa.com", 8883)
```

---

#### 3. ACLs (Access Control Lists)

```bash
# acl.conf
user sensor_temp
topic write iiot/sensores/temperatura
topic read iiot/comandos/sensor_temp/#

user app_grafana
topic read iiot/#
```

**mosquitto.conf**:
```
acl_file /etc/mosquitto/acl.conf
```

---

## 📊 Mejores Prácticas

### Diseño de Topics

✅ **BUENO**:
```
empresa/fabrica/linea/sensor_tipo
iiot/zona1/maquina2/temperatura
produccion/lote_123/estado
```

❌ **MALO**:
```
temp                    # Muy genérico
sensor/1/2/3/4/5/6     # Muy profundo
Temperatura Zona 1     # Espacios, no consistente
```

**Reglas**:
1. Jerárquico de general → específico
2. Minúsculas consistentes
3. Sin espacios (usar `_`)
4. Máximo 5-6 niveles
5. Nombres descriptivos

---

### Naming Conventions

```
[tipo_entidad]/[ubicacion]/[identificador]/[metrica]

Ejemplos:
sensores/fabrica1/temp_001/temperatura
actuadores/linea2/valvula_05/estado
eventos/zona3/alarma_humo/activa
```

---

### QoS Selection

```
┌────────────────────┬─────────────┐
│ Caso de Uso        │ QoS         │
├────────────────────┼─────────────┤
│ Temperatura cada 1s│ 0           │
│ Alarma incendio    │ 2           │
│ Estado máquina     │ 1 + Retain  │
│ Comando control    │ 2           │
│ Log eventos        │ 1           │
│ Heartbeat          │ 0           │
└────────────────────┴─────────────┘
```

**Regla general**:
- QoS 0: Datos continuos no críticos
- QoS 1: Eventos importantes
- QoS 2: Comandos críticos

---

### Retained Messages

✅ **Usar para**:
- Estado actual de dispositivos
- Configuración
- Última lectura conocida

❌ **NO usar para**:
- Series temporales continuas
- Datos que cambian frecuentemente
- Eventos históricos

---

### Tamaño de Payload

**Recomendación**: < 256 KB (límite por defecto Mosquitto)

**Óptimo**: 100-1000 bytes

```json
✅ BUENO (120 bytes):
{
  "sensor_id": "TEMP_001",
  "value": 65.5,
  "unit": "C",
  "timestamp": 1675453200
}

❌ EVITAR (>1 MB):
{
  "sensor_id": "TEMP_001",
  "history": [/* 10,000 lecturas */],
  "image": "base64_encoded_image..."
}
```

**Alternativa para grandes datos**: Publicar referencia, almacenar en S3/FTP

---

## 🧪 Testing y Debugging

### Verificar Broker Corriendo

```bash
# Netstat
netstat -an | grep 1883

# Docker
docker logs mosquitto

# Telnet test
telnet localhost 1883
```

---

### Monitorear Mensajes

```bash
# Todos los mensajes
mosquitto_sub -h localhost -t "#" -v

# Con timestamp
mosquitto_sub -h localhost -t "#" -v | ts '[%Y-%m-%d %H:%M:%S]'

# Contar mensajes por segundo
mosquitto_sub -h localhost -t "iiot/#" | pv -l > /dev/null
```

---

### Simular Carga

```bash
# Publicar 1000 mensajes rápido
for i in {1..1000}; do
  mosquitto_pub -h localhost -t "test/load" -m "msg_$i"
done

# Con intervalo
while true; do
  mosquitto_pub -h localhost -t "test/continuous" -m "$(date)"
  sleep 0.1  # 10 msg/seg
done
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- **MQTT.org**: https://mqtt.org/ (especificación)
- **Mosquitto**: https://mosquitto.org/documentation/
- **Paho Python**: https://www.eclipse.org/paho/index.php?page=clients/python/docs/index.php

### Tutoriales
- **MQTT Essentials** (HiveMQ): https://www.hivemq.com/mqtt-essentials/
- **MQTT by Example**: https://www.cloudmqtt.com/docs.html

### Herramientas
- **MQTT Explorer** (GUI): http://mqtt-explorer.com/
- **MQTT.fx** (Cliente desktop): https://mqttfx.jensd.de/
- **Node-RED**: Built-in MQTT nodes

### Alternativas a Mosquitto
- **EMQX**: Enterprise, alta escala
- **HiveMQ**: Cloud-native
- **VerneMQ**: Distribuido
- **RabbitMQ**: Con plugin MQTT

---

## ❓ Preguntas Frecuentes

**P: ¿MQTT usa TCP o UDP?**  
R: TCP por defecto (puerto 1883). Existe MQTT-SN (Sensor Networks) sobre UDP para redes muy limitadas.

**P: ¿MQTT es seguro?**  
R: Básico no encripta. MQTTS (puerto 8883) agrega TLS/SSL. Este proyecto usa básico (educativo).

**P: ¿Cuántos clientes soporta?**  
R: Depende del broker. Mosquitto: ~100K conexiones con hardware apropiado. EMQX: millones.

**P: ¿Qué pasa si broker se cae?**  
R: Clientes con QoS 1/2 reenvían mensajes al reconectar. Messages perdidos con QoS 0. Producción usa clustering.

**P: ¿Diferencia entre MQTT 3.1.1 y 5.0?**  
R: MQTT 5.0 agrega: reason codes, user properties, topic aliases, shared subscriptions. 3.1.1 más común aún.

**P: ¿Puedo usar MQTT en navegador?**  
R: Sí, vía WebSockets (puerto 9001 en este proyecto). Librerías: MQTT.js, Paho JavaScript.

**P: ¿Cómo escalar MQTT?**  
R: Load balancers, clustering, bridging brokers, sharding por topics.

---

## 🎓 Ejercicio Rápido

### Práctica 1: Echo Test

```bash
# Terminal 1 - Subscriber
mosquitto_sub -h localhost -t "test/echo" -v

# Terminal 2 - Publisher
mosquitto_pub -h localhost -t "test/echo" -m "Hola Mundo"
```

**Resultado esperado**: Terminal 1 muestra "test/echo Hola Mundo"

---

### Práctica 2: Wildcards

```bash
# Terminal 1
mosquitto_sub -h localhost -t "iiot/+/temperatura" -v

# Terminal 2
mosquitto_pub -h localhost -t "iiot/zona1/temperatura" -m "25"
mosquitto_pub -h localhost -t "iiot/zona2/temperatura" -m "30"
mosquitto_pub -h localhost -t "iiot/zona1/presion" -m "3.2"  # NO aparece
```

**Pregunta**: ¿Por qué el último no aparece?  
**Respuesta**: <details>Topic no coincide con `+/temperatura` (presion ≠ temperatura)</details>

---

### Práctica 3: Retained

```bash
# Publicar con retain
mosquitto_pub -h localhost -t "estado/sistema" -m "OPERATIVO" -r

# Cerrar terminal

# Abrir nuevo terminal y suscribirse
mosquitto_sub -h localhost -t "estado/sistema"
# ¿Recibe mensaje inmediatamente?
```

**Respuesta**: <details>Sí, porque tiene flag RETAIN</details>

---

## 📖 Glosario

| Término | Definición |
|---------|------------|
| **Broker** | Servidor MQTT que rutea mensajes |
| **Client** | Aplicación que publica o suscribe |
| **Payload** | Contenido del mensaje (bytes) |
| **Publish** | Enviar mensaje a topic |
| **Subscribe** | Registrarse para recibir mensajes de topic |
| **Topic** | Canal de comunicación jerárquico |
| **Wildcard** | Patrón para suscribirse a múltiples topics |
| **QoS** | Quality of Service (nivel de garantía) |
| **Retained** | Mensaje guardado por broker |
| **LWT** | Last Will and Testament (mensaje de desconexión) |
| **Clean Session** | Si false, mantiene suscripciones al reconectar |
| **Keep Alive** | Intervalo de heartbeat (segundos) |

---

## ✅ Checklist de Conceptos

Antes de examen, asegúrate de entender:

- [ ] Diferencia Publisher/Subscriber/Broker
- [ ] Estructura de topics jerárquicos
- [ ] Uso de wildcards `#` y `+`
- [ ] Diferencias entre QoS 0, 1, 2
- [ ] Concepto de retained messages
- [ ] Last Will and Testament (LWT)
- [ ] Ventajas MQTT vs HTTP para IIoT
- [ ] Mejores prácticas diseño de topics
- [ ] Comandos básicos mosquitto_pub/sub
- [ ] Código Python básico pub/sub

---

**¡MQTT Dominado! 🚀**

_"MQTT: Ligero, rápido, confiable. El idioma de IIoT."_

---

**Versión**: 1.0  
**Última Actualización**: Febrero 2026  
**Instructor**: Christian Spana

