dir.create("data", showWarnings = FALSE)
dir.create("plots", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)
dir.create("scripts", showWarnings = FALSE)

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

for (i in seq_along(script_list)) {
  cat("\n=== Running stage ", i, "/", length(script_list), ": ", script_list[i], " ===\n", sep = "")
  source(script_list[i])
}

cat("\n=== Full econometric analysis finished successfully. ===\n")
