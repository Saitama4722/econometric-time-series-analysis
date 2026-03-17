dir.create("data", showWarnings = FALSE)
dir.create("plots", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)
dir.create("scripts", showWarnings = FALSE)
dir.create("delivery", showWarnings = FALSE)

script_list <- c(
  "scripts/01_load_data.R",
  "scripts/02_exploratory_analysis.R",
  "scripts/03_data_preparation.R",
  "scripts/04_stat_tests.R",
  "scripts/05_ols_model.R",
  "scripts/06_arima_model.R",
  "scripts/07_garch_model.R",
  "scripts/08_var_model.R",
  "scripts/09_model_comparison.R"
)

CACHE_FILE <- "data/macro_timeseries.csv"
REQUIRED_COLS <- c("date", "inflation", "unemployment", "interest_rate", "industrial_production")

for (i in seq_along(script_list)) {
  cat("\n=== Running stage ", i, "/", length(script_list), ": ", script_list[i], " ===\n", sep = "")
  if (i == 1L) {
    load_ok <- tryCatch(
      { source(script_list[i]); TRUE },
      error = function(e) {
        if (file.exists(CACHE_FILE)) {
          probe <- tryCatch(
            readr::read_csv(CACHE_FILE, col_types = readr::cols(), n_max = 1L),
            error = function(e2) NULL
          )
          if (!is.null(probe) && all(REQUIRED_COLS %in% names(probe))) {
            message("Data load script failed; using existing cached dataset: ", CACHE_FILE)
            TRUE
          } else {
            stop(e)
          }
        } else {
          stop(e)
        }
      }
    )
    if (!load_ok) stop("Data loading failed and no valid cache available.")
  } else {
    source(script_list[i])
  }
}

clean_data <- readr::read_csv("data/macro_timeseries_clean.csv", col_types = readr::cols(date = readr::col_date()))
writexl::write_xlsx(clean_data, "delivery/macro_timeseries.xlsx")
readr::write_csv(clean_data, "delivery/macro_timeseries.csv")
access_date <- format(Sys.Date(), "%Y-%m-%d")
data_sources_lines <- c(
  "# Data Sources",
  "",
  "| Source platform | Variable code | Variable full name | Short description | Access method | Retrieval/access date |",
  "|-----------------|---------------|-------------------|-------------------|---------------|------------------------|",
  paste0("| FRED | CPIAUCSL | Consumer Price Index for All Urban Consumers: All Items in U.S. City Average | Seasonally adjusted CPI, all items | quantmod getSymbols(..., src = \"FRED\") | ", access_date, " |"),
  paste0("| FRED | UNRATE | Civilian Unemployment Rate | Seasonally adjusted monthly unemployment rate (percent) | quantmod getSymbols(..., src = \"FRED\") | ", access_date, " |"),
  paste0("| FRED | FEDFUNDS | Federal Funds Effective Rate | Monthly average effective federal funds rate (percent) | quantmod getSymbols(..., src = \"FRED\") | ", access_date, " |"),
  paste0("| FRED | INDPRO | Industrial Production Index | Seasonally adjusted index of industrial production | quantmod getSymbols(..., src = \"FRED\") | ", access_date, " |")
)
writeLines(data_sources_lines, "delivery/data_sources.md")
readme_delivery_lines <- c(
  "# Delivery Package",
  "",
  "| File | Description |",
  "|------|-------------|",
  "| macro_timeseries.xlsx | Final cleaned macroeconomic time series dataset (Excel). |",
  "| macro_timeseries.csv | Same dataset in CSV format. |",
  "| data_sources.md | Data source documentation (FRED series, codes, access). |",
  "| README_delivery.md | This file; overview of delivery contents. |"
)
writeLines(readme_delivery_lines, "delivery/README_delivery.md")

cat("\n=== Full econometric analysis finished successfully. ===\n")
cat("=== Delivery files written to delivery/ ===\n")
