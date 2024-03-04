from fastapi import FastAPI, HTTPException
import docker
import json

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
async def create_container(image: str, request_data: dict):
    # Check if request_data is empty or None
    if not request_data:
        raise HTTPException(status_code=400, detail="Request data is missing or empty")

    # Extract container parameters
    container_params = request_data.get("container_params", {})
    # Extract indicator parameters as environment variables for the container
    environment_vars = request_data.get("indicator_params", {})

    # Define the volume name
    volume_name = container_params.get('volume_name', 'tmp')

    # Define volumes to be mounted
    volumes = {volume_name: {"bind": "/app/tmp", "mode": "rw"}}

    # Define network
    network_name = container_params.get('network', 'clbb')

    # Run the container with environment variables, volumes, and networks
    container = docker_client.containers.run(
        image,
        detach=True,
        environment=environment_vars,
        volumes=volumes,
        auto_remove=True  # Set auto_remove to True to remove the container after it exits
    )

    try:
        network = docker_client.networks.get(network_name)
    except docker.errors.NotFound:
        network = docker_client.networks.create(network_name)
    
    network.connect(container)

    # Get container ID
    container_id = container.id

    return {"container_id": container_id}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8520, reload=True)
