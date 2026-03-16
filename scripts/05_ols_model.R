library(zoo)
library(xts)
library(dplyr)
library(lmtest)
library(sandwich)
library(readr)
library(ggplot2)

dir.create("results", showWarnings = FALSE)
dir.create("plots", showWarnings = FALSE)

df <- read_csv("data/macro_timeseries_clean.csv", col_types = cols(date = col_date()))
df <- na.omit(df)

model <- lm(inflation ~ unemployment + interest_rate + industrial_production, data = df)
print(summary(model))

robust_se <- coeftest(model, vcov = vcovHC(model, type = "HC1"))
print(robust_se)

res <- residuals(model)

ggplot(data.frame(date = df$date, residual = res), aes(x = date, y = residual)) +
  geom_line() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(x = "Date", y = "Residuals", title = "Residuals over Time") +
  theme_minimal()
ggsave("plots/residuals_over_time.png", width = 8, height = 5, dpi = 150)

ggplot(data.frame(residual = res), aes(x = residual)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(x = "Residuals", y = "Count", title = "Histogram of Residuals") +
  theme_minimal()
ggsave("plots/residuals_histogram.png", width = 8, height = 5, dpi = 150)

ggplot(data.frame(residual = res), aes(sample = residual)) +
  stat_qq() +
  stat_qq_line() +
  labs(x = "Theoretical Quantiles", y = "Sample Quantiles", title = "QQ Plot of Residuals") +
  theme_minimal()
ggsave("plots/residuals_qq.png", width = 8, height = 5, dpi = 150)

coef_df <- as.data.frame(summary(model)$coefficients)
coef_df <- cbind(Parameter = rownames(coef_df), coef_df)
rownames(coef_df) <- NULL
write_csv(coef_df, "results/ols_coefficients.csv")

sink("results/ols_model_summary.txt")
print(summary(model))
sink()
