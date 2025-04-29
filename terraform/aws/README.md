Aqui está um arquivo `README.md` completo com instruções claras para implantar seu cluster EKS usando os arquivos Terraform fornecidos:


# Terraform AWS EKS Cluster

Este projeto provisiona um cluster Amazon EKS (Elastic Kubernetes Service) com VPC, subnets públicas/privadas e node groups utilizando Terraform.

### Antes de tudo configure o Usando Workspaces do Terraform 
Os workspaces permitem gerenciar múltiplos ambientes (dev, staging, prod) com o mesmo código.

0. Inicialize o Terraform

```bash
terraform init
```

1. Criar um workspace para dev:
``` bash
terraform workspace new dev
```

2. Selecionar o workspace:
```bash
terraform workspace select dev
```
3. Verificar o workspace atual:
``` bash
terraform workspace show
```

>Saída esperada: "dev"

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurado
- Permissões AWS adequadas (AdministratorAccess ou equivalentes)
- kubectl instalado (para interação com o cluster)

## Estrutura de Arquivos
```markdown
./terraform/aws
├── README.md
├── main.tf # Configuração do provider e versões
├── variables.tf # Variáveis globais
├── vpc.tf # Módulo VPC com subnets
├── eks-cluster.tf # Configuração do cluster EKS
├── outputs.tf # Outputs do Terraform
└── environments/ # Configurações por ambiente (opcional)
├── dev/
└── prod/
```

## Como Usar

### 1. Clone o repositório

### 2. Configure as variáveis

Edite o arquivo `variables.tf` ou crie um `terraform.tfvars` com seus valores:

```hcl
aws_region  = "us-east-1"
project_name = "meu-projeto-eks"
```

### 3. Revise o plano de execução

```bash
terraform plan
```

### 4. Aplique a infraestrutura

```bash
terraform apply
```

Confirme digitando `yes` quando solicitado.

### 6. Configure o kubectl

Após a criação do cluster, atualize seu kubeconfig:

```bash
aws eks --region $(terraform output -raw aws_region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### 7. Verifique o cluster

```bash
kubectl get nodes
kubectl get pods -A
```

## Gerenciamento Avançado

### Workspaces (ambientes múltiplos)

1. Crie um workspace para dev/prod:

```bash
terraform workspace new dev
```

2. Selecione o workspace:

```bash
terraform workspace select dev
```

### Destruição da Infraestrutura

Para remover todos os recursos:

```bash
terraform destroy
```

## Outputs Úteis

Comando para listar todos os outputs:

```bash
terraform output
```

Principais outputs disponíveis:
- `cluster_name`: Nome do cluster EKS
- `cluster_endpoint`: Endpoint da API do Kubernetes
- `vpc_id`: ID da VPC criada

## Customização

### Node Groups
Edite `eks-cluster.tf` para modificar:
- Tipos de instância (`instance_types`)
- Tamanho do node group (`min_size`, `max_size`, `desired_size`)
- AMI (`ami_type`)

### Add-ons EKS
Adicione/remova add-ons na seção `cluster_addons` em `eks-cluster.tf`

## Troubleshooting

### Erros de Permissão
- Verifique se o usuário/role AWS tem permissões adequadas
- Confira as políticas do IAM associadas

### Problemas com kubectl
- Execute `aws sts get-caller-identity` para verificar as credenciais
- Verifique se o cluster está no status "ACTIVE" no console AWS

## Segurança
- Não comite arquivos `.tfstate` ou credenciais
- Utilize backend remoto (S3) para state files em produção


### Recursos Adicionais

- [Documentação Oficial do módulo EKS](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform Documentation](https://www.terraform.io/docs)

---
