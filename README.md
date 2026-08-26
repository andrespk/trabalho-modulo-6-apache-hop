# Desempenho de Alunos vs Qualidade do Sono
### Trabalho Final — Módulo 6: Apache Hop

> **Projeto ETL com Apache Hop | Integração de Dados | Indicadores e Dashboard**

---

## 👥 Equipe

| Nome | Papel |
|---|---|
| **Adriano Mourão** | Membro da equipe |
| **André Marques** | Membro da equipe |
| **Daniel Oliveira** | Membro da equipe |
| **Paulo Dourado** | Membro da equipe |
| **Thiago Leite** | Membro da equipe |

---

## 📋 Identificação do Projeto

| Campo | Detalhe |
|---|---|
| **Módulo** | 6 — Apache Hop |
| **Tema** | Performance de Alunos vs Qualidade do Sono |
| **Ferramenta ETL** | Apache Hop 2.19.0 |
| **Banco de Dados** | SQLite (containerizado via Docker) |
| **Dashboard** | Metabase |
| **Idioma** | Português Brasileiro (pt-BR) |

---

## 📂 Estrutura do Projeto

```
trabalho-modulo-6-apache-hop/
├── database/
│   ├── Sleep_Efficiency.csv                               # Dataset Sono (452 registros)
│   └── student_performance_dataset-selected-columns.csv  # Dataset Alunos (1001 registros)
├── docs/
│   └── Instrucoes para Trabalho Final - Modulo 6.pdf
├── hop-project/
│   ├── metadata/
│   │   └── rdbms-connection/
│   │       └── sqlite_estudantes.json
│   ├── pipelines/
│   │   ├── 01_ingestao_sono.hpl
│   │   ├── 02_ingestao_alunos.hpl
│   │   ├── 03_consolidacao_cruzada.hpl
│   │   └── 04_indicadores_kpi.hpl
│   ├── workflows/
│   │   └── orquestrador_principal.hwf
│   └── project-config.json
├── infra/
│   ├── docker-compose.yml
│   ├── sqlite/
│   │   └── estudantes.db
│   └── metabase/
│       └── metabase.db
└── README.md
```

---

## 🎯 Problema Principal

> **Existe relação entre a qualidade do sono e o desempenho acadêmico dos alunos? Como sexo, idade e nível de instrução parental influenciam essa relação?**

Perguntas investigadas:
1. Alunos com mais horas de sono têm notas mais altas?
2. Existe diferença de desempenho/sono entre gêneros?
3. O nível de educação parental influencia tanto o sono quanto a nota?
4. Qual o perfil de sono ideal associado às maiores notas?

---

## 📊 Datasets

### Dataset 1 — Sleep Efficiency

| Atributo | Valor |
|---|---|
| **Fonte** | Kaggle — Sleep Efficiency Dataset |
| **URL** | https://www.kaggle.com/datasets/equilibriumm/sleep-efficiency |
| **Arquivo** | `Sleep_Efficiency.csv` |
| **Registros** | 452 |
| **Nulos** | Caffeine consumption, Alcohol consumption, Exercise frequency |

**Colunas originais:**

| Coluna | Tipo | Descrição |
|---|---|---|
| `ID` | Integer | Identificador do registro |
| `Age` | Integer | Idade |
| `Gender` | String | Gênero (Male/Female) |
| `Bedtime` | DateTime | Horário de dormir |
| `Wakeup time` | DateTime | Horário de acordar |
| `Sleep duration` | Float | Duração do sono (horas) |
| `Sleep efficiency` | Float | Eficiência do sono (0.0–1.0) |
| `REM sleep percentage` | Integer | % sono REM |
| `Deep sleep percentage` | Integer | % sono profundo |
| `Light sleep percentage` | Integer | % sono leve |
| `Awakenings` | Float | Número de despertares |
| `Caffeine consumption` | Float | Consumo de cafeína (mg) |
| `Alcohol consumption` | Float | Consumo de álcool (oz) |
| `Smoking status` | String | Tabagismo (Yes/No) |
| `Exercise frequency` | Float | Frequência de exercícios (dias/semana) |

**Classificações derivadas criadas no ETL:**

| Campo Derivado | Lógica |
|---|---|
| `faixa_etaria` | Jovem (<25) / Adulto (25-45) / Sênior (>45) |
| `classificacao_sono` | Excelente (>=0.85) / Bom (>=0.70) / Regular (>=0.55) / Ruim (<0.55) |
| `categoria_duracao_sono` | Insuficiente (<6h) / Curto (6-7h) / Adequado (7-9h) / Longo (>9h) |
| `indice_qualidade_sono` | 0.4×eficiencia + 0.3×(profundo/100) + 0.2×(rem/100) - 0.1×(despertares/5) |
| `tabagista_flag` | 1 se fumante, 0 caso contrário |
| `pratica_exercicio_flag` | 1 se exercita, 0 caso contrário |

