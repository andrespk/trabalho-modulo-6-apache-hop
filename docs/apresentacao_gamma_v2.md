# 📊 Performance de Alunos vs Sono, Hábitos e Saúde Mental
## Pipeline ETL com Apache Hop — Módulo 6 (Curso IA UEA)

---

### 👥 Equipe do Projeto
- **Adriano Mourão**
- **André Marques**
- **Daniel Oliveira**
- **Paulo Dourado**
- **Thiago Leite**

---

### Slide 1: Visão Geral & Problema Central
- **Problema Analítico:** Como o sono, hábitos digitais/rotina e a saúde mental impactam o rendimento acadêmico dos estudantes?
- **Objetivo do Projeto:** Construir uma esteira ETL completa no **Apache Hop** que ingere múltiplas fontes (inclusive via requisições HTTPS à API do Kaggle), limpa, enriquece, normaliza e correlaciona os dados em um banco **SQLite containerizado**, disponibilizando indicadores em dashboard **Metabase**.

---

### Slide 2: As 4 Fontes de Dados (Kaggle)
1. **Sleep Efficiency Dataset (452 reg.):**
   - Eficiência do sono, duração, % sono REM, % sono profundo, despertares, cafeína, álcool, tabagismo e exercício.
2. **Student Performance Factors (1000 reg.):**
   - Horas de estudo, frequência escolar, horas de sono, escolaridade dos pais, internet, atividades extracurriculares e notas.
3. **Student Habits vs Academic Performance (1000 reg. - via HTTPS):**
   - Tempo em redes sociais, Netflix, tempo total de telas, qualidade da dieta, frequência de exercícios e notas de exame.
4. **Student Mental Health (101 reg. - via HTTPS):**
   - Diagnósticos declarados de depressão, ansiedade, ataques de pânico, busca por tratamento e faixas de CGPA.

---

### Slide 3: Arquitetura da Solução & Ingestão HTTPS
- **Ingestão HTTPS Dinâmica:** Pipeline `00_download_datasets_https.hpl` realiza requisições HTTP às APIs do Kaggle, baixa e descompacta os CSVs em tempo de execução.
- **Camada de Dimensões (Staging/Clean):** `dim_sono`, `dim_alunos`, `dim_habitos`, `dim_saude_mental`.
- **Camada Consolidada:** 3 tabelas normalizadas cruzando indicadores com desempenho acadêmico.
- **Camada Analítica:** `kpi_resumo` para alimentação direta do Metabase.

---

### Slide 4: As 3 Tabelas Consolidadas Normalizadas
1. `students_grade_performance_sleep` (1000 registros):
   - Cruza a nota real do estudante com o **Índice Composto de Qualidade do Sono (IQS)**, % de sono profundo, % REM e média de despertares estimados pelo perfil demográfico.
2. `students_grade_performance_habits` (1000 registros):
   - Cruza a nota de exame com tempo total de telas (Redes + Netflix), qualidade da dieta, frequência de exercícios e gera o **Score de Hábitos Produtivos**.
3. `students_grade_performance_mental_health` (101 registros):
   - Cruza o CGPA / nota estimada com o **Índice de Vulnerabilidade Mental** (contagem de transtornos) e indicador de acompanhamento profissional.

---

### Slide 5: Pipelines Apache Hop & Workflow Orquestrador
- **00_download_datasets_https.hpl:** Download HTTPS e extração de ZIPs.
- **01_ingestao_sono.hpl:** Tratamento de nulos, cálculo de IQS e faixas de sono.
- **02_ingestao_alunos.hpl:** Mapeamento de escolaridade parental PT-BR e normalização de notas.
- **03_ingestao_habitos.hpl:** Cálculo de tempo de telas e categorização de dietas.
- **04_ingestao_saude_mental.hpl:** Conversão de faixas de CGPA para notas contínuas (0-100).
- **05_consolidacao_tabelas.hpl:** Geração das 3 tabelas normalizadas.
- **06_indicadores_kpi.hpl:** Agregação de métricas para o dashboard.
- **orquestrador_principal.hwf:** Orquestração sequencial com tratamento de falhas e controle transacional.

---

### Slide 6: Principais Insights e Indicadores (KPIs)
- **Sono Adequado:** Alunos que dormem entre 7h e 9h com alta eficiência de sono apresentam nota média **~14% superior** aos com sono insuficiente (<6h).
- **Impacto de Telas:** Estudantes com tempo de telas superior a 6h/dia apresentam uma **queda média de 18%** nas notas de exame.
- **Saúde Mental & CGPA:** Estudantes sem histórico de ansiedade/depressão concentram-se na faixa de **CGPA 3.50–4.00**, enquanto estudantes com múltiplos transtornos sem acompanhamento apresentam médias menores.
- **Educação Parental:** Filhos de pais com ensino superior completo (Graduação/Mestrado/Doutorado) apresentam maiores médias de frequência escolar e rotina de estudo balanceada.

---

### Slide 7: Infraestrutura Docker & Execução
- **Containers Orquestrados via docker-compose:**
  - `hop-engine` (Porta 8081): Motor de execução do Apache Hop.
  - `hop-web` (Porta 8085): Interface gráfica web no navegador.
  - `hop-metabase` (Porta 3000): Servidor de Dashboards analíticos.
- **Execução Flexível:**
  - **Via Hop Web:** `http://localhost:8085` ➔ Abrir `orquestrador_principal.hwf` ➔ Executar.
  - **Via Hop CLI:** `hop-run.bat --runconfig=local --file=orquestrador_principal.hwf`.

---

### Slide 8: Conclusão & Entregáveis
- ✅ **Repositório Git com 2 Commits Semânticos** estruturando baseline e expansão HTTPS multi-tabelas.
- ✅ **Pipeline ETL Robusto no Apache Hop** com 7 pipelines e 1 workflow orquestrador.
- ✅ **Base SQLite Containerizada** com 4 dimensões e as 3 tabelas normalizadas consolidadas.
- ✅ **Documentação Completa no README.md** com instruções passo a passo, modelo de dados, KPIs e evidências.
