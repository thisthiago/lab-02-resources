import json
import boto3
from urllib.request import Request, urlopen
from datetime import datetime

def lambda_handler(event, context):
    # URL da API
    url = 'https://adm.senado.gov.br/adm-dadosabertos/api/v1/servidores/estagiarios'
    
    # Headers da requisição
    headers = {
        'accept': 'application/json'
    }
    
    try:
        req = Request(url, headers=headers, method='GET')
        with urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            
            bucket_name = 'dev-lab-02-us-east-2-landing'
            
            file_name = f'dados_abertos/senado/estagiarios/estagiarios_senado_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
            
            s3 = boto3.client('s3')
            s3.put_object(
                Bucket=bucket_name,
                Key=file_name,
                Body=json.dumps(data),
                ContentType='application/json'
            )
            
            return {
                'statusCode': 200,
                'body': f'Dados salvos com sucesso em {bucket_name}/{file_name}'
            }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Erro ao processar a requisição: {str(e)}'
        }