---

### Dataset 2 — Student Performance

| Atributo | Valor |
|---|---|
| **Fonte** | Kaggle — Student Performance Factors |
| **URL** | https://www.kaggle.com/datasets/lainguyn123/student-performance-factors |
| **Arquivo** | `student_performance_dataset-selected-columns.csv` |
| **Registros** | 1001 |
| **Nulos** | Nenhum nas colunas selecionadas |

**Colunas originais:**

| Coluna | Tipo | Descrição |
|---|---|---|
| `student_id` | Integer | Identificador do aluno |
| `gender` | String | Gênero (Male/Female) |
| `study_time_hours` | Float | Horas de estudo por dia |
| `attendance_percent` | Float | Percentual de frequência |
| `sleep_hours` | Float | Horas de sono por noite |
| `parental_education` | String | Escolaridade dos pais |
| `internet_access` | String | Acesso à internet (Yes/No) |
| `extracurricular_activities` | String | Atividades extracurriculares (Yes/No) |
| `part_time_job` | String | Trabalho parcial (Yes/No) |
| `previous_grade` | Float | Nota anterior (0–100) |

**Mapeamento PT-BR de Educação Parental:**

| Original | Código | Label PT-BR |
|---|---|---|
| None | 0 | Sem escolaridade |
| High School | 1 | Ensino Médio |
| Bachelors | 2 | Graduação |
| Masters | 3 | Mestrado |
| PhD | 4 | Doutorado |

**Classificações derivadas criadas no ETL:**

| Campo Derivado | Lógica |
|---|---|
| `classificacao_desempenho` | Excelente (>=85) / Bom (>=70) / Regular (>=55) / Insuficiente (<55) |
| `categoria_horas_sono` | Insuficiente (<6h) / Curto (6-7h) / Adequado (7-9h) / Longo (>9h) |
| `faixa_estudo` | Baixo (<2h) / Moderado (2-4h) / Alto (4-6h) / Intenso (>6h) |
| `nota_normalizada` | previous_grade / 100 |

---

## 🏗️ Arquitetura da Solução

```
FONTES DE DADOS (Kaggle)
Sleep_Efficiency.csv  +  student_performance.csv
         |                        |
         v                        v
   Pipeline 01              Pipeline 02
   Ingestao Sono            Ingestao Alunos
         |                        |
         v                        v
      dim_sono              dim_alunos
         |                        |
         +----------+-------------+
                    |
                    v
             Pipeline 03
       Consolidacao e Cruzamento
       (join: genero + faixa_sono)
                    |
                    v
   student_performance_grade_sleep
                    |
                    v
             Pipeline 04
           Indicadores / KPIs
                    |
                    v
              kpi_resumo
                    |
                    v
               METABASE
```

**Estratégia de Join (Pipeline 03):**
Como os datasets não possuem chave direta, o cruzamento usa **similaridade demográfica**:
`genero` + `faixa_sono` (faixas de 0.5 horas). Para cada aluno, as métricas de sono são calculadas como média dos registros com mesmo gênero e faixa de sono compatível.

> Declaração analítica: Esta é uma classificação analítica definida para o projeto, sem referência a norma externa.

---

## 🗄️ Banco de Dados SQLite

**Arquivo:** `infra/sqlite/estudantes.db`

### `dim_sono` — Dados tratados de sono (~440-452 registros)

| Coluna | Tipo | Descrição |
|---|---|---|
| `id_sono` | INTEGER PK | ID original |
| `idade` | INTEGER | Idade |
| `genero` | TEXT | Masculino / Feminino |
| `faixa_etaria` | TEXT | Jovem / Adulto / Sênior |
| `duracao_sono_horas` | REAL | Horas de sono |
| `eficiencia_sono` | REAL | 0.0-1.0 |
| `perc_rem` | REAL | % sono REM |
| `perc_sono_profundo` | REAL | % sono profundo |
| `perc_sono_leve` | REAL | % sono leve |
| `num_despertares` | REAL | Qtd. despertares |
| `consumo_cafeina` | REAL | mg (0 se nulo) |
| `consumo_alcool` | REAL | oz (0 se nulo) |
| `tabagista_flag` | INTEGER | 1=Sim / 0=Nao |
| `freq_exercicio` | REAL | Dias/semana |
| `classificacao_sono` | TEXT | Excelente / Bom / Regular / Ruim |
| `categoria_duracao_sono` | TEXT | Insuficiente / Curto / Adequado / Longo |
| `indice_qualidade_sono` | REAL | IQS 0.0-1.0 |
| `faixa_sono` | TEXT | Faixa para join |
| `dt_carga` | TEXT | Timestamp ETL |

