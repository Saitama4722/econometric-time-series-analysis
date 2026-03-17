pkgs <- c("quantmod", "zoo", "xts", "dplyr", "tidyr", "readr", "ggplot2", "lmtest", "sandwich", "urca", "forecast", "rugarch", "vars", "FinTS", "writexl")
installed <- rownames(installed.packages())
missing <- pkgs[!pkgs %in% installed]
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}
for (p in pkgs) {
  library(p, character.only = TRUE)
}

dir.create("data", showWarnings = FALSE)

getSymbols("CPIAUCSL", src = "FRED")
getSymbols("UNRATE", src = "FRED")
getSymbols("FEDFUNDS", src = "FRED")
getSymbols("INDPRO", src = "FRED")

CPIAUCSL <- to.monthly(CPIAUCSL)[, 4]
UNRATE <- to.monthly(UNRATE)[, 4]
FEDFUNDS <- to.monthly(FEDFUNDS)[, 4]
INDPRO <- to.monthly(INDPRO)[, 4]

merged <- merge(CPIAUCSL, UNRATE, FEDFUNDS, INDPRO)
df <- data.frame(
  date = index(merged),
  inflation = coredata(merged)[, 1],
  unemployment = coredata(merged)[, 2],
  interest_rate = coredata(merged)[, 3],
  industrial_production = coredata(merged)[, 4]
)
df$date <- as.Date(df$date)
df <- na.omit(df)
write.csv(df, "data/macro_timeseries.csv", row.names = FALSE)
