# Econometric Time Series Analysis

---

## Project Overview

This repository implements a full econometric pipeline for analyzing macroeconomic time series data. The workflow covers:

- **Data loading** — ingestion and validation of time series datasets
- **Exploratory data analysis** — visualization and summary statistics
- **Data preprocessing** — transformation and preparation for modeling
- **Statistical testing** — diagnostics and hypothesis tests
- **Econometric modeling** — estimation of multiple model classes
- **Model comparison** — evaluation and selection of best-performing specifications

---

## Models Used

The project implements the following econometric models:

| Model | Description |
|-------|-------------|
| **OLS regression** | Ordinary Least Squares for linear relationships |
| **ARIMA** | Univariate time series model for trend and seasonality |
| **GARCH** | Volatility modeling for conditional variance |
| **VAR** | Vector Autoregression for multivariate time series |

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

The pipeline runs all scripts sequentially and saves outputs (plots and results) automatically. No manual intervention is required between stages.

---

## Outputs

| Directory | Contents |
|-----------|----------|
| **plots/** | Visualizations, diagnostic plots, and time series charts produced by the pipeline |
| **results/** | Model summaries, coefficient tables, statistical test outputs, and exported results (e.g. CSV) |

---

---

# Эконометрический анализ временных рядов

---

## Обзор проекта

Репозиторий реализует полный эконометрический пайплайн для анализа макроэкономических временных рядов. В него входят:

- **Загрузка данных** — чтение и проверка наборов временных рядов
- **Разведочный анализ** — визуализация и описательная статистика
- **Предобработка данных** — преобразование и подготовка к моделированию
- **Статистическое тестирование** — диагностика и проверка гипотез
- **Эконометрическое моделирование** — оценка нескольких классов моделей
- **Сравнение моделей** — оценка и выбор наилучших спецификаций

---

## Используемые модели

В проекте реализованы следующие эконометрические модели:

| Модель | Описание |
|--------|----------|
| **OLS-регрессия** | Метод наименьших квадратов для линейных зависимостей |
| **ARIMA** | Унивариатная модель временных рядов для тренда и сезонности |
| **GARCH** | Моделирование волатильности условной дисперсии |
| **VAR** | Векторная авторегрессия для многомерных временных рядов |

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

Полный анализ можно выполнить автоматически из корня проекта в R или RStudio:

```r
source("run_project.R")
```

Пайплайн последовательно запускает все скрипты и автоматически сохраняет результаты (графики и таблицы). Ручное вмешательство между этапами не требуется.

---

## Результаты

| Каталог | Содержимое |
|---------|------------|
| **plots/** | Визуализации, диагностические графики и графики временных рядов, созданные пайплайном |
| **results/** | Сводки моделей, таблицы коэффициентов, результаты статистических тестов и экспорт (например, CSV) |
