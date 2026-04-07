#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(sf)
  library(tidycensus)
  library(tigris)
  library(jsonlite)
})

`%||%` <- function(x, y) if (is.null(x)) y else x

# Run this script from repository root.
ROOT <- getwd()

template_path <- file.path(ROOT, "apps", "nyc_spatial_confounding_guide.template.html")
output_path <- file.path(ROOT, "apps", "nyc_spatial_confounding_guide.html")

message("Building single-file NYC spatial confounding app...")

census_key <- Sys.getenv("CENSUS_API_KEY", unset = "da78adf0d44806a4957cf7805559f170ba2c69e7")
year <- as.integer(Sys.getenv("NYC_ACS_YEAR", unset = "2020"))

acs_vars <- c(
  uninsured_rate = "S2701_C04_001",
  poverty_rate = "S1701_C03_001",
  unemployment_rate = "S2301_C04_001"
)

ok <- str_detect(acs_vars, "_0[0-9][0-9]$")
if (any(!ok)) {
  stop("Invalid ACS variable IDs: ", paste(names(acs_vars)[!ok], collapse = ", "))
}

county_fips <- c("005", "047", "061", "081", "085")
county_names <- c("Bronx", "Kings", "New York", "Queens", "Richmond")

# Disable global cache writes to avoid sandbox permission issues.
options(tigris_use_cache = FALSE)
Sys.setenv(TIGRIS_CACHE_DIR = file.path(ROOT, ".tigris-cache"))
sf::sf_use_s2(FALSE)
census_api_key(census_key, install = FALSE, overwrite = TRUE)

message("1) Pulling ACS data...")
acs <- tidycensus::get_acs(
  survey = "acs5",
  variables = acs_vars,
  geography = "tract",
  state = "NY",
  year = year,
  geometry = FALSE
) %>%
  rename_with(tolower) %>%
  select(-moe) %>%
  mutate(variable = recode(variable, !!!setNames(names(acs_vars), acs_vars))) %>%
  group_by(geoid, name) %>%
  pivot_wider(values_from = estimate, names_from = variable) %>%
  ungroup() %>%
  filter(substr(geoid, 1, 5) %in% paste0("36", county_fips)) %>%
  mutate(
    uninsured_rate = as.numeric(uninsured_rate),
    poverty_rate = as.numeric(poverty_rate),
    unemployment_rate = as.numeric(unemployment_rate)
  ) %>%
  filter(
    between(uninsured_rate, 0, 100),
    between(poverty_rate, 0, 100),
    between(unemployment_rate, 0, 100)
  )

if (nrow(acs) < 100) stop("Too few ACS rows returned: ", nrow(acs))

message("2) Pulling tract geometries...")
tract_sf <- tigris::tracts(
  state = "NY",
  county = county_names,
  year = year,
  class = "sf"
) %>%
  st_transform(4326) %>%
  select(GEOID, NAMELSAD, geometry)

message("3) Joining ACS + geometry...")
sf_dat <- tract_sf %>%
  left_join(acs, by = c("GEOID" = "geoid")) %>%
  filter(!is.na(uninsured_rate), !is.na(poverty_rate), !is.na(unemployment_rate))

if (nrow(sf_dat) < 100) stop("Too few joined tracts: ", nrow(sf_dat))

coords <- st_coordinates(st_centroid(sf_dat))
k <- 8L
dmat <- as.matrix(dist(coords))
nn <- apply(dmat, 1, function(v) order(v)[2:(k + 1)])

morans_i <- function(vals, nbrs) {
  n <- length(vals)
  mu <- mean(vals)
  dev <- vals - mu
  num <- 0
  w <- 0
  for (i in seq_len(n)) {
    idx <- nbrs[, i]
    num <- num + sum(dev[i] * dev[idx])
    w <- w + length(idx)
  }
  den <- sum(dev^2)
  if (den <= 0) return(0)
  (n / max(w, 1)) * (num / den)
}

fit_bundle <- function(pred_col) {
  x <- sf_dat[[pred_col]]
  y <- sf_dat$uninsured_rate
  ols <- lm(y ~ x)
  resid <- residuals(ols)
  u <- resid - mean(resid)
  for (iter in 1:5) {
    next_u <- u
    for (i in seq_along(u)) {
      idx <- nn[, i]
      next_u[i] <- 0.35 * u[i] + 0.65 * mean(u[idx], na.rm = TRUE)
    }
    u <- next_u
  }
  phi <- pmin(0.99, pmax(0.01, var(u, na.rm = TRUE) / var(resid, na.rm = TRUE)))
  bym <- lm((y - 0.65 * u) ~ x)
  list(
    resid = resid,
    spatial = u,
    ols_slope = unname(coef(ols)[["x"]]),
    ols_r2 = summary(ols)$r.squared,
    resid_moran = morans_i(resid, nn),
    bym_slope = unname(coef(bym)[["x"]]),
    phi = as.numeric(phi)
  )
}

message("4) Fitting models...")
pov <- fit_bundle("poverty_rate")
une <- fit_bundle("unemployment_rate")

sf_dat <- sf_dat %>%
  mutate(
    resid_poverty = pov$resid,
    resid_unemployment = une$resid,
    spatial_poverty = pov$spatial,
    spatial_unemployment = une$spatial
  )

message("5) Creating embedded JSON payload...")
tmp_geojson <- tempfile(fileext = ".geojson")
sf::st_write(sf_dat, dsn = tmp_geojson, driver = "GeoJSON", quiet = TRUE, delete_dsn = TRUE)
geojson_obj <- jsonlite::fromJSON(tmp_geojson, simplifyVector = FALSE)

# keep only fields needed in browser
keep_props <- c(
  "GEOID", "NAMELSAD",
  "uninsured_rate", "poverty_rate", "unemployment_rate",
  "resid_poverty", "resid_unemployment",
  "spatial_poverty", "spatial_unemployment"
)
for (i in seq_along(geojson_obj$features)) {
  p <- geojson_obj$features[[i]]$properties
  p2 <- p[intersect(names(p), keep_props)]
  names(p2)[names(p2) == "NAMELSAD"] <- "namelsad"
  names(p2)[names(p2) == "GEOID"] <- "geoid"
  geojson_obj$features[[i]]$properties <- p2
}

payload <- list(
  meta = list(
    year = year,
    generated_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    n_tracts = nrow(sf_dat)
  ),
  summaries = list(
    uninsured_median = as.numeric(median(sf_dat$uninsured_rate, na.rm = TRUE)),
    uninsured_moran = as.numeric(morans_i(sf_dat$uninsured_rate, nn)),
    predictors = list(
      poverty = list(
        ols_slope = as.numeric(pov$ols_slope),
        ols_r2 = as.numeric(pov$ols_r2),
        resid_moran = as.numeric(pov$resid_moran),
        bym_slope = as.numeric(pov$bym_slope),
        phi = as.numeric(pov$phi)
      ),
      unemployment = list(
        ols_slope = as.numeric(une$ols_slope),
        ols_r2 = as.numeric(une$ols_r2),
        resid_moran = as.numeric(une$resid_moran),
        bym_slope = as.numeric(une$bym_slope),
        phi = as.numeric(une$phi)
      )
    )
  ),
  geojson = geojson_obj
)

json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE, null = "null", digits = 6)
template <- paste(readLines(template_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
html <- sub("__PRECOMPUTED_JSON__", json_payload, template, fixed = TRUE)
writeLines(html, output_path, useBytes = TRUE)

message("Done: ", output_path)