### `dim_alunos` — Dados tratados de alunos (~995-1001 registros)

| Coluna | Tipo | Descrição |
|---|---|---|
| `id_aluno` | INTEGER PK | ID original |
| `genero` | TEXT | Masculino / Feminino |
| `horas_estudo` | REAL | Horas/dia |
| `frequencia_escolar` | REAL | % frequência |
| `horas_sono` | REAL | Horas de sono |
| `nivel_ensino_pais_codigo` | INTEGER | 0-4 |
| `nivel_ensino_pais_label` | TEXT | Label PT-BR |
| `tem_internet` | INTEGER | 1=Sim / 0=Nao |
| `atividades_extracurriculares` | INTEGER | 1=Sim / 0=Nao |
| `trabalho_parcial` | INTEGER | 1=Sim / 0=Nao |
| `nota_anterior` | REAL | 0-100 |
| `nota_normalizada` | REAL | 0.0-1.0 |
| `classificacao_desempenho` | TEXT | Excelente / Bom / Regular / Insuficiente |
| `categoria_horas_sono` | TEXT | Insuficiente / Curto / Adequado / Longo |
| `faixa_estudo` | TEXT | Baixo / Moderado / Alto / Intenso |
| `faixa_sono` | TEXT | Faixa para join |
| `dt_carga` | TEXT | Timestamp ETL |

### `student_performance_grade_sleep` — Tabela principal (~995-1001 registros)

| Coluna | Tipo | Descrição |
|---|---|---|
| `id_registro` | INTEGER PK | Auto-incremental |
| `id_aluno` | INTEGER | FK dim_alunos |
| `genero` | TEXT | Gênero padronizado |
| `nivel_ensino_pais_label` | TEXT | Nível educação parental |
| `horas_sono` | REAL | Horas de sono do aluno |
| `nota_anterior` | REAL | Nota 0-100 |
| `classificacao_desempenho` | TEXT | Classificação da nota |
| `horas_estudo` | REAL | Horas de estudo |
| `frequencia_escolar` | REAL | % frequência |
| `iqs_estimado` | REAL | IQS médio estimado |
| `classificacao_sono_estimada` | TEXT | Qualidade estimada |
| `perc_rem_estimado` | REAL | REM% médio estimado |
| `perc_sono_profundo_estimado` | REAL | Sono profundo% médio |
| `num_despertares_estimado` | REAL | Despertares médios |
| `score_combinado` | REAL | 0.6*nota_norm + 0.4*IQS |
| `dt_carga` | TEXT | Timestamp ETL |

### `kpi_resumo` — Indicadores agregados para o Metabase

| Coluna | Tipo | Descrição |
|---|---|---|
| `id_kpi` | INTEGER PK | Auto-incremental |
| `dimensao` | TEXT | Tipo de agrupamento |
| `valor_dimensao` | TEXT | Valor do grupo |
| `total_alunos` | INTEGER | Qtd. de alunos |
| `nota_media` | REAL | Nota média |
| `iqs_medio` | REAL | IQS médio |
| `horas_sono_media` | REAL | Horas de sono médias |
| `nota_max` | REAL | Nota máxima |
| `nota_min` | REAL | Nota mínima |
| `pct_excelente` | REAL | % desempenho Excelente |
| `pct_bom` | REAL | % desempenho Bom |
| `dt_carga` | TEXT | Timestamp ETL |

**Estratégia Anti-Duplicidade:**
- Pipelines 01 e 02: DELETE + INSERT (truncate e reload)
- Pipeline 03: REPLACE INTO por id_aluno (upsert)
- Pipeline 04: trunca e recalcula todos os KPIs
- **Zero duplicidades em reprocessamentos**

---

## 📈 Indicadores (KPIs)

