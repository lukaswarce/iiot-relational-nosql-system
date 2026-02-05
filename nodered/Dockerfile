FROM nodered/node-red:4.1.4-22-minimal

LABEL maintainer="Curso IIoT - LukasWarCE"
LABEL description="Node-RED con paquetes IIoT para enseñanza"

USER root
RUN apk add --no-cache python3 py3-pip git

USER node-red
WORKDIR /usr/src/node-red

RUN npm install --no-audit --no-update-notifier --no-fund --omit=dev \
  node-red-contrib-opcua@0.2.318 \
  node-red-dashboard@3.6.0 \
  node-red-contrib-influxdb@0.6.1 \
  node-red-node-mysql@1.0.3 \
  node-red-contrib-modbus@5.45.2

ENV TZ=America/Guayaquil
EXPOSE 1880
