FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Install python and dependencies
RUN apt-get update && apt-get install -y python3 python3-pip libgl1-mesa-glx libglib2.0-0

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Expose port for FastAPI microservice
EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
