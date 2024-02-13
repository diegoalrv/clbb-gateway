#!/bin/bash

# Crear una carpeta para los archivos
# mkdir api_gateway
# cd api_gateway

# Escribir el archivo main.py
cat <<EOT >> main.py
from fastapi import FastAPI
import docker

app = FastAPI()
docker_client = docker.from_env()

@app.get("/")
async def read_root():
    return {"message": "Hello World"}

@app.get("/containers")
async def list_containers():
    containers = docker_client.containers.list()
    return [container.attrs for container in containers]

@app.post("/containers/{image}")
async def create_container(image: str):
    container = docker_client.containers.run(image, detach=True)
    return {"container_id": container.id}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8520, reload=True)
EOT

# Escribir el archivo Dockerfile
cat <<EOT >> Dockerfile
# Usa una imagen base de Python
FROM python:3.9-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos necesarios al contenedor
COPY requirements.txt ./ 
COPY main.py ./

# Instala las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Expone el puerto en el que tu aplicación se ejecutará
EXPOSE 8520

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8520"]
EOT

# Escribir el archivo docker-compose.yml
cat <<EOT >> docker-compose.yml
version: '3'

networks:
  clbb:
    external: true

services:
  api_gateway:
    container_name: api_gateway
    build: .
    command: uvicorn main:app --host 0.0.0.0 --port 8520
    ports:
      - "8520:8520"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

    networks:
      - clbb
EOT

# Escribir el archivo requirements.txt
cat <<EOT >> requirements.txt
fastapi
uvicorn
docker
EOT

echo "Archivos creados exitosamente en la carpeta api_gateway."
