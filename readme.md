Guia de Implementação: Yu-Gi-Oh! API (Checkpoint 2)

# 1\. Arquitetura da Solução

Este projeto implementa uma arquitetura de microserviços containerizados utilizando Docker. O foco central é a persistência de dados e a comunicação isolada entre camadas.

**• Rede Isolada:** Utilização da bridge customizada 'cp02-network' para permitir a resolução de nomes via DNS interno do Docker.

**• Persistência:** Uso de volume nomeado 'mysql-cp02-data' para garantir a integridade dos dados (RDBMS) em caso de reinicialização ou destruição do container.

**• Variáveis de Ambiente:** Configuração dinâmica de segredos e endereços de host, seguindo as melhores práticas de infraestrutura como código (IaC).

# 2\. Pré-requisitos

• Docker Engine instalado e rodando.

• Acesso ao terminal Linux (bash).

• Portas 5000 e 3306 liberadas no firewall do host (Azure NSG).

# 3\. Procedimento de Deploy

## Passo 3.1: Criação da Infraestrutura Base

docker network create cp02-network  
docker volume create mysql-cp02-data

## Passo 3.2: Deploy do Banco de Dados (MySQL)

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

## Passo 3.3: Deploy da API (Flask)

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

# 4\. Validação das Operações (CRUD)

Para testar o INSERT:

curl -X POST <http://localhost:5000/cartas> -H "Content-Type: application/json" -d '{"nome": "Kuriboh", "tipo": "Demônio", "ataque": 300, "defesa": 200}'

Para testar o SELECT (Read):

curl -X GET <http://localhost:5000/cartas>

# 5\. Manutenção e Limpeza

Para remover os containers sem apagar os dados do volume:

docker rm -f api-rm566234 mysql-rm566234