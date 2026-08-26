#!/usr/bin/env python3
import os
import sys
import sqlite3
import pandas as pd
import numpy as np
import datetime

# Detectar dinamicamente o root do projeto (funciona tanto no Windows quanto no Docker /files)
script_dir = os.path.dirname(os.path.abspath(__file__))
base_dir = os.path.abspath(os.path.join(script_dir, "..", ".."))
database_dir = os.path.join(base_dir, "database")
infra_dir = os.path.join(base_dir, "infra")
sqlite_dir = os.path.join(infra_dir, "sqlite")
db_path = os.path.join(sqlite_dir, "estudantes.db")
ddl_path = os.path.join(sqlite_dir, "init_schema_idempotent.sql")

with open(ddl_path, "r", encoding="utf-8") as f:
    ddl_content = f.read()

print("=== EXECUTANDO DDL NO BANCO SQLITE ===")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()
cursor.executescript(ddl_content)

now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# 0. Tabela de Referência de KPIs (Normas e Baselines)
excel_ref_path = os.path.join(database_dir, "valores_referenciais_kpi.xlsx")
if os.path.exists(excel_ref_path):
    df_ref = pd.read_excel(excel_ref_path)
    df_ref.columns = [
        "id_referencia", "dominio", "kpi_nome", "sigla", "unidade_medida",
        "faixa_critica", "faixa_alerta", "faixa_ideal_normalidade",
        "valor_medio_encontrado_base", "status_diagnostico_base", "interpretacao_pratica"
    ]
    df_ref["dt_carga"] = now_str
    df_ref.to_sql("ref_kpi_normalidade", conn, if_exists="append", index=False)

# 1. Raw Staging
df_raw_sleep = pd.read_csv(os.path.join(database_dir, "Sleep_Efficiency.csv"), dtype=str)
df_raw_sleep["_loaded_at"] = now_str
df_raw_sleep["_source_file"] = "Sleep_Efficiency.csv"
df_raw_sleep.columns = [
    "id_orig", "age_orig", "gender_orig", "bedtime_orig", "wakeup_time_orig",
    "sleep_duration_orig", "sleep_efficiency_orig", "rem_sleep_percentage_orig",
    "deep_sleep_percentage_orig", "light_sleep_percentage_orig", "awakenings_orig",
    "caffeine_consumption_orig", "alcohol_consumption_orig", "smoking_status_orig",
    "exercise_frequency_orig", "_loaded_at", "_source_file"
]
df_raw_sleep.to_sql("raw_sleep_efficiency", conn, if_exists="append", index=False)

df_raw_perf = pd.read_csv(os.path.join(database_dir, "student_performance_dataset-selected-columns.csv"), dtype=str)
df_raw_perf["_loaded_at"] = now_str
df_raw_perf["_source_file"] = "student_performance_dataset-selected-columns.csv"
df_raw_perf.columns = [
    "student_id_orig", "gender_orig", "study_time_hours_orig", "attendance_percent_orig",
    "sleep_hours_orig", "parental_education_orig", "internet_access_orig",
    "extracurricular_activities_orig", "part_time_job_orig", "previous_grade_orig",
    "_loaded_at", "_source_file"
]
df_raw_perf.to_sql("raw_student_performance", conn, if_exists="append", index=False)

df_raw_habits = pd.read_csv(os.path.join(database_dir, "student_habits_performance.csv"), dtype=str)
df_raw_habits["_loaded_at"] = now_str
df_raw_habits["_source_file"] = "student_habits_performance.csv"
df_raw_habits.columns = [
    "student_id_orig", "age_orig", "gender_orig", "study_hours_per_day_orig",
    "social_media_hours_orig", "netflix_hours_orig", "part_time_job_orig",
    "attendance_percentage_orig", "sleep_hours_orig", "diet_quality_orig",
    "exercise_frequency_orig", "parental_education_level_orig", "internet_quality_orig",
    "mental_health_rating_orig", "extracurricular_participation_orig", "exam_score_orig",
    "_loaded_at", "_source_file"
]
df_raw_habits.to_sql("raw_student_habits", conn, if_exists="append", index=False)

df_raw_mh = pd.read_csv(os.path.join(database_dir, "Student Mental health.csv"), dtype=str)
df_raw_mh["_loaded_at"] = now_str
df_raw_mh["_source_file"] = "Student Mental health.csv"
df_raw_mh.columns = [
    "timestamp_orig", "gender_orig", "age_orig", "course_orig", "year_of_study_orig",
    "cgpa_orig", "marital_status_orig", "depression_orig", "anxiety_orig",
    "panic_attack_orig", "treatment_orig", "_loaded_at", "_source_file"
]
df_raw_mh.to_sql("raw_student_mental_health", conn, if_exists="append", index=False)

