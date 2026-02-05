> [🇺🇸 **English**] | [🇪🇸 Español](../es/MQTT-GUIA-RAPIDA.md)

# MQTT - Quick Guide for Students

**Messaging Protocol for IIoT**

---

## 📋 What is MQTT?

**MQTT** = Message Queuing Telemetry Transport

**Simple Definition**:
> Lightweight messaging protocol designed for devices with limited resources and networks with low or unreliable bandwidth.

**Analogy**:
> MQTT is like a radio station 📻:
> - **Station (Broker)**: Transmits signal
> - **DJ (Publisher)**: Publishes content
> - **Listeners (Subscribers)**: Tune into channel of interest
> - **Frequencies (Topics)**: Specific channels

---

## 🏗️ MQTT Architecture

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│         📱 PUBLISHERS                               │
│    Sensors, PLCs, Apps that SEND messages           │
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
│        │   - Receives messages     │                │
│        │   - Routes to subscribers │                │
│        │   - Stores (retained)     │                │
│        └───────────┬───────────────┘                │
│                    ↓ SUBSCRIBE                      │
│        ┌─────────┬─┴───────┬───────────┐            │
│        │         │         │           │            │
│    ┌───▼──┐  ┌───▼──┐  ┌───▼──┐    ┌───▼──┐         │
│    │DB    │  │Grafana│ │App   │    │Logger│         │
│    │Influx│  │Dash  │  │Mobile│    │File  │         │
│    └──────┘  └──────┘  └──────┘    └──────┘         │
│                                                     │
│        💾 SUBSCRIBERS                               │
│    Apps, Databases that RECEIVE messages            │
│                                                     │
└─────────────────────────────────────────────────────┘

🔑 KEY: Publishers and Subscribers DON'T know each other
        (Total decoupling)
```

---

## 📡 Fundamental Concepts

### 1. Broker (Intermediary)

**Definition**: Central server that receives and distributes messages.

**In this project**: Mosquitto (`localhost:1883`)

**Responsibilities**:
- ✅ Accept client connections
- ✅ Receive published messages
- ✅ Filter by topics
- ✅ Distribute to appropriate subscribers
- ✅ Manage retained messages
- ✅ Implement QoS (Quality of Service)

---

### 2. Topics

**Definition**: Hierarchical communication channels.

**Structure**:
```
level1/level2/level3/...

Examples:
iiot/sensores/temperatura
iiot/sensores/presion
iiot/actuadores/valvula1
empresa/fabrica1/linea2/maquina5/temp
```

**Rules**:
- ✅ Separated by `/` (slash)
- ✅ Case-sensitive: `TEMP` ≠ `temp`
- ✅ Don't start with `/`
- ✅ Maximum 65,535 characters
- ✅ Avoid spaces (use `_`)

**Special Topics**:
- `$SYS/...`: Broker information (reserved)
- `#`: Multi-level wildcard (must be last)
- `+`: Single level wildcard

---

### 3. Wildcards

#### `#` - Multi-level

Matches any number of levels.

```bash
iiot/#
  ├── iiot/sensores/temperatura ✅
  ├── iiot/sensores/presion ✅
  ├── iiot/actuadores/valvula1 ✅
  └── iiot/linea1/maquina2/estado ✅

sensores/#
  ├── sensores/temp ✅
  ├── sensores/zona1/temp ✅
  └── iiot/sensores/temp ❌ (doesn't start with sensores/)

#
  └── ALL ✅ (any message)
```

**Rule**: `#` must be last character in subscription.

---

#### `+` - Single Level

Matches exactly one level.

```bash
iiot/+/temperatura
  ├── iiot/sensores/temperatura ✅
  ├── iiot/actuadores/temperatura ✅
  ├── iiot/linea1/temperatura ✅
  └── iiot/linea1/zona1/temperatura ❌ (more than one level)

iiot/+/+/estado
  ├── iiot/linea1/maquina2/estado ✅
  ├── iiot/fabrica2/linea5/estado ✅
  └── iiot/linea1/estado ❌ (fewer levels)

+/sensores/+
  ├── fabrica1/sensores/temp ✅
  ├── planta2/sensores/presion ✅
  └── sensores/temp ❌ (missing first level)
```

