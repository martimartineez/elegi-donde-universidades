(function () {
  "use strict";

  const areas = [
    {
      key: "Ciencias aplicadas",
      title: "Aplicadas y tecnología",
      icon: "⌘",
      color: "#668b5b",
      pale: "#ebf1e5",
      subareas: [
        "Arquitectura y diseño", "Astronomía", "Bioquímica y farmacia", "Ciencias agropecuarias",
        "Ciencias del suelo", "Estadística", "Industrias", "Informática", "Ingeniería",
        "Meteorología", "Otras ciencias aplicadas"
      ]
    },
    {
      key: "Ciencias básicas",
      title: "Exactas y naturales",
      icon: "⌬",
      color: "#7587a8",
      pale: "#edf0f7",
      subareas: ["Biología", "Física", "Matemática", "Química"]
    },
    {
      key: "Ciencias de la salud",
      title: "Salud y ciencias médicas",
      icon: "＋",
      color: "#b77e73",
      pale: "#f7ece8",
      subareas: [
        "Medicina", "Odontología", "Paramédicas y auxiliares", "Salud pública", "Sanidad", "Veterinaria"
      ]
    },
    {
      key: "Ciencias humanas",
      title: "Humanidades, educación y artes",
      icon: "◌",
      color: "#a284b0",
      pale: "#f2edf5",
      subareas: [
        "Arqueología", "Artes", "Educación", "Filosofía", "Historia", "Letras e idiomas", "Psicología", "Teología"
      ]
    },
    {
      key: "Ciencias sociales",
      title: "Sociales, derecho y economía",
      icon: "◎",
      color: "#ba9255",
      pale: "#f6f0e5",
      subareas: [
        "Ciencias políticas y relaciones", "Demografía y geografía", "Derecho",
        "Economía y administración", "Información y comunicación", "Otras ciencias sociales",
        "Relaciones institucionales", "Sociología"
      ]
    }
  ];

  const metadata = window.UNIVERSIDADES_METADATA || {};
  const universities = (Array.isArray(window.UNIVERSIDADES) ? window.UNIVERSIDADES : [])
    .map((university) => ({ ...university, ...(metadata[university.id] || {}) }));
  const state = { query: "", province: "", sectors: new Set(), area: "", subarea: "", unclassified: false, active: false };
  const elements = {
    search: document.getElementById("search-input"),
    province: document.getElementById("province-select"),
    sort: document.getElementById("sort-select"),
    grid: document.getElementById("university-grid"),
    areaPicker: document.getElementById("area-picker"),
    areaGrid: document.getElementById("area-grid"),
    results: document.getElementById("resultados"),
    summary: document.getElementById("results-summary"),
    visibleCount: document.getElementById("visible-count"),
    activeFilters: document.getElementById("active-filters"),
    emptyState: document.getElementById("empty-state"),
    dialog: document.getElementById("university-dialog"),
    detail: document.getElementById("university-detail")
  };

  const normalize = (value) => String(value || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();

  function populateOptions() {
    const provinces = [...new Set(universities.map((university) => university.province).filter(Boolean))]
      .sort((a, b) => a.localeCompare(b, "es"));
    provinces.forEach((province) => {
      const option = document.createElement("option");
      option.value = province;
      option.textContent = province;
      elements.province.append(option);
    });

  }

  function showResults() {
    state.active = true;
    elements.areaPicker.hidden = true;
    elements.results.hidden = false;
    renderResults();
  }

  function renderAreas() {
    elements.areaGrid.innerHTML = areas.map((area) => {
      const count = universities.filter((university) => (university.areas || []).includes(area.key)).length;
      return `
        <article class="area-card" style="--area-color:${area.color};--area-pale:${area.pale}">
          <button class="area-category" type="button" data-area="${area.key}" aria-pressed="${state.area === area.key && !state.subarea}">
            <span class="area-icon" aria-hidden="true">${area.icon}</span>
            <span><strong>${area.title}</strong><small>${count} instituciones</small></span>
          </button>
          <details class="area-disciplines" ${area.subareas.some((subarea) => state.subarea === subarea) ? "open" : ""}>
            <summary>Ver ${area.subareas.length} disciplinas</summary>
            <div class="discipline-tags">
              ${area.subareas.map((subarea) => {
                const matches = universities.filter((university) => (university.subareas || []).includes(subarea)).length;
                return `<button class="discipline-tag" type="button" data-subarea="${escapeHtml(subarea)}" aria-pressed="${state.subarea === subarea}">${escapeHtml(subarea)} <span>${matches}</span></button>`;
              }).join("")}
            </div>
          </details>
        </article>`;
    }).join("");

    const unclassifiedCount = universities.filter((university) => !(university.subareas || []).length).length;
    elements.areaGrid.insertAdjacentHTML("beforeend", `
      <article class="area-card area-card-unclassified">
        <button class="area-category" type="button" data-unclassified="true" aria-pressed="${state.unclassified}">
          <span class="area-icon" aria-hidden="true">?</span>
          <span><strong>Sin disciplinas detalladas</strong><small>${unclassifiedCount} instituciones · datos incompletos</small></span>
        </button>
        <p>La fuente no informa disciplinas específicas para estas instituciones.</p>
      </article>
    `);

    elements.areaGrid.querySelectorAll("[data-area]").forEach((button) => {
      button.addEventListener("click", () => {
        state.area = state.area === button.dataset.area ? "" : button.dataset.area;
        state.subarea = "";
        state.unclassified = false;
        showResults();
        renderAreas();
        elements.results.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    });
    elements.areaGrid.querySelectorAll("[data-subarea]").forEach((button) => {
      button.addEventListener("click", () => {
        const group = areas.find((area) => area.subareas.includes(button.dataset.subarea));
        if (!group) return;
        state.area = "";
        state.subarea = state.subarea === button.dataset.subarea ? "" : button.dataset.subarea;
        state.unclassified = false;
        showResults();
        renderAreas();
        elements.results.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    });
    elements.areaGrid.querySelector("[data-unclassified]").addEventListener("click", () => {
      state.area = "";
      state.subarea = "";
      state.unclassified = true;
      showResults();
      renderAreas();
      elements.results.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  }

  function getFilteredUniversities() {
    const query = normalize(state.query);
    const filtered = universities.filter((university) => {
      const searchText = normalize([
        university.name,
        university.abbreviation,
        ...(university.aliases || []),
        ...(university.areas || []),
        ...areas.filter((area) => (university.areas || []).includes(area.key)).map((area) => area.title),
        university.province,
        ...(university.subareas || [])
      ].join(" "));

      return (!query || searchText.includes(query))
        && (!state.province || university.province === state.province)
        && (!state.sectors.size || state.sectors.has(university.sector))
        && (!state.area || (university.areas || []).includes(state.area))
        && (!state.subarea || (university.subareas || []).includes(state.subarea))
        && (!state.unclassified || !(university.subareas || []).length);
    });

    filtered.sort((a, b) => {
      if (elements.sort.value === "students") {
        return (b.students2022 || 0) - (a.students2022 || 0) || a.name.localeCompare(b.name, "es");
      }
      return a.name.localeCompare(b.name, "es");
    });
    return filtered;
  }

  function renderCard(university) {
    const shownAreas = (university.subareas || []).slice(0, 3);
    const extraCount = (university.subareas || []).length - shownAreas.length;
    const studentCount = university.students2022
      ? `${university.students2022.toLocaleString("es-AR")} estudiantes en 2022`
      : "Matrícula no informada";

    return `
      <button class="university-card" type="button" data-university-id="${escapeHtml(university.id)}"
        aria-label="Ver resumen de ${escapeHtml(university.name)}">
        <div class="card-top">
          <div class="card-title">
            <h3>${escapeHtml(university.name)}</h3>
            ${university.abbreviation ? `<span class="university-abbreviation">${escapeHtml(university.abbreviation)}</span>` : ""}
          </div>
          <span class="sector-badge ${university.sector === "Privada" ? "private" : ""}">${escapeHtml(university.sector)}</span>
        </div>
        <span class="card-province">${escapeHtml(university.province || "Provincia no informada")}</span>
        <span class="card-tags">
          ${shownAreas.length
            ? shownAreas.map((subarea) => `<span class="card-tag">${escapeHtml(subarea)}</span>`).join("")
              + (extraCount > 0 ? `<span class="card-tag more">+${extraCount}</span>` : "")
            : `<span class="card-tag">Áreas sin desglose disponible</span>`}
        </span>
        <span class="card-footer">
          <strong>${escapeHtml(studentCount)}</strong>
          <span>Ver resumen <span aria-hidden="true">↗</span></span>
        </span>
      </button>`;
  }

  function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, (character) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;"
    })[character]);
  }

  function renderActiveFilters() {
    const filters = [];
    if (state.query) filters.push({
      label: `Búsqueda: ${state.query}`,
      clear: () => { state.query = ""; elements.search.value = ""; }
    });
    if (state.province) filters.push({
      label: state.province,
      clear: () => { state.province = ""; elements.province.value = ""; }
    });
    if (state.area && !state.subarea) filters.push({
      label: areas.find((area) => area.key === state.area)?.title || state.area,
      clear: () => { state.area = ""; renderAreas(); }
    });
    if (state.subarea) filters.push({
      label: state.subarea,
      clear: () => { state.subarea = ""; renderAreas(); }
    });
    if (state.unclassified) filters.push({
      label: "Sin disciplinas detalladas",
      clear: () => { state.unclassified = false; renderAreas(); }
    });
    state.sectors.forEach((sector) => filters.push({
      label: sector,
      clear: () => {
        state.sectors.delete(sector);
        document.querySelector(`input[name="sector"][value="${sector}"]`).checked = false;
      }
    }));

    elements.activeFilters.innerHTML = filters.map((filter, index) =>
      `<span class="filter-chip">${escapeHtml(filter.label)}<button type="button" data-remove-filter="${index}" aria-label="Quitar filtro ${escapeHtml(filter.label)}">×</button></span>`
    ).join("");

    elements.activeFilters.querySelectorAll("[data-remove-filter]").forEach((button) => {
      button.addEventListener("click", () => {
        filters[Number(button.dataset.removeFilter)].clear();
        renderResults();
      });
    });
  }

  function renderResults() {
    const results = getFilteredUniversities();
    elements.grid.innerHTML = results.map(renderCard).join("");
    elements.emptyState.hidden = results.length > 0;
    elements.grid.hidden = results.length === 0;
    elements.summary.textContent = `${results.length} ${results.length === 1 ? "institución encontrada" : "instituciones encontradas"}`;
    elements.visibleCount.textContent = `${results.length} resultados`;
    renderActiveFilters();

    elements.grid.querySelectorAll("[data-university-id]").forEach((card) => {
      card.addEventListener("click", () => openUniversity(card.dataset.universityId));
    });
  }

  function openUniversity(id) {
    const university = universities.find((item) => item.id === id);
    if (!university) return;

    const areasList = (university.subareas || []).length
      ? (university.subareas || []).map((area) => `<span class="detail-tag">${escapeHtml(area)}</span>`).join("")
      : `<p class="detail-muted">No hay un desglose por área disponible en los datos.</p>`;
    const students = university.students2022
      ? `${university.students2022.toLocaleString("es-AR")} estudiantes en 2022`
      : "Matrícula no informada en el anuario";
    const profileSummary = university.summary
      ? `<p class="detail-summary">${escapeHtml(university.summary)}</p>`
      : `<p class="detail-summary">Todavía no hay un resumen histórico verificado para esta institución.</p>`;
    const profileSources = university.summarySources || (university.summarySource && university.summarySource !== university.website
      ? [{ label: university.summarySourceLabel || "Ver fuente", url: university.summarySource }]
      : []);
    const profileSource = profileSources.map((source) =>
      `<a class="detail-source" href="${escapeHtml(source.url)}" target="_blank" rel="noopener noreferrer">${escapeHtml(source.label)} <span aria-hidden="true">↗</span></a>`
    ).join("");
    const funFact = university.funFact
      ? `<aside class="detail-fun-fact">
          <strong><span aria-hidden="true">✦</span> Dato curioso</strong>
          <p>${escapeHtml(university.funFact)}</p>
          ${(university.funFactSources || []).map((source) =>
            `<a class="detail-source" href="${escapeHtml(source.url)}" target="_blank" rel="noopener noreferrer">${escapeHtml(source.label)} <span aria-hidden="true">↗</span></a>`
          ).join("")}
        </aside>`
      : "";
    const websiteLink = university.website
      ? `<a class="detail-link primary-link" href="${escapeHtml(university.website)}" target="_blank" rel="noopener noreferrer">Visitar sitio oficial <span aria-hidden="true">↗</span></a>`
      : `<p class="detail-muted">Todavía no tenemos un enlace institucional verificado.</p>`;
    const faculties = (university.faculties || []).length
      ? `<section class="faculty-section">
          <h3>Facultades y unidades académicas</h3>
          <div class="faculty-links">${university.faculties.map((faculty) =>
            `<a class="detail-link faculty-link" href="${escapeHtml(faculty.url)}" target="_blank" rel="noopener noreferrer">${escapeHtml(faculty.name)} <span aria-hidden="true">↗</span></a>`
          ).join("")}</div>
        </section>`
      : "";

    elements.detail.innerHTML = `
      <div class="dialog-header">
        <span class="section-kicker">FICHA INSTITUCIONAL</span>
        <button class="dialog-close" type="button" aria-label="Cerrar ficha">×</button>
      </div>
      <div class="detail-title-row">
        <div>
          <h2 id="dialog-title">${escapeHtml(university.name)}</h2>
          ${university.abbreviation ? `<span class="detail-abbreviation">${escapeHtml(university.abbreviation)}</span>` : ""}
        </div>
        <span class="sector-badge ${university.sector === "Privada" ? "private" : ""}">${escapeHtml(university.sector)}</span>
      </div>
      <p class="detail-meta">${escapeHtml(university.province || "Provincia no informada")} · ${escapeHtml(students)}</p>
      <section class="institution-profile">
        <h3>Sobre la institución</h3>
        ${profileSummary}
        ${profileSource}
      </section>
      ${funFact}
      <section class="detail-section">
        <h3>Áreas con matrícula registrada</h3>
        <div class="detail-tags">${areasList}</div>
      </section>
      <div class="detail-actions">${websiteLink}</div>
      ${faculties}
      <p class="detail-disclaimer">La información de áreas y matrícula corresponde al Anuario Estadístico Universitario 2022. Confirmá las carreras vigentes en el sitio oficial.</p>
    `;

    elements.dialog.showModal();
    elements.detail.querySelector(".dialog-close").focus();
    elements.detail.querySelector(".dialog-close").addEventListener("click", () => elements.dialog.close());
  }

  function clearFilters() {
    state.query = "";
    state.province = "";
    state.sectors.clear();
    state.area = "";
    state.subarea = "";
    state.unclassified = false;
    elements.search.value = "";
    elements.province.value = "";
    document.querySelectorAll('input[name="sector"]').forEach((input) => { input.checked = false; });
    renderAreas();
    renderResults();
  }

  elements.search.addEventListener("input", () => {
    state.query = elements.search.value;
    if (state.query.trim()) showResults();
    else if (state.active) renderResults();
  });
  elements.province.addEventListener("change", () => {
    state.province = elements.province.value;
    renderResults();
  });
  elements.sort.addEventListener("change", renderResults);
  document.querySelectorAll('input[name="sector"]').forEach((input) => {
    input.addEventListener("change", () => {
      input.checked ? state.sectors.add(input.value) : state.sectors.delete(input.value);
      renderResults();
    });
  });
  document.getElementById("show-areas").addEventListener("click", () => {
    elements.areaPicker.hidden = false;
    elements.areaPicker.scrollIntoView({ behavior: "smooth", block: "start" });
  });
  document.getElementById("change-area").addEventListener("click", () => {
    elements.areaPicker.hidden = false;
    elements.areaPicker.scrollIntoView({ behavior: "smooth", block: "start" });
  });
  document.getElementById("close-areas").addEventListener("click", () => {
    elements.areaPicker.hidden = true;
  });
  document.getElementById("clear-filters").addEventListener("click", clearFilters);
  document.getElementById("empty-clear").addEventListener("click", clearFilters);
  elements.dialog.addEventListener("click", (event) => {
    if (event.target === elements.dialog) elements.dialog.close();
  });
  document.addEventListener("keydown", (event) => {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      elements.search.focus();
    }
  });

  populateOptions();
  renderAreas();
})();