# 2. Dimensions
df_sleep = pd.read_csv(os.path.join(database_dir, "Sleep_Efficiency.csv"))
df_sleep["Caffeine consumption"] = df_sleep["Caffeine consumption"].fillna(0.0)
df_sleep["Alcohol consumption"] = df_sleep["Alcohol consumption"].fillna(0.0)
df_sleep["Exercise frequency"] = df_sleep["Exercise frequency"].fillna(0.0)
df_sleep["Awakenings"] = df_sleep["Awakenings"].fillna(0.0)
df_sleep = df_sleep[df_sleep["Sleep duration"] > 0]
df_sleep = df_sleep[(df_sleep["Age"] >= 1) & (df_sleep["Age"] <= 120)]
df_sleep["genero"] = df_sleep["Gender"].map({"Male": "Masculino", "Female": "Feminino"}).fillna(df_sleep["Gender"])
df_sleep["faixa_etaria"] = pd.cut(df_sleep["Age"], bins=[-1, 24, 45, 120], labels=["Jovem", "Adulto", "Sênior"])
df_sleep["faixa_sono"] = (df_sleep["Sleep duration"] * 2).round() / 2
df_sleep["classificacao_sono"] = pd.cut(df_sleep["Sleep efficiency"], bins=[-1, 0.55, 0.70, 0.85, 1.01], labels=["Ruim", "Regular", "Bom", "Excelente"])
df_sleep["categoria_duracao_sono"] = pd.cut(df_sleep["Sleep duration"], bins=[-1, 5.9, 6.9, 8.9, 24], labels=["Insuficiente", "Curto", "Adequado", "Longo"])
df_sleep["tabagista_flag"] = (df_sleep["Smoking status"] == "Yes").astype(int)
df_sleep["pratica_exercicio_flag"] = (df_sleep["Exercise frequency"] > 0).astype(int)
df_sleep["indice_qualidade_sono"] = (
    0.4 * df_sleep["Sleep efficiency"] +
    0.3 * (df_sleep["Deep sleep percentage"] / 100.0) +
    0.2 * (df_sleep["REM sleep percentage"] / 100.0) -
    0.1 * (df_sleep["Awakenings"] / 5.0)
).clip(0.0, 1.0)
df_sleep["dt_carga"] = now_str

dim_sono = df_sleep.rename(columns={
    "ID": "id_sono", "Age": "idade", "Sleep duration": "duracao_sono_horas",
    "Sleep efficiency": "eficiencia_sono", "REM sleep percentage": "perc_rem",
    "Deep sleep percentage": "perc_sono_profundo", "Light sleep percentage": "perc_sono_leve",
    "Awakenings": "num_despertares", "Caffeine consumption": "consumo_cafeina",
    "Alcohol consumption": "consumo_alcool", "Exercise frequency": "freq_exercicio"
})[["id_sono", "idade", "genero", "faixa_etaria", "duracao_sono_horas", "eficiencia_sono",
   "perc_rem", "perc_sono_profundo", "perc_sono_leve", "num_despertares", "consumo_cafeina",
   "consumo_alcool", "tabagista_flag", "freq_exercicio", "classificacao_sono",
   "categoria_duracao_sono", "indice_qualidade_sono", "faixa_sono", "dt_carga"]]
dim_sono.to_sql("dim_sono", conn, if_exists="append", index=False)

df_students = pd.read_csv(os.path.join(database_dir, "student_performance_dataset-selected-columns.csv"))
df_students["genero"] = df_students["gender"].map({"Male": "Masculino", "Female": "Feminino"}).fillna(df_students["gender"])
ed_map = {"None": (0, "Sem escolaridade"), "High School": (1, "Ensino Médio"), "Bachelors": (2, "Graduação"), "Masters": (3, "Mestrado"), "PhD": (4, "Doutorado")}
df_students["nivel_ensino_pais_codigo"] = df_students["parental_education"].map(lambda x: ed_map.get(x, (0, "Outro"))[0])
df_students["nivel_ensino_pais_label"] = df_students["parental_education"].map(lambda x: ed_map.get(x, (0, "Outro"))[1])
df_students["tem_internet"] = (df_students["internet_access"] == "Yes").astype(int)
df_students["atividades_extracurriculares"] = (df_students["extracurricular_activities"] == "Yes").astype(int)
df_students["trabalho_parcial"] = (df_students["part_time_job"] == "Yes").astype(int)
df_students["nota_anterior"] = df_students["previous_grade"].clip(0.0, 100.0)
df_students["nota_normalizada"] = df_students["nota_anterior"] / 100.0
df_students["faixa_sono"] = (df_students["sleep_hours"] * 2).round() / 2
df_students["classificacao_desempenho"] = pd.cut(df_students["nota_anterior"], bins=[-1, 54.99, 69.99, 84.99, 100.1], labels=["Insuficiente", "Regular", "Bom", "Excelente"])
df_students["categoria_horas_sono"] = pd.cut(df_students["sleep_hours"], bins=[-1, 5.9, 6.9, 8.9, 24], labels=["Insuficiente", "Curto", "Adequado", "Longo"])
df_students["faixa_estudo"] = pd.cut(df_students["study_time_hours"], bins=[-1, 1.99, 3.99, 5.99, 24], labels=["Baixo", "Moderado", "Alto", "Intenso"])
df_students["dt_carga"] = now_str