| # | KPI | Dimensão | Pergunta Respondida |
|---|---|---|---|
| 1 | Nota média por gênero | Masculino / Feminino | Diferença de desempenho entre gêneros |
| 2 | IQS médio por educação parental | 5 níveis | Educação familiar impacta o sono? |
| 3 | Nota média por qualidade do sono | 4 classificações | Sono melhor = nota melhor? |
| 4 | Distribuição de desempenho | Por gênero e nível | Perfil acadêmico geral |
| 5 | Horas de sono por faixa de nota | 4 faixas | Quanto dormem os melhores alunos? |
| 6 | % Sono profundo por desempenho | 4 classificações | Deep sleep impacta a aprendizagem? |
| 7 | Score combinado por nível de ensino | 5 níveis | Qual grupo tem melhor equilíbrio? |
| 8 | Taxa de Excelentes por gênero | 2 gêneros | Paridade de gênero no topo |
| 9 | Correlação estudo vs nota | Contínuo | Estudo ou sono: o que importa mais? |
| 10 | Ranking top perfis (score) | Top 10 | Qual é o perfil do aluno ideal? |

---

## 🐳 Infraestrutura Docker

**Arquivo:** `infra/docker-compose.yml`

| Serviço | Imagem | Porta | Função |
|---|---|---|---|
| `hop-engine` | `apache/hop:2.19.0` | 8081:8080 | Motor ETL Apache Hop |
| `hop-web` | `apache/hop-web:2.19.0` | 8085:8080 | Interface Web Hop |
| `metabase` | `metabase/metabase:latest` | 3000:3000 | Dashboard de visualização |

| Interface | URL | Credenciais |
|---|---|---|
| Hop Web (GUI) | http://localhost:8085 | — |
| Hop Server API | http://localhost:8081 | cluster / cluster |
| Metabase | http://localhost:3000 | admin@hop.local / hop123456 |

---

## 🚀 Como Executar — Guia Completo

### Pré-requisitos

- **Docker Desktop** instalado e em execução
- **Apache Hop 2.19.0** instalado em `C:\AndreMarques\apache-hop-client-2.19.0\hop`
- Portas 8081, 8085 e 3000 livres

---

### PASSO 1 — Iniciar a Infraestrutura Docker

```powershell
# Acesse a pasta infra do projeto
cd C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\infra

# Suba todos os serviços em background
docker-compose up -d

# Verifique se os containers estão rodando
docker-compose ps

# Para acompanhar os logs em tempo real
docker-compose logs -f
```

Aguarde até que todos os serviços apareçam como **Up**. O Metabase pode levar 1-2 minutos para inicializar.

---

### PASSO 2 — Executar as Pipelines

#### Opção A: Via Interface Web (Hop Web GUI)

1. Abra o navegador em **http://localhost:8085**
2. No menu lateral, clique em **File → Open**
3. Navegue até `/hop-project/workflows/orquestrador_principal.hwf`
4. Clique no botão **▶ Run** na barra de ferramentas
5. Selecione o ambiente **local** e clique em **Launch**
6. Acompanhe a execução no painel de logs e no diagrama de fluxo

> **Dica:** Cada step ficará verde ao completar com sucesso ou vermelho em caso de erro.

#### Opção B: Via Apache Hop Desktop (GUI Local)

1. Execute `hop-gui.bat` em `C:\AndreMarques\apache-hop-client-2.19.0\hop`
2. Vá em **File → Open Project** e selecione a pasta `hop-project`
3. Abra o workflow `orquestrador_principal.hwf`
4. Clique em **▶ Run** e selecione o ambiente **local**

#### Opção C: Via CLI (Linha de Comando)

```powershell
# Acesse o diretório do Apache Hop
cd C:\AndreMarques\apache-hop-client-2.19.0\hop

# Execute o workflow completo (recomendado)
.\hop-run.bat `
  --runconfig=local `
  --project=C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\hop-project `
  --file=workflows\orquestrador_principal.hwf
```

Para executar pipelines individualmente via CLI:

```powershell
# Pipeline 01 — Ingestão Sono
.\hop-run.bat --runconfig=local --project=...\hop-project --file=pipelines\01_ingestao_sono.hpl

# Pipeline 02 — Ingestão Alunos
.\hop-run.bat --runconfig=local --project=...\hop-project --file=pipelines\02_ingestao_alunos.hpl

# Pipeline 03 — Consolidação
.\hop-run.bat --runconfig=local --project=...\hop-project --file=pipelines\03_consolidacao_cruzada.hpl

# Pipeline 04 — KPIs
.\hop-run.bat --runconfig=local --project=...\hop-project --file=pipelines\04_indicadores_kpi.hpl
```

> **Obs.:** O log de execução é salvo automaticamente em `hop-project/logs/`

---

### PASSO 3 — Verificar os Dados no SQLite

#### Via Docker exec (SQLite CLI)

```powershell
# Listar todas as tabelas
docker exec hop-sqlite sqlite3 /data/estudantes.db ".tables"

