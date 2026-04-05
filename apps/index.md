---
layout: default
title: 
---

<section class="home-section">
  <p class="lead">Small interactive tools and visualizations.</p>

  <div class="project-list">
    <div class="project-item">
      <a class="app-preview" href="{{ '/apps/bym2_explorer.html' | relative_url }}" aria-label="Open BYM2 Spatial Explorer (preview image links to app)">
        <img
          src="{{ '/assets/img/bym2-explorer-preview.png' | relative_url }}"
          alt="Preview of the BYM2 Spatial Explorer: dark UI with map, controls, and Moran scatter plot"
          width="1400"
          height="850"
          loading="lazy"
          decoding="async"
        />
      </a>
      <p class="app-preview__caption">Preview — click the image or link below to open the live app.</p>
      <div class="project-item__title"><a href="{{ '/apps/bym2_explorer.html' | relative_url }}">BYM2 Spatial Explorer</a></div>
      <p>Explore Poisson BYM2 spatial models with ICAR structure, Moran's I diagnostics, LISA clusters, and distributional histograms in the browser.</p>
      <p><a href="{{ '/apps/bym2_explorer.html' | relative_url }}">Open app</a></p>
    </div>

    <div class="project-item">
      <a class="app-preview" href="{{ '/apps/nyc_spatial_confounding_guide.html' | relative_url }}" aria-label="Open Spatial Confounding in NYC Health Data (preview image links to app)">
        <img
          src="{{ '/assets/img/nyc-confounding-preview.png' | relative_url }}"
          alt="Preview of the NYC Spatial Confounding Guide: dark UI with three-act narrative, census tract maps, and BYM2 coefficient comparison"
          width="1400"
          height="850"
          loading="lazy"
          decoding="async"
        />
      </a>
      <p class="app-preview__caption">Preview — click the image or link below to open the live app. Loads live 2019 ACS data from the Census API.</p>
      <div class="project-item__title"><a href="{{ '/apps/nyc_spatial_confounding_guide.html' | relative_url }}">Spatial Confounding in NYC Health Data</a></div>
      <p>A three-act interactive guide to spatial confounding using 2019 ACS census-tract data for NYC. Walks through the naive OLS, residual clustering, and BYM2 spatial adjustment — side by side.</p>
      <p><a href="{{ '/apps/nyc_spatial_confounding_guide.html' | relative_url }}">Open app</a></p>
    </div>
  </div>
</section>
