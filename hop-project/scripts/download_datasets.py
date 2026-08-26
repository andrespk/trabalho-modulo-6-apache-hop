import urllib.request
import zipfile
import io
import os
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
target_dir = os.path.join(base_dir, "database")
os.makedirs(target_dir, exist_ok=True)

datasets = {
    "student_habits_vs_academic_performance": "https://www.kaggle.com/api/v1/datasets/download/jayaantanaath/student-habits-vs-academic-performance",
    "student_mental_health": "https://www.kaggle.com/api/v1/datasets/download/shariful07/student-mental-health"
}

print("=== INICIANDO DOWNLOAD HTTPS DOS DATASETS KAGGLE ===")
for name, url in datasets.items():
    print(f"[*] Requisitando HTTPS: {url}...")
    req = urllib.request.Request(url, headers={"User-Agent": "ApacheHop-ETL-Client/2.19.0 (UEA-IA-Course)"})
    with urllib.request.urlopen(req, context=ctx, timeout=60) as resp:
        if resp.status == 200:
            data = resp.read()
            print(f"[OK] Download concluido: {len(data)} bytes recebidos")
            with zipfile.ZipFile(io.BytesIO(data)) as z:
                z.extractall(target_dir)
                print(f"[OK] Arquivos extraidos em {target_dir}: {z.namelist()}")
        else:
            print(f"[ERRO] Falha no download de {name}: Status HTTP {resp.status}")

print("=== DOWNLOAD E EXTRACAO CONCLUIDOS COM SUCESSO ===")
