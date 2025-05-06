FROM python:3.9-slim-buster

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ./ /app

RUN pip install --upgrade pip 
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000
EXPOSE 8501

ENV PYTHONPATH=/app

CMD ["bash", "-c", "uvicorn api:app --host 0.0.0.0 --port 8000 & streamlit run spotify_dashboard.py --server.address=0.0.0.0 --server.port=8501"]