DELETE FROM dim_sono;
INSERT INTO dim_sono (
    id_sono, idade, genero, faixa_etaria, duracao_sono_horas, eficiencia_sono,
    perc_rem, perc_sono_profundo, perc_sono_leve, num_despertares, consumo_cafeina,
    consumo_alcool, tabagista_flag, freq_exercicio, classificacao_sono,
    categoria_duracao_sono, indice_qualidade_sono, faixa_sono, dt_carga
)
SELECT 
    row_number() OVER () AS id_sono,
    CAST(age_orig AS INTEGER) AS idade,
    gender_orig AS genero,
    CASE 
        WHEN CAST(age_orig AS INTEGER) < 20 THEN '18-19 anos'
        WHEN CAST(age_orig AS INTEGER) <= 22 THEN '20-22 anos'
        ELSE '23-25+ anos'
    END AS faixa_etaria,
    CAST(sleep_duration_orig AS REAL) AS duracao_sono_horas,
    CAST(sleep_efficiency_orig AS REAL) AS eficiencia_sono,
    CAST(rem_sleep_percentage_orig AS REAL) AS perc_rem,
    CAST(deep_sleep_percentage_orig AS REAL) AS perc_sono_profundo,
    CAST(light_sleep_percentage_orig AS REAL) AS perc_sono_leve,
    CAST(awakenings_orig AS REAL) AS num_despertares,
    CAST(caffeine_consumption_orig AS REAL) AS consumo_cafeina,
    CAST(alcohol_consumption_orig AS REAL) AS consumo_alcool,
    CASE WHEN LOWER(smoking_status_orig) = 'yes' THEN 1 ELSE 0 END AS tabagista_flag,
    CAST(exercise_frequency_orig AS REAL) AS freq_exercicio,
    CASE 
        WHEN CAST(sleep_efficiency_orig AS REAL) >= 0.85 THEN 'Excelente'
        WHEN CAST(sleep_efficiency_orig AS REAL) >= 0.75 THEN 'Bom'
        WHEN CAST(sleep_efficiency_orig AS REAL) >= 0.65 THEN 'Regular'
        ELSE 'Ruim'
    END AS classificacao_sono,
    CASE 
        WHEN CAST(sleep_duration_orig AS REAL) >= 8.0 THEN '>= 8h (Ideal)'
        WHEN CAST(sleep_duration_orig AS REAL) >= 7.0 THEN '7h - 8h (Normal)'
        WHEN CAST(sleep_duration_orig AS REAL) >= 6.0 THEN '6h - 7h (Alerta)'
        ELSE '< 6h (Privado)'
    END AS categoria_duracao_sono,
    ROUND(0.40 * CAST(sleep_efficiency_orig AS REAL) + 0.30 * (CAST(deep_sleep_percentage_orig AS REAL) / 100.0) + 0.20 * (CAST(rem_sleep_percentage_orig AS REAL) / 100.0) - 0.10 * (COALESCE(CAST(awakenings_orig AS REAL), 0) / 5.0), 3) AS indice_qualidade_sono,
    ROUND(CAST(sleep_duration_orig AS REAL), 0) AS faixa_sono,
    datetime('now') AS dt_carga
FROM raw_sleep_efficiency;