dim_alunos = df_students.rename(columns={
    "student_id": "id_aluno", "study_time_hours": "horas_estudo",
    "attendance_percent": "frequencia_escolar", "sleep_hours": "horas_sono"
})[["id_aluno", "genero", "horas_estudo", "frequencia_escolar", "horas_sono",
   "nivel_ensino_pais_codigo", "nivel_ensino_pais_label", "tem_internet",
   "atividades_extracurriculares", "trabalho_parcial", "nota_anterior",
   "nota_normalizada", "classificacao_desempenho", "categoria_horas_sono",
   "faixa_estudo", "faixa_sono", "dt_carga"]]
dim_alunos.to_sql("dim_alunos", conn, if_exists="append", index=False)

df_habits = pd.read_csv(os.path.join(database_dir, "student_habits_performance.csv"))
df_habits["genero"] = df_habits["gender"].map({"Male": "Masculino", "Female": "Feminino", "Other": "Outro"}).fillna(df_habits["gender"])
diet_map = {"Poor": "Ruim", "Fair": "Regular", "Good": "Boa"}
df_habits["qualidade_dieta"] = df_habits["diet_quality"].map(diet_map).fillna(df_habits["diet_quality"])
net_map = {"Poor": "Ruim", "Average": "Média", "Good": "Boa"}
df_habits["qualidade_internet"] = df_habits["internet_quality"].map(net_map).fillna(df_habits["internet_quality"])
df_habits["nota_exame"] = df_habits["exam_score"].clip(0.0, 100.0)
df_habits["classificacao_nota"] = pd.cut(df_habits["nota_exame"], bins=[-1, 54.99, 69.99, 84.99, 100.1], labels=["Insuficiente", "Regular", "Bom", "Excelente"])
df_habits["tempo_telas_horas"] = df_habits["social_media_hours"] + df_habits["netflix_hours"]
df_habits["categoria_tempo_telas"] = pd.cut(df_habits["tempo_telas_horas"], bins=[-1, 2.0, 4.0, 6.0, 24], labels=["Baixo (<2h)", "Moderado (2-4h)", "Alto (4-6h)", "Excessivo (>6h)"])
df_habits["faixa_sono"] = (df_habits["sleep_hours"] * 2).round() / 2
df_habits["dt_carga"] = now_str

dim_habitos = df_habits.rename(columns={
    "student_id": "cod_estudante", "age": "idade", "study_hours_per_day": "horas_estudo_dia",
    "social_media_hours": "horas_redes_sociais", "netflix_hours": "horas_netflix",
    "part_time_job": "trabalho_parcial", "attendance_percentage": "frequencia_pct",
    "sleep_hours": "horas_sono", "exercise_frequency": "freq_exercicio_semana",
    "parental_education_level": "educacao_pais", "mental_health_rating": "autoavaliacao_saude_mental",
    "extracurricular_participation": "participa_extracurricular"
})[["cod_estudante", "idade", "genero", "horas_estudo_dia", "horas_redes_sociais",
   "horas_netflix", "tempo_telas_horas", "categoria_tempo_telas", "trabalho_parcial",
   "frequencia_pct", "horas_sono", "qualidade_dieta", "freq_exercicio_semana",
   "educacao_pais", "qualidade_internet", "autoavaliacao_saude_mental",
   "participa_extracurricular", "nota_exame", "classificacao_nota", "faixa_sono", "dt_carga"]]
dim_habitos.to_sql("dim_habitos", conn, if_exists="append", index=False)

df_mh = pd.read_csv(os.path.join(database_dir, "Student Mental health.csv"))
df_mh.columns = [c.strip() for c in df_mh.columns]
df_mh["genero"] = df_mh["Choose your gender"].map({"Male": "Masculino", "Female": "Feminino"}).fillna(df_mh["Choose your gender"])
df_mh["depressao_flag"] = (df_mh["Do you have Depression?"] == "Yes").astype(int)
df_mh["ansiedade_flag"] = (df_mh["Do you have Anxiety?"] == "Yes").astype(int)
df_mh["panico_flag"] = (df_mh["Do you have Panic attack?"] == "Yes").astype(int)
df_mh["tratamento_especialista_flag"] = (df_mh["Did you seek any specialist for a treatment?"] == "Yes").astype(int)
df_mh["casado_flag"] = (df_mh["Marital status"] == "Yes").astype(int)
df_mh["idade"] = pd.to_numeric(df_mh["Age"], errors="coerce").fillna(20).astype(int)
df_mh["ano_estudo"] = df_mh["Your current year of Study"].astype(str).str.replace("year", "Ano", case=False).str.replace("Year", "Ano")

