---
layout: default
title: Home
show_title: false
---

<section id="about" class="home-section">
  <div class="hero-grid">
    <div class="profile-card">
      <img src="{{ '/assets/img/steven-lawrence-headshot.jpg' | relative_url }}" alt="Steven Lawrence headshot" />
      <div class="profile-name">Steven Lawrence</div>
      <div class="profile-role">Doctoral Candidate</div>
      <div class="profile-org">NYU Grossman School of Medicine</div>
      <div class="social-links">
        <a href="mailto:steven.lawrence@nyulangone.org" aria-label="Email">Email</a>
        <a href="https://www.linkedin.com/in/steven-lawrence-bio-math/" aria-label="LinkedIn">in</a>
        <a href="https://github.com/Steven-LR" aria-label="GitHub">GH</a>
        <a href="https://scholar.google.com/citations?user=OmOghxUAAAAJ&hl=en" aria-label="Google Scholar">GS</a>
      </div>
    </div>

    <div>
      <h2>Biography</h2>
      <p class="lead">Biostatistician and PhD candidate with 7+ years of experience delivering statistical strategy for clinical research and applied analytics. Expertise in Bayesian/spatial modeling, longitudinal and time-to-event analysis, and geospatial analytics; translate complex data into decision-ready results for clinicians, executives, and program stakeholders. CRAN author and maintainer of <em>tidyRHRV</em>.</p>

      <div class="section-grid">
        <div class="list-card">
          <h3>Interests</h3>
          <ul>
            <li>Spatial Modeling</li>
            <li>Translational Research</li>
            <li>Geospatial and spatio-temporal Analytics</li>
            <li>Health Care Impact</li>
          </ul>
        </div>

        <div class="list-card">
          <h3>Education</h3>
          <ul>
            <li>PhD, Biostatistics, New York University, expected May 2026</li>
            <li>MS, Biostatistics, Columbia University, May 2021</li>
            <li>BS, Biology (Math Minor), CUNY Medgar Evers College, Jun 2019</li>
          </ul>
        </div>
      </div>

      <div class="card">
        <p><strong>Resume:</strong> <a href="{{ '/resume/' | relative_url }}">View resume page</a> or <a href="{{ '/assets/Steven_Lawrence_Resume_2026-02-24.pdf' | relative_url }}">download PDF</a>.</p>
        <p><strong>CV:</strong> <a href="{{ '/cv/' | relative_url }}">View CV (2025)</a>.</p>
      </div>
    </div>
  </div>
</section>

<section id="manuscripts" class="home-section">
  <h2>Selected Manuscripts</h2>
  <div class="manuscript-list">
    <div class="manuscript-item">
      <div class="manuscript-item__title"><a href="https://www.jns-journal.com/article/S0022-510X(21)01556-2/fulltext">High-throughput cleaning of raw ECG data</a></div>
      <div class="item-meta">J Neurol Sci, 2021</div>
      <div>Lawrence S, Robinson-Papp J, Kwon P.</div>
    </div>
    <div class="manuscript-item">
      <div class="manuscript-item__title"><a href="https://www.jns-journal.com/article/S0022-510X(21)01558-6/fulltext">Phenotyping autonomic neuropathy using principal component analysis</a></div>
      <div class="item-meta">Auton Neurosci, 2023</div>
      <div>Lawrence S, Mueller BR, Kwon P, Robinson-Papp J.</div>
    </div>
    <div class="manuscript-item">
      <div class="manuscript-item__title"><a href="https://journals.lww.com/painrpts/fulltext/2022/06000/disparities_in_telehealth_utilization_in_patients.6.aspx">Disparities in telehealth utilization in patients with pain during COVID-19</a></div>
      <div class="item-meta">Pain Reports, 2022</div>
      <div>Mueller BR, Lawrence S, Benn E, et al.</div>
    </div>
    <div class="manuscript-item">
      <div class="manuscript-item__title">ML prediction of medication adherence in heart failure</div>
      <div class="item-meta">JAMIA, 2025</div>
      <div>Adhikari S, Stokes T, Li X, Zhao Y, Lawrence S, et al.</div>
    </div>
  </div>
</section>

<section id="projects" class="home-section">
  <h2>Projects</h2>
  <div class="project-list">
    <div class="project-item">
      <div class="project-item__title">HIPAA-compliant proximity metrics protocol</div>
      <p>Designed a HIPAA-compliant protocol for allowing protected patient information to be used to calculate proximity metrics directly within an internal system, keeping identifiable data inside the secure environment.</p>
      <p><a href="{{ '/assets/slides/HPC_protocol.pdf' | relative_url }}">View slides (PDF)</a></p>
    </div>
    <div class="project-item">
      <div class="project-item__title">American Statistical Association - This Is Statistics Data Challenge</div>
      <div class="item-meta">2019</div>
      <p>Created visuals showing the association of opioid abuse and poverty statewide using CDC Multiple Death Causes data and U.S. Census data.</p>
      <ul>
        <li>Mentor: Emma Benn, DrPH</li>
        <li>Skills: Literature review, univariate and bivariate analysis, <code>choropleth</code>, <code>ggplot2</code>, <code>usmap</code></li>
      </ul>
    </div>
    <div class="project-item">
      <div class="project-item__title">tidyrhrv</div>
      <p><em>tidyrhrv</em> is an R package for reading, iteratively filtering, and analyzing the time component of multiple heart rate variability datasets at once, supporting reproducible HRV processing and autonomic phenotyping analyses.</p>
      <p><a href="https://github.com/steven-lr/tidyrhrv">Repository</a> | <a href="https://www.jns-journal.com/article/S0022-510X(21)01556-2/fulltext">Associated paper</a> | <a href="https://www.jns-journal.com/article/S0022-510X(21)01558-6/fulltext">Related paper</a></p>
    </div>
  </div>
</section>

<section id="teaching" class="home-section">
  <h2>Teaching Opportunities</h2>
  <div class="teaching-list">
    <div class="teaching-item">
      <div class="teaching-item__title">Teaching Assistantships</div>
      <ul>
        <li>TA, Clinical Trials course, Spring 2024</li>
        <li>TA, Adjoint RStudio, 2023</li>
        <li>TA, RStudio Conference with Rob Hyndman, 2020</li>
        <li>Teaching Assistant, NHGRI-funded Clinical Research Education in Genome Science (CRIEGS) short course, 2020</li>
      </ul>
    </div>
    <div class="teaching-item">
      <div class="teaching-item__title">R Workshop Using Publicly Available Data, Hampton University, 2024</div>
      <ul>
        <li>Workshop I: Data sourcing and wrangling</li>
        <li>Workshop II: Exploratory data analysis</li>
        <li>Workshop III: Interactive team science-based real world applications of data wrangling and EDA techniques</li>
        <li>Workshop IV: Advanced topics in statistical analysis and programming informed by participant interests</li>
      </ul>
      <p><a href="https://sl-itw.github.io/HU-Workshop/Hampton-Workshop%20(1).html#Day_1:_Afternoon">Follow-along workshop site</a> | <a href="{{ '/assets/slides/Presentation3_day2.pdf' | relative_url }}">Day 2 slide deck</a></p>
    </div>
  </div>
</section>

