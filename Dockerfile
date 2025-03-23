FROM python:3.9-slim-buster

WORKDIR /app

COPY huggingface_proxy.py .

RUN pip install --no-cache-dir fastapi uvicorn requests

EXPOSE 8000

CMD ["uvicorn", "huggingface_proxy:app", "--host", "0.0.0.0", "--port", "8000"]