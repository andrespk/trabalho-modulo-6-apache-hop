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