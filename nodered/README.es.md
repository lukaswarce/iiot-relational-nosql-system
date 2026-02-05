# Node-RED Flows

Este directorio contiene los flujos de Node-RED para el proyecto IIoT.

## Archivo flows.json

El archivo `flows.json` contiene flujos pre-configurados que se cargarán automáticamente cuando Node-RED inicie.

**NOTA IMPORTANTE**: Los flujos incluidos son básicos para demostración. Pueden ser extendidos con:

1. Flujos adicionales para escribir a InfluxDB
2. Flujos para escribir a MySQL 
3. Demo de transacciones ACID
4. Comparación de consultas
5. Integración polyglot persistence
6. Factory I/O (opcional, deshabilitado)

## Agregar Flujos Manualmente

1. Acceder a Node-RED: http://localhost:1880
2. Importar flujos desde el menú hamburguesa → Import
3. Copiar contenido de flows adicionales
4. Click en Deploy

## Configurar Conexiones

### InfluxDB
- Crear nodo "influxdb out"
- URL: http://influxdb:8086
- Token: my-super-secret-auth-token
- Organization: iiot-class
- Bucket: iiot_sensors

### MySQL  
- Crear nodo "mysql"
- Host: mysql
- Port: 3306
- Database: iiot_db
- User: student
- Password: student123

### MQTT
- Ya configurado en mqtt_broker config node
- Broker: mosquitto:1883

## Backup

Para hacer backup de los flujos:
1. Menu → Export → All flows
2. Guardar JSON en archivo seguro