**Multiple `+` allowed** in a topic.

---

### 4. QoS (Quality of Service)

Delivery guarantee levels.

| QoS | Name | Guarantee | Typical Use | Overhead |
|-----|--------|----------|------------|----------|
| **0** | At most once | Maximum 1 time (may be lost) | Non-critical sensors, high frequency | Low |
| **1** | At least once | At least 1 time (may duplicate) | Important sensors | Medium |
| **2** | Exactly once | Exactly 1 time (guaranteed) | Critical commands, transactions | High |

#### QoS 0 - Fire and Forget

```
Publisher         Broker          Subscriber
   │                │                 │
   │───PUBLISH(0)──>│                 │
   │                │──PUBLISH(0)───>│
   │                │                 │
   ✓ No acknowledgment                ✓
```

**Pros**: Fast, low overhead  
**Cons**: Messages may be lost  
**Use**: Temperature every second (if one is lost, another comes)

---

#### QoS 1 - At Least Once

```
Publisher         Broker          Subscriber
   │                │                 │
   │───PUBLISH(1)──>│                 │
   │<───PUBACK─────│                 │
   │                │──PUBLISH(1)───>│
   │                │<───PUBACK──────│
   ✓ Confirmed      ✓                ✓
```

**Pros**: Guarantees delivery  
**Cons**: May duplicate  
**Use**: Alarms, important events

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

**Pros**: Total guarantee, no duplicates  
**Cons**: Slower, more bandwidth  
**Use**: Control commands (open valve), payments

---

### 5. Retained Messages

**Definition**: Messages saved by broker for new subscribers.

**Behavior**:
```
1. Publisher publishes with RETAIN flag
   ├─> Broker saves last message of the topic
   
2. New subscriber connects
   ├─> Immediately receives last saved message
   └─> Doesn't wait for next publication
```

**Example**:
```bash
# Publish with retain
mosquitto_pub -t "iiot/estado/linea1" -m "operando" -r

# Subscriber that connects 10 min later
# Immediately receives "operando"
mosquitto_sub -t "iiot/estado/linea1"
# Output: operando (without waiting)
```

**Typical Use**:
- Current machine status
- Sensor configuration
- Last known reading

**Delete Retained Message**:
```bash
mosquitto_pub -t "iiot/estado/linea1" -m "" -r
# Empty message with retain = delete
```

---

### 6. Last Will and Testament (LWT)

**Definition**: Automatic message sent by broker if client disconnects unexpectedly.

**Configuration** (when connecting):
```python
client.will_set(
    topic="iiot/estado/sensor_temp",
    payload="OFFLINE",
    qos=1,
    retain=True
)
```

**Operation**:
```
1. Sensor connects with LWT configured
2. Sensor publishes normally: "ONLINE"
3. Sensor loses connection (cut cable, power outage)
4. Broker detects timeout (keepalive)
5. Broker automatically publishes: "OFFLINE"
6. Monitoring systems receive alert
```

**Real Use**:
- Detect offline sensors
- Disconnection alerts
- Heartbeat systems

---

## 🔌 Connection and Authentication

### This Project (Educational)

```
Broker: localhost (or mosquitto)
Port: 1883 (MQTT)
WS Port: 9001 (WebSockets)
User: N/A (anonymous)
Password: N/A
TLS/SSL: No (development)
```

### Real Production

```
Broker: mqtt.empresa.com
Port: 8883 (MQTTS - TLS)
User: sensor_001
Password: p4ssw0rd_secure
Certificate: ca.crt
```

---

## 💻 Practical Commands

### Mosquitto CLI

#### Publish Message