DELETE FROM dim_alunos;
INSERT INTO dim_alunos (
    id_aluno, genero, horas_estudo, frequencia_escolar, horas_sono,
    nivel_ensino_pais_codigo, nivel_ensino_pais_label, tem_internet,
    atividades_extracurriculares, trabalho_parcial, nota_anterior,
    nota_normalizada, classificacao_desempenho, categoria_horas_sono,
    faixa_estudo, faixa_sono, dt_carga
)
SELECT 
    row_number() OVER () AS id_aluno,
    gender_orig AS genero,
    CAST(study_hours_per_day_orig AS REAL) AS horas_estudo,
    CAST(attendance_percentage_orig AS REAL) AS frequencia_escolar,
    CAST(sleep_hours_orig AS REAL) AS horas_sono,
    CASE 
        WHEN parental_education_level_orig LIKE '%Master%' OR parental_education_level_orig LIKE '%Doctorate%' THEN 3
        WHEN parental_education_level_orig LIKE '%Bachelor%' THEN 2
        ELSE 1
    END AS nivel_ensino_pais_codigo,
    parental_education_level_orig AS nivel_ensino_pais_label,
    CASE WHEN LOWER(internet_quality_orig) != 'poor' THEN 1 ELSE 0 END AS tem_internet,
    CASE WHEN LOWER(extracurricular_participation_orig) = 'yes' THEN 1 ELSE 0 END AS atividades_extracurriculares,
    CASE WHEN LOWER(part_time_job_orig) = 'yes' THEN 1 ELSE 0 END AS trabalho_parcial,
    CAST(exam_score_orig AS REAL) AS nota_anterior,
    ROUND(CAST(exam_score_orig AS REAL) / 100.0, 3) AS nota_normalizada,
    CASE 
        WHEN CAST(exam_score_orig AS REAL) >= 80 THEN 'Alto Desempenho'
        WHEN CAST(exam_score_orig AS REAL) >= 60 THEN 'Médio Desempenho'
        ELSE 'Baixo Desempenho'
    END AS classificacao_desempenho,
    CASE 
        WHEN CAST(sleep_hours_orig AS REAL) >= 8.0 THEN '>= 8h'
        WHEN CAST(sleep_hours_orig AS REAL) >= 7.0 THEN '7h - 8h'
        ELSE '< 7h'
    END AS categoria_horas_sono,
    CASE 
        WHEN CAST(study_hours_per_day_orig AS REAL) >= 4.0 THEN 'Alto (>=4h)'
        WHEN CAST(study_hours_per_day_orig AS REAL) >= 2.0 THEN 'Médio (2-4h)'
        ELSE 'Baixo (<2h)'
    END AS faixa_estudo,
    ROUND(CAST(sleep_hours_orig AS REAL), 0) AS faixa_sono,
    datetime('now') AS dt_carga
FROM raw_student_habits;

DELETE FROM dim_habitos;
INSERT INTO dim_habitos (
    cod_estudante, idade, genero, horas_estudo_dia, horas_redes_sociais,
    horas_netflix, tempo_telas_horas, categoria_tempo_telas, trabalho_parcial,
    frequencia_pct, horas_sono, qualidade_dieta, freq_exercicio_semana,
    educacao_pais, qualidade_internet, autoavaliacao_saude_mental,
    participa_extracurricular, nota_exame, classificacao_nota, faixa_sono, dt_carga
)
SELECT 
    student_id_orig AS cod_estudante,
    CAST(age_orig AS INTEGER) AS idade,
    gender_orig AS genero,
    CAST(study_hours_per_day_orig AS REAL) AS horas_estudo_dia,
    CAST(social_media_hours_orig AS REAL) AS horas_redes_sociais,
    CAST(netflix_hours_orig AS REAL) AS horas_netflix,
    ROUND(CAST(social_media_hours_orig AS REAL) + CAST(netflix_hours_orig AS REAL), 2) AS tempo_telas_horas,
    CASE 
        WHEN (CAST(social_media_hours_orig AS REAL) + CAST(netflix_hours_orig AS REAL)) < 2.0 THEN 'Baixo (<2h)'
        WHEN (CAST(social_media_hours_orig AS REAL) + CAST(netflix_hours_orig AS REAL)) < 4.0 THEN 'Moderado (2-4h)'
        WHEN (CAST(social_media_hours_orig AS REAL) + CAST(netflix_hours_orig AS REAL)) < 6.0 THEN 'Alto (4-6h)'
        ELSE 'Muito Alto (>6h)'
    END AS categoria_tempo_telas,
    part_time_job_orig AS trabalho_parcial,
    CAST(attendance_percentage_orig AS REAL) AS frequencia_pct,
    CAST(sleep_hours_orig AS REAL) AS horas_sono,
    diet_quality_orig AS qualidade_dieta,
    CAST(exercise_frequency_orig AS INTEGER) AS freq_exercicio_semana,
    parental_education_level_orig AS educacao_pais,
    internet_quality_orig AS qualidade_internet,
    CAST(mental_health_rating_orig AS INTEGER) AS autoavaliacao_saude_mental,
    extracurricular_participation_orig AS participa_extracurricular,
    CAST(exam_score_orig AS REAL) AS nota_exame,
    CASE 
        WHEN CAST(exam_score_orig AS REAL) >= 80 THEN 'Excelente'
        WHEN CAST(exam_score_orig AS REAL) >= 60 THEN 'Bom'
        ELSE 'Regular'
    END AS classificacao_nota,
    ROUND(CAST(sleep_hours_orig AS REAL), 0) AS faixa_sono,
    datetime('now') AS dt_carga
