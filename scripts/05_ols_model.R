library(zoo)
library(xts)
library(dplyr)
library(lmtest)
library(sandwich)
library(readr)
library(ggplot2)

dir.create("results", showWarnings = FALSE)
dir.create("plots", showWarnings = FALSE)

df <- readr::read_csv("data/macro_timeseries_clean.csv", col_types = readr::cols(date = readr::col_date()))
df <- na.omit(df)

model <- stats::lm(inflation ~ unemployment + interest_rate + industrial_production, data = df)
print(summary(model))

robust_se <- lmtest::coeftest(model, vcov = sandwich::vcovHC(model, type = "HC1"))
print(robust_se)

res <- stats::residuals(model)

ggplot2::ggplot(data.frame(date = df$date, residual = res), ggplot2::aes(x = date, y = residual)) +
  ggplot2::geom_line() +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed") +
  ggplot2::labs(x = "Date", y = "Residuals", title = "Residuals over Time") +
  ggplot2::theme_minimal()
ggplot2::ggsave("plots/residuals_over_time.png", width = 8, height = 5, dpi = 150)

ggplot2::ggplot(data.frame(residual = res), ggplot2::aes(x = residual)) +
  ggplot2::geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  ggplot2::labs(x = "Residuals", y = "Count", title = "Histogram of Residuals") +
  ggplot2::theme_minimal()
ggplot2::ggsave("plots/residuals_histogram.png", width = 8, height = 5, dpi = 150)

ggplot2::ggplot(data.frame(residual = res), ggplot2::aes(sample = residual)) +
  ggplot2::stat_qq() +
  ggplot2::stat_qq_line() +
  ggplot2::labs(x = "Theoretical Quantiles", y = "Sample Quantiles", title = "QQ Plot of Residuals") +
  ggplot2::theme_minimal()
ggplot2::ggsave("plots/residuals_qq.png", width = 8, height = 5, dpi = 150)

coef_df <- as.data.frame(summary(model)$coefficients)
coef_df <- cbind(Parameter = rownames(coef_df), coef_df)
rownames(coef_df) <- NULL
readr::write_csv(coef_df, "results/ols_coefficients.csv")

sink("results/ols_model_summary.txt")
print(summary(model))
sink()
