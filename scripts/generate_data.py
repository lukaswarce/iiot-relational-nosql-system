#!/usr/bin/env python3
"""
MQTT Test Data Generator / Generador de Datos de Prueba MQTT
=============================================================

English:
--------
Generates realistic IIoT sensor data and publishes to MQTT broker for testing.
Simulates temperature, pressure, and vibration sensors from multiple production lines.

Usage:
    python scripts/generate_data.py [options]

Options:
    --broker HOST       MQTT broker host (default: localhost)
    --port PORT         MQTT broker port (default: 1883)
    --interval SECONDS  Publishing interval (default: 5)
    --lines NUMBER      Number of production lines (default: 5)
    --duration SECONDS  Run duration in seconds (0 = infinite, default: 0)

Example:
    python scripts/generate_data.py --interval 2 --lines 3 --duration 60

Español:
--------
Genera datos realistas de sensores IIoT y los publica al broker MQTT para pruebas.
Simula sensores de temperatura, presión y vibración de múltiples líneas de producción.

Uso:
    python scripts/generate_data.py [opciones]

Opciones:
    --broker HOST       Host del broker MQTT (predeterminado: localhost)
    --port PORT         Puerto del broker MQTT (predeterminado: 1883)
    --interval SEGUNDOS Intervalo de publicación (predeterminado: 5)
    --lines NÚMERO      Número de líneas de producción (predeterminado: 5)
    --duration SEGUNDOS Duración en segundos (0 = infinito, predeterminado: 0)

Ejemplo:
    python scripts/generate_data.py --interval 2 --lines 3 --duration 60
"""

import argparse
import json
import random
import time
from datetime import datetime
from typing import Dict, List

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("Error: paho-mqtt library not found / Biblioteca paho-mqtt no encontrada")
    print("Install with / Instalar con: pip install paho-mqtt")
    exit(1)


# =============================================================================
# SENSOR CONFIGURATION / CONFIGURACIÓN DE SENSORES
# =============================================================================

SENSOR_CONFIG = {
    "temperature": {
        "min": 20.0,  # °C
        "max": 95.0,  # °C
        "normal_range": (65.0, 80.0),  # Normal operating range / Rango operativo normal
        "warning_threshold": 85.0,  # Warning level / Nivel de advertencia
        "critical_threshold": 90.0,  # Critical level / Nivel crítico
        "unit": "°C"
    },
    "pressure": {
        "min": 0.5,  # bar
        "max": 8.0,  # bar
        "normal_range": (4.0, 6.5),  # Normal operating range / Rango operativo normal
        "warning_threshold": 7.0,  # Warning level / Nivel de advertencia
        "critical_threshold": 7.5,  # Critical level / Nivel crítico
        "unit": "bar"
    },
    "vibration": {
        "min": 0.0,  # mm/s RMS
        "max": 50.0,  # mm/s RMS
        "normal_range": (2.0, 15.0),  # Normal operating range / Rango operativo normal
        "warning_threshold": 30.0,  # Warning level / Nivel de advertencia
        "critical_threshold": 40.0,  # Critical level / Nivel crítico
        "unit": "mm/s"
    }
}

# Production line locations / Ubicaciones de líneas de producción
LOCATIONS = [
    "factory_floor_a",
    "factory_floor_b",
    "assembly_zone_1",
    "assembly_zone_2",
    "warehouse"
]


# =============================================================================
# MQTT CALLBACKS / CALLBACKS MQTT
# =============================================================================

def on_connect(client, userdata, flags, rc):
    """
    Callback when client connects to broker
    Callback cuando el cliente se conecta al broker
    """
    if rc == 0:
        print("✓ Connected to MQTT broker / Conectado al broker MQTT")
    else:
        print(f"✗ Connection failed with code {rc} / Conexión falló con código {rc}")


def on_publish(client, userdata, mid):
    """
    Callback when message is published (optional verbose mode)
    Callback cuando se publica un mensaje (modo verbose opcional)
    """
    pass  # Silent mode / Modo silencioso


# =============================================================================
# DATA GENERATION / GENERACIÓN DE DATOS
# =============================================================================

class SensorSimulator:
    """
    Simulates realistic sensor behavior with noise and anomalies
    Simula comportamiento realista de sensores con ruido y anomalías
    """
    
    def __init__(self, sensor_type: str, line_id: int):
        self.sensor_type = sensor_type
        self.line_id = line_id
        self.config = SENSOR_CONFIG[sensor_type]
        self.current_value = random.uniform(*self.config["normal_range"])
        self.anomaly_probability = 0.05  # 5% chance of anomaly / 5% probabilidad de anomalía
        
    def generate_value(self) -> float:
        """
        Generate next sensor reading with realistic variation
        Genera próxima lectura de sensor con variación realista
        """
        # Simulate random walk with noise / Simular camino aleatorio con ruido
        noise = random.gauss(0, 0.5)
        drift = random.uniform(-0.3, 0.3)
        
        # Randomly inject anomalies / Inyectar anomalías aleatoriamente
        if random.random() < self.anomaly_probability:
            # Create spike or drop / Crear pico o caída
            anomaly = random.choice([-1, 1]) * random.uniform(5, 15)
            self.current_value += anomaly
        else:
            self.current_value += noise + drift
        
        # Clamp to sensor limits / Limitar a límites del sensor
        self.current_value = max(
            self.config["min"],
            min(self.config["max"], self.current_value)
        )
        
        return round(self.current_value, 2)
    
    def get_status(self, value: float) -> str:
        """
        Determine sensor status based on thresholds
        Determinar estado del sensor basado en umbrales
        """
        if value >= self.config["critical_threshold"]:
            return "critical"
        elif value >= self.config["warning_threshold"]:
            return "warning"
        elif self.config["normal_range"][0] <= value <= self.config["normal_range"][1]:
            return "normal"
        else:
            return "low"


