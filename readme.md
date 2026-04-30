Guia de Implementação: Yu-Gi-Oh! API (Checkpoint 2)

# Integrantes da Equipe

• Ana Flavia Camelo - RM561489  
• Gustavo Kenji Terada - RM562745  
• João Guilherme Carvalho Novaes - RM566234  
• Pedro Chasci Puga - RM565154  
• Lucas Figueiredo Vieira - RM561342

# 1\. Arquitetura da Solução

Este projeto implementa uma arquitetura containerizada utilizando Docker. O foco central é a persistência de dados e a comunicação isolada entre camadas.

**• Rede Isolada:** Utilização da bridge customizada 'cp02-network' para permitir a resolução de nomes via DNS interno do Docker.

**• Persistência:** Uso de volume nomeado 'mysql-cp02-data' para garantir a integridade dos dados (RDBMS) em caso de reinicialização ou destruição do container.

**• Variáveis de Ambiente:** Configuração dinâmica de segredos e endereços de host, seguindo as melhores práticas de infraestrutura como código (IaC).

# 2\. Estrutura do Repositório

Este repositório contém os seguintes artefatos essenciais para a execução do laboratório:

**• deploy.sh:** Script de provisionamento automatizado (IaC) que cria a infraestrutura de base (redes e volumes) e sobe os containers sequencialmente. O uso deste script é a forma recomendada de subir a aplicação.  
**• app.py:** Código fonte da API RESTful escrita em Python utilizando o micro-framework Flask.  
**• init.sql:** Script DDL/DML que o MySQL executa na primeira inicialização para criar a tabela de cartas e popular os dados iniciais do laboratório.

# 3\. Pré-requisitos

• Docker Engine instalado e rodando.

• Acesso ao terminal Linux (bash).

# 4\. Procedimento de Deploy (Manual)

Recomendamos a utilização do script \`./deploy.sh\` na raiz do projeto. Caso prefira provisionar os recursos manualmente via CLI, siga os passos abaixo:

## Passo 4.1: Criação da Infraestrutura Base

docker network create cp02-network  
docker volume create mysql-cp02-data

## Passo 4.2: Deploy do Banco de Dados (MySQL)

Navegue até a pasta 'mysql-CP2' e execute:

docker run --name mysql-rm566234 -d \\  
\-e MYSQL_ROOT_PASSWORD=senha-cp02 \\  
\-e MYSQL_DATABASE=yugioh \\  
\-e MYSQL_USER=user-cp02 \\  
\-e MYSQL_PASSWORD=senha-cp02 \\  
\--network cp02-network \\  
\-p 3306:3306 \\  
\-v mysql-cp02-data:/var/lib/mysql \\  
\-v \$(pwd)/docker-entrypoint-initdb.d/init.sql:/docker-entrypoint-initdb.d/init.sql \\  
mysql:8.0

## Passo 4.3: Deploy da API (Flask)

Navegue até a pasta 'CP2-api' e execute:

docker run --name api-rm566234 -d \\  
\-v \$(pwd):/app \\  
\-w /app \\  
\-p 5000:5000 \\  
\--network cp02-network \\  
\-e DB_HOST=mysql-rm566234 \\  
\-e DB_USER=user-cp02 \\  
\-e DB_PASSWORD=senha-cp02 \\  
\-e DB_NAME=yugioh \\  
python:3.10-slim \\  
bash -c "pip install --no-cache-dir flask mysql-connector-python && python app.py"

# 5\. Validação das Operações (CRUD)

O utilitário 'jq' é utilizado para formatar o JSON de resposta no terminal.

READ (Listar Registros):

curl -s -X GET <http://localhost:5000/cartas> | jq

CREATE (Inserir Registro):

curl -s -X POST <http://localhost:5000/cartas> \\  
\-H "Content-Type: application/json" \\  
\-d '{"nome": "Bulbassaur", "tipo": "Dragão", "ataque": 3000, "defesa": 2500}' | jq

UPDATE (Atualizar Registro ID 1):

curl -s -X PUT <http://localhost:5000/cartas/1> \\  
\-H "Content-Type: application/json" \\  
\-d '{"nome": "João", "tipo": "Dragão Divino", "ataque": 4500, "defesa": 3800}' | jq

DELETE (Remover Registro ID 1):

curl -s -X DELETE <http://localhost:5000/cartas/1> | jq

# 6\. Manutenção e Limpeza

Para remover os containers sem apagar os dados persistidos no volume:

docker rm -f api-rm566234 mysql-rm566234
