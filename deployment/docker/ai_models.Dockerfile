FROM python:3.11-slim
WORKDIR /app
COPY ai_models/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ai_models .
CMD ["python", "main.py"]