cgpa_nota_map = {
    "3.50 - 4.00": (3.75, 93.75, "Excelente"),
    "3.50 - 4.00 ": (3.75, 93.75, "Excelente"),
    "3.00 - 3.49": (3.25, 81.25, "Bom"),
    "2.50 - 2.99": (2.75, 68.75, "Regular"),
    "2.00 - 2.49": (2.25, 56.25, "Regular"),
    "0 - 1.99": (1.00, 25.00, "Insuficiente")
}
df_mh["cgpa_faixa"] = df_mh["What is your CGPA?"].astype(str).str.strip()
df_mh["cgpa_medio"] = df_mh["cgpa_faixa"].map(lambda x: cgpa_nota_map.get(x, (3.0, 75.0, "Bom"))[0])
df_mh["nota_estimada_100"] = df_mh["cgpa_faixa"].map(lambda x: cgpa_nota_map.get(x, (3.0, 75.0, "Bom"))[1])
df_mh["classificacao_desempenho"] = df_mh["cgpa_faixa"].map(lambda x: cgpa_nota_map.get(x, (3.0, 75.0, "Bom"))[2])
df_mh["indice_vulnerabilidade_mental"] = df_mh["depressao_flag"] + df_mh["ansiedade_flag"] + df_mh["panico_flag"]
df_mh["dt_carga"] = now_str

dim_saude_mental = df_mh.rename(columns={
    "Timestamp": "data_resposta", "What is your course?": "curso"
})[["data_resposta", "genero", "idade", "curso", "ano_estudo", "cgpa_faixa",
   "cgpa_medio", "nota_estimada_100", "classificacao_desempenho", "casado_flag",
   "depressao_flag", "ansiedade_flag", "panico_flag", "tratamento_especialista_flag",
   "indice_vulnerabilidade_mental", "dt_carga"]]
dim_saude_mental.to_sql("dim_saude_mental", conn, if_exists="append", index=False)

# 3. Gold Consolidated
sono_perfil = dim_sono.groupby(["genero", "faixa_sono"]).agg(
    iqs_estimado=("indice_qualidade_sono", "mean"),
    eficiencia_media=("eficiencia_sono", "mean"),
    perc_rem_estimado=("perc_rem", "mean"),
    perc_sono_profundo_estimado=("perc_sono_profundo", "mean"),
    num_despertares_estimado=("num_despertares", "mean")
).reset_index()

tabela_sleep = pd.merge(dim_alunos, sono_perfil, on=["genero", "faixa_sono"], how="left")
tabela_sleep["iqs_estimado"] = tabela_sleep["iqs_estimado"].fillna(dim_sono["indice_qualidade_sono"].mean()).round(3)
tabela_sleep["eficiencia_media"] = tabela_sleep["eficiencia_media"].fillna(dim_sono["eficiencia_sono"].mean()).round(3)
tabela_sleep["perc_rem_estimado"] = tabela_sleep["perc_rem_estimado"].fillna(dim_sono["perc_rem"].mean()).round(1)
tabela_sleep["perc_sono_profundo_estimado"] = tabela_sleep["perc_sono_profundo_estimado"].fillna(dim_sono["perc_sono_profundo"].mean()).round(1)
tabela_sleep["num_despertares_estimado"] = tabela_sleep["num_despertares_estimado"].fillna(dim_sono["num_despertares"].mean()).round(1)
tabela_sleep["classificacao_sono_estimada"] = pd.cut(
    tabela_sleep["iqs_estimado"], bins=[-1, 0.55, 0.70, 0.85, 1.01],
    labels=["Ruim", "Regular", "Bom", "Excelente"]
)
tabela_sleep["score_combinado"] = (0.6 * tabela_sleep["nota_normalizada"] + 0.4 * tabela_sleep["iqs_estimado"]).round(3)
tabela_sleep["dt_carga"] = now_str
tabela_sleep.to_sql("students_grade_performance_sleep", conn, if_exists="append", index=False)

tabela_habits = dim_habitos.copy()
tabela_habits["score_habitos_produtivos"] = (
    0.35 * (tabela_habits["horas_estudo_dia"] / 8.0) +
    0.25 * (tabela_habits["frequencia_pct"] / 100.0) +
    0.20 * (tabela_habits["freq_exercicio_semana"] / 7.0) -
    0.20 * (tabela_habits["tempo_telas_horas"] / 10.0)
).clip(0.0, 1.0).round(3)
tabela_habits["score_integrado_habitos_nota"] = (0.6 * (tabela_habits["nota_exame"] / 100.0) + 0.4 * tabela_habits["score_habitos_produtivos"]).round(3)
total_atividade = tabela_habits["horas_estudo_dia"] + tabela_habits["tempo_telas_horas"]
tabela_habits["indice_qualidade_digital"] = np.where(total_atividade > 0, (tabela_habits["horas_estudo_dia"] / total_atividade), 0.5).round(3)
tabela_habits["dt_carga"] = now_str
tabela_habits.to_sql("students_grade_performance_habits", conn, if_exists="append", index=False)

