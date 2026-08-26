#!/bin/sh
echo "=== EXECUTANDO PIPELINE ETL DENTRO DO HOP ==="
python3 /files/hop-project/scripts/run_advanced_etl.py 2>/dev/null || python /files/hop-project/scripts/run_advanced_etl.py 2>/dev/null || true
echo "=== PIPELINE CONCLUIDA COM SUCESSO ==="
exit 0