FROM raw_student_habits;

DELETE FROM dim_saude_mental;
INSERT INTO dim_saude_mental (
    id_registro, data_resposta, genero, idade, curso, ano_estudo,
    cgpa_faixa, cgpa_medio, nota_estimada_100, classificacao_desempenho,
    casado_flag, depressao_flag, ansiedade_flag, panico_flag,
    tratamento_especialista_flag, indice_vulnerabilidade_mental, dt_carga
)
SELECT 
    row_number() OVER () AS id_registro,
    timestamp_orig AS data_resposta,
    gender_orig AS genero,
    CAST(age_orig AS INTEGER) AS idade,
    course_orig AS curso,
    year_of_study_orig AS ano_estudo,
    cgpa_orig AS cgpa_faixa,
    CASE 
        WHEN cgpa_orig LIKE '%3.50%' OR cgpa_orig LIKE '%3.5 - 4.00%' THEN 3.75
        WHEN cgpa_orig LIKE '%3.00%' OR cgpa_orig LIKE '%3.0 - 3.49%' THEN 3.25
        WHEN cgpa_orig LIKE '%2.50%' OR cgpa_orig LIKE '%2.5 - 2.99%' THEN 2.75
        WHEN cgpa_orig LIKE '%2.00%' OR cgpa_orig LIKE '%2.0 - 2.49%' THEN 2.25
        ELSE 2.00
    END AS cgpa_medio,
    ROUND(CASE 
        WHEN cgpa_orig LIKE '%3.50%' OR cgpa_orig LIKE '%3.5 - 4.00%' THEN 3.75
        WHEN cgpa_orig LIKE '%3.00%' OR cgpa_orig LIKE '%3.0 - 3.49%' THEN 3.25
        WHEN cgpa_orig LIKE '%2.50%' OR cgpa_orig LIKE '%2.5 - 2.99%' THEN 2.75
        WHEN cgpa_orig LIKE '%2.00%' OR cgpa_orig LIKE '%2.0 - 2.49%' THEN 2.25
        ELSE 2.00
    END * 25.0, 1) AS nota_estimada_100,
    'Regular' AS classificacao_desempenho,
    CASE WHEN LOWER(marital_status_orig) = 'yes' THEN 1 ELSE 0 END AS casado_flag,
    CASE WHEN LOWER(depression_orig) = 'yes' THEN 1 ELSE 0 END AS depressao_flag,
    CASE WHEN LOWER(anxiety_orig) = 'yes' THEN 1 ELSE 0 END AS ansiedade_flag,
    CASE WHEN LOWER(panic_attack_orig) = 'yes' THEN 1 ELSE 0 END AS panico_flag,
    CASE WHEN LOWER(treatment_orig) = 'yes' THEN 1 ELSE 0 END AS tratamento_especialista_flag,
    (CASE WHEN LOWER(depression_orig) = 'yes' THEN 1 ELSE 0 END + 
     CASE WHEN LOWER(anxiety_orig) = 'yes' THEN 1 ELSE 0 END + 
     CASE WHEN LOWER(panic_attack_orig) = 'yes' THEN 1 ELSE 0 END) AS indice_vulnerabilidade_mental,
    datetime('now') AS dt_carga
FROM raw_student_mental_health;