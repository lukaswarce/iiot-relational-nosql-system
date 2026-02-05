# Node-RED Flows

> 🇺🇸 **English** | [🇪🇸 Español](README.es.md)

This directory contains the Node-RED flows for the IIoT project.

## flows.json File

The `flows.json` file contains pre-configured flows that will load automatically when Node-RED starts.

**IMPORTANT NOTE**: The included flows are basic for demonstration purposes. They can be extended with:

1. Additional flows to write to InfluxDB
2. Flows to write to MySQL 
3. ACID transaction demos
4. Query comparison demonstrations
5. Polyglot persistence integration
6. Factory I/O integration (optional, disabled by default)

## Adding Flows Manually

1. Access Node-RED: http://localhost:1880
2. Import flows from hamburger menu → Import
3. Copy content from additional flows
4. Click Deploy

## Configuring Connections

### InfluxDB
- Create "influxdb out" node
- URL: http://influxdb:8086
- Token: my-super-secret-auth-token
- Organization: iiot-class
- Bucket: iiot_sensors

### MySQL  
- Create "mysql" node
- Host: mysql
- Port: 3306
- Database: iiot_db
- User: student
- Password: student123

### MQTT
- Already configured in mqtt_broker config node
- Broker: mosquitto:1883

## Backup

To backup flows:
1. Menu → Export → All flows
2. Save JSON to secure file

## Flow Description

The current flows implement:

- **MQTT Subscription**: Subscribes to `iiot/factory/#` topics
- **Data Routing**: Routes messages based on sensor type
- **InfluxDB Writer**: Writes time-series data to InfluxDB
- **MySQL Writer**: Writes events and alerts to MySQL
- **Debug Nodes**: Monitor data flow in real-time

---

**Last Updated**: February 5, 2026