class DataGenerator:
    """
    Main data generator class / Clase principal generadora de datos
    """
    
    def __init__(self, num_lines: int):
        self.num_lines = num_lines
        self.simulators: Dict[int, Dict[str, SensorSimulator]] = {}
        
        # Initialize simulators for each line and sensor type
        # Inicializar simuladores para cada línea y tipo de sensor
        for line_id in range(1, num_lines + 1):
            self.simulators[line_id] = {
                sensor_type: SensorSimulator(sensor_type, line_id)
                for sensor_type in SENSOR_CONFIG.keys()
            }
    
    def generate_batch(self) -> List[Dict]:
        """
        Generate a batch of sensor readings for all lines
        Generar un lote de lecturas de sensores para todas las líneas
        """
        messages = []
        timestamp = datetime.utcnow().isoformat() + "Z"
        
        for line_id, sensors in self.simulators.items():
            location = LOCATIONS[(line_id - 1) % len(LOCATIONS)]
            
            for sensor_type, simulator in sensors.items():
                value = simulator.generate_value()
                status = simulator.get_status(value)
                
                # Create MQTT message / Crear mensaje MQTT
                topic = f"iiot/factory/line{line_id}/{sensor_type}"
                payload = {
                    "sensor_id": f"{sensor_type}_line{line_id}",
                    "line_id": line_id,
                    "location": location,
                    "measurement": sensor_type,
                    "value": value,
                    "unit": simulator.config["unit"],
                    "status": status,
                    "timestamp": timestamp
                }
                
                messages.append({"topic": topic, "payload": json.dumps(payload)})
        
        return messages


# =============================================================================
# MAIN FUNCTION / FUNCIÓN PRINCIPAL
# =============================================================================

def main():
    """Main execution / Ejecución principal"""
    
    # Parse command line arguments / Parsear argumentos de línea de comandos
    parser = argparse.ArgumentParser(
        description="IIoT MQTT Test Data Generator / Generador de Datos de Prueba MQTT IIoT"
    )
    parser.add_argument("--broker", default="localhost", help="MQTT broker host")
    parser.add_argument("--port", type=int, default=1883, help="MQTT broker port")
    parser.add_argument("--interval", type=float, default=5.0, help="Publishing interval (seconds)")
    parser.add_argument("--lines", type=int, default=5, help="Number of production lines")
    parser.add_argument("--duration", type=int, default=0, help="Run duration (seconds, 0=infinite)")
    parser.add_argument("--verbose", action="store_true", help="Verbose output")
    
    args = parser.parse_args()
    
    # Print configuration / Imprimir configuración
    print("=" * 70)
    print("IIoT MQTT Test Data Generator / Generador de Datos de Prueba MQTT IIoT")
    print("=" * 70)
    print(f"Broker: {args.broker}:{args.port}")
    print(f"Production Lines / Líneas de Producción: {args.lines}")
    print(f"Interval / Intervalo: {args.interval}s")
    print(f"Duration / Duración: {'infinite / infinito' if args.duration == 0 else f'{args.duration}s'}")
    print("=" * 70)
    
    # Initialize MQTT client / Inicializar cliente MQTT
    client = mqtt.Client(client_id="iiot_data_generator")
    client.on_connect = on_connect
    if args.verbose:
        client.on_publish = on_publish
    
    try:
        client.connect(args.broker, args.port, keepalive=60)
        client.loop_start()
    except Exception as e:
        print(f"✗ Failed to connect to broker / Error al conectar al broker: {e}")
        return
    
    # Initialize data generator / Inicializar generador de datos
    generator = DataGenerator(args.lines)
    
    # Publishing loop / Bucle de publicación
    start_time = time.time()
    message_count = 0
    
    try:
        while True:
            # Check duration / Verificar duración
            if args.duration > 0 and (time.time() - start_time) >= args.duration:
                print("\n✓ Duration reached, stopping / Duración alcanzada, deteniendo")
                break
            
            # Generate and publish messages / Generar y publicar mensajes
            messages = generator.generate_batch()
            
            for msg in messages:
                result = client.publish(msg["topic"], msg["payload"], qos=0)
                message_count += 1
                
                if args.verbose:
                    payload = json.loads(msg["payload"])
                    print(f"→ {msg['topic']}: {payload['value']}{payload['unit']} ({payload['status']})")
            
            # Progress indicator / Indicador de progreso
            if not args.verbose:
                elapsed = int(time.time() - start_time)
                print(f"\r📊 Published / Publicados: {message_count} messages | "
                      f"Elapsed / Transcurrido: {elapsed}s", end="", flush=True)
            
            # Wait for next interval / Esperar siguiente intervalo
            time.sleep(args.interval)
            
    except KeyboardInterrupt:
        print("\n\n⚠ Interrupted by user / Interrumpido por usuario")
    except Exception as e:
        print(f"\n✗ Error: {e}")
    finally:
        client.loop_stop()
        client.disconnect()
        print(f"\n✓ Disconnected. Total messages / Desconectado. Mensajes totales: {message_count}")


if __name__ == "__main__":
    main()
