-- =====================================================================
-- SCRIPT DDL DE INICIALIZACAO IDEMPOTENTE DO BANCO DE DADOS
-- Banco: estudantes.db (SQLite 3)
-- =====================================================================

DROP TABLE IF EXISTS raw_sleep_efficiency;
CREATE TABLE raw_sleep_efficiency (
    _raw_id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_orig TEXT, age_orig TEXT, gender_orig TEXT, bedtime_orig TEXT,
    wakeup_time_orig TEXT, sleep_duration_orig TEXT, sleep_efficiency_orig TEXT,
    rem_sleep_percentage_orig TEXT, deep_sleep_percentage_orig TEXT,
    light_sleep_percentage_orig TEXT, awakenings_orig TEXT,
    caffeine_consumption_orig TEXT, alcohol_consumption_orig TEXT,
    smoking_status_orig TEXT, exercise_frequency_orig TEXT,
    _loaded_at TEXT NOT NULL, _source_file TEXT NOT NULL
);

DROP TABLE IF EXISTS raw_student_performance;
CREATE TABLE raw_student_performance (
    _raw_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id_orig TEXT, gender_orig TEXT, study_time_hours_orig TEXT,
    attendance_percent_orig TEXT, sleep_hours_orig TEXT, parental_education_orig TEXT,
    internet_access_orig TEXT, extracurricular_activities_orig TEXT,
    part_time_job_orig TEXT, previous_grade_orig TEXT,
    _loaded_at TEXT NOT NULL, _source_file TEXT NOT NULL
);

DROP TABLE IF EXISTS raw_student_habits;
CREATE TABLE raw_student_habits (
    _raw_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id_orig TEXT, age_orig TEXT, gender_orig TEXT, study_hours_per_day_orig TEXT,
    social_media_hours_orig TEXT, netflix_hours_orig TEXT, part_time_job_orig TEXT,
    attendance_percentage_orig TEXT, sleep_hours_orig TEXT, diet_quality_orig TEXT,
    exercise_frequency_orig TEXT, parental_education_level_orig TEXT,
    internet_quality_orig TEXT, mental_health_rating_orig TEXT,
    extracurricular_participation_orig TEXT, exam_score_orig TEXT,
    _loaded_at TEXT NOT NULL, _source_file TEXT NOT NULL
);

DROP TABLE IF EXISTS raw_student_mental_health;
CREATE TABLE raw_student_mental_health (
    _raw_id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp_orig TEXT, gender_orig TEXT, age_orig TEXT, course_orig TEXT,
    year_of_study_orig TEXT, cgpa_orig TEXT, marital_status_orig TEXT,
    depression_orig TEXT, anxiety_orig TEXT, panic_attack_orig TEXT,
    treatment_orig TEXT, _loaded_at TEXT NOT NULL, _source_file TEXT NOT NULL
);

