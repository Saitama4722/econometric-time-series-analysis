library(zoo)
library(xts)
library(vars)
library(urca)
library(readr)
library(ggplot2)

dir.create("plots", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)

df <- read_csv("data/macro_timeseries_clean.csv", col_types = cols(date = col_date()))
df <- df[order(df$date), ]
df <- df[, c("inflation", "unemployment", "interest_rate", "industrial_production")]

ts_data <- ts(df, start = 1, frequency = 12)

adf_inflation <- ur.df(ts_data[, "inflation"], type = "drift", selectlags = "AIC")
adf_unemployment <- ur.df(ts_data[, "unemployment"], type = "drift", selectlags = "AIC")
adf_interest_rate <- ur.df(ts_data[, "interest_rate"], type = "drift", selectlags = "AIC")
adf_industrial_production <- ur.df(ts_data[, "industrial_production"], type = "drift", selectlags = "AIC")

print("ADF test - inflation:")
print(summary(adf_inflation))
print("ADF test - unemployment:")
print(summary(adf_unemployment))
print("ADF test - interest_rate:")
print(summary(adf_interest_rate))
print("ADF test - industrial_production:")
print(summary(adf_industrial_production))

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

lag_selection <- VARselect(ts_data, lag.max = 10, type = "const")
print("VAR lag selection (AIC, HQ, SC, FPE):")
print(lag_selection)

p_opt <- as.integer(lag_selection$selection["AIC(n)"])
var_model <- VAR(ts_data, p = p_opt, type = "const")

print(summary(var_model))

n_ahead <- 24
irf_inflation <- irf(var_model, impulse = "inflation", response = colnames(ts_data), n.ahead = n_ahead)
irf_unemployment <- irf(var_model, impulse = "unemployment", response = colnames(ts_data), n.ahead = n_ahead)
irf_interest_rate <- irf(var_model, impulse = "interest_rate", response = colnames(ts_data), n.ahead = n_ahead)
irf_industrial_production <- irf(var_model, impulse = "industrial_production", response = colnames(ts_data), n.ahead = n_ahead)

irf_list <- list(
  inflation = irf_inflation,
  unemployment = irf_unemployment,
  interest_rate = irf_interest_rate,
  industrial_production = irf_industrial_production
)

for (imp_name in names(irf_list)) {
  irf_obj <- irf_list[[imp_name]]
  irf_mat <- irf_obj$irf[[imp_name]]
  h <- 0:(nrow(irf_mat) - 1)
  plot_df <- data.frame(
    horizon = rep(h, ncol(irf_mat)),
    response = rep(colnames(irf_mat), each = length(h)),
    value = as.numeric(irf_mat)
  )
  p <- ggplot(plot_df, aes(x = horizon, y = value, color = response)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    labs(x = "Horizon", y = "Response", title = paste("IRF: Shock to", imp_name)) +
    theme_minimal() +
    theme(legend.title = element_blank())
  ggsave(paste0("plots/irf_", imp_name, ".png"), plot = p, width = 8, height = 5, dpi = 100)
}

acoef_list <- Acoef(var_model)
coef_rows <- list()
for (lag_idx in seq_along(acoef_list)) {
  mat <- acoef_list[[lag_idx]]
  for (i in seq_len(nrow(mat))) {
    for (j in seq_len(ncol(mat))) {
      coef_rows[[length(coef_rows) + 1]] <- data.frame(
        Lag = lag_idx,
        Equation = rownames(mat)[i],
        Variable = colnames(mat)[j],
        Coefficient = mat[i, j]
      )
    }
  }
}
coef_df <- do.call(rbind, coef_rows)
write_csv(coef_df, "results/var_coefficients.csv")

sink("results/var_model_summary.txt", split = TRUE)
print(summary(var_model))
sink()
