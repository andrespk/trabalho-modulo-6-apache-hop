# 📊 Performance de Alunos vs Sono, Hábitos e Saúde Mental
## Pipeline ETL e Orquestração com Apache Hop — Módulo 6 (Curso IA UEA)

---

### 👥 Equipe do Projeto
- **Adriano Mourão**
- **André Marques**
- **Daniel Oliveira**
- **Paulo Dourado**
- **Thiago Leite**

---

### Slide 1: Visão Geral & Problema Central
- **Problema Analítico:** Como o sono, os hábitos digitais/rotina e a saúde mental impactam conjuntamente o rendimento acadêmico dos estudantes?
- **Objetivo do Projeto:** Construir uma esteira ETL completa no **Apache Hop** que ingere múltiplas fontes (inclusive via requisições HTTPS à API do Kaggle), limpa, enriquece, normaliza e correlaciona os dados em um banco **SQLite containerizado**, disponibilizando indicadores em dashboard **Metabase** e com validação por **Testes E2E no Playwright**.

---

### Slide 2: As 4 Fontes de Dados do Kaggle
1. **Sleep Efficiency Dataset (452 reg.):** Eficiência do sono, duração, % REM, % sono profundo, despertares, cafeína, álcool e exercícios.
2. **Student Performance Factors (1.000 reg.):** Horas de estudo, frequência escolar, horas de sono, escolaridade dos pais e notas.
3. **Student Habits vs Academic Performance (1.000 reg. - HTTPS):** Tempo em redes sociais, Netflix, qualidade da dieta, frequência de exercícios e notas de exame.
4. **Student Mental Health (101 reg. - HTTPS):** Diagnósticos declarados de depressão, ansiedade, ataques de pânico, busca por tratamento e CGPA.

---

### Slide 3: Arquitetura Medalhão no Apache Hop
- **Camada Bronze (Raw):** Tabelas `raw_*` com dados crus exatamente como recebidos dos CSVs e metadados de auditoria (`_loaded_at`, `_source_file`).
- **Camada Silver (Clean Dims):** Tabelas `dim_*` higienizadas, tipos padronizados e métricas derivadas (IQS, tempo total de telas).
- **Camada Gold (Consolidada):** As 3 tabelas normalizadas cruzando indicadores demográficos e comportamentais com as notas reais.
- **Camada Platinum (KPIs):** Tabelas analíticas agregadas prontas para consumo imediato no Metabase.

---

### Slide 4: Detalhamento da Orquestração no Apache Hop
- **Workflow Master DAG (`orquestrador_principal.hwf`):**
  - **Passo 00:** Execução de DDL SQL idempotente (`init_schema_idempotent.sql`).
  - **Passo 01:** Ingestão HTTPS com política de 3 retries, backoff exponencial e fallback para cache local.
  - **Passo 02:** Carga da Camada Bronze (`raw_*`).
  - **Passo 03:** Transformação e Carga da Camada Silver (`dim_*`).
  - **Passo 04:** Consolidação e Cruzamento da Camada Gold (3 Tabelas Normalizadas).
  - **Passo 05:** Agregação da Camada Platinum (KPIs Multidimensionais).
  - **Tratamento de Exceções:** Qualquer erro em etapas críticas aciona a rota de desvio para `Tratamento_Erro_Abort`, abortando com registro em log.

---

### Slide 5: As 3 Tabelas Consolidadas Normalizadas (Gold Layer)
1. `students_grade_performance_sleep` (1.000 reg.):
   - Cruza a nota real com o **Índice Composto de Qualidade do Sono (IQS)**, % de sono profundo e despertares noturnos.
2. `students_grade_performance_habits` (1.000 reg.):
   - Cruza a nota de exame com tempo total de telas (*Social Media + Netflix*), dieta, exercícios e o **Score de Hábitos Produtivos**.
3. `students_grade_performance_mental_health` (101 reg.):
   - Cruza o CGPA com o **Índice de Vulnerabilidade Mental** (contagem de transtornos) e indicador de busca por ajuda profissional.

---

### Slide 6: Novos KPIs Avançados & Multidimensionais (Platinum Layer)
- **ROI do Estudo (Nota por Hora):** Estudantes com sono adequado produzem **18.4 pts/hora de estudo**, contra **12.1 pts/hora** dos privados de sono.
- **Matriz de Risco Acadêmico:** Estudantes no grupo de Risco Crítico (>5h telas + <6h sono + trabalho parcial) apresentam **42.8% de taxa de reprovação**.
- **Fator de Resiliência:** Praticar atividade física regular (≥3x/semana) amortiza o impacto do estresse e eleva as notas em **+11.2 pontos**.
- **Vulnerabilidade por Curso:** Cursos de Exatas/Tecnologia apresentam maior taxa declarada de ansiedade (48.3%) em relação a Humanas (34.1%).

---

### Slide 7: Garantia de Idempotência e Testes E2E (Playwright)
- **Idempotência Absoluta:** O reprocessamento da esteira 1x ou 100x resulta rigorosamente nas mesmas contagens e 0 duplicatas.
- **Suíte de Testes Automatizada:**
  - 6 testes cobrindo Ingestão HTTPS, Execução ETL, Integridade de 16 Tabelas, Idempotência, Data Quality e Renderização de UI.
  - **100% de Taxa de Aprovação** com relatório HTML e screenshots capturados.

---

### Slide 8: Infraestrutura Docker & Execução
- **Containers Orquestrados:**
  - `hop-engine` (8081): Servidor de execução ETL headless.
  - `hop-web` (8085): Interface gráfica Web do Apache Hop no navegador.
  - `hop-metabase` (3000): Servidor de Dashboards analíticos.
- **Execução Flexível:**
  - **Via Hop Web GUI:** `http://localhost:8085` ➔ Abrir `orquestrador_principal.hwf` ➔ Run.
  - **Via Hop CLI:** `hop-run.bat --runconfig=local --file=workflows/orquestrador_principal.hwf`.

---

### Slide 9: Conclusão & Entregáveis
- ✅ **Repositório Git Versionado** com histórico estruturado de commits semânticos.
- ✅ **Esteira ETL Resiliente e Idempotente no Apache Hop** com 7 pipelines e 1 workflow master.
- ✅ **Base SQLite Completa com 16 Tabelas** organizadas em Arquitetura Medalhão.
- ✅ **Suíte de Testes E2E com Playwright** validando todo o ciclo e gerando relatório oficial.
- ✅ **Documentação Técnica Completa no README.md** e Apresentação Executiva no Gamma.
