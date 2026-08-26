"""
Ingestao HTTPS Resiliente com Apache Hop / Python
- Retry com backoff exponencial (3 tentativas)
- Timeout de conexao e socket
- Validacao de integridade e descompressao de ZIP
- Fallback seguro para cache local caso haja indisponibilidade temporaria
"""
import urllib.request
import zipfile
import io
import os
import ssl
import time
import sys

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
target_dir = os.path.join(base_dir, "database")
os.makedirs(target_dir, exist_ok=True)

datasets = {
    "student_habits_vs_academic_performance": {
        "url": "https://www.kaggle.com/api/v1/datasets/download/jayaantanaath/student-habits-vs-academic-performance",
        "expected_file": "student_habits_performance.csv"
    },
    "student_mental_health": {
        "url": "https://www.kaggle.com/api/v1/datasets/download/shariful07/student-mental-health",
        "expected_file": "Student Mental health.csv"
    }
}

MAX_RETRIES = 3
INITIAL_BACKOFF = 2  # segundos

print("====================================================================")
print("  INICIANDO INGESTAO HTTPS RESILIENTE DE DATASETS KAGGLE")
print("====================================================================")

for name, meta in datasets.items():
    url = meta["url"]
    expected_file = meta["expected_file"]
    file_path = os.path.join(target_dir, expected_file)
    success = False
    
    for attempt in range(1, MAX_RETRIES + 1):
        print(f"[*] [{name}] Tentativa {attempt}/{MAX_RETRIES} - Requisitando: {url}")
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "ApacheHop-ETL-Client/2.19.0 (UEA-Course)"}
            )
            with urllib.request.urlopen(req, context=ctx, timeout=20) as resp:
                if resp.status == 200:
                    data = resp.read()
                    if len(data) == 0:
                        raise ValueError("Resposta recebida com corpo vazio (0 bytes).")
                    
                    with zipfile.ZipFile(io.BytesIO(data)) as z:
                        z.extractall(target_dir)
                        print(f"    [SUCESSO] Download concluido ({len(data)} bytes). Arquivos: {z.namelist()}")
                    success = True
                    break
                else:
                    print(f"    [AVISO] Codigo HTTP inesperado: {resp.status}")
        except Exception as e:
            print(f"    [ERRO] Falha na tentativa {attempt}: {str(e)}")
            if attempt < MAX_RETRIES:
                sleep_time = INITIAL_BACKOFF ** attempt
                print(f"    [INFO] Aguardando {sleep_time}s para nova tentativa (Backoff Exponencial)...")
                time.sleep(sleep_time)
                
    if not success:
        print(f"[ALERTA DE RESILIENCIA] Nao foi possivel baixar {name} apos {MAX_RETRIES} tentativas.")
        if os.path.exists(file_path):
            print(f"[FALLBACK ATIVADO] Utilizando copia em cache local existente: {file_path} ({os.path.getsize(file_path)} bytes).")
            print("[INFO] Processo downstream continuara normalmente com dados preservados.")
        else:
            print(f"[ERRO CRITICO] Nenhum cache local disponivel para {expected_file}!")
            sys.exit(1)

print("====================================================================")
print("  INGESTAO HTTPS CONCLUIDA COM SUCESSO E GARANTIA DE RESILIENCIA")
print("====================================================================")
