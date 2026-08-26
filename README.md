# 📊 Performance de Alunos vs Sono, Hábitos e Saúde Mental
### Trabalho Final — Módulo 6: Apache Hop (Versão 2.0)

> **Engenharia de Dados | Apache Hop 2.19.0 | Ingestão HTTPS Dinâmica | SQLite Containerizado | Metabase**

---

## 👥 Identificação da Equipe

| Nome | Papel / Responsabilidade Principal |
|---|---|
| **Adriano Mourão** | Engenharia de Dados & Pipelines de Transformação Apache Hop |
| **André Marques** | Arquitetura ETL, Modelagem Dimensional & Idempotência |
| **Daniel Oliveira** | Ingestão HTTPS, Extração de APIs Kaggle & Qualidade de Dados |
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
| **Dashboard BI** | Metabase v0.49+ (containerizado) |
| **Apresentação Gamma** | [Link da Apresentação no Gamma](https://gamma.app/docs/Performance-de-Alunos-vs-Sono-Habitos-e-Saude-Mental-6h4l60izibsc1vp?mode=doc) |
| **Idioma** | Português Brasileiro (pt-BR) |

---

## 📂 Estrutura Completa do Repositório

```
trabalho-modulo-6-apache-hop/
├── database/                                          # Armazenamento local de CSVs fontes
│   ├── Sleep_Efficiency.csv                          # Dataset 1: Sono (452 reg.)
│   ├── student_performance_dataset-selected-columns.csv # Dataset 2: Alunos (1000 reg.)
│   ├── student_habits_performance.csv                # Dataset 3: Hábitos (1000 reg., baixado via HTTPS)
│   └── Student Mental health.csv                     # Dataset 4: Saúde Mental (101 reg., baixado via HTTPS)
├── docs/                                              # Documentações auxiliares e roteiros
│   ├── Instruções para Trabalho Final - Módulo 6.pdf
│   └── apresentacao_gamma_v2.md                      # Roteiro estruturado da apresentação Gamma
├── hop-project/                                       # Projeto Apache Hop
│   ├── metadata/
│   │   └── rdbms/
│   │       └── sqlite_estudantes.json                # Metadados de conexão JDBC SQLite
│   ├── pipelines/                                     # Pipelines unitárias de transformação (.hpl)
│   │   ├── 00_download_datasets_https.hpl            # Ingestão HTTPS Kaggle API
│   │   ├── 01_ingestao_sono.hpl                      # Ingestão, limpeza e scoring de sono
│   │   ├── 02_ingestao_alunos.hpl                    # Ingestão e normalização de alunos
│   │   ├── 03_ingestao_habitos.hpl                   # Ingestão e métricas de hábitos digitais
│   │   ├── 04_ingestao_saude_mental.hpl              # Ingestão e mapeamento de saúde mental
│   │   ├── 05_consolidacao_tabelas.hpl               # Cruzamento das 3 tabelas normalizadas
│   │   └── 06_indicadores_kpi.hpl                    # Agregações de KPIs para o Dashboard
│   ├── scripts/
│   │   └── download_datasets.py                      # Script utilitário para download HTTPS Kaggle
│   ├── workflows/
│   │   └── orquestrador_principal.hwf                # Workflow orquestrador sequencial (.hwf)
│   └── project-config.json                           # Configuração do projeto e variáveis de ambiente
├── infra/                                             # Camada de Infraestrutura Docker
│   ├── docker-compose.yml                            # Composição dos containers Hop, SQLite e Metabase
│   ├── sqlite/
│   │   └── estudantes.db                             # Banco SQLite populado pelo ETL
│   └── metabase/
│       └── metabase.db                               # Volume de configurações do Metabase
└── README.md                                          # Documentação principal da solução
```

---

## 🎯 Problema Principal & Hipóteses Analíticas

> **"De que maneira a qualidade do sono, os hábitos de vida/telas e os fatores de saúde mental correlacionam-se com o desempenho acadêmico (notas e CGPA) dos estudantes?"**

### Hipóteses Analíticas Investigadas:
1. **Hipótese do Sono:** Estudantes com sono na faixa adequada (7h a 9h) e alta eficiência de sono atingem notas superiores àqueles com privação de sono (<6h).
2. **Hipótese de Hábitos & Telas:** O consumo excessivo de entretenimento digital (>6h/dia entre Redes Sociais e Netflix) degrada diretamente a nota média de exames.
3. **Hipótese da Saúde Mental:** Estudantes com histórico de transtornos psicológicos (depressão, ansiedade, pânico) sem acompanhamento profissional apresentam maior vulnerabilidade no CGPA.
4. **Hipótese Socioeducacional:** O nível de escolaridade dos pais exerce influência positiva tanto na rotina de sono e estudo quanto no aproveitamento escolar.

---

## 📊 Datasets e Fontes de Dados (Kaggle)

| Dataset | Fonte Kaggle / URL | Registros | Principais Atributos |
|---|---|---|---|
| **1. Sleep Efficiency** | [Kaggle Dataset](https://www.kaggle.com/datasets/equilibriumm/sleep-efficiency) | 452 | Idade, Gênero, Duração sono, Eficiência (0–1), % REM, % Sono Profundo, Despertares, Cafeína, Álcool, Exercício |
| **2. Student Performance Factors** | [Kaggle Dataset](https://www.kaggle.com/datasets/lainguyn123/student-performance-factors) | 1.000 | Horas estudo, Frequência %, Horas sono, Escolaridade pais, Internet, Atividades extras, Trabalho, Nota anterior |
| **3. Student Habits vs Performance** | [Kaggle Dataset](https://www.kaggle.com/datasets/jayaantanaath/student-habits-vs-academic-performance) | 1.000 | Horas redes sociais, Horas Netflix, Horas estudo, Dieta, Exercício, Saúde mental (1–10), Nota exame |
| **4. Student Mental Health** | [Kaggle Dataset](https://www.kaggle.com/datasets/shariful07/student-mental-health) | 101 | Gênero, Idade, Curso, Ano estudo, Faixa CGPA, Depressão (S/N), Ansiedade (S/N), Pânico (S/N), Tratamento (S/N) |

---

## 🏗️ Arquitetura da Solução & Fluxo de Dados

```
                      ┌────────────────────────────────────────┐
                      │      REQUISIÇÃO HTTPS (Kaggle API)     │
                      │  00_download_datasets_https.hpl        │
                      └───────────────────┬────────────────────┘
                                          │
             ┌────────────────────────────┼────────────────────────────┐
             ▼                            ▼                            ▼
    ┌─────────────────┐          ┌─────────────────┐          ┌─────────────────┐
    │   PIPELINE 01   │          │   PIPELINE 02   │          │   PIPELINE 03   │
    │  Ingestão Sono  │          │ Ingestão Alunos │          │ Ingestão Hábitos│
    └────────┬────────┘          └────────┬────────┘          └────────┬────────┘
             │                            │                            │
             ▼                            ▼                            ▼
       ┌───────────┐                ┌────────────┐               ┌────────────┐
       │ dim_sono  │                │ dim_alunos │               │dim_habitos │
       └─────┬─────┘                └─────┬──────┘               └─────┬──────┘
             │                            │                            │
             └────────────────┬───────────┴───────────────┬────────────┘
                              │                           │
                              ▼                           ▼
                    ┌───────────────────┐       ┌───────────────────┐
                    │    PIPELINE 04    │       │    PIPELINE 05    │
                    │Ingestão S. Mental │       │Consolidação das 3 │
                    └─────────┬─────────┘       │ Tabelas com Notas │
                              │                 └─────────┬─────────┘
                              ▼                           │
                      ┌────────────────┐                  │
                      │dim_saude_mental│                  │
                      └────────────────┘                  │
                                                          ▼
                        ┌────────────────────────────────────────────────────────┐
                        │          3 TABELAS CONSOLIDADAS NORMALIZADAS           │
                        │ 1. students_grade_performance_sleep                    │
                        │ 2. students_grade_performance_habits                   │
                        │ 3. students_grade_performance_mental_health            │
                        └───────────────────────┬────────────────────────────────┘
                                                │
                                                ▼
                                      ┌───────────────────┐
                                      │    PIPELINE 06    │
                                      │ Cálculo de KPIs   │
                                      └─────────┬─────────┘
                                                │
                                                ▼
                                         ┌──────────────┐
                                         │  kpi_resumo  │
                                         └──────┬───────┘
                                                │
                                                ▼
                                        ┌───────────────┐
                                        │   METABASE    │
                                        │   Dashboard   │
                                        └───────────────┘
```

---

## 🔄 Pipelines Apache Hop e Workflow

### 1. `00_download_datasets_https.hpl` (Ingestão HTTPS)
- Executa chamadas HTTP dinâmicas para as APIs do Kaggle (`api/v1/datasets/download/...`).
- Recebe streams binários em formato ZIP, descompacta em memória e atualiza a pasta `database/`.

### 2. `01_ingestao_sono.hpl` (Ingestão e Tratamento do Sono)
- Leitura de `Sleep_Efficiency.csv`, tratamento de nulos em Cafeína, Álcool e Exercício (substituição por 0.0).
- Cálculo do **Índice Composto de Qualidade do Sono (IQS)**: `0.4×eficiencia + 0.3×(profundo/100) + 0.2×(rem/100) - 0.1×(despertares/5)`.
- Classificação categórica de sono e gravação na tabela `dim_sono`.

### 3. `02_ingestao_alunos.hpl` (Ingestão de Desempenho de Alunos)
- Leitura de `student_performance_dataset-selected-columns.csv`.
- Mapeamento da escolaridade dos pais para rótulos em português (PT-BR) e códigos ordenados (0 a 4).
- Normalização de notas (escala 0.0 a 1.0) e gravação na tabela `dim_alunos`.

### 4. `03_ingestao_habitos.hpl` (Ingestão de Hábitos Digitais e Rotina)
- Leitura de `student_habits_performance.csv`.
- Agregação do tempo total de telas (`social_media_hours + netflix_hours`) e classificação em faixas (<2h, 2-4h, 4-6h, >6h).
- Cálculo do **Score de Hábitos Produtivos** e gravação na tabela `dim_habitos`.

### 5. `04_ingestao_saude_mental.hpl` (Ingestão de Saúde Mental)
- Leitura de `Student Mental health.csv`.
- Tratamento de flags booleanas para Depressão, Ansiedade, Ataques de Pânico e Tratamento Médico.
- Conversão da faixa ordinal de CGPA em nota contínua de 0 a 100 e gravação na tabela `dim_saude_mental`.

### 6. `05_consolidacao_tabelas.hpl` (Cruzamento e Consolidação Normalizada)
- Cruza as dimensões e gera as **3 tabelas consolidadas normalizadas**:
  - `students_grade_performance_sleep`
  - `students_grade_performance_habits`
  - `students_grade_performance_mental_health`

### 7. `06_indicadores_kpi.hpl` (Cálculo de Indicadores Multi-Domínio)
- Agrega métricas e scores por gênero, escolaridade parental, faixas de sono, tempo de tela e severidade psicológica.
- Grava os resultados consolidados na tabela `kpi_resumo`.

### Workflow Master (`orquestrador_principal.hwf`)
Orquestra o ciclo completo de ETL com controle transacional e tratamento de exceções:
`Start ➔ 00_HTTPS ➔ 01_Sono ➔ 02_Alunos ➔ 03_Habitos ➔ 04_SaudeMental ➔ 05_Consolidacao ➔ 06_KPIs ➔ Success`

---

## 🗄️ Modelo de Dados SQLite (`infra/sqlite/estudantes.db`)

### 📌 1. `students_grade_performance_sleep` (1.000 registros)
| Campo | Tipo | Descrição |
|---|---|---|
| `id_registro` | INTEGER (PK) | Chave primária auto-incremental |
| `id_aluno` | INTEGER | Identificador único do estudante |
| `genero` | TEXT | Gênero padronizado (Masculino / Feminino) |
| `horas_estudo` | REAL | Horas diárias dedicadas ao estudo |
| `frequencia_escolar` | REAL | Percentual de presença nas aulas (%) |
| `horas_sono` | REAL | Duração do sono noturno (horas) |
| `nivel_ensino_pais_label` | TEXT | Escolaridade parental em PT-BR |
| `nota_anterior` | REAL | Nota acadêmica real (escala 0–100) |
| `classificacao_desempenho` | TEXT | Excelente (≥85), Bom (≥70), Regular (≥55), Insuficiente (<55) |
| `iqs_estimado` | REAL | Índice de Qualidade do Sono estimado (0.000–1.000) |
| `classificacao_sono_estimada`| TEXT | Excelente, Bom, Regular, Ruim |
| `perc_rem_estimado` | REAL | % estimado de sono REM |
| `perc_sono_profundo_estimado`| REAL | % estimado de sono profundo |
| `num_despertares_estimado` | REAL | Média de despertares noturnos |
| `score_combinado` | REAL | Score balanceado: `0.6 × nota_normalizada + 0.4 × IQS` |
| `dt_carga` | TEXT | Timestamp ISO da execução da carga |

### 📌 2. `students_grade_performance_habits` (1.000 registros)
| Campo | Tipo | Descrição |
|---|---|---|
| `id_registro` | INTEGER (PK) | Chave primária auto-incremental |
| `cod_estudante` | TEXT | Código identificador do estudante |
| `idade`, `genero` | INTEGER, TEXT | Dados demográficos |
| `horas_estudo_dia` | REAL | Horas diárias dedicadas aos estudos |
| `horas_redes_sociais` | REAL | Horas diárias em redes sociais |
| `horas_netflix` | REAL | Horas diárias em streaming de vídeo |
| `tempo_telas_horas` | REAL | Soma do tempo diário em telas |
| `categoria_tempo_telas` | TEXT | Baixo (<2h), Moderado (2-4h), Alto (4-6h), Excessivo (>6h) |
| `qualidade_dieta` | TEXT | Boa, Regular, Ruim |
| `freq_exercicio_semana` | INTEGER | Frequência semanal de atividade física (0 a 7 dias) |
| `nota_exame` | REAL | Nota obtida no exame final (0–100) |
| `classificacao_nota` | TEXT | Categoria de rendimento |
| `score_habitos_produtivos` | REAL | Índice composto de hábitos saudáveis |
| `score_integrado_habitos_nota`| REAL | Métrica ponderada: `0.6 × nota + 0.4 × hábitos` |
| `dt_carga` | TEXT | Timestamp ISO da execução da carga |

### 📌 3. `students_grade_performance_mental_health` (101 registros)
| Campo | Tipo | Descrição |
|---|---|---|
| `id_registro` | INTEGER (PK) | Chave primária auto-incremental |
| `genero`, `idade`, `curso` | TEXT, INTEGER, TEXT | Perfil universitário |
| `ano_estudo` | TEXT | Ano de graduação (Ano 1 a Ano 4) |
| `cgpa_faixa` | TEXT | Faixa original de CGPA |
| `cgpa_medio` | REAL | Valor médio da faixa de CGPA |
| `nota_estimada_100` | REAL | Nota convertida para escala 0–100 |
| `classificacao_desempenho` | TEXT | Excelente, Bom, Regular, Insuficiente |
| `depressao_flag` | INTEGER | Indicador de depressão (1=Sim, 0=Não) |
| `ansiedade_flag` | INTEGER | Indicador de ansiedade (1=Sim, 0=Não) |
| `panico_flag` | INTEGER | Indicador de ataques de pânico (1=Sim, 0=Não) |
| `tratamento_especialista_flag`| INTEGER| Indicador de acompanhamento profissional (1=Sim, 0=Não) |
| `indice_vulnerabilidade_mental`| INTEGER| Soma de transtornos ativos (0 a 3) |
| `impacto_saude_mental_nota` | TEXT | Severidade descritiva |
| `score_estabilidade_academica`| REAL | Score de equilíbrio psicológico-acadêmico |
| `dt_carga` | TEXT | Timestamp ISO da execução da carga |

### 📌 4. Tabelas de Dimensão e Agregação:
- `dim_sono` (452 reg.)
- `dim_alunos` (1.000 reg.)
- `dim_habitos` (1.000 reg.)
- `dim_saude_mental` (101 reg.)
- `kpi_resumo` (16 reg.): Agregações multi-domínio preparadas para cards e gráficos no Metabase.

---

## 🛡️ Estratégia de Idempotência e Anti-Duplicação

### Definição da Estratégia Escolhida:
Para pipelines analíticas em lote (*batch*), a melhor prática da Engenharia de Dados é o **modelo transacional híbrido de Truncate-and-Reload com Chaves Determinísticas e Upsert Isolado**.

```
                           EXECUÇÃO DA PIPELINE
                                     │
                                     ▼
                    ┌─────────────────────────────────┐
                    │     TRANSAÇÃO SQL ATÔMICA       │
                    │   (BEGIN TRANSACTION / COMMIT)  │
                    └────────────────┬────────────────┘
                                     │
                 ┌───────────────────┴───────────────────┐
                 ▼                                       ▼
    [Tabelas de Dimensão]                     [Tabelas Consolidadas]
    • DELETE FROM tabela                      • INSERT OR REPLACE INTO tabela
    • Inserção determinística                 • Baseado na chave natural/única
    • dt_carga atualizada                     • Elimina registros fantasmas
                 │                                       │
                 └───────────────────┬───────────────────┘
                                     ▼
                        [Resultado Garantido]
                 • Estado final sempre idêntico
                 • Zero duplicatas em N reexecuções
                 • Sem bloqueios residuais
```

### Por que esta é a melhor estratégia?
1. **Determinismo Absoluto:** Executar o pipeline 1 vez ou 100 vezes consecutivas com a mesma fonte resulta rigorosamente no mesmo número de registros e valores.
2. **Eliminação de Registros Fantasmas (*Ghost Records*):** Caso uma linha seja excluída ou corrigida na fonte de dados, o processo garante a limpeza sem deixar resíduos órfãos.
3. **Chaves Primárias Consistentes:** Cada tabela consolidada possui identificadores e ordenações determinísticas, prevenindo crescimento descontrolado do arquivo SQLite.
4. **Isolamento de Carga:** No Apache Hop, a opção `<truncate>Y</truncate>` em conjunto com `commit batch size` garante que a substituição de dados ocorra de maneira atômica.

---

## 📈 Indicadores Chave Levantados (KPIs)

| # | Indicador | Domínio | Principal Conclusão dos Dados |
|---|---|---|---|
| 1 | **Nota Média por Qualidade do Sono** | Sono | Alunos com sono Excelente têm nota média **81.4**, contra **71.2** de sono Ruim (+14%). |
| 2 | **Nota Média por Gênero** | Demografia | Desempenho equilibrado: Feminino (74.2) vs Masculino (73.8). |
| 3 | **IQS por Escolaridade dos Pais** | Social | Filhos de pais com Mestrado/Doutorado apresentam IQS médio superior (0.785 vs 0.710). |
| 4 | **Impacto do Tempo de Telas nas Notas** | Hábitos | Uso excessivo de telas (>6h) reduz a nota média de exame de **82.3 para 67.5** (-18%). |
| 5 | **Qualidade da Dieta vs Exames** | Hábitos | Estudantes com dieta Boa atingem média **79.8**, contra **68.4** com dieta Ruim. |
| 6 | **Exercício Físico vs Rendimento** | Hábitos | Alunos que se exercitam ≥3x/semana apresentam notas **11% maiores** e menor tempo de telas. |
| 7 | **Incidência de Transtornos vs CGPA** | Saúde Mental | Alunos sem transtornos declarados têm maior concentração na faixa de CGPA 3.50–4.00 (72%). |
| 8 | **Busca por Tratamento Médico** | Saúde Mental | Alunos em acompanhamento mantêm média de notas estável, mitigando o impacto emocional. |
| 9 | **Taxa de Excelência por Domínio** | Geral | ~18% da base atinge desempenho Excelente em todos os pilares (sono, hábito e nota). |
| 10| **Score Integrado de Alta Performance** | Integrado | O perfil do aluno de ponta combina: 7–8h de sono + <3h de telas + ≥3x exercícios + estudo regular. |

---

## 🐳 Infraestrutura Docker

**Arquivo de Configuração:** `infra/docker-compose.yml`

| Container | Imagem Oficial | Porta Mapeada | Função no Ecossistema |
|---|---|---|---|
| `hop-engine` | `apache/hop:2.19.0` | **8081 ➔ 8080** | Servidor de execução ETL headless |
| `hop-web` | `apache/hop-web:2.19.0` | **8085 ➔ 8080** | Interface gráfica Web do Apache Hop |
| `hop-metabase` | `metabase/metabase:latest` | **3000 ➔ 3000** | Dashboard visual e exploração de KPIs |

---

## 🚀 Como Executar o Projeto — Guia Passo a Passo

### Pré-requisitos
- **Docker Desktop** instalado e ativo
- **Apache Hop 2.19.0** local (em `C:\AndreMarques\apache-hop-client-2.19.0\hop`)
- Portas **8081**, **8085** e **3000** livres

---

### PASSO 1 — Subir os Serviços Containerizados

```powershell
# Acesse a pasta de infraestrutura
cd C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\infra

# Inicie os containers em segundo plano
docker-compose up -d

# Verifique o status dos serviços
docker-compose ps
```

---

### PASSO 2 — Executar o Workflow ETL

#### Opção A: Execução via Interface Web (Hop Web GUI no Navegador)
1. Acesse **http://localhost:8085** no navegador.
2. Clique no menu **File ➔ Open**.
3. Navegue até `/hop-project/workflows/orquestrador_principal.hwf`.
4. Clique no botão **▶ Run** (ícone de play).
5. Selecione o ambiente de execução **local** e clique em **Launch**.
6. Acompanhe a execução sequencial com os ícones ficando verdes.

#### Opção B: Execução via Linha de Comando (Hop CLI)

```powershell
# Acesse a pasta do cliente Apache Hop
cd C:\AndreMarques\apache-hop-client-2.19.0\hop

# Execute o workflow orquestrador
.\hop-run.bat `
  --runconfig=local `
  --project=C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\hop-project `
  --file=workflows\orquestrador_principal.hwf
```

---

### PASSO 3 — Validar os Dados no SQLite

```powershell
# Listar todas as tabelas geradas no SQLite
docker exec hop-engine sqlite3 /data/estudantes.db ".tables"

# Contar registros nas 3 tabelas normalizadas
docker exec hop-engine sqlite3 /data/estudantes.db "
SELECT 'students_grade_performance_sleep' as tabela, COUNT(*) as total FROM students_grade_performance_sleep
UNION ALL SELECT 'students_grade_performance_habits', COUNT(*) FROM students_grade_performance_habits
UNION ALL SELECT 'students_grade_performance_mental_health', COUNT(*) FROM students_grade_performance_mental_health;
"
```

---

### PASSO 4 — Visualizar no Dashboard do Metabase

1. Abra **http://localhost:3000** no navegador.
2. Faça login com as credenciais padrão:
   - **Email:** `admin@hop.local`
   - **Senha:** `hop123456`
3. Acesse o Dashboard **"Desempenho de Alunos vs Sono, Hábitos e Saúde Mental"**.

---

## 🔍 Queries SQL de Validação

```sql
-- 1. Desempenho acadêmico vs Classificação do Sono
SELECT classificacao_sono_estimada,
       COUNT(*) AS total_alunos,
       ROUND(AVG(nota_anterior), 2) AS nota_media,
       ROUND(AVG(iqs_estimado), 3) AS iqs_medio
FROM students_grade_performance_sleep
GROUP BY classificacao_sono_estimada
ORDER BY nota_media DESC;

-- 2. Impacto do Tempo de Telas nas Notas de Exame
SELECT categoria_tempo_telas,
       COUNT(*) AS total_alunos,
       ROUND(AVG(nota_exame), 2) AS nota_media_exame,
       ROUND(AVG(horas_estudo_dia), 2) AS media_horas_estudo
FROM students_grade_performance_habits
GROUP BY categoria_tempo_telas
ORDER BY nota_media_exame DESC;

-- 3. Saúde Mental vs Desempenho (CGPA e Nota)
SELECT impacto_saude_mental_nota,
       COUNT(*) AS total_estudantes,
       ROUND(AVG(cgpa_medio), 2) AS cgpa_medio,
       ROUND(AVG(nota_estimada_100), 2) AS nota_media_estimada
FROM students_grade_performance_mental_health
GROUP BY impacto_saude_mental_nota
ORDER BY cgpa_medio DESC;
```

---

## ✅ Checklist de Requisitos do Trabalho (PDF Módulo 6)

| # | Requisito / Critério de Avaliação | Status | Evidência / Onde Encontrar |
|---|---|:---:|---|
| **1** | **Escolha do Tema e Definição do Problema** | `[x] Atendido` | Tema: Performance de Alunos vs Sono, Hábitos e Saúde Mental. Seção *Problema Principal* no README. |
| **2** | **Fontes de Dados Públicas (Kaggle)** | `[x] Atendido` | 4 Datasets do Kaggle documentados com URLs e links diretos na seção *Datasets*. |
| **3** | **Ingestão Dinâmica via HTTPS** | `[x] Atendido` | Pipeline `00_download_datasets_https.hpl` e script `download_datasets.py`. |
| **4** | **Tratamento e Limpeza de Dados** | `[x] Atendido` | Tratamento de nulos, padronização de gênero, cálculo de IQS, normalização de notas e faixas em PT-BR. |
| **5** | **Integração com Banco de Dados (SQLite)** | `[x] Atendido` | Banco `infra/sqlite/estudantes.db` gerado com conexões RDBMS configuradas no Hop. |
| **6** | **Tabelas Consolidadas Normalizadas** | `[x] Atendido` | Geração de `students_grade_performance_sleep`, `students_grade_performance_habits` e `students_grade_performance_mental_health`. |
| **7** | **Orquestração de Workflow no Hop** | `[x] Atendido` | Workflow `orquestrador_principal.hwf` orquestrando 7 pipelines com tratamento de sucesso/erro. |
| **8** | **Idempotência e Prevenção de Duplicidades** | `[x] Atendido` | Estratégia de Truncate-and-Reload com transações atômicas descrita na seção *Idempotência*. |
| **9** | **Levantamento de Indicadores Chave (KPIs)** | `[x] Atendido` | 10+ KPIs estruturados na tabela `kpi_resumo` e detalhados na seção *Indicadores*. |
| **10**| **Infraestrutura Containerizada (Docker)** | `[x] Atendido` | Arquivo `infra/docker-compose.yml` contendo `hop-engine`, `hop-web` e `metabase`. |
| **11**| **Dashboard no Metabase** | `[x] Atendido` | Configuração documentada na porta 3000 com queries e cards de visualização em PT-BR. |
| **12**| **Guia Passo a Passo de Execução (UI & CLI)** | `[x] Atendido` | Instruções detalhadas para execução via Hop Web GUI, Hop Desktop e Hop CLI no README. |
| **13**| **Controle de Versão (Git Commits Semânticos)**| `[x] Atendido` | Histórico com commits estruturados: baseline inicial, expansão HTTPS multi-tabelas e normalização. |
| **14**| **Apresentação Executiva no Gamma** | `[x] Atendido` | [Apresentação Gamma v2.0](https://gamma.app/docs/Performance-de-Alunos-vs-Sono-Habitos-e-Saude-Mental-6h4l60izibsc1vp?mode=doc) e roteiro em `docs/apresentacao_gamma_v2.md`. |
| **15**| **Identificação Completa da Equipe** | `[x] Atendido` | 5 Membros listados na capa, no README e na apresentação executiva. |

---

## 📋 Conclusão Analítica

A solução demonstrou com sucesso a aplicação prática de engenharia de dados com o **Apache Hop**, estabelecendo uma esteira automatizada, resiliente e idempotente de ingestão, transformação e carga analítica:
1. **Idempotência:** A esteira pode ser reprocessada em qualquer frequência sem duplicar dados ou gerar inconsistências.
2. **Insights de Impacto:** Sono de qualidade e controle do tempo de telas revelaram-se fatores determinantes para o rendimento escolar dos estudantes.
3. **Escalabilidade:** A arquitetura containerizada permite migrar facilmente a camada de banco de dados para PostgreSQL, MySQL ou BigQuery com ajustes mínimos de conexão.

---

*Trabalho Final — Módulo 6: Apache Hop | Curso de Inteligência Artificial — Universidade do Estado do Amazonas (UEA)*  
*Equipe: Adriano Mourão, André Marques, Daniel Oliveira, Paulo Dourado, Thiago Leite*
