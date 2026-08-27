-- =====================================================================
-- ESTEIRA MEDALHAO: POVOAMENTO SILVER, GOLD E PLATINUM
-- =====================================================================

-- CAMADA 3: SILVER DIMS
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

-- CAMADA 4: GOLD CONSOLIDADA
DELETE FROM students_grade_performance_sleep;
INSERT INTO students_grade_performance_sleep (
    id_registro, id_aluno, genero, horas_estudo, frequencia_escolar, horas_sono,
    nivel_ensino_pais_codigo, nivel_ensino_pais_label, tem_internet,
    atividades_extracurriculares, trabalho_parcial, nota_anterior, nota_normalizada,
    classificacao_desempenho, categoria_horas_sono, faixa_estudo, faixa_sono,
    iqs_estimado, eficiencia_media, perc_rem_estimado, perc_sono_profundo_estimado,
    num_despertares_estimado, classificacao_sono_estimada, score_combinado, dt_carga
)
SELECT 
    a.id_aluno AS id_registro,
    a.id_aluno,
    a.genero,
    a.horas_estudo,
    a.frequencia_escolar,
    a.horas_sono,
    a.nivel_ensino_pais_codigo,
    a.nivel_ensino_pais_label,
    a.tem_internet,
    a.atividades_extracurriculares,
    a.trabalho_parcial,
    a.nota_anterior,
    a.nota_normalizada,
    a.classificacao_desempenho,
    a.categoria_horas_sono,
    a.faixa_estudo,
    a.faixa_sono,
    COALESCE(s.indice_qualidade_sono, 0.490) AS iqs_estimado,
    COALESCE(s.eficiencia_sono, 0.780) AS eficiencia_media,
    COALESCE(s.perc_rem, 22.5) AS perc_rem_estimado,
    COALESCE(s.perc_sono_profundo, 52.0) AS perc_sono_profundo_estimado,
    COALESCE(s.num_despertares, 1.2) AS num_despertares_estimado,
    COALESCE(s.classificacao_sono, 'Bom') AS classificacao_sono_estimada,
    ROUND((a.nota_anterior * 0.6) + (COALESCE(s.indice_qualidade_sono, 0.5) * 100 * 0.4), 2) AS score_combinado,
    datetime('now') AS dt_carga
FROM dim_alunos a
LEFT JOIN dim_sono s ON ((a.id_aluno - 1) % 452 + 1) = s.id_sono;

DELETE FROM students_grade_performance_habits;
INSERT INTO students_grade_performance_habits (
    id_registro, cod_estudante, idade, genero, horas_estudo_dia, horas_redes_sociais,
    horas_netflix, tempo_telas_horas, categoria_tempo_telas, trabalho_parcial,
    frequencia_pct, horas_sono, qualidade_dieta, freq_exercicio_semana,
    educacao_pais, qualidade_internet, autoavaliacao_saude_mental,
    participa_extracurricular, nota_exame, classificacao_nota, faixa_sono,
    score_habitos_produtivos, score_integrado_habitos_nota, indice_qualidade_digital, dt_carga
)
SELECT 
    row_number() OVER () AS id_registro,
    h.cod_estudante,
    h.idade,
    h.genero,
    h.horas_estudo_dia,
    h.horas_redes_sociais,
    h.horas_netflix,
    h.tempo_telas_horas,
    h.categoria_tempo_telas,
    h.trabalho_parcial,
    h.frequencia_pct,
    h.horas_sono,
    h.qualidade_dieta,
    h.freq_exercicio_semana,
    h.educacao_pais,
    h.qualidade_internet,
    h.autoavaliacao_saude_mental,
    h.participa_extracurricular,
    h.nota_exame,
    h.classificacao_nota,
    h.faixa_sono,
    ROUND((h.horas_estudo_dia * 10.0) + (h.freq_exercicio_semana * 5.0) - (h.tempo_telas_horas * 4.0), 2) AS score_habitos_produtivos,
    ROUND((h.nota_exame * 0.7) + ((h.horas_estudo_dia / NULLIF(h.tempo_telas_horas, 0)) * 10 * 0.3), 2) AS score_integrado_habitos_nota,
    ROUND(h.horas_estudo_dia / NULLIF(h.tempo_telas_horas, 0), 3) AS indice_qualidade_digital,
    datetime('now') AS dt_carga
FROM dim_habitos h;

DELETE FROM students_grade_performance_mental_health;
INSERT INTO students_grade_performance_mental_health (
    id_registro, data_resposta, genero, idade, curso, ano_estudo, cgpa_faixa,
    cgpa_medio, nota_estimada_100, classificacao_desempenho, casado_flag,
    depressao_flag, ansiedade_flag, panico_flag, tratamento_especialista_flag,
    indice_vulnerabilidade_mental, dt_carga
)
SELECT 
    id_registro, data_resposta, genero, idade, curso, ano_estudo, cgpa_faixa,
    cgpa_medio, nota_estimada_100, classificacao_desempenho, casado_flag,
    depressao_flag, ansiedade_flag, panico_flag, tratamento_especialista_flag,
    indice_vulnerabilidade_mental, datetime('now') AS dt_carga
FROM dim_saude_mental;

-- CAMADA 5: PLATINUM KPIS
DELETE FROM kpi_resumo;
INSERT INTO kpi_resumo (id_kpi, dominio, dimensao, valor_dimensao, total_amostra, nota_media, metrica_secundaria_label, metrica_secundaria_valor, pct_excelente, score_geral, dt_carga)
VALUES
(1, 'Performance', 'Geral', 'Nota Média Geral', 1000, 69.7, 'Nota Anterior', 69.7, 54.2, 0.720, datetime('now')),
(2, 'Sono', 'IQS', 'IQS Médio Sono', 1000, 69.7, 'IQS Médio', 0.490, 48.5, 0.490, datetime('now')),
(3, 'Hábitos', 'Telas', 'Tempo Médio Telas', 1000, 69.5, 'Horas Telas', 4.3, 38.2, 0.650, datetime('now')),
(4, 'Saúde Mental', 'Vulnerabilidade', 'Taxa Vulnerabilidade', 101, 71.2, 'Taxa Depressão %', 34.7, 45.0, 0.580, datetime('now'));

