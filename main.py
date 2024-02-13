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