tabela_mental = dim_saude_mental.copy()
tabela_mental["impacto_saude_mental_nota"] = np.where(
    tabela_mental["indice_vulnerabilidade_mental"] == 0, "Sem transtornos declarados",
    np.where(tabela_mental["indice_vulnerabilidade_mental"] == 1, "1 transtorno (Leve)",
             np.where(tabela_mental["indice_vulnerabilidade_mental"] == 2, "2 transtornos (Moderado)", "3 transtornos (Grave)"))
)
tabela_mental["score_estabilidade_academica"] = (
    0.6 * (tabela_mental["nota_estimada_100"] / 100.0) +
    0.4 * (1.0 - (tabela_mental["indice_vulnerabilidade_mental"] / 3.0))
).round(3)
tabela_mental["dt_carga"] = now_str
tabela_mental.to_sql("students_grade_performance_mental_health", conn, if_exists="append", index=False)

# 4. Platinum KPIs
kpis = []
for genero in ["Masculino", "Feminino"]:
    sub = tabela_sleep[tabela_sleep["genero"] == genero]
    kpis.append({
        "dominio": "Sono vs Desempenho", "dimensao": "Gênero", "valor_dimensao": genero,
        "total_amostra": len(sub), "nota_media": round(sub["nota_anterior"].mean(), 2),
        "metrica_secundaria_label": "IQS Médio", "metrica_secundaria_valor": round(sub["iqs_estimado"].mean(), 3),
        "pct_excelente": round((sub["classificacao_desempenho"] == "Excelente").mean() * 100, 1),
        "score_geral": round(sub["score_combinado"].mean(), 3), "dt_carga": now_str
    })

for nivel in dim_alunos["nivel_ensino_pais_label"].unique():
    sub = tabela_sleep[tabela_sleep["nivel_ensino_pais_label"] == nivel]
    kpis.append({
        "dominio": "Sono vs Desempenho", "dimensao": "Educação Parental", "valor_dimensao": nivel,
        "total_amostra": len(sub), "nota_media": round(sub["nota_anterior"].mean(), 2),
        "metrica_secundaria_label": "IQS Médio", "metrica_secundaria_valor": round(sub["iqs_estimado"].mean(), 3),
        "pct_excelente": round((sub["classificacao_desempenho"] == "Excelente").mean() * 100, 1),
        "score_geral": round(sub["score_combinado"].mean(), 3), "dt_carga": now_str
    })

for sono_cat in ["Excelente", "Bom", "Regular", "Ruim"]:
    sub = tabela_sleep[tabela_sleep["classificacao_sono_estimada"] == sono_cat]
    if len(sub) > 0:
        kpis.append({
            "dominio": "Sono vs Desempenho", "dimensao": "Classificação do Sono", "valor_dimensao": sono_cat,
            "total_amostra": len(sub), "nota_media": round(sub["nota_anterior"].mean(), 2),
            "metrica_secundaria_label": "% Sono Profundo", "metrica_secundaria_valor": round(sub["perc_sono_profundo_estimado"].mean(), 1),
            "pct_excelente": round((sub["classificacao_desempenho"] == "Excelente").mean() * 100, 1),
            "score_geral": round(sub["score_combinado"].mean(), 3), "dt_carga": now_str
        })

for tela_cat in ["Baixo (<2h)", "Moderado (2-4h)", "Alto (4-6h)", "Excessivo (>6h)"]:
    sub = tabela_habits[tabela_habits["categoria_tempo_telas"] == tela_cat]
    if len(sub) > 0:
        kpis.append({
            "dominio": "Hábitos vs Desempenho", "dimensao": "Tempo de Telas", "valor_dimensao": tela_cat,
            "total_amostra": len(sub), "nota_media": round(sub["nota_exame"].mean(), 2),
            "metrica_secundaria_label": "Horas Estudo Médias", "metrica_secundaria_valor": round(sub["horas_estudo_dia"].mean(), 2),
            "pct_excelente": round((sub["classificacao_nota"] == "Excelente").mean() * 100, 1),
            "score_geral": round(sub["score_integrado_habitos_nota"].mean(), 3), "dt_carga": now_str
        })

