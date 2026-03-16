library(zoo)
library(xts)
library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)

dir.create("plots", showWarnings = FALSE)
dir.create("results", showWarnings = FALSE)

df <- read_csv("data/macro_timeseries.csv", col_types = cols(date = col_date(format = "%Y-%m-%d")))

str(df)

desc_vars <- df %>% select(-date)
print(summary(desc_vars))

vars_ts <- c("inflation", "unemployment", "interest_rate", "industrial_production")
for (v in vars_ts) {
  p <- ggplot(df, aes(x = date, y = .data[[v]])) +
    geom_line() +
    labs(x = "Date", y = v) +
    theme_minimal()
  ggsave(file.path("plots", paste0(v, ".png")), plot = p, width = 8, height = 4, dpi = 150)
}

num_df <- df %>% select(all_of(vars_ts))
cor_mat <- cor(num_df)
cor_df <- as.data.frame(cor_mat)
cor_df <- cbind(variable = rownames(cor_df), cor_df)
rownames(cor_df) <- NULL
write_csv(cor_df, "results/correlation_matrix.csv")

cor_long <- data.frame(
  var1 = rep(rownames(cor_mat), ncol(cor_mat)),
  var2 = rep(colnames(cor_mat), each = nrow(cor_mat)),
  correlation = c(cor_mat)
)
cor_long$var1 <- factor(cor_long$var1, levels = vars_ts)
cor_long$var2 <- factor(cor_long$var2, levels = rev(vars_ts))
p_heat <- ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, limits = c(-1, 1)) +
  geom_text(aes(label = round(correlation, 2)), size = 3.5) +
  labs(x = "", y = "", fill = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("plots/correlation_heatmap.png", plot = p_heat, width = 6, height = 5, dpi = 150)