# Contar registros em cada tabela
docker exec hop-sqlite sqlite3 /data/estudantes.db "
SELECT 'dim_sono' as tabela, COUNT(*) as total FROM dim_sono
UNION ALL SELECT 'dim_alunos', COUNT(*) FROM dim_alunos
UNION ALL SELECT 'student_performance_grade_sleep', COUNT(*) FROM student_performance_grade_sleep
UNION ALL SELECT 'kpi_resumo', COUNT(*) FROM kpi_resumo;
"
```

#### Via DB Browser for SQLite (ferramenta gráfica)

1. Instale o DB Browser for SQLite (https://sqlitebrowser.org/)
2. Abra o arquivo `infra/sqlite/estudantes.db`
3. Navegue pelas tabelas na aba **Browse Data**
4. Use a aba **Execute SQL** para queries customizadas

---

### PASSO 4 — Visualizar no Metabase (Dashboard)

1. Abra o navegador em **http://localhost:3000**
2. Faça login com:
   - **Email:** admin@hop.local
   - **Senha:** hop123456
3. Na tela inicial, acesse o dashboard **"Desempenho vs Sono"**
4. Explore os KPIs e gráficos:

| Card | Tipo | Conteúdo |
|---|---|---|
| Nota Média Geral | Number | KPI principal |
| IQS Médio Geral | Number | Índice de Qualidade do Sono |
| Nota por Gênero | Bar chart | Comparativo Masculino vs Feminino |
| Distribuição de Desempenho | Pie chart | % por categoria |
| Correlação Sono x Nota | Scatter plot | Relação horas vs nota |
| IQS por Nível de Ensino | Bar chart | Educação parental vs sono |
| Horas de Sono por Faixa de Nota | Bar chart | Padrão dos melhores alunos |
| % Sono Profundo por Desempenho | Bar chart | Deep sleep e aprendizagem |
| Score Combinado por Nível | Bar chart | Equilíbrio desempenho+sono |
| Ranking Top Perfis | Table | Top 10 perfis de alunos |

> **Filtros disponíveis:** Gênero, Nível de educação parental, Classificação do sono, Classificação de desempenho

---

### PASSO 5 — Encerrar a Infraestrutura

```powershell
# Parar os containers (mantém os dados)
docker-compose stop

# Remover containers (mantém volumes)
docker-compose down

# Remover containers E volumes (CUIDADO: apaga os dados)
docker-compose down -v
```

---

## ✅ Checklist de Validação

- [x] Dataset e link da fonte definidos (Kaggle)
- [x] Problema principal descrito
- [x] 4 Pipelines de ingestão e transformação criados
- [x] Tratamento de nulos, tipos e rejeições implementado
- [x] Integração com SQLite containerizado
- [x] 4 tabelas estruturadas e documentadas
- [x] Workflow de orquestração com tratamento de erros
- [x] 10 indicadores (KPIs) calculados
- [x] Dashboard Metabase configurado com 10 cards
- [x] Estratégia anti-duplicidade implementada e documentada

---

## 🔍 Queries de Validação

```sql
-- Contagem por tabela
SELECT 'dim_sono' as tabela, COUNT(*) as total FROM dim_sono
UNION ALL SELECT 'dim_alunos', COUNT(*) FROM dim_alunos
UNION ALL SELECT 'student_performance_grade_sleep', COUNT(*) FROM student_performance_grade_sleep
UNION ALL SELECT 'kpi_resumo', COUNT(*) FROM kpi_resumo;

-- Nota média por qualidade do sono
SELECT classificacao_sono_estimada,
       COUNT(*) as total,
       ROUND(AVG(nota_anterior), 2) as nota_media,
       ROUND(AVG(iqs_estimado), 3) as iqs_medio
FROM student_performance_grade_sleep
GROUP BY classificacao_sono_estimada
ORDER BY nota_media DESC;

-- Verificar duplicidades (deve retornar zero linhas)
SELECT id_aluno, COUNT(*) as cnt
FROM student_performance_grade_sleep
GROUP BY id_aluno HAVING cnt > 1;
```

---

## 📋 Conclusão

Os dados revelam **correlação positiva entre qualidade do sono e desempenho acadêmico**. Alunos com sono adequado (7-9h) apresentam notas médias superiores. O nível de educação parental influencia ambos. A diferença entre gêneros é pequena em notas, mas visível nos padrões de sono.

**Decisão técnica:** Como os datasets não possuem chave direta, optou-se por join demográfico (genero + faixa_sono), enriquecendo cada aluno com médias dos indicadores de sono de perfis similares.

---

*Trabalho Final — Módulo 6: Apache Hop | Curso IA UEA*
*Equipe: Adriano Mourão, André Marques, Daniel Oliveira, Paulo Dourado, Thiago Leite*
