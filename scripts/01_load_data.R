pkgs <- c("quantmod", "zoo", "xts", "dplyr", "tidyr", "readr", "ggplot2", "lmtest", "sandwich", "urca", "forecast", "rugarch", "vars", "FinTS", "writexl")
installed <- rownames(installed.packages())
missing <- pkgs[!pkgs %in% installed]
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}
for (p in pkgs) {
  library(p, character.only = TRUE)
}

options(timeout = 120)
dir.create("data", showWarnings = FALSE)

CACHE_FILE <- "data/macro_timeseries.csv"
FRED_SERIES <- c("CPIAUCSL", "UNRATE", "FEDFUNDS", "INDPRO")
REQUIRED_COLS <- c("date", "inflation", "unemployment", "interest_rate", "industrial_production")
MAX_RETRIES <- 3
RETRY_DELAY <- 2

download_one <- function(symbol) {
  for (attempt in seq_len(MAX_RETRIES)) {
    tryCatch({
      getSymbols(symbol, src = "FRED", env = globalenv())
      if (exists(symbol, envir = globalenv())) return(TRUE)
    }, error = function(e) NULL)
    if (attempt < MAX_RETRIES) Sys.sleep(RETRY_DELAY)
  }
  FALSE
}

all_ok <- TRUE
for (sym in FRED_SERIES) {
  if (!download_one(sym)) {
    all_ok <- FALSE
    break
  }
}

if (all_ok) {
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
  write.csv(df, CACHE_FILE, row.names = FALSE)
} else {
  if (file.exists(CACHE_FILE)) {
    cached <- tryCatch(
      readr::read_csv(CACHE_FILE, col_types = readr::cols(), n_max = 1L),
      error = function(e) NULL
    )
    if (!is.null(cached) && all(REQUIRED_COLS %in% names(cached))) {
      message("Online FRED download failed; using existing local cached dataset: ", CACHE_FILE)
    } else {
      stop("FRED download failed and ", CACHE_FILE, " is missing or invalid. Cannot continue.")
    }
  } else {
    stop("FRED download failed and ", CACHE_FILE, " does not exist. Cannot continue.")
  }
}
