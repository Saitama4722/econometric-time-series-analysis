library(zoo)
library(xts)
library(forecast)
library(rugarch)
library(vars)
library(urca)
library(readr)
library(dplyr)

dir.create("results", showWarnings = FALSE)

df <- readr::read_csv("data/macro_timeseries_clean.csv", col_types = readr::cols(date = readr::col_date()))
df <- na.omit(df)
df <- df[order(df$date), ]

ols_model <- stats::lm(inflation ~ unemployment + interest_rate + industrial_production, data = df)
ols_aic <- stats::AIC(ols_model)
ols_bic <- stats::BIC(ols_model)

inflation_ts <- xts(df$inflation, order.by = df$date)
inflation_ts <- as.ts(inflation_ts)
arima_fit <- forecast::auto.arima(inflation_ts)
arima_aic <- stats::AIC(arima_fit)
arima_bic <- stats::BIC(arima_fit)

inflation_xts <- xts(df$inflation, order.by = df$date)
diff_inflation <- diff(inflation_xts)[, 1]
diff_inflation <- na.omit(diff_inflation)
garch_spec <- rugarch::ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)
garch_fit <- rugarch::ugarchfit(spec = garch_spec, data = diff_inflation)
garch_ics <- rugarch::infocriteria(garch_fit)
garch_aic <- garch_ics[1]
garch_bic <- garch_ics[2]

df_var <- df[, c("inflation", "unemployment", "interest_rate", "industrial_production")]
ts_data <- ts(df_var, start = 1, frequency = 12)
adf_inflation <- urca::ur.df(ts_data[, "inflation"], type = "drift", selectlags = "AIC")
adf_unemployment <- urca::ur.df(ts_data[, "unemployment"], type = "drift", selectlags = "AIC")
adf_interest_rate <- urca::ur.df(ts_data[, "interest_rate"], type = "drift", selectlags = "AIC")
adf_industrial_production <- urca::ur.df(ts_data[, "industrial_production"], type = "drift", selectlags = "AIC")
adf_stats <- c(
  adf_inflation@teststat[1],
  adf_unemployment@teststat[1],
  adf_interest_rate@teststat[1],
  adf_industrial_production@teststat[1]
)
adf_crits <- adf_inflation@cval[1, 1]
need_diff <- any(adf_stats > adf_crits)
if (need_diff) {
  ts_data <- diff(ts_data)
  ts_data <- na.omit(ts_data)
}
lag_selection <- vars::VARselect(ts_data, lag.max = 10, type = "const")
p_opt <- as.integer(lag_selection$selection["AIC(n)"])
var_model <- vars::VAR(ts_data, p = p_opt, type = "const")
var_aic <- stats::AIC(var_model)
var_bic <- stats::BIC(var_model)

comparison_df <- data.frame(
  Model = c("OLS", "ARIMA", "GARCH", "VAR"),
  AIC = c(ols_aic, arima_aic, garch_aic, var_aic),
  BIC = c(ols_bic, arima_bic, garch_bic, var_bic)
)

best_aic_model <- comparison_df$Model[which.min(comparison_df$AIC)]
best_bic_model <- comparison_df$Model[which.min(comparison_df$BIC)]

print(comparison_df)

readr::write_csv(comparison_df, "results/model_comparison.csv")

report_lines <- c(
  "Model comparison (information criteria).",
  paste("Best model by AIC:", best_aic_model),
  paste("Best model by BIC:", best_bic_model)
)
writeLines(report_lines, "results/best_model.txt")
