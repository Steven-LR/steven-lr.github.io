---
layout: default
title: 
---

<section class="home-section">
  <p class="lead">Small interactive tools and visualizations. They are meant to be slightly technical and fun. The goal is to provide a means to learn about how similarities in near by areas induce a spatial structure that can be informative when observing diseas or other ecological variables on a map</p>

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
      <a class="app-preview" href="{{ '/apps/nyc_spatial_confounding_guide.html' | relative_url }}" aria-label="Open Spatial Confounding in NYC Health Data (single-file app)">
        <img
          src="{{ '/assets/img/nyc-confounding-preview.png' | relative_url }}"
          alt="Preview of the NYC Spatial Confounding app: tract choropleths, model diagnostics, and coefficient comparison"
          width="1400"
          height="850"
          loading="lazy"
          decoding="async"
        />
      </a>
      <p class="app-preview__caption">Preview — click below to open the single-file precomputed app.</p>
      <div class="project-item__title"><a href="{{ '/apps/nyc_spatial_confounding_guide.html' | relative_url }}">Spatial Confounding in NYC Health Data</a></div>
      <p>Single-file app with precomputed ACS + tract geometry joins from R (<code>tidycensus</code> + <code>tigris</code>), rendered with Leaflet choropleths and in-browser diagnostics.</p>
      <p><a href="{{ '/apps/nyc_spatial_confounding_guide.html' | relative_url }}">Open app</a></p>
    </div>
  </div>
</section>
