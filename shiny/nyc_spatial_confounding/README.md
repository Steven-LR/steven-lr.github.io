# NYC Spatial Confounding (Shiny)

This Shiny app replaces the browser-only join logic with an R-native pipeline:

- Pull ACS tract-level estimates with `tidycensus::get_acs()`
- Pull tract geometries with `tigris::tracts()`
- Join by `GEOID` in R
- Render tract choropleths with `leaflet`
- Render distribution and model plots with `ggplot2`

## Variables used

- `uninsured_rate = S2701_C04_001E`
- `poverty_rate = S1701_C03_001E`
- `unemployment_rate = S2301_C04_001E`

## Run locally

```r
install.packages(c(
  "shiny","dplyr","tidyr","stringr","sf","tidycensus","tigris",
  "leaflet","ggplot2","scales","tibble"
))
shiny::runApp("shiny/nyc_spatial_confounding")
```

## Deployment note

GitHub Pages cannot run Shiny server code. Deploy this app to a Shiny host
(for example shinyapps.io or Posit Connect), then link/embed that URL from
`apps/index.md` on the static site.
