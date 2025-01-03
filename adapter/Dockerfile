FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install paho-mqtt influxdb-client
CMD ["python", "-u", "adapter.py"]
