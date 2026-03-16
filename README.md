# Econometric Time Series Analysis

---

## Project Overview

This repository implements a full econometric pipeline for analyzing macroeconomic time series data. The workflow covers:

- **Data loading** — Import and validation of macroeconomic series
- **Exploratory data analysis** — Summary statistics and visual inspection
- **Data preprocessing** — Transformations and preparation for modeling
- **Statistical testing** — Unit root and stationarity checks
- **Econometric modeling** — Estimation of multiple model classes
- **Model comparison** — Criteria-based selection of the preferred specification

---

## Models Used

The project implements the following econometric models:

| Model | Description |
|-------|-------------|
| **OLS regression** | Linear regression with robust standard errors |
| **ARIMA** | Univariate autoregressive integrated moving average time series model |
| **GARCH** | GARCH volatility model for conditional variance |
| **VAR** | Vector autoregression multivariate model |

---

## Project Structure

```
econometric-time-series-analysis/
├── data/
├── plots/
├── results/
├── scripts/
│   ├── 01_load_data.R
│   ├── 02_exploratory_analysis.R
│   ├── 03_data_preparation.R
│   ├── 04_stat_tests.R
│   ├── 05_ols_model.R
│   ├── 06_arima_model.R
│   ├── 07_garch_model.R
│   ├── 08_var_model.R
│   └── 09_model_comparison.R
├── run_project.R
└── README.md
```

---

## Running the Project

The entire analysis can be executed automatically from the project root in R or RStudio:

```r
source("run_project.R")
```

The pipeline runs all scripts sequentially and saves outputs to the `plots/` and `results/` directories automatically.

---

## Outputs

### `plots/`

Visualizations and diagnostics produced by the pipeline: time series plots, correlation heatmaps, residual and diagnostic plots for OLS, ARIMA, GARCH, and VAR (including impulse response functions).

### `results/`

Model summaries and statistical outputs: correlation matrices, test results, coefficient estimates, model summaries (OLS, ARIMA, GARCH, VAR), and model comparison tables.

---

# Эконометрический анализ временных рядов

---

## Обзор проекта

Репозиторий реализует полный эконометрический пайплайн для анализа макроэкономических временных рядов. В него входят:

- **Загрузка данных** — импорт и проверка макроэкономических рядов
- **Разведочный анализ** — описательная статистика и визуальный анализ
- **Предобработка данных** — преобразования и подготовка к моделированию
- **Статистическое тестирование** — проверки единичного корня и стационарности
- **Эконометрическое моделирование** — оценка нескольких классов моделей
- **Сравнение моделей** — выбор предпочтительной спецификации по критериям

---

## Используемые модели

В проекте реализованы следующие эконометрические модели:

| Модель | Описание |
|--------|----------|
| **OLS-регрессия** | Линейная регрессия с робастными стандартными ошибками |
| **ARIMA** | Унивариатная модель авторегрессии — скользящего среднего |
| **GARCH** | Модель волатильности GARCH для условной дисперсии |
| **VAR** | Векторная авторегрессия (многомерная модель) |

---

## Структура проекта

```
econometric-time-series-analysis/
├── data/
├── plots/
├── results/
├── scripts/
│   ├── 01_load_data.R
│   ├── 02_exploratory_analysis.R
│   ├── 03_data_preparation.R
│   ├── 04_stat_tests.R
│   ├── 05_ols_model.R
│   ├── 06_arima_model.R
│   ├── 07_garch_model.R
│   ├── 08_var_model.R
│   └── 09_model_comparison.R
├── run_project.R
└── README.md
```

---

## Запуск проекта

Полный анализ выполняется автоматически из корня проекта в R или RStudio:

```r
source("run_project.R")
```

Пайплайн последовательно запускает все скрипты и сохраняет результаты в каталоги `plots/` и `results/` автоматически.

---

## Результаты

### `plots/`

Визуализации и диагностики: графики временных рядов, тепловые карты корреляций, графики остатков и диагностика для OLS, ARIMA, GARCH и VAR (включая функции импульсного отклика).

### `results/`

Сводки моделей и статистические результаты: матрицы корреляций, результаты тестов, оценки коэффициентов, сводки моделей (OLS, ARIMA, GARCH, VAR) и таблицы сравнения моделей.