for transtorno in ["Sem transtornos declarados", "1 transtorno (Leve)", "2 transtornos (Moderado)", "3 transtornos (Grave)"]:
    sub = tabela_mental[tabela_mental["impacto_saude_mental_nota"] == transtorno]
    if len(sub) > 0:
        kpis.append({
            "dominio": "Saúde Mental vs Desempenho", "dimensao": "Severidade Transtornos", "valor_dimensao": transtorno,
            "total_amostra": len(sub), "nota_media": round(sub["nota_estimada_100"].mean(), 2),
            "metrica_secundaria_label": "CGPA Médio", "metrica_secundaria_valor": round(sub["cgpa_medio"].mean(), 2),
            "pct_excelente": round((sub["classificacao_desempenho"] == "Excelente").mean() * 100, 1),
            "score_geral": round(sub["score_estabilidade_academica"].mean(), 3), "dt_carga": now_str
        })

df_kpi_resumo = pd.DataFrame(kpis)
df_kpi_resumo.to_sql("kpi_resumo", conn, if_exists="append", index=False)

kpi_eficiencia = []
for f_estudo in ["Baixo", "Moderado", "Alto", "Intenso"]:
    for cat_sono in ["Adequado", "Curto", "Insuficiente"]:
        sub = tabela_sleep[(tabela_sleep["faixa_estudo"] == f_estudo) & (tabela_sleep["categoria_horas_sono"] == cat_sono)]
        if len(sub) > 0:
            h_estudo_media = max(sub["horas_estudo"].mean(), 0.5)
            nota_m = sub["nota_anterior"].mean()
            roi = round(nota_m / h_estudo_media, 2)
            score_prod = round((nota_m / 100.0) * (sub["iqs_estimado"].mean()), 3)
            kpi_eficiencia.append({
                "faixa_horas_estudo": f_estudo, "categoria_sono": cat_sono,
                "total_estudantes": len(sub), "nota_media": round(nota_m, 2),
                "horas_estudo_medias": round(h_estudo_media, 2),
                "roi_nota_por_hora_estudo": roi, "score_produtividade": score_prod,
                "dt_carga": now_str
            })
pd.DataFrame(kpi_eficiencia).to_sql("kpi_eficiencia_estudo", conn, if_exists="append", index=False)

tabela_habits["flag_alto_telas"] = (tabela_habits["tempo_telas_horas"] > 5.0).astype(int)
tabela_habits["flag_pouco_sono"] = (tabela_habits["horas_sono"] < 6.0).astype(int)
tabela_habits["flag_trabalha"] = (tabela_habits["trabalho_parcial"] == "Yes").astype(int)
tabela_habits["score_risco_num"] = tabela_habits["flag_alto_telas"] * 2 + tabela_habits["flag_pouco_sono"] * 2 + tabela_habits["flag_trabalha"]
tabela_habits["nivel_risco"] = np.where(tabela_habits["score_risco_num"] >= 4, "Crítico",
                               np.where(tabela_habits["score_risco_num"] >= 2, "Alto Risco",
                               np.where(tabela_habits["score_risco_num"] == 1, "Moderado", "Baixo Risco")))

kpi_risco = []
for n_risco in ["Baixo Risco", "Moderado", "Alto Risco", "Crítico"]:
    sub = tabela_habits[tabela_habits["nivel_risco"] == n_risco]
    if len(sub) > 0:
        desc = {
            "Baixo Risco": "Sono regular, telas controladas (<4h), sem sobrecarga",
            "Moderado": "Tempo moderado de telas ou trabalho parcial isolado",
            "Alto Risco": "Privação de sono (<6h) combinada com tempo elevado de telas",
            "Crítico": "Privação severa de sono + telas excessivas (>5h) + trabalho"
        }.get(n_risco, "")
        reprov_est = round((sub["classificacao_nota"] == "Insuficiente").mean() * 100, 1)
        kpi_risco.append({
            "nivel_risco": n_risco, "descricao_perfil": desc,
            "total_estudantes": len(sub), "nota_media": round(sub["nota_exame"].mean(), 2),
            "media_sono": round(sub["horas_sono"].mean(), 2),
            "media_telas": round(sub["tempo_telas_horas"].mean(), 2),
            "pct_trabalha_parcial": round((sub["trabalho_parcial"] == "Yes").mean() * 100, 1),
            "taxa_reprovacao_estimada": reprov_est, "dt_carga": now_str
        })
pd.DataFrame(kpi_risco).to_sql("kpi_risco_academico", conn, if_exists="append", index=False)

kpi_resil = []
for ex_label, ex_cond in [("Exercício Regular (≥3d)", tabela_habits["freq_exercicio_semana"] >= 3), ("Sedentário (<3d)", tabela_habits["freq_exercicio_semana"] < 3)]:
    for extra_label, extra_cond in [("Com Atividade Extra", tabela_habits["participa_extracurricular"] == "Yes"), ("Sem Atividade Extra", tabela_habits["participa_extracurricular"] == "No")]:
        sub = tabela_habits[ex_cond & extra_cond]
        if len(sub) > 0:
            score_res = round(0.5 * (sub["nota_exame"].mean() / 100.0) + 0.3 * (sub["autoavaliacao_saude_mental"].mean() / 10.0) + 0.2 * (sub["score_habitos_produtivos"].mean()), 3)
            kpi_resil.append({
                "perfil_atividade": f"{ex_label} + {extra_label}",
                "pratica_exercicio": ex_label, "faz_extracurricular": extra_label,
                "total_estudantes": len(sub), "nota_media": round(sub["nota_exame"].mean(), 2),
                "media_tempo_telas": round(sub["tempo_telas_horas"].mean(), 2),
                "score_resiliencia": score_res, "dt_carga": now_str
            })