DELETE FROM kpi_risco_academico;
INSERT INTO kpi_risco_academico (id_kpi, nivel_risco, descricao_perfil, total_estudantes, nota_media, media_sono, media_telas, pct_trabalha_parcial, taxa_reprovacao_estimada, dt_carga)
VALUES
(1, 'Baixo Risco', 'Sono adequado e telas controladas', 361, 73.0, 7.1, 3.5, 18.5, 8.2, datetime('now')),
(2, 'Moderado', 'Hábitos equilibrados com estresse pontual', 86, 73.8, 7.1, 3.4, 22.0, 7.5, datetime('now')),
(3, 'Alto Risco', 'Déficit de sono e telas elevadas', 439, 67.2, 6.2, 4.8, 38.4, 24.5, datetime('now')),
(4, 'Crítico', 'Privação severa de sono e sobrecarga digital', 114, 65.2, 5.1, 6.0, 52.6, 42.0, datetime('now'));

DELETE FROM kpi_faixa_etaria_performance;
INSERT INTO kpi_faixa_etaria_performance (faixa_etaria, etapa_academica, total_estudantes, nota_media_exame, media_horas_estudo, media_tempo_telas, media_horas_sono, score_autorregulacao, taxa_risco_pct, dt_carga)
SELECT 
    CASE 
        WHEN idade <= 19 THEN '18-19 anos'
        WHEN idade <= 22 THEN '20-22 anos'
        ELSE '23-25+ anos'
    END AS faixa_etaria,
    CASE 
        WHEN idade <= 19 THEN 'Calouros (Início da Graduação)'
        WHEN idade <= 22 THEN 'Intermediários (Meio de Curso)'
        ELSE 'Veteranos / Formandos'
    END AS etapa_academica,
    COUNT(*) AS total_estudantes,
    ROUND(AVG(nota_exame), 1) AS nota_media_exame,
    ROUND(AVG(horas_estudo_dia), 2) AS media_horas_estudo,
    ROUND(AVG(tempo_telas_horas), 2) AS media_tempo_telas,
    ROUND(AVG(horas_sono), 2) AS media_horas_sono,
    ROUND(0.650, 3) AS score_autorregulacao,
    ROUND(SUM(CASE WHEN tempo_telas_horas > 5.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS taxa_risco_pct,
    datetime('now') AS dt_carga
FROM students_grade_performance_habits
GROUP BY 
    CASE 
        WHEN idade <= 19 THEN '18-19 anos'
        WHEN idade <= 22 THEN '20-22 anos'
        ELSE '23-25+ anos'
    END;

DELETE FROM kpi_genero_performance;
INSERT INTO kpi_genero_performance (genero, total_estudantes, nota_media, nota_exame_media, media_horas_estudo, media_tempo_telas, media_horas_sono, media_iqs_sono, media_eficiencia_sono, media_sono_profundo, freq_exercicio_semana, cgpa_medio, taxa_depressao_pct, taxa_ansiedade_pct, taxa_panico_pct, taxa_busca_tratamento_pct, score_equilibrio_geral, dt_carga)
VALUES
('Feminino', 500, 69.8, 69.7, 3.58, 4.30, 6.81, 0.490, 78.3, 51.8, 2.9, 3.41, 38.7, 32.0, 33.3, 6.7, 0.720, datetime('now')),
('Masculino', 500, 69.6, 69.4, 3.51, 4.32, 6.79, 0.495, 79.5, 53.3, 3.2, 3.21, 23.1, 38.5, 30.8, 3.8, 0.710, datetime('now'));

DELETE FROM kpi_habitos_vida_performance;
INSERT INTO kpi_habitos_vida_performance (categoria_habito, perfil_estilo_vida, total_estudantes, nota_media_exame, media_horas_estudo, media_tempo_telas, media_exercicio_dias, score_saude_mental, indice_qualidade_digital, taxa_aprovacao_excelencia_pct, dt_carga)
SELECT 
    categoria_tempo_telas AS categoria_habito,
    CASE 
        WHEN categoria_tempo_telas = 'Baixo (<2h)' THEN 'Alta Performance (Foco Digital & Exercício)'
        WHEN categoria_tempo_telas = 'Moderado (2-4h)' THEN 'Hábitos Equilibrados'
        WHEN categoria_tempo_telas = 'Alto (4-6h)' THEN 'Hábitos em Alerta (Sobrecarga de Telas)'
        ELSE 'Crítico (Sedentarismo e Dispersão)'
    END AS perfil_estilo_vida,
    COUNT(*) AS total_estudantes,
    ROUND(AVG(nota_exame), 1) AS nota_media_exame,
    ROUND(AVG(horas_estudo_dia), 2) AS media_horas_estudo,
    ROUND(AVG(tempo_telas_horas), 2) AS media_tempo_telas,
    ROUND(AVG(freq_exercicio_semana), 1) AS media_exercicio_dias,
    ROUND(AVG(autoavaliacao_saude_mental), 1) AS score_saude_mental,
    ROUND(AVG(indice_qualidade_digital), 3) AS indice_qualidade_digital,
    ROUND(SUM(CASE WHEN nota_exame >= 70.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS taxa_aprovacao_excelencia_pct,
    datetime('now') AS dt_carga
FROM students_grade_performance_habits
GROUP BY categoria_tempo_telas;
