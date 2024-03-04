# Usa una imagen base de Python
FROM python:3.9

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos necesarios al contenedor
COPY requirements.txt ./ 
COPY main.py ./

# Instala las dependencias
RUN pip install --no-cache-dir -r requirements.txt
# RUN pip install --upgrade paramiko cryptography

# Expone el puerto en el que tu aplicación se ejecutará
EXPOSE 8520

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8520"]