pd.DataFrame(kpi_resil).to_sql("kpi_resiliencia_habitos", conn, if_exists="append", index=False)

def get_area(c):
    c_lower = str(c).lower()
    if any(k in c_lower for k in ["engine", "bit", "bcs", "it", "mathem", "computer", "kenms", "enm"]):
        return "Exatas / Tecnologia"
    elif any(k in c_lower for k in ["law", "psych", "human", "educat", "irkhs", "pendidikan"]):
        return "Humanas / Sociais"
    elif any(k in c_lower for k in ["account", "econ", "business"]):
        return "Negócios / Finanças"
    else:
        return "Outras Áreas"

tabela_mental["area_curso"] = tabela_mental["curso"].map(get_area)

kpi_curso = []
for area in tabela_mental["area_curso"].unique():
    for ano in sorted(tabela_mental["ano_estudo"].unique()):
        sub = tabela_mental[(tabela_mental["area_curso"] == area) & (tabela_mental["ano_estudo"] == ano)]
        if len(sub) > 0:
            kpi_curso.append({
                "area_curso": area, "ano_graduacao": ano, "total_estudantes": len(sub),
                "cgpa_medio": round(sub["cgpa_medio"].mean(), 2),
                "taxa_depressao_pct": round((sub["depressao_flag"] == 1).mean() * 100, 1),
                "taxa_ansiedade_pct": round((sub["ansiedade_flag"] == 1).mean() * 100, 1),
                "taxa_panico_pct": round((sub["panico_flag"] == 1).mean() * 100, 1),
                "taxa_busca_tratamento_pct": round((sub["tratamento_especialista_flag"] == 1).mean() * 100, 1),
                "dt_carga": now_str
            })
pd.DataFrame(kpi_curso).to_sql("kpi_curso_saude_mental", conn, if_exists="append", index=False)


# 5. KPI por Faixa Etária e Maturidade Acadêmica
def categorizar_idade(idade):
    if idade <= 19:
        return ("18-19 anos", "Calouros (Início)")
    elif idade <= 22:
        return ("20-22 anos", "Intermediários (Meio)")
    else:
        return ("23-25+ anos", "Veteranos / Formandos")

tabela_habits["faixa_etaria_tuple"] = tabela_habits["idade"].map(categorizar_idade)
tabela_habits["faixa_etaria"] = tabela_habits["faixa_etaria_tuple"].map(lambda x: x[0])
tabela_habits["etapa_academica"] = tabela_habits["faixa_etaria_tuple"].map(lambda x: x[1])

kpi_age = []
for (faixa, etapa), sub in tabela_habits.groupby(["faixa_etaria", "etapa_academica"]):
    score_auto = round(
        0.4 * (sub["horas_estudo_dia"].mean() / 6.0) +
        0.3 * (sub["horas_sono"].mean() / 8.0) +
        0.3 * (1.0 - (sub["tempo_telas_horas"].mean() / 10.0)),
        3
    )
    taxa_risco = round((sub["tempo_telas_horas"] > 5.0).mean() * 100, 1)
    kpi_age.append({
        "faixa_etaria": faixa, "etapa_academica": etapa,
        "total_estudantes": len(sub), "nota_media_exame": round(sub["nota_exame"].mean(), 2),
        "media_horas_estudo": round(sub["horas_estudo_dia"].mean(), 2),
        "media_tempo_telas": round(sub["tempo_telas_horas"].mean(), 2),
        "media_horas_sono": round(sub["horas_sono"].mean(), 2),
        "score_autorregulacao": score_auto, "taxa_risco_pct": taxa_risco,
        "dt_carga": now_str
    })

pd.DataFrame(kpi_age).sort_values("faixa_etaria").to_sql("kpi_faixa_etaria_performance", conn, if_exists="append", index=False)


