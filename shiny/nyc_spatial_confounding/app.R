library(shiny)
library(dplyr)
library(tidyr)
library(stringr)
library(sf)
library(tidycensus)
library(tigris)
library(leaflet)
library(ggplot2)
library(scales)

options(tigris_use_cache = TRUE)
sf::sf_use_s2(FALSE)

CENSUS_KEY <- "da78adf0d44806a4957cf7805559f170ba2c69e7"
NYC_COUNTY_FIPS <- c("005", "047", "061", "081", "085")
NYC_COUNTY_NAMES <- c("Bronx", "Kings", "New York", "Queens", "Richmond")

# Subject-table variables requested by user
ACS_VARS <- c(
  uninsured_rate = "S2701_C04_001E",
  poverty_rate = "S1701_C03_001E",
  unemployment_rate = "S2301_C04_001E"
)

acs_var_ok <- str_detect(ACS_VARS, "_0[0-9][0-9]E$")
if (any(!acs_var_ok)) {
  stop(
    "Review ACS variable IDs: ",
    paste(names(ACS_VARS)[!acs_var_ok], collapse = ", ")
  )
}

fetch_acs <- function(year = 2020, key = CENSUS_KEY) {
  census_api_key(key, install = FALSE, overwrite = TRUE)

  tidycensus::get_acs(
    survey = "acs5",
    variables = ACS_VARS,
    geography = "tract",
    state = "NY",
    year = year,
    geometry = FALSE
  ) %>%
    rename_with(tolower) %>%
    select(-moe) %>%
    group_by(geoid, name) %>%
    pivot_wider(values_from = estimate, names_from = variable) %>%
    ungroup() %>%
    filter(substr(geoid, 1, 5) %in% paste0("36", NYC_COUNTY_FIPS)) %>%
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
}

fetch_tract_shapes <- function(year = 2020) {
  tigris::tracts(
    state = "NY",
    county = NYC_COUNTY_NAMES,
    year = year,
    class = "sf"
  ) %>%
    st_transform(4326) %>%
    select(GEOID, NAMELSAD, geometry)
}

fit_models <- function(sf_dat, predictor_col = "poverty_rate", y_col = "uninsured_rate") {
  pts <- st_centroid(sf_dat) %>% st_coordinates()
  dat <- sf_dat %>% st_drop_geometry()

  dat <- dat %>%
    mutate(
      x = .data[[predictor_col]],
      y = .data[[y_col]]
    )

  ols <- lm(y ~ x, data = dat)
  dat$residual_ols <- residuals(ols)

  # Spatial smoothing proxy for structured component
  # Uses 8-nearest centroid neighbors and iterative averaging.
  dmat <- as.matrix(dist(pts))
  nn <- apply(dmat, 1, function(v) order(v)[2:9])
  u <- dat$residual_ols
  for (iter in seq_len(5)) {
    u_next <- u
    for (i in seq_along(u)) {
      nbr_i <- nn[, i]
      u_next[i] <- 0.35 * u[i] + 0.65 * mean(u[nbr_i], na.rm = TRUE)
    }
    u <- u_next
  }
  dat$spatial_effect <- u
  dat$phi <- pmin(0.95, pmax(0.2, var(u, na.rm = TRUE) / var(dat$residual_ols, na.rm = TRUE)))

  bym <- lm((y - 0.65 * spatial_effect) ~ x, data = dat)

  sf_dat %>%
    mutate(
      predictor = dat$x,
      outcome = dat$y,
      residual_ols = dat$residual_ols,
      spatial_effect = dat$spatial_effect
    ) %>%
    st_as_sf() %>%
    structure(
      ols = ols,
      bym = bym,
      phi = unique(dat$phi)[1]
    )
}

