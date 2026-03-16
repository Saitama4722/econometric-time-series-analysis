library(zoo)
library(xts)
library(forecast)
library(readr)
library(ggplot2)

dir.create("plots", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)

df <- readr::read_csv("data/macro_timeseries_clean.csv", col_types = readr::cols(date = readr::col_date()))
df <- df[order(df$date), ]
inflation_ts <- xts(df$inflation, order.by = df$date)
inflation_ts <- as.ts(inflation_ts)

png("plots/acf_inflation.png", width = 600, height = 400, res = 100)
forecast::Acf(inflation_ts, main = "ACF of Inflation")
dev.off()

png("plots/pacf_inflation.png", width = 600, height = 400, res = 100)
forecast::Pacf(inflation_ts, main = "PACF of Inflation")
dev.off()

arima_fit <- forecast::auto.arima(inflation_ts)
print(summary(arima_fit))

resid_arima <- stats::residuals(arima_fit)

png("plots/residuals_over_time_arima.png", width = 600, height = 400, res = 100)
plot(resid_arima, type = "l", xlab = "Time", ylab = "Residuals", main = "ARIMA Residuals Over Time")
dev.off()

png("plots/residuals_histogram_arima.png", width = 600, height = 400, res = 100)
hist(resid_arima, breaks = 30, main = "ARIMA Residuals Histogram", xlab = "Residuals")
dev.off()

png("plots/residuals_qq_arima.png", width = 600, height = 400, res = 100)
qqnorm(resid_arima, main = "Q-Q Plot of ARIMA Residuals")
qqline(resid_arima)
dev.off()

coef_df <- data.frame(
  parameter = names(coef(arima_fit)),
  value = as.numeric(coef(arima_fit))
)
readr::write_csv(coef_df, "results/arima_coefficients.csv")

sink("results/arima_model_summary.txt")
print(summary(arima_fit))
sink()