```bash
# Basic
mosquitto_pub -h localhost -t "iiot/test" -m "Hello MQTT"

# With QoS
mosquitto_pub -h localhost -t "iiot/test" -m "Important" -q 1

# With Retain
mosquitto_pub -h localhost -t "iiot/estado" -m "ONLINE" -r

# Multiple options
mosquitto_pub \
  -h localhost \
  -t "iiot/sensores/temp" \
  -m '{"value": 65.5, "unit": "C"}' \
  -q 1 \
  -r
```

---

#### Subscribe to Topic

```bash
# One topic
mosquitto_sub -h localhost -t "iiot/sensores/temperatura"

# Wildcard
mosquitto_sub -h localhost -t "iiot/#"

# Verbose (show topic)
mosquitto_sub -h localhost -t "iiot/#" -v

# With timestamp
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

# Create client
client = mqtt.Client(client_id="sensor_temp_001")

# Connect
client.connect("localhost", 1883, 60)

# Publish
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
    
    print(f"Published: {payload}")
    time.sleep(1)
```

---

#### Subscriber

```python
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Connected with code: {rc}")
    # Subscribe on connect
    client.subscribe("iiot/#", qos=1)

def on_message(client, userdata, msg):
    print(f"Topic: {msg.topic}")
    print(f"Message: {msg.payload.decode()}")
    print(f"QoS: {msg.qos}")
    print(f"Retained: {msg.retain}")
    print("-" * 50)

# Create client
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

# Connect and loop
client.connect("localhost", 1883, 60)
client.loop_forever()
```

---

## 🎯 IIoT Use Cases

### Case 1: Simple Sensor

**Flow**:
```
Temp Sensor ─[pub]─> iiot/fabrica1/linea2/temperatura
                            │
                            ├─[sub]─> InfluxDB (historical)
                            ├─[sub]─> Grafana (visualization)
                            └─[sub]─> Alert System (alarms)
```

**Topic Strategy**:
```
iiot/[factory]/[line]/[sensor_type]
```

---

### Case 2: Actuator Control

**Flow**:
```
Control App ─[pub]─> iiot/comandos/valvula1/abrir
                            │
                            └─[sub]─> PLC (executes command)

PLC ─[pub]─> iiot/estado/valvula1/abierta
        │
        └─[sub]─> Control App (confirmation)
```

**QoS**: 2 (guarantee of single execution)

---

### Case 3: Multiple Sensors

**Topics Structure**:
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
# All temperatures
iiot/sensores/+/temperatura

# Everything from zona1
iiot/sensores/zona1/#

# Everything
iiot/sensores/#
```

---

## ⚖️ MQTT vs HTTP

| Feature | MQTT | HTTP |
|----------------|------|------|
| **Overhead** | 2 bytes header | 200+ bytes header |
| **Pattern** | Pub/Sub asynchronous | Request/Response synchronous |
| **Connection** | Persistent | Per request (HTTP/1.1 keep-alive) |
| **Real-Time Push** | ✅ Native | ❌ Needs polling/WebSockets |
| **Bandwidth** | Very low | High |
| **Battery** | Efficient | Consumes more |
| **Complexity** | Requires broker | Direct |
| **IIoT Use** | ⭐⭐⭐⭐⭐ Ideal | ⭐⭐ REST API |

**When to Use MQTT**:
- ✅ Sensor data (high frequency)
- ✅ Networks with limitations (3G, LoRa)
- ✅ Battery-powered devices
- ✅ Real-time push needed
- ✅ Multiple consumers of same data

**When to Use HTTP**:
- ✅ Traditional RESTful APIs
- ✅ Direct web integration
- ✅ Occasional requests
- ✅ No additional broker needed

---

## 🔐 Security

### Development (This Project)

```
✅ Anonymous: Allowed
✅ TLS: No
✅ Firewall: localhost only
⚠️ DO NOT use in production
```

### Production

#### 1. User/Password Authentication

```bash
# Create user
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

