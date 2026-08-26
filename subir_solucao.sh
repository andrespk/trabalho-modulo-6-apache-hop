#!/bin/bash
set -e

echo "====================================================================="
echo "  SUBINDO AMBIENTE COMPLETO (APACHE HOP + METABASE + SQLITE)"
echo "====================================================================="

echo "[1/3] Inicializando containers Docker..."
docker compose -f infra/docker-compose.yml up -d

echo "[2/3] Aguardando inicialização do Metabase e Apache Hop..."
sleep 8

echo "[3/3] Garantindo provisionamento idempotente do Metabase..."
python3 hop-project/scripts/provision_metabase_idempotent.py || python hop-project/scripts/provision_metabase_idempotent.py

echo ""
echo "====================================================================="
echo "  AMBIENTE PRONTO PARA USO!"
echo "====================================================================="
echo "  - Metabase Dashboard : http://localhost:3001/dashboard/2"
echo "  - Usuario Padrão     : admin@uea.edu.br"
echo "  - Senha de Acesso    : HopAdmin2024!"
echo ""
echo "  - Apache Hop Web UI  : http://localhost:8085/ui"
echo "  - Preview Web Local  : http://localhost:8088/dashboard_preview.html"
echo "====================================================================="