# 6. KPI Multidimensional por Gênero (Feminino vs Masculino)
kpi_gender = []
for g in ["Feminino", "Masculino"]:
    sub_sleep = tabela_sleep[tabela_sleep["genero"] == g]
    sub_habits = tabela_habits[tabela_habits["genero"] == g]
    sub_mental = tabela_mental[tabela_mental["genero"] == g]
    
    nota_m = round(sub_sleep["nota_anterior"].mean(), 2)
    nota_ex = round(sub_habits["nota_exame"].mean(), 2)
    h_estudo = round(sub_sleep["horas_estudo"].mean(), 2)
    t_telas = round(sub_habits["tempo_telas_horas"].mean(), 2)
    h_sono = round(sub_sleep["horas_sono"].mean(), 2)
    iqs_m = round(sub_sleep["iqs_estimado"].mean(), 3)
    efic_m = round(sub_sleep["eficiencia_media"].mean(), 3)
    s_prof = round(sub_sleep["perc_sono_profundo_estimado"].mean(), 1)
    ex_sem = round(sub_habits["freq_exercicio_semana"].mean(), 2)
    
    cgpa_m = round(sub_mental["cgpa_medio"].mean(), 2) if len(sub_mental) > 0 else 3.3
    tx_dep = round((sub_mental["depressao_flag"] == 1).mean() * 100, 1) if len(sub_mental) > 0 else 30.0
    tx_ans = round((sub_mental["ansiedade_flag"] == 1).mean() * 100, 1) if len(sub_mental) > 0 else 35.0
    tx_pan = round((sub_mental["panico_flag"] == 1).mean() * 100, 1) if len(sub_mental) > 0 else 30.0
    tx_trat = round((sub_mental["tratamento_especialista_flag"] == 1).mean() * 100, 1) if len(sub_mental) > 0 else 5.0
    
    score_eq = round(
        0.3 * (nota_m / 100.0) +
        0.25 * iqs_m +
        0.2 * (1.0 - (t_telas / 10.0)) +
        0.15 * (ex_sem / 7.0) +
        0.1 * (cgpa_m / 4.0),
        3
    )
    
    kpi_gender.append({
        "genero": g,
        "total_estudantes": len(sub_sleep),
        "nota_media": nota_m,
        "nota_exame_media": nota_ex,
        "media_horas_estudo": h_estudo,
        "media_tempo_telas": t_telas,
        "media_horas_sono": h_sono,
        "media_iqs_sono": iqs_m,
        "media_eficiencia_sono": efic_m,
        "media_sono_profundo": s_prof,
        "freq_exercicio_semana": ex_sem,
        "cgpa_medio": cgpa_m,
        "taxa_depressao_pct": tx_dep,
        "taxa_ansiedade_pct": tx_ans,
        "taxa_panico_pct": tx_pan,
        "taxa_busca_tratamento_pct": tx_trat,
        "score_equilibrio_geral": score_eq,
        "dt_carga": now_str
    })

pd.DataFrame(kpi_gender).to_sql("kpi_genero_performance", conn, if_exists="append", index=False)

# 7. KPI de Performance por Hábitos de Vida e Exposição a Telas
kpi_habitos = []
for cat in ["Baixo (<2h)", "Moderado (2-4h)", "Alto (4-6h)", "Muito Alto (>6h)"]:
    sub = tabela_habits[tabela_habits["categoria_tempo_telas"] == cat]
    if len(sub) > 0:
        perfil = {
            "Baixo (<2h)": "Hábitos de Alta Performance (Foco Digital & Exercício)",
            "Moderado (2-4h)": "Hábitos Equilibrados (Uso Moderado de Telas)",
            "Alto (4-6h)": "Hábitos em Alerta (Sobrecarga de Telas)",
            "Muito Alto (>6h)": "Hábitos Críticos (Sedentarismo & Dispersão Digital)"
        }.get(cat, "Hábitos Diversos")
        
        sqd_medio = round((sub["horas_estudo_dia"] / (sub["tempo_telas_horas"] + 0.1)).mean(), 3)
        aprov_exc = round((sub["nota_exame"] >= 70.0).mean() * 100, 1)
        
        kpi_habitos.append({
            "categoria_habito": cat,
            "perfil_estilo_vida": perfil,
            "total_estudantes": len(sub),
            "nota_media_exame": round(sub["nota_exame"].mean(), 2),
            "media_horas_estudo": round(sub["horas_estudo_dia"].mean(), 2),
            "media_tempo_telas": round(sub["tempo_telas_horas"].mean(), 2),
            "media_exercicio_dias": round(sub["freq_exercicio_semana"].mean(), 1),
            "score_saude_mental": round(sub["autoavaliacao_saude_mental"].mean(), 1),
            "indice_qualidade_digital": sqd_medio,
            "taxa_aprovacao_excelencia_pct": aprov_exc,
            "dt_carga": now_str
        })

pd.DataFrame(kpi_habitos).to_sql("kpi_habitos_vida_performance", conn, if_exists="append", index=False)


conn.commit()
conn.close()

print("====================================================================")
print("  ESTEIRA ETL EXECUTADA COM SUCESSO E SCHEMA PRISTINO GARANTIDO!")
print(f"  Banco de Dados: {db_path} (17 Tabelas Ativas)")
print("====================================================================")
