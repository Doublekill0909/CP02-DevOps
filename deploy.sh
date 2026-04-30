#!/bin/bash

# ==============================================================================
# Script de Deploy Automático - Checkpoint 2 (Docker)
# Infraestrutura: Rede Bridge Customizada, Volume Persistente, MySQL e API Flask
# ==============================================================================

echo "========================================================"
echo "Iniciando o Deploy da Infraestrutura (RM566234)..."
echo "========================================================"

# 1. Configuração de Rede
echo "[1/4] Criando a rede isolada (cp02-network)..."
# O redirecionamento 2>/dev/null esconde mensagens de erro caso a rede já exista
docker network create cp02-network 2>/dev/null || echo "A rede já existe. Seguindo..."

# 2. Configuração de Armazenamento
echo "[2/4] Criando o volume para persistência do banco..."
docker volume create mysql-cp02-data

# 3. Provisionamento do Banco de Dados
echo "[3/4] Subindo o Banco de Dados (MySQL 8.0)..."
# Remove o container antigo silenciosamente para evitar erro de "Name Conflict"
docker rm -f mysql-rm566234 2>/dev/null

# OBSERVAÇÃO DE PATH: Este script assume que você está rodando ele da raiz do seu projeto,
# onde as pastas 'mysql-CP2' e 'CP2-api' existem.
docker run --name mysql-rm566234 -d \
  -e MYSQL_ROOT_PASSWORD=senha-cp02 \
  -e MYSQL_DATABASE=yugioh \
  -e MYSQL_USER=user-cp02 \
  -e MYSQL_PASSWORD=senha-cp02 \
  --network cp02-network \
  -p 3306:3306 \
  -v mysql-cp02-data:/var/lib/mysql \
  -v $(pwd)/mysql-CP2/docker-entrypoint-initdb.d/init.sql:/docker-entrypoint-initdb.d/init.sql \
  mysql:8.0

# Prevenção de Race Condition (Condição de Corrida)
echo "Aguardando 15 segundos para o MySQL processar o init.sql e abrir a porta 3306..."
sleep 15

# 4. Provisionamento da API
echo "[4/4] Subindo a API (Flask)..."
docker rm -f api-rm566234 2>/dev/null

docker run --name api-rm566234 -d \
  -v $(pwd)/CP2-api:/app \
  -w /app \
  -p 5000:5000 \
  --network cp02-network \
  -e DB_HOST=mysql-rm566234 \
  -e DB_USER=user-cp02 \
  -e DB_PASSWORD=senha-cp02 \
  -e DB_NAME=yugioh \
  python:3.10-slim \
  bash -c "pip install --no-cache-dir flask mysql-connector-python && python app.py"

echo "========================================================"
echo "Deploy finalizado com sucesso! Teste o endpoint em http://localhost:5000/health"
echo "========================================================"