DROP TABLE IF EXISTS dim_sono;
CREATE TABLE dim_sono (
    id_sono INTEGER PRIMARY KEY,
    idade INTEGER, genero TEXT, faixa_etaria TEXT,
    duracao_sono_horas REAL, eficiencia_sono REAL, perc_rem REAL,
    perc_sono_profundo REAL, perc_sono_leve REAL, num_despertares REAL,
    consumo_cafeina REAL, consumo_alcool REAL, tabagista_flag INTEGER,
    freq_exercicio REAL, classificacao_sono TEXT, categoria_duracao_sono TEXT,
    indice_qualidade_sono REAL, faixa_sono REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS dim_alunos;
CREATE TABLE dim_alunos (
    id_aluno INTEGER PRIMARY KEY,
    genero TEXT, horas_estudo REAL, frequencia_escolar REAL, horas_sono REAL,
    nivel_ensino_pais_codigo INTEGER, nivel_ensino_pais_label TEXT,
    tem_internet INTEGER, atividades_extracurriculares INTEGER, trabalho_parcial INTEGER,
    nota_anterior REAL, nota_normalizada REAL, classificacao_desempenho TEXT,
    categoria_horas_sono TEXT, faixa_estudo TEXT, faixa_sono REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS dim_habitos;
CREATE TABLE dim_habitos (
    cod_estudante TEXT PRIMARY KEY,
    idade INTEGER, genero TEXT, horas_estudo_dia REAL,
    horas_redes_sociais REAL, horas_netflix REAL, tempo_telas_horas REAL,
    categoria_tempo_telas TEXT, trabalho_parcial TEXT, frequencia_pct REAL,
    horas_sono REAL, qualidade_dieta TEXT, freq_exercicio_semana INTEGER,
    educacao_pais TEXT, qualidade_internet TEXT, autoavaliacao_saude_mental INTEGER,
    participa_extracurricular TEXT, nota_exame REAL, classificacao_nota TEXT,
    faixa_sono REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS dim_saude_mental;
CREATE TABLE dim_saude_mental (
    id_registro INTEGER PRIMARY KEY AUTOINCREMENT,
    data_resposta TEXT, genero TEXT, idade INTEGER, curso TEXT,
    ano_estudo TEXT, cgpa_faixa TEXT, cgpa_medio REAL,
    nota_estimada_100 REAL, classificacao_desempenho TEXT, casado_flag INTEGER,
    depressao_flag INTEGER, ansiedade_flag INTEGER, panico_flag INTEGER,
    tratamento_especialista_flag INTEGER, indice_vulnerabilidade_mental INTEGER,
    dt_carga TEXT
);

DROP TABLE IF EXISTS students_grade_performance_sleep;
CREATE TABLE students_grade_performance_sleep (
    id_registro INTEGER PRIMARY KEY AUTOINCREMENT,
    id_aluno INTEGER NOT NULL,
    genero TEXT, horas_estudo REAL, frequencia_escolar REAL, horas_sono REAL,
    nivel_ensino_pais_codigo INTEGER, nivel_ensino_pais_label TEXT,
    tem_internet INTEGER, atividades_extracurriculares INTEGER, trabalho_parcial INTEGER,
    nota_anterior REAL, nota_normalizada REAL, classificacao_desempenho TEXT,
    categoria_horas_sono TEXT, faixa_estudo TEXT, faixa_sono REAL,
    iqs_estimado REAL, eficiencia_media REAL, perc_rem_estimado REAL,
    perc_sono_profundo_estimado REAL, num_despertares_estimado REAL,
    classificacao_sono_estimada TEXT, score_combinado REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS students_grade_performance_habits;
CREATE TABLE students_grade_performance_habits (
    id_registro INTEGER PRIMARY KEY AUTOINCREMENT,
    cod_estudante TEXT NOT NULL,
    idade INTEGER, genero TEXT, horas_estudo_dia REAL,
    horas_redes_sociais REAL, horas_netflix REAL, tempo_telas_horas REAL,
    categoria_tempo_telas TEXT, trabalho_parcial TEXT, frequencia_pct REAL,
    horas_sono REAL, qualidade_dieta TEXT, freq_exercicio_semana INTEGER,
    educacao_pais TEXT, qualidade_internet TEXT, autoavaliacao_saude_mental INTEGER,
    participa_extracurricular TEXT, nota_exame REAL, classificacao_nota TEXT,
    faixa_sono REAL, score_habitos_produtivos REAL, score_integrado_habitos_nota REAL,
    indice_qualidade_digital REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS students_grade_performance_mental_health;
CREATE TABLE students_grade_performance_mental_health (
    id_registro INTEGER PRIMARY KEY AUTOINCREMENT,
    data_resposta TEXT, genero TEXT, idade INTEGER, curso TEXT,
    ano_estudo TEXT, cgpa_faixa TEXT, cgpa_medio REAL,
    nota_estimada_100 REAL, classificacao_desempenho TEXT, casado_flag INTEGER,
    depressao_flag INTEGER, ansiedade_flag INTEGER, panico_flag INTEGER,
    tratamento_especialista_flag INTEGER, indice_vulnerabilidade_mental INTEGER,
    impacto_saude_mental_nota TEXT, score_estabilidade_academica REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS kpi_resumo;
CREATE TABLE kpi_resumo (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    dominio TEXT, dimensao TEXT, valor_dimensao TEXT, total_amostra INTEGER,
    nota_media REAL, metrica_secundaria_label TEXT, metrica_secundaria_valor REAL,
    pct_excelente REAL, score_geral REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS kpi_eficiencia_estudo;
CREATE TABLE kpi_eficiencia_estudo (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    faixa_horas_estudo TEXT, categoria_sono TEXT, total_estudantes INTEGER,
    nota_media REAL, horas_estudo_medias REAL, roi_nota_por_hora_estudo REAL,
    score_produtividade REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS kpi_risco_academico;
CREATE TABLE kpi_risco_academico (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    nivel_risco TEXT, descricao_perfil TEXT, total_estudantes INTEGER,
    nota_media REAL, media_sono REAL, media_telas REAL, pct_trabalha_parcial REAL,
    taxa_reprovacao_estimada REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS kpi_resiliencia_habitos;
CREATE TABLE kpi_resiliencia_habitos (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    perfil_atividade TEXT, pratica_exercicio TEXT, faz_extracurricular TEXT,
    total_estudantes INTEGER, nota_media REAL, media_tempo_telas REAL,
    score_resiliencia REAL, dt_carga TEXT
);

DROP TABLE IF EXISTS kpi_curso_saude_mental;
CREATE TABLE kpi_curso_saude_mental (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    area_curso TEXT, ano_graduacao TEXT, total_estudantes INTEGER,
    cgpa_medio REAL, taxa_depressao_pct REAL, taxa_ansiedade_pct REAL,
    taxa_panico_pct REAL, taxa_busca_tratamento_pct REAL, dt_carga TEXT
);

CREATE INDEX IF NOT EXISTS idx_perf_sleep_aluno ON students_grade_performance_sleep(id_aluno);
CREATE INDEX IF NOT EXISTS idx_perf_sleep_genero ON students_grade_performance_sleep(genero);
CREATE INDEX IF NOT EXISTS idx_perf_habits_cod ON students_grade_performance_habits(cod_estudante);
CREATE INDEX IF NOT EXISTS idx_perf_mental_cgpa ON students_grade_performance_mental_health(cgpa_medio);

DROP TABLE IF EXISTS ref_kpi_normalidade;
CREATE TABLE ref_kpi_normalidade (
    id_referencia INTEGER PRIMARY KEY,
    dominio TEXT NOT NULL,
    kpi_nome TEXT NOT NULL,
    sigla TEXT NOT NULL,
    unidade_medida TEXT NOT NULL,
    faixa_critica TEXT NOT NULL,
    faixa_alerta TEXT NOT NULL,
    faixa_ideal_normalidade TEXT NOT NULL,
    valor_medio_encontrado_base REAL NOT NULL,
    status_diagnostico_base TEXT NOT NULL,
    interpretacao_pratica TEXT NOT NULL,
    dt_carga TEXT NOT NULL
);


DROP TABLE IF EXISTS kpi_faixa_etaria_performance;
CREATE TABLE kpi_faixa_etaria_performance (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    faixa_etaria TEXT NOT NULL,
    etapa_academica TEXT NOT NULL,
    total_estudantes INTEGER NOT NULL,
    nota_media_exame REAL NOT NULL,
    media_horas_estudo REAL NOT NULL,
    media_tempo_telas REAL NOT NULL,
    media_horas_sono REAL NOT NULL,
    score_autorregulacao REAL NOT NULL,
    taxa_risco_pct REAL NOT NULL,
    dt_carga TEXT NOT NULL
);


DROP TABLE IF EXISTS kpi_genero_performance;
CREATE TABLE kpi_genero_performance (
    id_kpi INTEGER PRIMARY KEY AUTOINCREMENT,
    genero TEXT NOT NULL,
    total_estudantes INTEGER NOT NULL,
    nota_media REAL NOT NULL,
    nota_exame_media REAL NOT NULL,
    media_horas_estudo REAL NOT NULL,
    media_tempo_telas REAL NOT NULL,
    media_horas_sono REAL NOT NULL,
    media_iqs_sono REAL NOT NULL,
    media_eficiencia_sono REAL NOT NULL,
    media_sono_profundo REAL NOT NULL,
    freq_exercicio_semana REAL NOT NULL,
    cgpa_medio REAL NOT NULL,
    taxa_depressao_pct REAL NOT NULL,
    taxa_ansiedade_pct REAL NOT NULL,
    taxa_panico_pct REAL NOT NULL,
    taxa_busca_tratamento_pct REAL NOT NULL,
    score_equilibrio_geral REAL NOT NULL,
    dt_carga TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_kpi_dominio ON kpi_resumo(dominio);
