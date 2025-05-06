import requests
import boto3
import json
from datetime import datetime

bucket_name = "dev-lab-02-us-east-2-landing"
base_url = "http://localhost:8000"

s3 = boto3.client('s3')

def consumir_e_salvar(endpoint, categoria):
    url = f"{base_url}/{endpoint}"
    s3_key = f"spotify/{categoria}/{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.json"

    response = requests.get(url)
    response.raise_for_status()
    dados = response.json()

    json_data = json.dumps(dados, ensure_ascii=False, indent=2)

    s3.put_object(
        Bucket=bucket_name,
        Key=s3_key,
        Body=json_data.encode('utf-8'),
        ContentType='application/json'
    )

    print(f"✅ Dados de '{categoria}' salvos em s3://{bucket_name}/{s3_key}")


consumir_e_salvar("usuarios", "usuarios")
consumir_e_salvar("musicas", "musicas")
consumir_e_salvar("streamings", "streamings")
