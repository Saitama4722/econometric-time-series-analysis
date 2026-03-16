library(zoo)
library(xts)
library(dplyr)
library(tidyr)
library(readr)

df <- readr::read_csv("data/macro_timeseries.csv", col_types = readr::cols(date = readr::col_date()))

missing_counts <- colSums(is.na(df))
print("Missing values per column:")
print(missing_counts)

df <- df %>% na.omit()

numeric_cols <- names(df)[sapply(df, is.numeric)]
outlier_counts <- setNames(integer(length(numeric_cols)), numeric_cols)
for (col in numeric_cols) {
  q1 <- quantile(df[[col]], 0.25, na.rm = TRUE)
  q3 <- quantile(df[[col]], 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  outlier_counts[col] <- sum(df[[col]] < lower | df[[col]] > upper, na.rm = TRUE)
}
print("Outliers per variable (IQR method):")
print(outlier_counts)

df <- df %>%
  dplyr::mutate(
    log_inflation = log(inflation),
    log_industrial_production = log(industrial_production)
  )

numeric_to_scale <- names(df)[sapply(df, is.numeric)]
df_scaled <- df
for (col in numeric_to_scale) {
  df_scaled[[col]] <- (df_scaled[[col]] - mean(df_scaled[[col]], na.rm = TRUE)) / sd(df_scaled[[col]], na.rm = TRUE)
}

xts_data <- xts(df[, -1], order.by = df$date)

readr::write_csv(df, "data/macro_timeseries_clean.csv")
readr::write_csv(df_scaled, "data/macro_timeseries_scaled.csv")
