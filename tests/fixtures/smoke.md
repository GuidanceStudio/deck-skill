+++
title = "Render Smoke"
palette = "cool"
lang = "en"
+++

# Render Smoke

Fixture exercising the M15/M16/M17 render regressions.

---

## Two columns must stay side-by-side in print (M16)

:::columns

:::col
Left column content.

- Alpha
- Beta

:::col
Right column content.

- Gamma
- Delta

:::

---

## Wide table must wrap, no scrollbar, no clip (M17)

| Quarter | Region | Pipeline | Closed-won | Net retention | Forecast next |
|---------|--------|----------|------------|---------------|---------------|
| Q1 2026 | EMEA   | €1.20M   | €380K      | 112%          | €1.45M        |
| Q2 2026 | AMER   | €2.05M   | €610K      | 119%          | €2.30M        |
| Q3 2026 | APAC   | €0.95M   | €240K      | 104%          | €1.10M        |