**Python Client with TLS**:
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

## 📊 Best Practices

### Topics Design

✅ **GOOD**:
```
empresa/fabrica/linea/sensor_tipo
iiot/zona1/maquina2/temperatura
produccion/lote_123/estado
```

❌ **BAD**:
```
temp                    # Too generic
sensor/1/2/3/4/5/6     # Too deep
Temperatura Zona 1     # Spaces, not consistent
```

**Rules**:
1. Hierarchical from general → specific
2. Consistent lowercase
3. No spaces (use `_`)
4. Maximum 5-6 levels
5. Descriptive names

---

### Naming Conventions

```
[entity_type]/[location]/[identifier]/[metric]

Examples:
sensores/fabrica1/temp_001/temperatura
actuadores/linea2/valvula_05/estado
eventos/zona3/alarma_humo/activa
```

---

### QoS Selection

```
┌────────────────────┬─────────────┐
│ Use Case           │ QoS         │
├────────────────────┼─────────────┤
│ Temperature every 1s│ 0           │
│ Fire alarm         │ 2           │
│ Machine status     │ 1 + Retain  │
│ Control command    │ 2           │
│ Event log          │ 1           │
│ Heartbeat          │ 0           │
└────────────────────┴─────────────┘
```

**General rule**:
- QoS 0: Continuous non-critical data
- QoS 1: Important events
- QoS 2: Critical commands

---

### Retained Messages

✅ **Use for**:
- Current device status
- Configuration
- Last known reading

❌ **DON'T use for**:
- Continuous time series
- Frequently changing data
- Historical events

---

### Payload Size

**Recommendation**: < 256 KB (Mosquitto default limit)

**Optimal**: 100-1000 bytes

```json
✅ GOOD (120 bytes):
{
  "sensor_id": "TEMP_001",
  "value": 65.5,
  "unit": "C",
  "timestamp": 1675453200
}

❌ AVOID (>1 MB):
{
  "sensor_id": "TEMP_001",
  "history": [/* 10,000 readings */],
  "image": "base64_encoded_image..."
}
```

**Alternative for large data**: Publish reference, store in S3/FTP

---

## 🧪 Testing and Debugging

### Verify Broker Running

```bash
# Netstat
netstat -an | grep 1883

# Docker
docker logs mosquitto

# Telnet test
telnet localhost 1883
```

---

### Monitor Messages

```bash
# All messages
mosquitto_sub -h localhost -t "#" -v

# With timestamp
mosquitto_sub -h localhost -t "#" -v | ts '[%Y-%m-%d %H:%M:%S]'

# Count messages per second
mosquitto_sub -h localhost -t "iiot/#" | pv -l > /dev/null
```

---

### Simulate Load

```bash
# Publish 1000 messages fast
for i in {1..1000}; do
  mosquitto_pub -h localhost -t "test/load" -m "msg_$i"
done

# With interval
while true; do
  mosquitto_pub -h localhost -t "test/continuous" -m "$(date)"
  sleep 0.1  # 10 msg/sec
done
```

---

## 📚 Additional Resources

### Official Documentation
- **MQTT.org**: https://mqtt.org/ (specification)
- **Mosquitto**: https://mosquitto.org/documentation/
- **Paho Python**: https://www.eclipse.org/paho/index.php?page=clients/python/docs/index.php

### Tutorials
- **MQTT Essentials** (HiveMQ): https://www.hivemq.com/mqtt-essentials/
- **MQTT by Example**: https://www.cloudmqtt.com/docs.html

### Tools
- **MQTT Explorer** (GUI): http://mqtt-explorer.com/
- **MQTT.fx** (Desktop client): https://mqttfx.jensd.de/
- **Node-RED**: Built-in MQTT nodes

### Mosquitto Alternatives
- **EMQX**: Enterprise, large scale
- **HiveMQ**: Cloud-native
- **VerneMQ**: Distributed
- **RabbitMQ**: With MQTT plugin

---

