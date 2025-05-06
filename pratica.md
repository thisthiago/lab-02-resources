### Aula prática

1. Instalar ferramentas
    - Terraform 
    - AWS CLI

2. Baixar imagens docker
    - docker pull thisthiago/jupyter:latest
    - docker pull thisthiago/spotify-data-app:1.0
    - docker network create lab-02-network
    - docker run -d --network lab-02-network --name jupyter  -p 8888:8888 thisthiago/jupyter:latest
    - docker run -d --network lab-02-network --name spotify-data-app  -p 8000:8000 -p 8501:8501 thisthiago/spotify-data-app:1.0

3. Notebook Delta Lake
    - Subir dados para exemplificação no S3

4. Notebook Spark Streaming

5. Notebook Case Barbearia
    - Diponibilizar url de db, ou podem escoler usar o db provisionado na infra própria

6. Criação de tabelas no athena via terraform

7. Execução de Lambdas buscando dados de API abertas