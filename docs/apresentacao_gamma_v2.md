# 📊 Performance de Alunos vs Sono, Hábitos e Saúde Mental
## Pipeline ETL, Orquestração e Arquitetura Medalhão com Apache Hop | Módulo 6 — Curso IA UEA

---

### 👥 Equipe do Projeto
- **Adriano Mourão**
- **André Marques**
- **Daniel Oliveira**
- **Paulo Dourado**
- **Thiago Leite**

---

- **Repositório GitHub (Público):** [https://github.com/andrespk/trabalho-modulo-6-apache-hop](https://github.com/andrespk/trabalho-modulo-6-apache-hop)

### Slide 1: Visão Geral & Problema Central
- **Problema Analítico:** Qual o impacto combinado do sono, dos hábitos digitais/telas e da saúde mental no desempenho acadêmico (notas e CGPA)?
- **Objetivo do Projeto:** Construir uma esteira ETL completa no **Apache Hop** que ingere múltiplas fontes (inclusive via requisições HTTPS à API do Kaggle), limpa, enriquece, normaliza e correlaciona os dados em um banco **SQLite containerizado** com 19 tabelas, integrando valores referenciais em **Excel**, dashboard no **Metabase** e validação com **Playwright E2E**.

---

### Slide 2: Glossário de Termos e Siglas Técnicas
- **IQS (Índice de Qualidade do Sono):** Métrica ponderada (0.000 a 1.000) combinando eficiência, sono profundo (+), sono REM (+) e despertares (-). Ideal: $\ge 0.700$.
- **ROI do Estudo:** Razão de rendimento acadêmico: pontos de nota por hora diária estudada. Ideal: $\ge 15.0	ext{ pts/h}$.
- **CGPA:** *Cumulative Grade Point Average* (escala 0.00 a 4.00), média global do ensino superior. Ideal: $\ge 3.00$.
- **Score de Resiliência:** Indicador do poder amortecedor do estresse através de exercícios físicos regulares ($\ge 3	ext{d/sem}$) e atividades extracurriculares. Ideal: $\ge 0.700$.
- **Índice de Risco:** Nível de sobrecarga acadêmica cruzando sono insuficiente ($<6	ext{h}$), excesso de telas ($>5	ext{h}$) e trabalho parcial.

---

### Slide 3: As Fontes de Dados e Planilha de Baselines
- **1. Sleep Efficiency (452 reg.):** Eficiência, sono profundo, REM, cafeína, álcool, exercício.
- **2. Student Performance Factors (1.000 reg.):** Horas de estudo, frequência, escolaridade dos pais, notas.
- **3. Student Habits vs Performance (1.000 reg. via HTTPS):** Redes sociais, Netflix, tempo de telas, dieta, exames.
- **4. Student Mental Health (101 reg. via HTTPS):** Depressão, ansiedade, pânico, busca por tratamento, CGPA.
- **5. Valores Referenciais em Excel (`valores_referenciais_kpi.xlsx`):** 10 normas de baseline inseridas na esteira (`ref_kpi_normalidade`).

---

### Slide 4: Baselines e Valores Referenciais de Normalidade
- **IQS:** Faixa ideal $\ge 0.700$ (Média na base: **0.742** ➔ `Normal`).
- **Duração do Sono:** Faixa ideal $7.0	ext{h} - 9.0	ext{h}$ (Média na base: **7.46h** ➔ `Normal`).
- **Tempo de Telas:** Faixa ideal $< 2.0	ext{h/dia}$ (Média na base: **4.52h** ➔ `Alerta / Moderado`).
- **ROI do Estudo:** Faixa ideal $\ge 15.0	ext{ pts/h}$ (Média na base: **18.35 pts/h** ➔ `Excelente`).
- **Score de Resiliência:** Faixa ideal $\ge 0.700$ (Média na base: **0.654** ➔ `Alerta / Moderado`).
- **Vulnerabilidade Mental:** Faixa ideal $0$ sintomas (Média na base: **1.07** ➔ `Alerta / Moderado`).

---

### Slide 5: Arquitetura Medalhão no Apache Hop
- **Camada de Referência:** `ref_kpi_normalidade` com as regras de baseline de normalidade.
- **Camada Bronze (Raw):** Tabelas `raw_*` com dados crus exatamente como recebidos dos CSVs e metadados de auditoria (`_loaded_at`, `_source_file`).
- **Camada Silver (Clean Dims):** Tabelas `dim_*` higienizadas (IQS, notas normalizadas, escolaridade em PT-BR).
- **Camada Gold (Consolidada):** As 3 tabelas normalizadas cruzando indicadores com notas reais.
- **Camada Platinum (KPIs):** Tabelas analíticas agregadas prontas para consumo no Metabase.

---

### Slide 6: Detalhamento da Orquestração no Apache Hop
- **Workflow Master DAG (`orquestrador_principal.hwf`):**
  - **Passo 00:** DDL SQL Idempotente (`init_schema_idempotent.sql`).
  - **Passo 01:** Ingestão HTTPS Resiliente (3 retries, backoff exponencial, fallback para cache local).
  - **Passo 02:** Carga da Camada Bronze (`raw_*`) e Referências (`ref_*`).
  - **Passo 03:** Transformação e Carga da Camada Silver (`dim_*`).
  - **Passo 04:** Consolidação da Camada Gold (3 Tabelas Normalizadas).
  - **Passo 05:** Agregação da Camada Platinum (KPIs Multidimensionais).
  - **Rotas de Exceção:** Desvio automático para `Tratamento_Erro_Abort` em caso de falhas.

---

### Slide 7: As 3 Tabelas Consolidadas Normalizadas (Gold Layer)
1. `students_grade_performance_sleep` (1.000 reg.):
   - Nota real vs IQS, % sono profundo, REM e despertares noturnos.
2. `students_grade_performance_habits` (1.000 reg.):
   - Nota de exame vs tempo total de telas (Redes + Netflix), dieta, exercícios e Score de Hábitos.
3. `students_grade_performance_mental_health` (101 reg.):
   - CGPA / nota estimada vs Índice de Vulnerabilidade Mental e acompanhamento profissional.

---

### Slide 8: Novos KPIs Multidimensionais (Platinum Layer)
- **ROI do Estudo:** Alunos descansados produzem **18.4 pts/hora de estudo** vs **12.1 pts/hora** dos privados de sono (+52% de eficiência).
- **Matriz de Risco:** Grupo em Risco Crítico (>5h telas + <6h sono + trabalho parcial) tem **42.8% de taxa de reprovação**.
- **Fator de Resiliência:** Prática regular de exercícios (≥3x/sem) eleva as notas em **+11.2 pontos**.
- **Insights por Sexo (Feminino vs Masculino):** Notas equilibradas (69.8 pts F vs 69.6 pts M); mulheres buscam quase o dobro de acompanhamento psicológico (6.7% vs 3.8%), sustentando CGPA superior (3.41 vs 3.21).
- **Maturidade por Idade (Calouros vs Veteranos):** Estudantes mais velhos (23-25+ anos) atingem nota média superior (75.8 pts) e maior autorregulação (0.659) contra calouros de 18-19 anos.
- **Vulnerabilidade por Curso:** Cursos de Exatas/Tecnologia apresentam taxa declarada de ansiedade superior (48.3%) em relação a Humanas (34.1%).

---

### Slide 9: Visualização Analítica no Dashboard (Donuts, Radar e Barras)
- **Gráficos de Donuts (Roscas):**
  * Qualidade do Sono: 28% Excelente, 45% Bom, 19% Regular, 8% Ruim.
  * Matriz de Risco: 38% Baixo Risco, 31% Moderado, 21% Alto Risco, 10% Crítico.
- **Gráfico de Radar (Perfil Multidimensional):**
  * Contrapõe 6 eixos (Nota, Sono, Frequência, Resiliência, Telas e Saúde Mental) entre Alunos de Alto Desempenho e Alunos em Risco Crítico.
- **Gráficos de Barras (ROI e Telas):**
  * ROI do Estudo: Alunos com sono adequado obtêm até +52% de nota por hora estudada.
  * Queda por Telas: Discentes com >6h de entretenimento digital caem de 82.3 para 67.5 na média (-18%).

---

### Slide 10: Suíte de Testes E2E com Playwright
- **100% de Aprovação (6/6 Testes Aprovados):**
  * Teste 1: Ingestão HTTPS Resiliente com retries e fallback.
  * Teste 2: Execução completa da pipeline ETL Apache Hop.
  * Teste 3: Integridade e contagens exatas das 19 tabelas.
  * Teste 4: Garantia de Idempotência estrita (reprocessamento 2x sem duplicatas).
  * Teste 5: Regras de Qualidade de Dados e validação das 10 normas de baseline.
  * Teste 6: Renderização e validação de interface do Dashboard no Playwright com screenshots.
- Relatórios oficiais gerados: `relatorio_teste_e2e.html` e `relatorio_teste_e2e.md`.

---

### Slide 11: Conclusões e Percepções dos Indicadores
1. **Sono Adequado é Multiplicador Cognitivo:** Sono $\ge 7	ext{h}$ com IQS $\ge 0.85$ garante $+14.2\%$ na nota final; sono $<6	ext{h}$ compromete severamente a retenção.
2. **Ponto de Inflexão Digital:** Acima de $4	ext{h/dia}$ de telas de entretenimento, há degradação acelerada do desempenho; acima de $6	ext{h}$, a perda média é de **-18%** na nota.
3. **Qualidade x Quantidade de Estudo:** Estudar exausto reduz a produtividade por hora em **-34%** em relação ao estudo com mente descansada.
4. **Exercício Físico como Fator de Proteção:** Atividade física regular ($\ge 3	ext{x/sem}$) protege o discente contra a queda de rendimento induzida por estresse.
5. **Impacto do Suporte Psicológico:** Estudantes em acompanhamento profissional sustentam CGPA estável ($\ge 3.25$) mesmo diante de quadros de ansiedade ou depressão.
