#!/usr/bin/env python3
import json

# Leer flows actual
with open('nodered/flows.json', 'r') as f:
    flows = json.load(f)

# Nuevos flows con conexiones a InfluxDB y MySQL
new_nodes = [
    # Tab MQTT -> InfluxDB
    {"id": "tab_mqtt_influx", "type": "tab", "label": "🌡️ MQTT → InfluxDB", "disabled": False},
    {"id": "mqtt_in_influx", "type": "mqtt in", "z": "tab_mqtt_influx", "name": "📥 Suscribir Temperatura", "topic": "iiot/sensors/temperature", "qos": "1", "datatype": "json", "broker": "mqtt_broker", "x": 140, "y": 100, "wires": [["func_influx", "debug_influx"]]},
    {"id": "func_influx", "type": "function", "z": "tab_mqtt_influx", "name": "🔧 Preparar InfluxDB", "func": "const data = msg.payload;\nmsg.payload = {temperature: data.value, sensor_id: data.sensor_id, location: data.location};\nreturn msg;", "x": 400, "y": 100, "wires": [["influx_out"]]},
    {"id": "influx_out", "type": "influxdb out", "z": "tab_mqtt_influx", "influxdb": "influx_config", "name": "💾 Escribir InfluxDB", "measurement": "temperature", "precision": "s", "x": 680, "y": 100, "wires": []},
    {"id": "debug_influx", "type": "debug", "z": "tab_mqtt_influx", "name": "🐛 Debug", "active": True, "x": 400, "y": 160, "wires": []},
    
    # Tab MQTT -> MySQL
    {"id": "tab_mqtt_mysql", "type": "tab", "label": "📊 MQTT → MySQL", "disabled": False},
    {"id": "mqtt_in_mysql", "type": "mqtt in", "z": "tab_mqtt_mysql", "name": "📥 Todos Sensores", "topic": "iiot/sensors/#", "qos": "1", "datatype": "json", "broker": "mqtt_broker", "x": 140, "y": 100, "wires": [["func_mysql"]]},
    {"id": "func_mysql", "type": "function", "z": "tab_mqtt_mysql", "name": "🔧 Preparar SQL", "func": "const d = msg.payload;\nconst esc = s => String(s||'').replace(/'/g, \"''\");\nmsg.topic = `INSERT INTO sensor_readings (sensor_id, sensor_type, value, unit, location) VALUES ('${esc(d.sensor_id)}', '${esc(d.sensor_type)}', ${d.value}, '${esc(d.unit)}', '${esc(d.location)}')`;\nreturn msg;", "x": 370, "y": 100, "wires": [["mysql_out", "debug_sql"]]},
    {"id": "mysql_out", "type": "mysql", "z": "tab_mqtt_mysql", "mydb": "mysql_config", "name": "💾 Insertar MySQL", "x": 650, "y": 100, "wires": [["debug_result"]]},
    {"id": "debug_sql", "type": "debug", "z": "tab_mqtt_mysql", "name": "🐛 SQL", "active": True, "complete": "topic", "x": 620, "y": 160, "wires": []},
    {"id": "debug_result", "type": "debug", "z": "tab_mqtt_mysql", "name": "🐛 Resultado", "active": True, "x": 860, "y": 100, "wires": []},
    
    # Configs
    {"id": "mqtt_broker", "type": "mqtt-broker", "name": "Mosquitto IIoT", "broker": "mosquitto", "port": "1883", "clientid": "", "usetls": False, "protocolVersion": "4", "keepalive": "60", "cleansession": True},
    {"id": "influx_config", "type": "influxdb", "hostname": "influxdb", "port": "8086", "protocol": "http", "database": "iiot_sensors", "name": "InfluxDB IIoT", "usetls": False, "influxdbVersion": "2.0", "url": "http://influxdb:8086", "rejectUnauthorized": False},
    {"id": "mysql_config", "type": "MySQLdatabase", "name": "MySQL IIoT", "host": "mysql", "port": "3306", "db": "iiot_db", "tz": "America/Guayaquil", "charset": "UTF8"}
]

# Agregar nuevos nodos
flows.extend(new_nodes)

# Guardar
with open('nodered/flows.json', 'w') as f:
    json.dump(flows, f, indent=2)

print(f"✅ Flows actualizados: {len(flows)} nodos")
print("✅ Agregados:")
print("   - Tab MQTT → InfluxDB")
print("   - Tab MQTT → MySQL") 
print("   - Configuraciones de conexión")
