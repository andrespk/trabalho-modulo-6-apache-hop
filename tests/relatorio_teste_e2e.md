# 🧪 Relatório Oficial de Testes End-to-End (E2E) — Playwright
**Projeto:** Performance de Alunos vs Sono, Hábitos e Saúde Mental  
**Módulo:** 6 — Apache Hop (Pós-Graduação IA UEA)  
**Data/Hora da Execução:** 2026-08-26 15:16:48  
**Taxa de Sucesso:** 6/6 (100% de Aprovação)

---

## 📊 Resultados dos Testes

| Caso de Teste | Status | Detalhes / Evidência |
|---|:---:|---|
| **Teste 01: Ingestão HTTPS Resiliente (Kaggle APIs)** | `PASSED` | Download com retry e fallback concluído. |
| **Teste 02: Execução End-to-End da Pipeline ETL Apache Hop** | `PASSED` | Todas as camadas (Bronze, Silver, Gold, Platinum, Reference) processadas. |
| **Teste 03: Validação de Integridade e Contagens nas 18 Tabelas** | `PASSED` | Todas as 18 tabelas validadas com contagens exatas. |
| **Teste 04: Garantia de Idempotência da Esteira ETL (Reprocessamento)** | `PASSED` | Reprocessamento 2x consecutivo gerou contagens idênticas com 0 duplicatas. |
| **Teste 05: Regras de Qualidade de Dados e Ranges Numéricos** | `PASSED` | 100% dos dados e das 10 regras de normalidade respeitam os limites numéricos. |
| **Teste 06: Renderização de Dashboard com Donuts, Radares e Barras (Playwright)** | `PASSED` | Dashboard validado (4 cards, 5 gráficos interativos Chart.js, 3 tabelas). Screenshot: C:\AndreMarques\projects\curso-ia-uea\modulo-6-apache-hop\trabalho-modulo-6-apache-hop\tests\screenshots\metabase_dashboard_e2e.png |

---

## 📸 Evidências Capturadas
- **Dashboard Completo:** `tests/screenshots/metabase_dashboard_e2e.png`
- **Gráficos de Donuts e Radar:** `tests/screenshots/charts_donuts_radar.png`
- **Cards de KPIs:** `tests/screenshots/kpi_cards_preview.png`
- **Relatório HTML:** `tests/relatorio_teste_e2e.html`
