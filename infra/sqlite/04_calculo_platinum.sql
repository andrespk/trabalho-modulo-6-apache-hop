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