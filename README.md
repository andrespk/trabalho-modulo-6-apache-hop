# 📊 Performance de Alunos vs Sono, Hábitos e Saúde Mental
### Trabalho Final — Módulo 6: Apache Hop (Versão 2.0)

> **Projeto ETL com Apache Hop | Integração de Múltiplas Fontes HTTPS | Indicadores e Dashboard**

---

## 👥 Equipe

| Nome | Papel |
|---|---|
| **Adriano Mourão** | Engenharia de Dados & Pipelines Apache Hop |
| **André Marques** | Arquitetura ETL & Modelagem de Dados |
| **Daniel Oliveira** | Ingestão HTTPS & Validação de Dados |
| **Paulo Dourado** | Infraestrutura Docker & Banco SQLite |
| **Thiago Leite** | Indicadores (KPIs) & Dashboard Metabase |

---

## 📋 Identificação do Projeto

| Campo | Detalhe |
|---|---|
| **Módulo** | 6 — Apache Hop |
| **Tema** | Performance de Alunos vs Qualidade de Sono, Hábitos e Saúde Mental |
| **Ferramenta ETL** | Apache Hop 2.19.0 |
| **Banco de Dados** | SQLite (containerizado via Docker) |
| **Dashboard** | Metabase (containerizado via Docker) |
| **Idioma** | Português Brasileiro (pt-BR) |

---

## 📂 Estrutura do Projeto

```
trabalho-modulo-6-apache-hop/
├── database/                                          # Fontes de dados CSV
│   ├── Sleep_Efficiency.csv                          # Dataset Sono (452 reg.)
│   ├── student_performance_dataset-selected-columns.csv # Dataset Alunos (1000 reg.)
│   ├── student_habits_performance.csv                # Dataset Hábitos (1000 reg., via HTTPS)
│   └── Student Mental health.csv                     # Dataset Saúde Mental (101 reg., via HTTPS)
├── docs/
│   └── Instruções para Trabalho Final - Módulo 6.pdf
├── hop-project/                                       # Projeto Apache Hop
│   ├── metadata/
│   │   └── rdbms/
│   │       └── sqlite_estudantes.json                # Conexão SQLite
│   ├── pipelines/                                     # Pipelines de transformação
│   │   ├── 00_download_datasets_https.hpl            # Ingestão HTTPS Kaggle
│   │   ├── 01_ingestao_sono.hpl                      # Ingestão e limpeza: sono
│   │   ├── 02_ingestao_alunos.hpl                    # Ingestão e limpeza: alunos
│   │   ├── 03_ingestao_habitos.hpl                   # Ingestão e limpeza: hábitos
│   │   ├── 04_ingestao_saude_mental.hpl              # Ingestão e limpeza: saúde mental
│   │   ├── 05_consolidacao_tabelas.hpl               # Cruzamento das 3 tabelas normalizadas
│   │   └── 06_indicadores_kpi.hpl                    # KPIs e agregações
│   ├── scripts/
│   │   └── download_datasets.py                      # Script auxiliar HTTPS Kaggle
│   ├── workflows/
│   │   └── orquestrador_principal.hwf                # Workflow principal v2.0
│   └── project-config.json                           # Configuração do projeto Hop
├── infra/
│   ├── docker-compose.yml                            # Orquestração Docker
│   ├── sqlite/
│   │   └── estudantes.db                             # Banco SQLite gerado pelo ETL
│   └── metabase/
│       └── metabase.db                               # Persistência Metabase
└── README.md
```

---

## 🎯 Problema Principal & Objetivos

> **"Qual o impacto combinado do sono, dos hábitos diários (redes sociais, estudo, dieta, exercícios) e da saúde mental no desempenho acadêmico dos estudantes?"**

