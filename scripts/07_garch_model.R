library(zoo)
library(xts)
library(rugarch)
library(readr)
library(ggplot2)
library(FinTS)

dir.create("plots", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)

df <- readr::read_csv("data/macro_timeseries_clean.csv", col_types = readr::cols(date = readr::col_date()))
df <- df[order(df$date), ]
inflation_xts <- xts::xts(df$inflation, order.by = df$date)

diff_inflation <- diff(inflation_xts)[, 1]
diff_inflation <- na.omit(diff_inflation)

arch_test <- FinTS::ArchTest(as.numeric(diff_inflation), lags = 12)
print(arch_test)

garch_spec <- rugarch::ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)
garch_fit <- rugarch::ugarchfit(spec = garch_spec, data = diff_inflation)

print(garch_fit)

cond_vol <- rugarch::sigma(garch_fit)
std_resid <- rugarch::residuals(garch_fit, standardize = TRUE)

cond_vol_df <- data.frame(
  date = zoo::index(diff_inflation),
  volatility = as.numeric(cond_vol)
)
ggplot2::ggplot(cond_vol_df, ggplot2::aes(x = date, y = volatility)) +
  ggplot2::geom_line() +
  ggplot2::labs(x = "Date", y = "Conditional Volatility", title = "GARCH(1,1) Conditional Volatility") +
  ggplot2::theme_minimal()
ggplot2::ggsave("plots/volatility_over_time_garch.png", width = 8, height = 5, dpi = 100)

std_resid_df <- data.frame(
  date = zoo::index(diff_inflation),
  residuals = as.numeric(std_resid)
)
ggplot2::ggplot(std_resid_df, ggplot2::aes(x = date, y = residuals)) +
  ggplot2::geom_line() +
  ggplot2::labs(x = "Date", y = "Standardized Residuals", title = "GARCH(1,1) Standardized Residuals") +
  ggplot2::theme_minimal()
ggplot2::ggsave("plots/standardized_residuals_garch.png", width = 8, height = 5, dpi = 100)

ggplot2::ggplot(cond_vol_df, ggplot2::aes(x = volatility)) +
  ggplot2::geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  ggplot2::labs(x = "Conditional Volatility", y = "Count", title = "Histogram of Conditional Volatility") +
  ggplot2::theme_minimal()
ggplot2::ggsave("plots/volatility_histogram_garch.png", width = 8, height = 5, dpi = 100)

coef_est <- coef(garch_fit)
coef_df <- data.frame(
  parameter = names(coef_est),
  estimate = as.numeric(coef_est)
)
readr::write_csv(coef_df, "results/garch_coefficients.csv")

sink("results/garch_model_summary.txt")
print(garch_fit)
sink()
