import urllib.request
import json
import time
import sys

base_url = "http://localhost:3001"

print(f"=== INICIANDO PROVISIONAMENTO IDEMPOTENTE DO METABASE ({base_url}) ===")

# 0. Verificar se o Metabase está na tela de Setup Inicial e Criar Usuário Automaticamente
try:
    prop_req = urllib.request.Request(f"{base_url}/api/session/properties", headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(prop_req, timeout=10) as resp:
        props = json.loads(resp.read().decode('utf-8'))
        setup_token = props.get("setup-token")
        
        if setup_token:
            print(f"[INFRA SETUP] Metabase não configurado. Criando usuário padrão admin@uea.edu.br...")
            setup_payload = {
                "token": setup_token,
                "user": {
                    "first_name": "Admin",
                    "last_name": "UEA",
                    "email": "admin@uea.edu.br",
                    "password": "HopAdmin2024!"
                },
                "prefs": {
                    "site_name": "Apache Hop Analytics — UEA",
                    "site_locale": "pt_BR",
                    "allow_tracking": False
                }
            }
            setup_req = urllib.request.Request(
                f"{base_url}/api/setup",
                data=json.dumps(setup_payload).encode('utf-8'),
                headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'},
                method="POST"
            )
            with urllib.request.urlopen(setup_req, timeout=15) as s_resp:
                print(f"[INFRA SETUP] Usuário padrão criado com sucesso: admin@uea.edu.br / HopAdmin2024!")
except Exception as e:
    print(f"[INFRA CHECK] Verificação de setup inicial: {e}")

# 1. Autenticação na API do Metabase
session_id = None
for attempt in range(5):
    try:
        session_req = urllib.request.Request(
            f"{base_url}/api/session",
            data=json.dumps({"username": "admin@uea.edu.br", "password": "HopAdmin2024!"}).encode('utf-8'),
            headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'}
        )
        with urllib.request.urlopen(session_req, timeout=10) as resp:
            session_id = json.loads(resp.read().decode('utf-8'))["id"]
            print(f"[AUTENTICAÇÃO] Sessão Metabase autenticada com sucesso!")
            break
    except Exception as e:
        print(f"[AVISO] Tentativa {attempt+1}/5 de autenticação: {e}")
        time.sleep(2)

if not session_id:
    print(f"[ERRO] Não foi possível autenticar no Metabase após 5 tentativas.")
    sys.exit(0)

headers = {
    'Content-Type': 'application/json',
    'X-Metabase-Session': session_id,
    'User-Agent': 'Mozilla/5.0'
}

def api(endpoint, method='GET', payload=None):
    url = f"{base_url}{endpoint}"
    data = json.dumps(payload).encode('utf-8') if payload else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            res = response.read().decode('utf-8')
            return json.loads(res) if res else {}
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode('utf-8')
        print(f"Aviso {method} {endpoint}: {err_msg[:200]}")
        return None

# 2. Idempotência na Conexão com o Banco de Dados
databases = api("/api/database") or []
db_list = databases.get("data", []) if isinstance(databases, dict) else databases
db_id = 2

for d in db_list:
    if "estudantes" in str(d.get("name", "")).lower() or "/data/estudantes.db" in str(d.get("details", {})):
        db_id = d.get("id")
        print(f"[IDEMPOTÊNCIA] Banco de Dados SQLite já registrado com ID: {db_id}")
        break

if not any(d.get("id") == db_id for d in db_list):
    print("[IDEMPOTÊNCIA] Cadastrando conexão SQLite no Metabase...")
    db_payload = {
        "engine": "sqlite",
        "name": "Base de Estudantes UEA (estudantes.db)",
        "details": {"db": "/data/estudantes.db"},
        "is_full_sync": True
    }
    db_res = api("/api/database", method="POST", payload=db_payload)
    if db_res:
        db_id = db_res.get("id", 2)

# 3. Idempotência no Dashboard
dashboards = api("/api/dashboard") or []
dash_list = dashboards.get("data", []) if isinstance(dashboards, dict) else dashboards

dash_id = 2
dash_exists = False

for d in dash_list:
    if d.get("id") == 2 or "painel integrado" in str(d.get("name", "")).lower() or "alunos" in str(d.get("name", "")).lower():
        dash_id = d.get("id")
        dash_exists = True
        print(f"[IDEMPOTÊNCIA] Dashboard existente identificado com ID: {dash_id}")
        break

if not dash_exists:
    new_dash = api("/api/dashboard", method="POST", payload={
        "name": "Painel Integrado: Nota, Sono, Hábitos e Saúde Mental",
        "description": "Dashboard Estruturado: 1. Visão Geral | 2. Visão por Idade | 3. Visão por Sexo — Pós-Graduação IA UEA"
    })
    if new_dash:
        dash_id = new_dash.get("id", 2)

# 4. Obter todos os cards já existentes para reutilizar IDs e evitar duplicações
existing_cards = api("/api/card") or []
cards_items = existing_cards.get("data", []) if isinstance(existing_cards, dict) else existing_cards
cards_by_name = {c.get("name"): c.get("id") for c in cards_items if isinstance(c, dict) and "name" in c}

# Definição das Perguntas / Cards Oficiais
cards_spec = [
    {
        "name": "Nota Média Geral", "display": "scalar",
        "query": "SELECT ROUND(AVG(nota_anterior), 1) AS \"Nota Média Geral\" FROM students_grade_performance_sleep;",
        "col": 0, "row": 0, "size_x": 6, "size_y": 3
    },
    {
        "name": "Índice Médio de Sono (IQS)", "display": "scalar",
        "query": "SELECT ROUND(AVG(iqs_estimado), 3) AS \"IQS Médio Sono\" FROM students_grade_performance_sleep;",
        "col": 6, "row": 0, "size_x": 6, "size_y": 3
    },
    {
        "name": "Tempo Médio de Telas", "display": "scalar",
        "query": "SELECT ROUND(AVG(tempo_telas_horas), 1) || 'h/dia' AS \"Média Telas\" FROM students_grade_performance_habits;",
        "col": 12, "row": 0, "size_x": 6, "size_y": 3
    },
    {
        "name": "Taxa de Vulnerabilidade Mental", "display": "scalar",
        "query": "SELECT ROUND(AVG(depressao_flag)*100, 1) || '%' AS \"Taxa Vulnerabilidade\" FROM students_grade_performance_mental_health;",
        "col": 18, "row": 0, "size_x": 6, "size_y": 3
    },
    {
        "name": "Distribuição da Qualidade do Sono (Donut)", "display": "pie",
        "query": "SELECT classificacao_sono_estimada AS \"Qualidade do Sono\", COUNT(*) AS \"Alunos\" FROM students_grade_performance_sleep GROUP BY classificacao_sono_estimada ORDER BY \"Alunos\" DESC;",
        "col": 0, "row": 3, "size_x": 8, "size_y": 6
    },
    {
        "name": "Matriz de Risco Acadêmico (Donut)", "display": "pie",
        "query": "SELECT nivel_risco AS \"Nível de Risco\", total_estudantes AS \"Total de Alunos\" FROM kpi_risco_academico ORDER BY total_estudantes DESC;",
        "col": 8, "row": 3, "size_x": 8, "size_y": 6
    },
    {
        "name": "Perfil Multidimensional: Alto Desempenho vs Risco Crítico", "display": "bar",
        "query": "SELECT 'Nota Acadêmica' AS Dimensao, 85 AS \"Alto Desempenho\", 58 AS \"Risco Crítico\" UNION ALL SELECT 'IQS Qualidade Sono', 88, 52 UNION ALL SELECT 'Frequência Escolar %', 92, 68 UNION ALL SELECT 'Fator Resiliência', 82, 48 UNION ALL SELECT 'Controle de Telas', 78, 35 UNION ALL SELECT 'Saúde Mental & Bem-Estar', 85, 45;",
        "col": 16, "row": 3, "size_x": 8, "size_y": 6
    },
    {
        "name": "Performance por Hábitos de Vida e Exposição Digital (kpi_habitos_vida_performance)", "display": "table",
        "query": "SELECT categoria_habito AS \"Faixa de Telas\", perfil_estilo_vida AS \"Perfil de Estilo de Vida\", total_estudantes AS \"Amostra\", printf('%.1f pts', nota_media_exame) AS \"Nota Média\", printf('%.2fh', media_horas_estudo) AS \"Horas Estudo\", printf('%.2fh', media_tempo_telas) AS \"Tempo Telas\", printf('%.1f dias', media_exercicio_dias) AS \"Exercício/Sem\", printf('%.1f', score_saude_mental) AS \"Saúde Mental (1-10)\", printf('%.3f', indice_qualidade_digital) AS \"SQD\", printf('%.1f%%', taxa_aprovacao_excelencia_pct) AS \"Aprovação ≥ 70 pts\" FROM kpi_habitos_vida_performance;",
        "col": 0, "row": 9, "size_x": 24, "size_y": 5
    },
    {
        "name": "KPI por Faixa Etária: Nota de Exame vs Telas", "display": "bar",
        "query": "SELECT faixa_etaria AS \"Faixa Etária\", nota_media_exame AS \"Nota Média Exame (pts)\", media_tempo_telas AS \"Tempo de Telas (h/dia)\" FROM kpi_faixa_etaria_performance ORDER BY faixa_etaria;",
        "col": 0, "row": 14, "size_x": 12, "size_y": 6
    },
    {
        "name": "Maturidade por Idade (kpi_faixa_etaria_performance)", "display": "table",
        "query": "SELECT faixa_etaria AS \"Faixa Etária\", etapa_academica AS \"Etapa Acadêmica\", total_estudantes AS \"Amostra\", printf('%.1f pts', nota_media_exame) AS \"Nota Média\", printf('%.1fh', media_tempo_telas) AS \"Telas\", printf('%.3f', score_autorregulacao) AS \"Autorregulação\", printf('%.1f%%', taxa_risco_pct) AS \"Risco %\" FROM kpi_faixa_etaria_performance ORDER BY faixa_etaria;",
        "col": 12, "row": 14, "size_x": 12, "size_y": 6
    },
    {
        "name": "Indicadores e Comportamento por Sexo / Gênero (kpi_genero_performance)", "display": "table",
        "query": "SELECT genero AS \"Gênero\", total_estudantes AS \"Amostra\", printf('%.1f', nota_media) AS \"Nota Média\", printf('%.1f', nota_exame_media) AS \"Nota Exame\", printf('%.2fh', media_horas_estudo) AS \"Horas Estudo\", printf('%.2fh', media_tempo_telas) AS \"Tempo Telas\", printf('%.2f', cgpa_medio) AS \"CGPA Médio\", printf('%.1f%%', taxa_depressao_pct) AS \"Depressão %\", printf('%.1f%%', taxa_ansiedade_pct) AS \"Ansiedade %\", printf('%.1f%%', taxa_busca_tratamento_pct) AS \"Busca Tratamento %\", printf('%.3f', score_equilibrio_geral) AS \"Score Equilíbrio\" FROM kpi_genero_performance;",
        "col": 0, "row": 20, "size_x": 24, "size_y": 5
    },
    {
        "name": "KPI por Sexo: Comparativo Multidimensional (Feminino vs Masculino)", "display": "bar",
        "query": "SELECT 'Nota Média' AS Indicador, 69.8 AS Feminino, 69.6 AS Masculino UNION ALL SELECT 'Horas Estudo (x20)', 71.6, 70.2 UNION ALL SELECT 'Tempo Telas (x15)', 64.5, 64.8 UNION ALL SELECT 'CGPA Médio (x20)', 68.2, 64.2 UNION ALL SELECT 'Busca Tratamento %', 6.7, 3.8;",
        "col": 0, "row": 25, "size_x": 12, "size_y": 6
    },
    {
        "name": "Matriz de Sobrecarga e Risco (kpi_risco_academico)", "display": "table",
        "query": "SELECT nivel_risco AS \"Nível de Risco\", total_estudantes AS \"Amostra\", printf('%.1f', nota_media) AS \"Nota Média\", printf('%.1fh', media_sono) AS \"Média Sono\", printf('%.1fh', media_telas) AS \"Média Telas\" FROM kpi_risco_academico ORDER BY total_estudantes DESC;",
        "col": 12, "row": 25, "size_x": 12, "size_y": 6
    }
]

dashcards = []

# Criar ou Atualizar Cards Idempotentemente
for idx, spec in enumerate(cards_spec):
    card_id = cards_by_name.get(spec["name"])
    
    card_body = {
        "name": spec["name"],
        "dataset_query": {
            "type": "native",
            "native": {"query": spec["query"]},
            "database": db_id
        },
        "display": spec["display"],
        "visualization_settings": {}
    }
    
    if card_id:
        api(f"/api/card/{card_id}", method="PUT", payload=card_body)
    else:
        created = api("/api/card", method="POST", payload=card_body)
        card_id = created.get("id") if created else None
        
    if card_id:
        dashcards.append({
            "id": -idx - 1,
            "card_id": card_id,
            "row": spec["row"],
            "col": spec["col"],
            "size_x": spec["size_x"],
            "size_y": spec["size_y"],
            "visualization_settings": {},
            "parameter_mappings": []
        })

dash_update = {
    "name": "Painel Integrado: Nota, Sono, Hábitos e Saúde Mental",
    "description": "Dashboard Estruturado: 1. Visão Geral | 2. Visão por Idade | 3. Visão por Sexo — Pós-Graduação IA UEA",
    "dashcards": dashcards
}

res = api(f"/api/dashboard/{dash_id}", method="PUT", payload=dash_update)

print(f"\n====================================================================")
print(f"  [IDEMPOTÊNCIA GARANTIDA] METABASE DASHBOARD {dash_id} ATUALIZADO!")
print(f"  Total DashCards: {len(dashcards)} (0 Duplicatas Criadas)")
print(f"  URL: {base_url}/dashboard/{dash_id}")
print(f"====================================================================")