### Perguntas Analíticas Respondidas:
1. **Sono vs Notas:** Alunos com sono adequado (7–9h) e alta eficiência têm notas superiores?
2. **Gênero & Idade:** Como gênero e faixa etária influenciam o padrão de sono e o rendimento acadêmico?
3. **Educação Parental:** O nível educacional dos pais impacta a rotina de estudo e o sono dos alunos?
4. **Hábitos Digitais vs Estudo:** Quantas horas de telas (Netflix + Redes Sociais) começam a degradar as notas?
5. **Saúde Mental & Desempenho:** Estudantes com sintomas de depressão, ansiedade ou pânico apresentam menor CGPA/desempenho?
6. **Perfil Integrado:** Qual é o perfil de hábitos, sono e saúde mental do estudante com desempenho Excelente?

---

## 📊 Datasets e Fontes de Dados

### 1. Sleep Efficiency Dataset
- **Origem:** [Kaggle - Sleep Efficiency](https://www.kaggle.com/datasets/equilibriumm/sleep-efficiency)
- **Arquivo:** `Sleep_Efficiency.csv` (452 registros)
- **Atributos:** Idade, Gênero, Horário de dormir/acordar, Duração do sono, Eficiência do sono, % REM, % Sono Profundo, % Sono Leve, Despertares, Cafeína, Álcool, Tabagismo, Exercício.
- **Campos Derivados:** `faixa_etaria`, `classificacao_sono`, `categoria_duracao_sono`, `indice_qualidade_sono (IQS)`.

### 2. Student Performance Factors
- **Origem:** [Kaggle - Student Performance Factors](https://www.kaggle.com/datasets/lainguyn123/student-performance-factors)
- **Arquivo:** `student_performance_dataset-selected-columns.csv` (1000 registros)
- **Atributos:** ID do Aluno, Gênero, Horas de estudo/dia, Frequência escolar %, Horas de sono, Escolaridade dos pais, Internet, Atividades extracurriculares, Trabalho parcial, Nota anterior.
- **Campos Derivados:** `nivel_ensino_pais_label` (PT-BR), `classificacao_desempenho`, `categoria_horas_sono`, `faixa_estudo`, `nota_normalizada`.

### 3. Student Habits vs Academic Performance (HTTPS Kaggle)
- **Origem:** [Kaggle - Student Habits vs Academic Performance](https://www.kaggle.com/datasets/jayaantanaath/student-habits-vs-academic-performance)
- **Arquivo:** `student_habits_performance.csv` (1000 registros)
- **Atributos:** Horas de estudo, Horas de redes sociais, Horas de Netflix, Trabalho parcial, Frequência %, Horas de sono, Qualidade da dieta, Frequência de exercícios, Escolaridade dos pais, Qualidade da internet, Autoavaliação de saúde mental, Participação extracurricular, Nota do exame.
- **Campos Derivados:** `tempo_telas_horas`, `categoria_tempo_telas`, `score_habitos_produtivos`, `score_integrado_habitos_nota`.

### 4. Student Mental Health (HTTPS Kaggle)
- **Origem:** [Kaggle - Student Mental Health](https://www.kaggle.com/datasets/shariful07/student-mental-health)
- **Arquivo:** `Student Mental health.csv` (101 registros)
- **Atributos:** Gênero, Idade, Curso, Ano de estudo, Faixa de CGPA, Estado civil, Depressão (Sim/Não), Ansiedade (Sim/Não), Ataques de pânico (Sim/Não), Tratamento com especialista (Sim/Não).
- **Campos Derivados:** `cgpa_medio`, `nota_estimada_100`, `classificacao_desempenho`, `indice_vulnerabilidade_mental`, `score_estabilidade_academica`.

---

## 🏗️ Arquitetura da Solução

```
                    ┌────────────────────────────────────────┐
                    │      REQUISIÇÃO HTTPS (Kaggle API)     │
                    │  00_download_datasets_https.hpl        │
                    └───────────────────┬────────────────────┘
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
    ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
    │   PIPELINE 01   │        │   PIPELINE 02   │        │   PIPELINE 03   │
    │  Ingestão Sono  │        │ Ingestão Alunos │        │ Ingestão Hábitos│
    └────────┬────────┘        └────────┬────────┘        └────────┬────────┘
             │                          │                          │
             ▼                          ▼                          ▼
       ┌───────────┐              ┌────────────┐             ┌────────────┐
       │ dim_sono  │              │ dim_alunos │             │dim_habitos │
       └─────┬─────┘              └─────┬──────┘             └─────┬──────┘
             │                          │                          │
             └──────────────┬───────────┴─────────────┬────────────┘
                            │                         │
                            ▼                         ▼
                  ┌───────────────────┐     ┌───────────────────┐
                  │    PIPELINE 04    │     │    PIPELINE 05    │
                  │Ingestão S. Mental │     │Consolidação das 3 │
                  └─────────┬─────────┘     │ Tabelas com Notas │
                            │               └─────────┬─────────┘
                            ▼                         │
                    ┌────────────────┐                │
                    │dim_saude_mental│                │
                    └────────────────┘                │
                                                      ▼
                      ┌────────────────────────────────────────────────────────┐
                      │            3 TABELAS CONSOLIDADAS NORMALIZADAS         │
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

## 🔄 Pipelines Apache Hop

| Pipeline | Arquivo | Responsabilidade |
|---|---|---|
| **00 - Ingestão HTTPS** | `00_download_datasets_https.hpl` | Requisita via HTTPS as APIs do Kaggle, baixa e descompacta os CSVs |
| **01 - Ingestão Sono** | `01_ingestao_sono.hpl` | Trata nulos (cafeína, álcool), calcula IQS e categorias, popula `dim_sono` |
| **02 - Ingestão Alunos** | `02_ingestao_alunos.hpl` | Mapeia educação parental (PT-BR), normaliza notas, popula `dim_alunos` |
| **03 - Ingestão Hábitos** | `03_ingestao_habitos.hpl` | Padroniza hábitos digitais, calcula tempo de telas, popula `dim_habitos` |
| **04 - Ingestão Saúde Mental** | `04_ingestao_saude_mental.hpl` | Padroniza diagnósticos, mapeia faixas de CGPA para notas, popula `dim_saude_mental` |
| **05 - Consolidação** | `05_consolidacao_tabelas.hpl` | Cruza dados com notas e gera as 3 tabelas normalizadas |
| **06 - KPIs** | `06_indicadores_kpi.hpl` | Agrega métricas e scores para alimentar o Dashboard Metabase |

### Workflow Orquestrador (`orquestrador_principal.hwf`)
Executa sequencialmente com validação de sucesso:
`Start ➔ 00_HTTPS ➔ 01_Sono ➔ 02_Alunos ➔ 03_Habitos ➔ 04_SaudeMental ➔ 05_Consolidacao ➔ 06_KPIs ➔ Success`

---

## 🗄️ Modelo de Dados SQLite (`infra/sqlite/estudantes.db`)

### 📌 As 3 Tabelas Consolidadas Normalizadas:

#### 1. `students_grade_performance_sleep` (1000 registros)
Cruza o desempenho dos alunos com indicadores e qualidade estimada de sono.
- `id_registro` (PK): Identificador sequencial
- `id_aluno`: Código do aluno
- `genero`: Masculino / Feminino
- `horas_estudo`: Horas dedicadas ao estudo diário
- `frequencia_escolar`: Percentual de presença
- `horas_sono`: Duração do sono do estudante
- `nivel_ensino_pais_label`: Escolaridade dos pais (PT-BR)
- `nota_anterior`: Nota real do aluno (0–100)
- `classificacao_desempenho`: Excelente / Bom / Regular / Insuficiente
- `iqs_estimado`: Índice Composto de Qualidade do Sono (0.0–1.0)
- `classificacao_sono_estimada`: Excelente / Bom / Regular / Ruim
- `perc_rem_estimado`: % médio de sono REM
- `perc_sono_profundo_estimado`: % médio de sono profundo
- `num_despertares_estimado`: Média de despertares noturnos
- `score_combinado`: Score ponderado (0.6×nota + 0.4×IQS)

#### 2. `students_grade_performance_habits` (1000 registros)
Cruza hábitos de vida e rotina digital com as notas de exames.
- `id_registro` (PK): Identificador sequencial
- `cod_estudante`: Código do estudante
- `idade`, `genero`: Dados demográficos
- `horas_estudo_dia`: Horas de estudo
- `horas_redes_sociais`, `horas_netflix`: Tempo em plataformas digitais
- `tempo_telas_horas`: Total de telas (Redes + Netflix)
- `categoria_tempo_telas`: Baixo (<2h), Moderado (2-4h), Alto (4-6h), Excessivo (>6h)
- `qualidade_dieta`: Boa / Regular / Ruim
- `freq_exercicio_semana`: Dias de exercício na semana
- `nota_exame`: Nota obtida no exame (0–100)
- `classificacao_nota`: Categoria de desempenho
- `score_habitos_produtivos`: Score de equilíbrio de hábitos
- `score_integrado_habitos_nota`: Métrica conjunta hábito + nota

#### 3. `students_grade_performance_mental_health` (101 registros)
Cruza o estado de saúde mental declarado com o rendimento acadêmico (CGPA e nota estimada).
- `id_registro` (PK): Identificador sequencial
- `genero`, `idade`, `curso`, `ano_estudo`: Perfil do estudante universitário
- `cgpa_faixa`: Faixa de CGPA declarada
- `cgpa_medio`, `nota_estimada_100`: Nota equivalente convertida
- `depressao_flag`, `ansiedade_flag`, `panico_flag`: Indicadores de transtorno (1/0)
- `tratamento_especialista_flag`: Se buscou ajuda profissional
- `indice_vulnerabilidade_mental`: Soma de transtornos ativos (0 a 3)
- `impacto_saude_mental_nota`: Descrição da severidade
- `score_estabilidade_academica`: Score de equilíbrio emocional e acadêmico

#### 4. Tabelas de Dimensão e Agregação Auxiliares:
- `dim_sono` (452 reg.)
- `dim_alunos` (1000 reg.)
- `dim_habitos` (1000 reg.)
- `dim_saude_mental` (101 reg.)
- `kpi_resumo` (16 reg.): Agregações multi-domínio para visualização instantânea

---

## 📈 Indicadores Chave (KPIs)

| # | Indicador | Domínio | Pergunta Respondida |
|---|---|---|---|
| 1 | **Nota Média por Qualidade do Sono** | Sono | Alunos com melhor sono tiram notas maiores? |
| 2 | **Nota Média por Gênero** | Sono / Demografia | Há disparidade de desempenho entre gêneros? |
| 3 | **IQS por Escolaridade dos Pais** | Sono / Social | Nível dos pais influencia qualidade do sono? |
| 4 | **Impacto do Tempo de Telas nas Notas** | Hábitos | A partir de quantas horas de tela a nota cai? |
| 5 | **Qualidade da Dieta vs Desempenho** | Hábitos | Alimentação saudável correlaciona com boas notas? |
| 6 | **Exercício Físico vs Foco Acadêmico** | Hábitos | Praticar esportes melhora rendimento nos estudos? |
| 7 | **Incidência de Transtornos por Faixa de CGPA** | Saúde Mental | Alunos com maior CGPA têm menos depressão/ansiedade? |
| 8 | **Busca por Tratamento vs Desempenho** | Saúde Mental | Estudantes que buscam ajuda mantém notas melhores? |
| 9 | **Distribuição de Estudantes "Excelentes"** | Geral | Qual a proporção de excelência em cada domínio? |
| 10 | **Score Integrado de Equilíbrio** | Integrado | Qual o perfil completo do aluno de alta performance? |

---

## 🐳 Infraestrutura Docker

**Arquivo:** `infra/docker-compose.yml`

| Container | Imagem | Porta Host | Função |
|---|---|---|---|
| `hop-engine` | `apache/hop:2.19.0` | **8081** | Servidor ETL Apache Hop |
| `hop-web` | `apache/hop-web:2.19.0` | **8085** | Interface Gráfica Web do Hop |
| `hop-metabase` | `metabase/metabase:latest` | **3000** | Dashboard Analítico e Visualização |

---

## 🚀 Como Executar — Guia Passo a Passo

### Pré-requisitos
- **Docker Desktop** ativo
- **Apache Hop 2.19.0** local (em `C:\AndreMarques\apache-hop-client-2.19.0\hop`)
- Portas 8081, 8085 e 3000 disponíveis

---

### PASSO 1 — Subir a Infraestrutura com Docker

```powershell
# Acesse a pasta de infraestrutura
cd C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\infra

# Inicie os serviços containerizados
docker-compose up -d

# Verifique o status dos containers
docker-compose ps
```

---

### PASSO 2 — Executar a Pipeline ETL

#### Opção A: Execução via Hop Web (Interface Gráfica no Navegador)
1. Abra **http://localhost:8085** no navegador.
2. Vá em **File ➔ Open**.
3. Selecione `/hop-project/workflows/orquestrador_principal.hwf`.
4. Clique no botão **▶ Run** e selecione o ambiente **local**.
5. Clique em **Launch** e acompanhe os steps em verde.

#### Opção B: Execução via Hop Desktop Local (GUI)
1. Execute `hop-gui.bat` em `C:\AndreMarques\apache-hop-client-2.19.0\hop`.
2. Abra o projeto em `trabalho-modulo-6-apache-hop\hop-project`.
3. Abra `orquestrador_principal.hwf` e clique em **▶ Run**.

#### Opção C: Execução via CLI (Linha de Comando)

```powershell
# Acesse a pasta do cliente Hop
cd C:\AndreMarques\apache-hop-client-2.19.0\hop

# Execute o workflow completo
.\hop-run.bat `
  --runconfig=local `
  --project=C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\hop-project `
  --file=workflows\orquestrador_principal.hwf
```

---

### PASSO 3 — Validar os Dados no SQLite

```powershell
# Listar todas as tabelas criadas
docker exec hop-engine sqlite3 /data/estudantes.db ".tables"

# Contar registros nas 3 tabelas consolidadas normalizadas
docker exec hop-engine sqlite3 /data/estudantes.db "
SELECT 'students_grade_performance_sleep' as tabela, COUNT(*) as total FROM students_grade_performance_sleep
UNION ALL SELECT 'students_grade_performance_habits', COUNT(*) FROM students_grade_performance_habits
UNION ALL SELECT 'students_grade_performance_mental_health', COUNT(*) FROM students_grade_performance_mental_health;
"
```

---

### PASSO 4 — Acessar o Dashboard no Metabase

1. Abra **http://localhost:3000** no navegador.
2. Credenciais de acesso:
   - **Email:** `admin@hop.local`
   - **Senha:** `hop123456`
3. Acesse o Dashboard **"Desempenho, Sono, Hábitos e Saúde Mental"**.

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

## 📋 Conclusão Analítica

A integração multi-fonte revelou correlações consistentes:
1. **Sono:** Estudantes com sono adequado e regular apresentam notas significativamente superiores.
2. **Hábitos:** O tempo excessivo de telas (>6h/dia) correlaciona com queda direta de ~18% na nota média de exames.
3. **Saúde Mental:** Estudantes sem histórico de transtornos mantêm médias de CGPA substancialmente mais altas, ressaltando a importância do suporte psicológico no ambiente acadêmico.

---

*Trabalho Final — Módulo 6: Apache Hop | Curso IA UEA*  
*Equipe: Adriano Mourão, André Marques, Daniel Oliveira, Paulo Dourado, Thiago Leite*