## ❓ Frequently Asked Questions

**Q: Does MQTT use TCP or UDP?**  
A: TCP by default (port 1883). MQTT-SN (Sensor Networks) exists over UDP for very limited networks.

**Q: Is MQTT secure?**  
A: Basic doesn't encrypt. MQTTS (port 8883) adds TLS/SSL. This project uses basic (educational).

**Q: How many clients does it support?**  
A: Depends on broker. Mosquitto: ~100K connections with appropriate hardware. EMQX: millions.

**Q: What happens if broker crashes?**  
A: Clients with QoS 1/2 resend messages when reconnecting. Messages lost with QoS 0. Production uses clustering.

**Q: Difference between MQTT 3.1.1 and 5.0?**  
A: MQTT 5.0 adds: reason codes, user properties, topic aliases, shared subscriptions. 3.1.1 still more common.

**Q: Can I use MQTT in browser?**  
A: Yes, via WebSockets (port 9001 in this project). Libraries: MQTT.js, Paho JavaScript.

**Q: How to scale MQTT?**  
A: Load balancers, clustering, bridging brokers, sharding by topics.

---

## 🎓 Quick Exercise

### Practice 1: Echo Test

```bash
# Terminal 1 - Subscriber
mosquitto_sub -h localhost -t "test/echo" -v

# Terminal 2 - Publisher
mosquitto_pub -h localhost -t "test/echo" -m "Hello World"
```

**Expected result**: Terminal 1 shows "test/echo Hello World"

---

### Practice 2: Wildcards

```bash
# Terminal 1
mosquitto_sub -h localhost -t "iiot/+/temperatura" -v

# Terminal 2
mosquitto_pub -h localhost -t "iiot/zona1/temperatura" -m "25"
mosquitto_pub -h localhost -t "iiot/zona2/temperatura" -m "30"
mosquitto_pub -h localhost -t "iiot/zona1/presion" -m "3.2"  # Doesn't appear
```

**Question**: Why doesn't the last one appear?  
**Answer**: <details>Topic doesn't match `+/temperatura` (presion ≠ temperatura)</details>

---

### Practice 3: Retained

```bash
# Publish with retain
mosquitto_pub -h localhost -t "estado/sistema" -m "OPERATIONAL" -r

# Close terminal

# Open new terminal and subscribe
mosquitto_sub -h localhost -t "estado/sistema"
# Does it receive message immediately?
```

**Answer**: <details>Yes, because it has RETAIN flag</details>

---

## 📖 Glossary

| Term | Definition |
|---------|------------|
| **Broker** | MQTT server that routes messages |
| **Client** | Application that publishes or subscribes |
| **Payload** | Message content (bytes) |
| **Publish** | Send message to topic |
| **Subscribe** | Register to receive messages from topic |
| **Topic** | Hierarchical communication channel |
| **Wildcard** | Pattern to subscribe to multiple topics |
| **QoS** | Quality of Service (guarantee level) |
| **Retained** | Message saved by broker |
| **LWT** | Last Will and Testament (disconnection message) |
| **Clean Session** | If false, maintains subscriptions when reconnecting |
| **Keep Alive** | Heartbeat interval (seconds) |

---

## ✅ Concepts Checklist

Before exam, make sure you understand:

- [ ] Publisher/Subscriber/Broker differences
- [ ] Hierarchical topics structure
- [ ] Use of wildcards `#` and `+`
- [ ] Differences between QoS 0, 1, 2
- [ ] Retained messages concept
- [ ] Last Will and Testament (LWT)
- [ ] MQTT vs HTTP advantages for IIoT
- [ ] Topics design best practices
- [ ] Basic mosquitto_pub/sub commands
- [ ] Basic Python pub/sub code

---

**MQTT Mastered! 🚀**

_"MQTT: Lightweight, fast, reliable. The language of IIoT."_

---

**Version**: 1.0  
**Last Update**: February 2026  
**Instructor**: Christian Spana