pal_for <- function(x, domain = NULL, diverging = FALSE) {
  if (is.null(domain)) domain <- range(x, na.rm = TRUE)
  if (diverging) {
    leaflet::colorNumeric(
      palette = c("#1a3a6e", "#2f66d8", "#38c9a0", "#f0a04b", "#e05c6a"),
      domain = domain
    )
  } else {
    leaflet::colorNumeric(
      palette = c("#1a3a6e", "#2f66d8", "#38c9a0", "#f0a04b", "#e05c6a"),
      domain = domain
    )
  }
}

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background: #0e1117; color: #e2e8f4; }
      .well, .panel { background: #161b25; border-color: #2a3347; color: #e2e8f4; }
      .form-control, .btn-default { background: #1c2333; color: #e2e8f4; border-color: #2a3347; }
      .leaflet-container { background: #0e1117; }
      .metric { font-size: 15px; margin: 6px 0; }
      .small-note { color: #7a8aaa; }
    "))
  ),
  titlePanel("Spatial Confounding in NYC Health Data (Shiny)"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("year", "ACS/TIGER Year", choices = 2019:2023, selected = 2020),
      selectInput(
        "predictor",
        "Predictor",
        choices = c("poverty_rate" = "poverty_rate", "unemployment_rate" = "unemployment_rate"),
        selected = "poverty_rate"
      ),
      actionButton("reload", "Reload Data"),
      tags$hr(),
      uiOutput("metrics"),
      tags$p(class = "small-note", "Data source: tidycensus + tigris; joined by tract GEOID.")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Act 1: Uninsured map",
          br(),
          leafletOutput("map_uninsured", height = 480),
          br(),
          plotOutput("hist_uninsured", height = 280)
        ),
        tabPanel(
          "Act 2: Naive model",
          br(),
          fluidRow(
            column(6, plotOutput("scatter_ols", height = 320)),
            column(6, leafletOutput("map_residual", height = 320))
          )
        ),
        tabPanel(
          "Act 3: Spatial adjustment",
          br(),
          fluidRow(
            column(6, leafletOutput("map_spatial", height = 320)),
            column(6, plotOutput("coef_compare", height = 320))
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Loads ACS + geometries — only re-runs on Reload button
  raw_data <- eventReactive(input$reload, {
    withProgress(message = "Loading ACS + TIGER data", value = 0, {
      incProgress(0.2, detail = "Fetching ACS")
      acs <- fetch_acs(year = as.integer(input$year), key = CENSUS_KEY)

      incProgress(0.4, detail = "Fetching tract geometries")
      tracts_sf <- fetch_tract_shapes(year = as.integer(input$year))

      incProgress(0.6, detail = "Joining")
      sf_dat <- tracts_sf %>%
        left_join(acs, by = c("GEOID" = "geoid")) %>%
        filter(!is.na(uninsured_rate), !is.na(poverty_rate), !is.na(unemployment_rate))

      incProgress(1)
      list(sf_dat = sf_dat)
    })
  }, ignoreNULL = FALSE)

  # Fits models — re-runs whenever predictor changes OR new data is loaded
  data_bundle <- reactive({
    rd <- raw_data()
    modeled <- fit_models(rd$sf_dat, predictor_col = input$predictor, y_col = "uninsured_rate")
    list(sf = modeled)
  })

  output$metrics <- renderUI({
    sf_dat <- data_bundle()$sf
    ols <- attr(sf_dat, "ols")
    bym <- attr(sf_dat, "bym")
    phi <- attr(sf_dat, "phi")
    slope_ols <- coef(ols)[["x"]]
    slope_bym <- coef(bym)[["x"]]
    tagList(
      div(class = "metric", sprintf("Tracts loaded: %s", scales::comma(nrow(sf_dat)))),
      div(class = "metric", sprintf("Median uninsured: %.1f%%", median(sf_dat$uninsured_rate, na.rm = TRUE))),
      div(class = "metric", sprintf("OLS slope: %.3f", slope_ols)),
      div(class = "metric", sprintf("Spatial-adjusted slope: %.3f", slope_bym)),
      div(class = "metric", sprintf("Structured share (phi): %.1f%%", 100 * phi))
    )
  })

  output$map_uninsured <- renderLeaflet({
    sf_dat <- data_bundle()$sf
    pal <- pal_for(sf_dat$uninsured_rate)
    leaflet(sf_dat) %>%
      addProviderTiles("CartoDB.DarkMatterNoLabels") %>%
      addPolygons(
        fillColor = ~pal(uninsured_rate),
        fillOpacity = 0.85,
        color = "#1e2a3c",
        weight = 0.5,
        popup = ~sprintf("%s<br/>Uninsured: %.1f%%", NAMELSAD, uninsured_rate)
      ) %>%
      addLegend("bottomright", pal = pal, values = ~uninsured_rate, title = "Uninsured (%)")
  })

  output$hist_uninsured <- renderPlot({
    sf_dat <- data_bundle()$sf %>% st_drop_geometry()
    ggplot(sf_dat, aes(x = uninsured_rate)) +
      geom_histogram(bins = 24, fill = "#4f8ef7", color = "#0e1117") +
      theme_minimal(base_size = 13) +
      labs(x = "Uninsured rate (%)", y = "Tracts", title = "Distribution of uninsured rates") +
      theme(
        panel.background = element_rect(fill = "#0e1117", color = NA),
        plot.background = element_rect(fill = "#0e1117", color = NA),
        text = element_text(color = "#e2e8f4"),
        axis.text = element_text(color = "#e2e8f4")
      )
  })

  output$scatter_ols <- renderPlot({
    sf_dat <- data_bundle()$sf %>% st_drop_geometry()
    pred_label <- switch(input$predictor,
      poverty_rate     = "Poverty Rate (%)",
      unemployment_rate = "Unemployment Rate (%)",
      input$predictor
    )
    ggplot(sf_dat, aes(x = predictor, y = outcome)) +
      geom_point(aes(color = "Census Tract"), alpha = 0.5) +
      geom_smooth(aes(color = "OLS Fit"), method = "lm", se = FALSE, linewidth = 1.2) +
      scale_color_manual(
        name = NULL,
        values = c("Census Tract" = "#7fb3ff", "OLS Fit" = "#e05c6a")
      ) +
      theme_minimal(base_size = 13) +
      labs(
        x = pred_label,
        y = "Uninsured Rate (%)",
        title = "Naive OLS relationship"
      ) +
      theme(
        panel.background = element_rect(fill = "#0e1117", color = NA),
        plot.background = element_rect(fill = "#0e1117", color = NA),
        text = element_text(color = "#e2e8f4"),
        axis.text = element_text(color = "#e2e8f4"),
        legend.position = "top",
        legend.background = element_rect(fill = "#161b25", color = NA),
        legend.key = element_rect(fill = "#0e1117", color = NA)
      )
  })

  output$map_residual <- renderLeaflet({
    sf_dat <- data_bundle()$sf
    lim <- max(abs(sf_dat$residual_ols), na.rm = TRUE)
    pal <- pal_for(sf_dat$residual_ols, domain = c(-lim, lim), diverging = TRUE)
    leaflet(sf_dat) %>%
      addProviderTiles("CartoDB.DarkMatterNoLabels") %>%
      addPolygons(
        fillColor = ~pal(residual_ols),
        fillOpacity = 0.85,
        color = "#1e2a3c",
        weight = 0.5,
        popup = ~sprintf("%s<br/>Residual: %.2f", NAMELSAD, residual_ols)
      ) %>%
      addLegend("bottomright", pal = pal, values = ~residual_ols, title = "OLS residual")
  })

  output$map_spatial <- renderLeaflet({
    sf_dat <- data_bundle()$sf
    lim <- max(abs(sf_dat$spatial_effect), na.rm = TRUE)
    pal <- pal_for(sf_dat$spatial_effect, domain = c(-lim, lim), diverging = TRUE)
    leaflet(sf_dat) %>%
      addProviderTiles("CartoDB.DarkMatterNoLabels") %>%
      addPolygons(
        fillColor = ~pal(spatial_effect),
        fillOpacity = 0.85,
        color = "#1e2a3c",
        weight = 0.5,
        popup = ~sprintf("%s<br/>Spatial effect: %.2f", NAMELSAD, spatial_effect)
      ) %>%
      addLegend("bottomright", pal = pal, values = ~spatial_effect, title = "Structured effect")
  })

  output$coef_compare <- renderPlot({
    sf_dat <- data_bundle()$sf
    ols <- attr(sf_dat, "ols")
    bym <- attr(sf_dat, "bym")
    phi <- attr(sf_dat, "phi")

    plot_dat <- tibble::tibble(
      model = c("Naive OLS", "Spatial-adjusted"),
      coef = c(unname(coef(ols)[["x"]]), unname(coef(bym)[["x"]]))
    )

    ggplot(plot_dat, aes(x = model, y = coef, fill = model)) +
      geom_col(width = 0.55) +
      geom_hline(yintercept = 0, color = "#7a8aaa", linewidth = 0.4) +
      annotate(
        "text", x = 1.5, y = max(abs(plot_dat$coef)) * 0.9,
        label = sprintf("\u03c6 = %.2f (structured share)", phi),
        color = "#e2e8f4", size = 3.8
      ) +
      scale_fill_manual(
        name = "Model",
        values = c("Naive OLS" = "#e05c6a", "Spatial-adjusted" = "#4f8ef7")
      ) +
      theme_minimal(base_size = 13) +
      theme(
        legend.position = "top",
        legend.background = element_rect(fill = "#161b25", color = NA),
        legend.key = element_rect(fill = "#0e1117", color = NA),
        panel.background = element_rect(fill = "#0e1117", color = NA),
        plot.background = element_rect(fill = "#0e1117", color = NA),
        text = element_text(color = "#e2e8f4"),
        axis.text = element_text(color = "#e2e8f4")
      ) +
      labs(
        title = "Coefficient comparison",
        x = "Model",
        y = "Slope (predictor coefficient)"
      )
  })
}

shinyApp(ui, server)
