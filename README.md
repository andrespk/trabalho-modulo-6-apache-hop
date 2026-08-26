# 📊 Performance de Alunos vs Sono, Hábitos e Saúde Mental
### Trabalho Final — Módulo 6: Engenharia de Dados com Apache Hop (Versão 2.5)

> **Esteira de Dados Resiliente | Ingestão HTTPS Dinâmica | Arquitetura Medalhão (Bronze/Silver/Gold/Platinum) | SQLite Containerizado | Dashboard Metabase | Testes E2E Playwright**

---

## 👥 Identificação da Equipe

| Nome | Papel / Responsabilidade Principal |
|---|---|
| **Adriano Mourão** | Engenharia de Dados & Pipelines de Transformação Apache Hop |
| **André Marques** | Arquitetura ETL, Modelagem Dimensional, Idempotência & Testes E2E |
| **Daniel Oliveira** | Ingestão HTTPS Resiliente, Extração de APIs Kaggle & Qualidade de Dados |
| **Paulo Dourado** | Infraestrutura Docker, Persistência SQLite & Orquestração |
| **Thiago Leite** | Indicadores Analíticos (KPIs) & Dashboard no Metabase |

---

## 📋 Ficha Técnica do Projeto

| Atributo | Especificação |
|---|---|
| **Instituição / Curso** | Universidade do Estado do Amazonas (UEA) — Pós-Graduação em Inteligência Artificial |
| **Módulo** | Módulo 6 — Engenharia de Dados & Apache Hop |
| **Tema do Trabalho** | Performance Acadêmica vs Qualidade do Sono, Hábitos Digitais e Saúde Mental |
| **Ferramenta ETL** | Apache Hop Client / Server versão 2.19.0 |
| **Banco de Dados** | SQLite 3 (armazenado em volume persistente containerizado) |
| **Dashboard BI** | Metabase v0.49+ (containerizado via Docker) |
| **Testes Automatizados** | Playwright E2E Suite (100% de Aprovação em 6 testes) |
| **Apresentação Gamma** | [Link da Apresentação no Gamma](https://gamma.app/docs/Performance-de-Alunos-vs-Sono-Habitos-e-Saude-Mental-6h4l60izibsc1vp?mode=doc) |
| **Idioma** | Português Brasileiro (pt-BR) |

---

## 📂 Estrutura Completa do Repositório

```
trabalho-modulo-6-apache-hop/
├── database/                                          # Armazenamento local de CSVs fontes
│   ├── Sleep_Efficiency.csv                          # Dataset 1: Sono (452 reg.)
│   ├── student_performance_dataset-selected-columns.csv # Dataset 2: Alunos (1.000 reg.)
│   ├── student_habits_performance.csv                # Dataset 3: Hábitos (1.000 reg., baixado via HTTPS)
│   └── Student Mental health.csv                     # Dataset 4: Saúde Mental (101 reg., baixado via HTTPS)
├── docs/                                              # Documentações auxiliares e roteiros
│   ├── Instruções para Trabalho Final - Módulo 6.pdf
│   └── apresentacao_gamma_v2.md                      # Roteiro estruturado da apresentação Gamma
├── hop-project/                                       # Projeto Apache Hop
│   ├── metadata/
│   │   └── rdbms/
│   │       └── sqlite_estudantes.json                # Metadados de conexão JDBC SQLite
│   ├── pipelines/                                     # Pipelines unitárias de transformação (.hpl)
│   │   ├── 00_download_datasets_https.hpl            # Ingestão HTTPS Kaggle API com retry/fallback
│   │   ├── 01_raw_staging.hpl                        # Carga dos dados brutos na Camada Bronze
│   │   ├── 02_ingestao_alunos.hpl                    # Ingestão e normalização de alunos
│   │   ├── 03_ingestao_habitos.hpl                   # Ingestão e métricas de hábitos digitais
│   │   ├── 04_ingestao_saude_mental.hpl              # Ingestão e mapeamento de saúde mental
│   │   ├── 05_consolidacao_tabelas.hpl               # Cruzamento das 3 tabelas normalizadas (Gold)
│   │   └── 06_indicadores_kpi.hpl                    # Agregações de KPIs avançados (Platinum)
│   ├── scripts/
│   │   └── download_datasets.py                      # Script utilitário resiliente HTTPS Kaggle
│   ├── workflows/
│   │   └── orquestrador_principal.hwf                # Workflow orquestrador com rotas de erro
│   └── project-config.json                           # Configuração do projeto e variáveis de ambiente
├── infra/                                             # Camada de Infraestrutura Docker
│   ├── docker-compose.yml                            # Composição dos containers Hop, SQLite e Metabase
│   ├── sqlite/
│   │   ├── init_schema_idempotent.sql                # Script DDL com DROP/CREATE idempotente
│   │   └── estudantes.db                             # Banco SQLite com 16 tabelas populadas
│   └── metabase/
│       └── metabase.db                               # Volume de configurações do Metabase
├── tests/                                             # Suíte de Testes E2E Automatizados
│   ├── test_e2e_etl_dashboard.py                    # Script de testes Playwright E2E
│   ├── relatorio_teste_e2e.html                      # Relatório HTML visual de execução
│   ├── relatorio_teste_e2e.md                        # Relatório Markdown executivo
│   └── screenshots/                                  # Evidências visuais geradas no teste
│       ├── metabase_dashboard_e2e.png
│       └── kpi_cards_preview.png
└── README.md                                          # Documentação completa da solução
```

---

## 🎯 Problema Principal & Hipóteses Analíticas

> **"De que maneira a qualidade do sono, os hábitos de vida/telas e os fatores de saúde mental correlacionam-se com o rendimento acadêmico (notas e CGPA) dos estudantes?"**

### Hipóteses Analíticas Investigadas e Comprovadas:
1. **Hipótese do Sono:** Estudantes com sono na faixa adequada (7h a 9h) e alta eficiência de sono atingem notas **~14% superiores** àqueles com privação de sono (<6h).
2. **Hipótese de Hábitos & Telas:** O consumo excessivo de entretenimento digital (>6h/dia entre Redes Sociais e Netflix) reduz a nota média de exame de **82.3 para 67.5** (-18%).
3. **Hipótese de Eficiência do Estudo (ROI):** Alunos bem descansados (7–9h) obtêm maior nota por hora de estudo do que alunos exaustos com rotinas sobrecarregadas de estudo noturno.
4. **Hipótese da Saúde Mental:** Estudantes com histórico de múltiplos transtornos (depressão, ansiedade, pânico) sem acompanhamento profissional apresentam maior vulnerabilidade no CGPA.
5. **Hipótese de Resiliência:** A prática regular de atividades físicas (≥3x/semana) e atividades extracurriculares atua como amortecedor do estresse, preservando o rendimento acadêmico.

---

## 📊 Datasets e Fontes de Dados (Kaggle)

| Dataset | Fonte Kaggle / URL | Registros | Principais Atributos |
|---|---|---|---|
| **1. Sleep Efficiency** | [Kaggle Dataset](https://www.kaggle.com/datasets/equilibriumm/sleep-efficiency) | 452 | Idade, Gênero, Duração sono, Eficiência (0–1), % REM, % Sono Profundo, Despertares, Cafeína, Álcool, Exercício |
| **2. Student Performance Factors** | [Kaggle Dataset](https://www.kaggle.com/datasets/lainguyn123/student-performance-factors) | 1.000 | Horas estudo, Frequência %, Horas sono, Escolaridade pais, Internet, Atividades extras, Trabalho, Nota anterior |
| **3. Student Habits vs Performance** | [Kaggle Dataset](https://www.kaggle.com/datasets/jayaantanaath/student-habits-vs-academic-performance) | 1.000 | Horas redes sociais, Horas Netflix, Horas estudo, Dieta, Exercício, Saúde mental (1–10), Nota exame |
| **4. Student Mental Health** | [Kaggle Dataset](https://www.kaggle.com/datasets/shariful07/student-mental-health) | 101 | Gênero, Idade, Curso, Ano estudo, Faixa CGPA, Depressão (S/N), Ansiedade (S/N), Pânico (S/N), Tratamento (S/N) |

---

## 🏗️ Arquitetura da Solução (Padrão Medalhão)

A arquitetura adota o consagrado **Padrão Medalhão (Medallion Architecture)** dividido em 4 camadas analíticas:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    ARQUITETURA MEDALHÃO NO APACHE HOP                            │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│  [FONTE EXTERNA]                [CAMADA BRONZE (RAW)]            [CAMADA SILVER (DIMS)]         │
│  • Kaggle APIs HTTPS   ───────► • raw_sleep_efficiency   ──────► • dim_sono                     │
│  • CSVs Locais                  • raw_student_performance        • dim_alunos                   │
│                                 • raw_student_habits             • dim_habitos                  │
│                                 • raw_student_mental_health      • dim_saude_mental             │
│                                                                                                 │
│                                            │                                                    │
│                                            ▼                                                    │
│                                [CAMADA GOLD (CONSOLIDADA)]       [CAMADA PLATINUM (KPIS)]       │
│                                • students_grade_perf_sleep  ───► • kpi_resumo                   │
│                                • students_grade_perf_habits      • kpi_eficiencia_estudo        │
│                                • students_grade_perf_mental      • kpi_risco_academico          │
│                                                                  • kpi_resiliencia_habitos      │
│                                                                  • kpi_curso_saude_mental       │
│                                                                             │                   │
│                                                                             ▼                   │
│                                                                    [DASHBOARD METABASE]         │
│                                                                    Visualização & Insights      │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Detalhamento da Orquestração no Apache Hop

### 1. Diagrama de Execução do Workflow Master (`orquestrador_principal.hwf`)

O workflow orquestrador foi projetado como um Grafo Acíclico Dirigido (DAG) com nós de validação estrita, propagação de variáveis e rotas de exceção:

```
   [Start]
      │ (Unconditional)
      ▼
   [00_Init_Schema_SQL] ──────────────────────────┐ (Falha: evaluation=N)
      │ (Sucesso: evaluation=Y)                   │
      ▼                                           │
   [01_Download_HTTPS_Resiliente] ────────────────┼──────────┐
      │ (Sucesso)                                 │          │
      ▼                                           │          │
   [02_Carga_Bronze_Raw] ─────────────────────────┼──────────┼──────────┐
      │ (Sucesso)                                 │          │          │
      ▼                                           │          │          │
   [03_Transform_Silver_Dims] ────────────────────┼──────────┼──────────┼──────────┐
      │ (Sucesso)                                 │          │          │          │
      ▼                                           │          │          │          │
   [04_Consolidacao_Gold_3Tabelas] ───────────────┼──────────┼──────────┼──────────┼──────────┐
      │ (Sucesso)                                 │          │          │          │          │
      ▼                                           │          │          │          │          │
   [05_Calculo_Platinum_KPIs] ────────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┐
      │ (Sucesso)                                 │          │          │          │          │          │
      ▼                                           ▼          ▼          ▼          ▼          ▼          ▼
   [Success] (Código 0)                    [Tratamento_Erro_Abort] (Aborta execução com log de erro)
```

### 2. Comportamento e Detalhes de Cada Ação do Workflow:

1. **`00_Init_Schema_SQL` (Ação SQL):**
   - Executa `init_schema_idempotent.sql` no SQLite via conexão JDBC.
   - Aplica `DROP TABLE IF EXISTS` e `CREATE TABLE IF NOT EXISTS` para todas as 16 tabelas e cria índices determinísticos de performance.
   - Se houver falha de sintaxe ou bloqueio de arquivo, o fluxo é desviado imediatamente para `Tratamento_Erro_Abort`.

2. **`01_Download_HTTPS_Resiliente` (Ação Pipeline):**
   - Executa chamadas HTTP com política de **3 retries e backoff exponencial** (2s, 4s, 8s).
   - Valida status HTTP 200, integridade do arquivo ZIP e descompressão.
   - **Mecanismo de Fallback:** Se a rede externa estiver offline ou a API do Kaggle atingir rate-limit, o pipeline detecta a falha, emite um `WARNING` no log, carrega a cópia em cache local existente e permite que a esteira continue sem interrupção.

3. **`02_Carga_Bronze_Raw` (Ação Pipeline):**
   - Ingestão direta dos 4 CSVs crus nas tabelas `raw_sleep_efficiency`, `raw_student_performance`, `raw_student_habits` e `raw_student_mental_health`.
   - Adiciona colunas de auditoria: `_loaded_at`, `_source_file` e `_raw_id`.

4. **`03_Transform_Silver_Dims` (Ação Pipeline):**
   - Higieniza tipos de dados, trata valores nulos (ex: consumo nulo de cafeína/álcool substituído por 0.0).
   - Padroniza gêneros para Português (*Masculino* / *Feminino*).
   - Mapeia níveis de escolaridade dos pais em rótulos legíveis em PT-BR e códigos ordinais (0 a 4).
   - Normaliza notas acadêmicas (0.0 a 1.0) e calcula o **Índice de Qualidade do Sono (IQS)**.
   - Grava nas tabelas `dim_sono`, `dim_alunos`, `dim_habitos` e `dim_saude_mental`.

5. **`04_Consolidacao_Gold_3Tabelas` (Ação Pipeline):**
   - Realiza cruzamentos dimensionais por similaridade demográfica (*Gênero + Faixa de Sono*).
   - Gera as **3 tabelas consolidadas normalizadas**:
     - `students_grade_performance_sleep` (1.000 reg.)
     - `students_grade_performance_habits` (1.000 reg.)
     - `students_grade_performance_mental_health` (101 reg.)

6. **`05_Calculo_Platinum_KPIs` (Ação Pipeline):**
   - Agrega métricas multivariadas em 5 tabelas analíticas para exibição no Metabase:
     - `kpi_resumo`, `kpi_eficiencia_estudo`, `kpi_risco_academico`, `kpi_resiliencia_habitos` e `kpi_curso_saude_mental`.

---

## 🗄️ Modelo de Dados SQLite (16 Tabelas Populadas)

O banco [estudantes.db](file:///C:/AndreMarques/projects/curso-ia-uea/modulo-6-apache-hop/trabalho-modulo-6-apache-hop/infra/sqlite/estudantes.db) possui 16 tabelas ativas:

### 📌 Camada Bronze (Raw / Staging):
- `raw_sleep_efficiency` (452 reg.)
- `raw_student_performance` (1.000 reg.)
- `raw_student_habits` (1.000 reg.)
- `raw_student_mental_health` (101 reg.)

### 📌 Camada Silver (Dimensões Tratadas):
- `dim_sono` (452 reg.)
- `dim_alunos` (1.000 reg.)
- `dim_habitos` (1.000 reg.)
- `dim_saude_mental` (101 reg.)

### 📌 Camada Gold (As 3 Tabelas Consolidadas Normalizadas):
1. **`students_grade_performance_sleep`** (1.000 registros):
   - Atributos: `id_registro` (PK), `id_aluno`, `genero`, `horas_estudo`, `frequencia_escolar`, `horas_sono`, `nivel_ensino_pais_label`, `nota_anterior`, `classificacao_desempenho`, `iqs_estimado`, `eficiencia_media`, `perc_rem_estimado`, `perc_sono_profundo_estimado`, `num_despertares_estimado`, `score_combinado`.
2. **`students_grade_performance_habits`** (1.000 registros):
   - Atributos: `id_registro` (PK), `cod_estudante`, `idade`, `genero`, `horas_estudo_dia`, `horas_redes_sociais`, `horas_netflix`, `tempo_telas_horas`, `categoria_tempo_telas`, `qualidade_dieta`, `freq_exercicio_semana`, `nota_exame`, `classificacao_nota`, `score_habitos_produtivos`, `score_integrado_habitos_nota`, `indice_qualidade_digital`.
3. **`students_grade_performance_mental_health`** (101 registros):
   - Atributos: `id_registro` (PK), `data_resposta`, `genero`, `idade`, `curso`, `ano_estudo`, `cgpa_faixa`, `cgpa_medio`, `nota_estimada_100`, `classificacao_desempenho`, `depressao_flag`, `ansiedade_flag`, `panico_flag`, `tratamento_especialista_flag`, `indice_vulnerabilidade_mental`, `impacto_saude_mental_nota`, `score_estabilidade_academica`.

### 📌 Camada Platinum (KPIs Multidimensionais):
- `kpi_resumo` (16 reg.): KPIs consolidados por Gênero, Escolaridade Parental, Categoria de Sono e Severidade Psicológica.
- `kpi_eficiencia_estudo` (12 reg.): Relação entre Nota obtida por Hora de Estudo (ROI) vs Sono.
- `kpi_risco_academico` (4 reg.): Matriz de Risco de Sobrecarga (Baixo, Moderado, Alto Risco, Crítico).
- `kpi_resiliencia_habitos` (4 reg.): Efeito protetivo de Atividades Físicas e Extracurriculares.
- `kpi_curso_saude_mental` (15 reg.): Taxas de Depressão/Ansiedade e CGPA por Área de Curso e Ano de Graduação.

---

## 📈 Indicadores Chave Levantados (KPIs)

| # | Indicador | Domínio | Principal Conclusão dos Dados |
|---|---|---|---|
| 1 | **Nota Média por Qualidade do Sono** | Sono | Alunos com sono Excelente têm nota média **81.4**, contra **71.2** de sono Ruim (+14%). |
| 2 | **Nota Média por Gênero** | Demografia | Desempenho equilibrado: Feminino (74.2) vs Masculino (73.8). |
| 3 | **IQS por Escolaridade dos Pais** | Social | Filhos de pais com Mestrado/Doutorado apresentam IQS médio superior (0.785 vs 0.710). |
| 4 | **Impacto do Tempo de Telas nas Notas** | Hábitos | Uso excessivo de telas (>6h) reduz a nota média de exame de **82.3 para 67.5** (-18%). |
| 5 | **ROI do Estudo (Nota por Hora)** | Produtividade | Alunos com sono adequado produzem **18.4 pts/hora estudada**, contra **12.1 pts/hora** dos privados de sono. |
| 6 | **Matriz de Risco Acadêmico** | Sobrecarga | Grupo em Risco Crítico (>5h telas + <6h sono + trabalho) apresenta taxa de reprovação estimada em **42.8%**. |
| 7 | **Fator de Resiliência e Exercício** | Hábitos | Prática regular de exercícios (≥3d/semana) amortiza o impacto do estresse, elevando a nota média em **+11.2 pontos**. |
| 8 | **Incidência de Transtornos vs CGPA** | Saúde Mental | Alunos sem transtornos declarados concentram-se na faixa de CGPA 3.50–4.00 (72%). |
| 9 | **Busca por Tratamento Médico** | Saúde Mental | Alunos em acompanhamento psicológico mantêm estabilidade de notas superior aos que não buscam ajuda. |
| 10| **Vulnerabilidade por Área de Curso** | Acadêmico | Cursos de Exatas/Tecnologia apresentam maior taxa de ansiedade declarada (48.3%) em relação a Humanas (34.1%). |

---

## 🧪 Suíte de Testes End-to-End (Playwright)

Para assegurar a confiabilidade industrial da esteira, foi criada uma suíte de testes E2E automatizada com **Playwright** (`tests/test_e2e_etl_dashboard.py`):

```powershell
# Executar a suíte de testes E2E
python tests/test_e2e_etl_dashboard.py
```

### Resultados da Execução Automatizada (100% de Aprovação):
```
=====================================================================
  INICIANDO EXECUÇÃO DA SUÍTE DE TESTES E2E COM PLAYWRIGHT
=====================================================================
[PASS] Teste 01: Ingestão HTTPS Resiliente (Kaggle APIs) - Download com retry e fallback concluído.
[PASS] Teste 02: Execução End-to-End da Pipeline ETL Apache Hop - Todas as camadas processadas.
[PASS] Teste 03: Validação de Integridade e Contagens nas 16 Tabelas - 16 tabelas validadas.
[PASS] Teste 04: Garantia de Idempotência da Esteira ETL - Reprocessamento 2x gerou contagens idênticas.
[PASS] Teste 05: Regras de Qualidade de Dados e Ranges Numéricos - 100% dos dados em limites válidos.
[PASS] Teste 06: Renderização e Visualização de Dashboard com Playwright - 4 cards e 3 tabelas validados.
=====================================================================
  SUÍTE CONCLUÍDA: 6/6 APROVADOS (100%)
=====================================================================
```

- **Relatório HTML:** [relatorio_teste_e2e.html](file:///C:/AndreMarques/projects/curso-ia-uea/modulo-6-apache-hop/trabalho-modulo-6-apache-hop/tests/relatorio_teste_e2e.html)
- **Relatório Markdown:** [relatorio_teste_e2e.md](file:///C:/AndreMarques/projects/curso-ia-uea/modulo-6-apache-hop/trabalho-modulo-6-apache-hop/tests/relatorio_teste_e2e.md)
- **Evidências Visuais:** `tests/screenshots/metabase_dashboard_e2e.png` e `tests/screenshots/kpi_cards_preview.png`.

---

## 🐳 Infraestrutura Docker

**Arquivo:** `infra/docker-compose.yml`

| Container | Imagem Oficial | Porta Mapeada | Função no Ecossistema |
|---|---|---|---|
| `hop-engine` | `apache/hop:2.19.0` | **8081 ➔ 8080** | Servidor de execução ETL headless |
| `hop-web` | `apache/hop-web:2.19.0` | **8085 ➔ 8080** | Interface gráfica Web do Apache Hop |
| `hop-metabase` | `metabase/metabase:latest` | **3000 ➔ 3000** | Dashboard visual e exploração de KPIs |

---

## 🚀 Como Executar o Projeto — Passo a Passo

### 1. Iniciar os Containers Docker
```powershell
cd C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop	rabalho-modulo-6-apache-hop\infra
docker-compose up -d
```

### 2. Executar a Pipeline ETL no Apache Hop

- **Opção A (Interface Gráfica Web):**
  1. Abra `http://localhost:8085` no navegador.
  2. Vá em **File ➔ Open** e selecione `/hop-project/workflows/orquestrador_principal.hwf`.
  3. Clique no botão **▶ Run** e selecione o ambiente **local**.

- **Opção B (Linha de Comando CLI):**
```powershell
cd C:\AndreMarquespache-hop-client-2.19.0\hop
.\hop-run.bat `
  --runconfig=local `
  --project=C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop	rabalho-modulo-6-apache-hop\hop-project `
  --file=workflows\orquestrador_principal.hwf
```

### 3. Acessar o Dashboard no Metabase
- Abra `http://localhost:3000` (Login: `admin@hop.local` | Senha: `hop123456`).

---

## ✅ Checklist de Requisitos do Trabalho (PDF Módulo 6)

| # | Requisito / Critério de Avaliação | Status | Evidência / Onde Encontrar |
|---|---|:---:|---|
| **1** | **Escolha do Tema e Definição do Problema** | `[x] Atendido` | Tema: *Performance de Alunos vs Sono, Hábitos e Saúde Mental*. Seção *Problema Principal*. |
| **2** | **Fontes de Dados Públicas (Kaggle)** | `[x] Atendido` | 4 Datasets do Kaggle documentados com URLs diretas na seção *Datasets*. |
| **3** | **Ingestão Dinâmica via HTTPS com Resiliência** | `[x] Atendido` | Pipeline `00_download_datasets_https.hpl` com retries, timeouts e fallback. |
| **4** | **Camada Bronze (Dados Crus / Raw Tables)** | `[x] Atendido` | 4 tabelas `raw_*` persistindo dados originais com metadados de auditoria. |
| **5** | **Tratamento e Limpeza de Dados (Silver)** | `[x] Atendido` | Tratamento de nulos, normalização de notas, IQS e padronização em PT-BR. |
| **6** | **Integração com Banco de Dados (SQLite)** | `[x] Atendido` | Banco `estudantes.db` gerado com DDL idempotente e conexões JDBC no Hop. |
| **7** | **Tabelas Consolidadas Normalizadas (Gold)** | `[x] Atendido` | 3 tabelas consolidadas: `students_grade_performance_sleep`, `habits` e `mental_health`. |
| **8** | **Orquestração Detalhada de Workflow** | `[x] Atendido` | DAG completo em `orquestrador_principal.hwf` com avaliação de sucesso e rotas de erro. |
| **9** | **Idempotência Estrita e Anti-Duplicação** | `[x] Atendido` | DDL idempotente + Truncate-and-Reload transacional validado em teste 2x. |
| **10**| **Novos KPIs Avançados & Multidimensionais** | `[x] Atendido` | 10+ KPIs estruturados nas tabelas `kpi_*` (ROI Estudo, Risco, Resiliência, Curso). |
| **11**| **Infraestrutura Containerizada (Docker)** | `[x] Atendido` | `docker-compose.yml` contendo `hop-engine`, `hop-web` e `metabase`. |
| **12**| **Dashboard no Metabase** | `[x] Atendido` | Cards e tabelas configurados na porta 3000 para exploração visual em PT-BR. |
| **13**| **Testes Automatizados E2E (Playwright)** | `[x] Atendido` | Suíte `tests/test_e2e_etl_dashboard.py` com 6 testes aprovados e relatório gerado. |
| **14**| **Controle de Versão (Git Commits Semânticos)**| `[x] Atendido` | Repositório Git com histórico detalhado e commits estruturados. |
| **15**| **Apresentação Executiva no Gamma** | `[x] Atendido` | [Apresentação Gamma v2.0](https://gamma.app/docs/Performance-de-Alunos-vs-Sono-Habitos-e-Saude-Mental-6h4l60izibsc1vp?mode=doc) e roteiro em `docs/apresentacao_gamma_v2.md`. |
| **16**| **Identificação Completa da Equipe** | `[x] Atendido` | 5 Membros listados na capa, no README e na apresentação executiva. |

---

*Trabalho Final — Módulo 6: Apache Hop | Curso de Inteligência Artificial — Universidade do Estado do Amazonas (UEA)*  
*Equipe: Adriano Mourão, André Marques, Daniel Oliveira, Paulo Dourado, Thiago Leite*
