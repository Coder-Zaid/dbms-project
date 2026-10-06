/**
 * DAIRY FARM STUDIO • FRONTEND CONTROLLER
 * Full CRUD Operations across all 8 modules with Light/Dark Theme Support
 */

// Global State
let allAnimals = [];
let allBreeds = [];
let allMilkRecords = [];
let allBuyers = [];
let allAvailableYields = [];
let allQualityRecords = [];
let allFeedInventory = [];
let pendingDelete = { type: null, id: null, label: null };

// Cattle Registered Names Lookup (eliminates pure numbering)
const CATTLE_NAMES = {
  1: "Nandini", 2: "Ganga", 3: "Kamdhenu", 4: "Gauri", 5: "Surabhi",
  6: "Lakshmi", 7: "Kaveri", 8: "Amrita", 9: "Bhavani", 10: "Saraswati",
  11: "Yamuna", 12: "Radha", 13: "Shanti", 14: "Kalyani", 15: "Durga",
  16: "Anandi", 17: "Gayatri", 18: "Revati", 19: "Rohini", 20: "Mangala",
  21: "Chameli", 22: "Padma", 23: "Malati", 24: "Bela", 25: "Tulsi",
  26: "Parvati", 27: "Devaki", 28: "Yashoda", 29: "Sita", 30: "Uma",
  31: "Meera", 32: "Tara", 33: "Usha", 34: "Sandhya", 35: "Manorama",
  36: "Annapurna", 37: "Pushpa", 38: "Sneha", 39: "Champa", 40: "Vasundhara",
  41: "Shakuntala", 42: "Mallika", 43: "Kunti", 44: "Menaka", 45: "Urvashi",
  46: "Rambha", 47: "Damayanti", 48: "Madhavi", 49: "Mohini", 50: "Nandi (Sire Bull)"
};

function getCattleName(id) {
  return CATTLE_NAMES[id] || `Cattle #${id}`;
}

// Presets for SQL Studio
const SQL_PRESETS = {
  q29: `SELECT a.animal_id, a.animal_tag, b.breed_name, my.quantity_litres,
       qt.fat_percentage, qt.snf_percentage, si.quantity_sold, s.total_amount, bu.buyer_name
FROM animal a
JOIN breed b ON a.breed_id = b.breed_id
JOIN milking_session ms ON a.animal_id = ms.animal_id
JOIN milk_yield my ON ms.session_id = my.session_id
LEFT JOIN quality_test qt ON my.yield_id = qt.yield_id
LEFT JOIN sale_item si ON my.yield_id = si.yield_id
LEFT JOIN sale s ON si.sale_id = s.sale_id
LEFT JOIN buyer bu ON s.buyer_id = bu.buyer_id
WHERE a.animal_id = 20;`,

  shifts: `SELECT 
    ms.session_type AS 'Milking Shift',
    COUNT(ms.session_id) AS 'Session Count',
    ROUND(SUM(my.quantity_litres), 2) AS 'Total Litres Harvested',
    ROUND(AVG(my.quantity_litres), 2) AS 'Average Yield per Cow'
FROM milking_session ms
JOIN milk_yield my ON ms.session_id = my.session_id
GROUP BY ms.session_type
ORDER BY SUM(my.quantity_litres) DESC;`,

  quality: `SELECT 
    qt.test_id,
    a.animal_tag,
    b.breed_name,
    qt.fat_percentage,
    qt.snf_percentage,
    qt.density,
    CASE 
      WHEN qt.fat_percentage >= 3.50 AND qt.snf_percentage >= 8.50 THEN 'Grade A Premium'
      ELSE 'Standard Grade'
    END AS quality_rating
FROM quality_test qt
JOIN milk_yield my ON qt.yield_id = my.yield_id
JOIN milking_session ms ON my.session_id = ms.session_id
JOIN animal a ON ms.animal_id = a.animal_id
JOIN breed b ON a.breed_id = b.breed_id
WHERE qt.fat_percentage >= 3.50 AND qt.snf_percentage >= 8.50
ORDER BY qt.fat_percentage DESC;`,

  summary: `SELECT * FROM animal_milk_summary ORDER BY total_litres DESC LIMIT 25;`
};

// ============================================================================
// Initialization on DOM Load
// ============================================================================
document.addEventListener("DOMContentLoaded", () => {
  initTheme();
  setupNavigation();
  loadBreeds();
  loadBuyers();
  loadAvailableYields();
  loadDashboardData();
  loadAnimals();
  loadMilkRecords();
  initInfoHoverEngine();

  // Set default dates
  const today = new Date().toISOString().split("T")[0];
  ["milk-date-input", "sale-date-input", "quality-date-input", "feed-date-input"].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.value = today;
  });

  // Shortcut for SQL execute (Ctrl+Enter or Cmd+Enter)
  const sqlInput = document.getElementById("sql-query-input");
  if (sqlInput) {
    sqlInput.addEventListener("keydown", (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
        e.preventDefault();
        runSQLQuery();
      }
    });
  }
});

// ============================================================================
// Theme Management (Default: Light Theme)
// ============================================================================
function initTheme() {
  const saved = localStorage.getItem("dairy_studio_theme") || "light";
  document.documentElement.setAttribute("data-theme", saved);
  const btn = document.getElementById("theme-toggle-btn");
  if (btn) btn.innerText = saved === "light" ? "☀️ Light Theme" : "🌙 Dark Theme";
}

function toggleTheme() {
  const html = document.documentElement;
  const current = html.getAttribute("data-theme") || "light";
  const next = current === "light" ? "dark" : "light";
  html.setAttribute("data-theme", next);
  localStorage.setItem("dairy_studio_theme", next);
  const btn = document.getElementById("theme-toggle-btn");
  if (btn) btn.innerText = next === "light" ? "☀️ Light Theme" : "🌙 Dark Theme";
}

// ============================================================================
// Sidebar Navigation (8 Modules)
// ============================================================================
function setupNavigation() {
  const navItems = document.querySelectorAll(".nav-item");
  navItems.forEach(item => {
    item.addEventListener("click", () => {
      navItems.forEach(n => n.classList.remove("active"));
      document.querySelectorAll(".studio-view").forEach(v => v.classList.remove("active"));

      item.classList.add("active");
      const targetViewId = item.getAttribute("data-view");
      const targetView = document.getElementById(targetViewId);
      if (targetView) targetView.classList.add("active");

      // Auto-load data for target view
      if (targetViewId === "view-dashboard") loadDashboardData();
      else if (targetViewId === "view-herd") loadAnimals();
      else if (targetViewId === "view-milk") loadMilkRecords();
      else if (targetViewId === "view-quality") loadQualityRecords();
      else if (targetViewId === "view-feed") loadFeedRecords();
      else if (targetViewId === "view-sales") loadSalesRecords();
    });
  });
}

// ============================================================================
// 1. Dashboard Metrics & Analytics
// ============================================================================
async function loadDashboardData() {
  try {
    const res = await fetch("/api/dashboard");
    if (!res.ok) throw new Error("Failed to load dashboard metrics");
    const data = await res.json();

    document.getElementById("kpi-total-animals").innerText = data.total_animals;
    document.getElementById("kpi-total-milk").innerText = `${data.total_milk_litres.toFixed(1)} L`;
    document.getElementById("kpi-total-revenue").innerText = `₹${data.total_sales_revenue.toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
    document.getElementById("kpi-low-stock").innerText = data.low_stock_feed_items;

    // Shift distribution
    const shiftContainer = document.getElementById("shift-stats-container");
    if (shiftContainer && data.shifts) {
      shiftContainer.innerHTML = data.shifts.map(s => `
        <div class="shift-stat-row" data-info-entity="shift_stat" data-shift="${s.session_type}" data-litres="${s.litres}" style="cursor:help;">
          <span class="shift-stat-title">${s.session_type} Milking Harvest <span class="info-hover-icon">ⓘ</span></span>
          <span class="shift-stat-val">${s.litres} Litres</span>
        </div>
      `).join("");
    }

    // Quality overview averages
    const qContainer = document.getElementById("quality-overview-container");
    if (qContainer && data.quality) {
      qContainer.innerHTML = `
        <div class="q-badge-box" data-info-entity="kpi_avg_fat" data-val="${data.quality.avg_fat || '3.9'}" style="cursor:help;">
          <div class="q-label">Avg Butterfat <span class="info-hover-icon">ⓘ</span></div>
          <div class="q-value">${data.quality.avg_fat || '3.9'}%</div>
        </div>
        <div class="q-badge-box" data-info-entity="kpi_avg_snf" data-val="${data.quality.avg_snf || '8.7'}" style="cursor:help;">
          <div class="q-label">Avg SNF solids <span class="info-hover-icon">ⓘ</span></div>
          <div class="q-value">${data.quality.avg_snf || '8.7'}%</div>
        </div>
        <div class="q-badge-box" data-info-entity="kpi_avg_density" data-val="${data.quality.avg_density || '1.030'}" style="cursor:help;">
          <div class="q-label">Specific Density <span class="info-hover-icon">ⓘ</span></div>
          <div class="q-value">${data.quality.avg_density || '1.030'}</div>
        </div>
      `;
    }

    // Top breeds table
    const breedsTbody = document.getElementById("dashboard-breeds-tbody");
    if (breedsTbody && data.top_breeds) {
      breedsTbody.innerHTML = data.top_breeds.map(b => `
        <tr>
          <td>
            <strong data-info-entity="breed" data-breed="${b.breed_name}" style="cursor:help;">
              ${b.breed_name}<span class="info-hover-icon">ⓘ</span>
            </strong>
          </td>
          <td>
            <span class="badge badge-success" data-info-entity="breed_count" data-breed="${b.breed_name}" data-count="${b.count}" style="cursor:help;">
              ${b.count} Head<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td>
            <code data-info-entity="breed_category" style="cursor:help;">
              Dairy Cattle<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
        </tr>
      `).join("");
    }

  } catch (err) {
    console.error("Dashboard metric load failed:", err);
  }
}

// ============================================================================
// Breeds & Buyers Master Lookups
// ============================================================================
async function loadBreeds() {
  try {
    const res = await fetch("/api/breeds");
    if (!res.ok) throw new Error("Failed to load breeds");
    allBreeds = await res.json();

    const select = document.getElementById("animal-breed-select");
    if (select) {
      select.innerHTML = '<option value="">Select a breed...</option>';
      allBreeds.forEach(b => {
        const opt = document.createElement("option");
        opt.value = b.breed_id;
        opt.textContent = `${b.breed_name} (${b.description || 'Standard'})`;
        select.appendChild(opt);
      });
    }
  } catch (err) {
    console.error("Failed to load breeds master:", err);
  }
}

async function loadBuyers() {
  try {
    const res = await fetch("/api/buyers");
    if (!res.ok) throw new Error("Failed to load buyers");
    allBuyers = await res.json();

    const select = document.getElementById("sale-buyer-select");
    if (select) {
      select.innerHTML = '<option value="">Select a buyer / cooperative...</option>';
      allBuyers.forEach(b => {
        const opt = document.createElement("option");
        opt.value = b.buyer_id;
        opt.textContent = `${b.buyer_name} (${b.address} • Ph: ${b.contact})`;
        select.appendChild(opt);
      });
    }
  } catch (err) {
    console.error("Failed to load buyers:", err);
  }
}

async function loadAvailableYields() {
  try {
    const res = await fetch("/api/available-yields");
    if (!res.ok) throw new Error("Failed to load yields");
    allAvailableYields = await res.json();

    // Populate Sale modal yield select
    const saleSelect = document.getElementById("sale-yield-select");
    if (saleSelect) {
      saleSelect.innerHTML = '<option value="">Select available yield lot...</option>';
      allAvailableYields.forEach(y => {
        const name = getCattleName(y.animal_id);
        const opt = document.createElement("option");
        opt.value = y.yield_id;
        opt.dataset.qty = y.quantity_litres;
        opt.textContent = `Lot #${y.yield_id} • ${y.quantity_litres} L from ${name} (${y.animal_tag}) - ${y.session_date} ${y.session_type}`;
        saleSelect.appendChild(opt);
      });
    }

    // Populate Quality modal yield select
    const qSelect = document.getElementById("quality-yield-select");
    if (qSelect) {
      qSelect.innerHTML = '<option value="">Select yield lot to test...</option>';
      allAvailableYields.forEach(y => {
        const name = getCattleName(y.animal_id);
        const opt = document.createElement("option");
        opt.value = y.yield_id;
        opt.textContent = `Lot #${y.yield_id} • ${y.quantity_litres} L from ${name} (${y.animal_tag}) - ${y.session_date}`;
        qSelect.appendChild(opt);
      });
    }
  } catch (err) {
    console.error("Failed to load available yields:", err);
  }
}

// ============================================================================
// 2. Herd Registry (Cattle Master)
// ============================================================================
async function loadAnimals() {
  const tbody = document.getElementById("animals-tbody");
  tbody.innerHTML = '<tr><td colspan="7" class="loading-state">Querying table animal from MySQL 8.0...</td></tr>';

  try {
    const res = await fetch("/api/animals?limit=100");
    if (!res.ok) throw new Error(`HTTP ${res.status}: Failed to fetch cattle records`);
    const data = await res.json();
    allAnimals = data.records;

    const countPill = document.getElementById("animal-count-pill");
    if (countPill) countPill.innerText = `${data.total} Records in MySQL`;

    populateMilkAnimalDropdown();
    populateFeedAnimalDropdown();
    renderAnimalsTable(allAnimals);
  } catch (err) {
    console.error("Animal load failed:", err);
    tbody.innerHTML = `<tr><td colspan="7" class="loading-state" style="color: var(--danger)">Failed to load records from MySQL. (${err.message})</td></tr>`;
  }
}

function renderAnimalsTable(list) {
  const tbody = document.getElementById("animals-tbody");
  if (!list || list.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" class="loading-state">No matching cattle records found.</td></tr>';
    return;
  }

  tbody.innerHTML = list.map(a => {
    let badgeClass = "badge-success";
    if (a.status === "Sold") badgeClass = "badge-warning";
    else if (a.status === "Deceased") badgeClass = "badge-danger";
    else if (a.status === "Transferred") badgeClass = "badge-info";

    const name = getCattleName(a.animal_id);

    return `
      <tr>
        <td>
          <code data-info-entity="animal_pk" data-id="${a.animal_id}" title="Internal Primary Key">
            #${a.animal_id}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <div data-info-entity="cattle" data-id="${a.animal_id}" data-tag="${a.animal_tag}" data-name="${name}" data-breed="${a.breed_name}" data-gender="${a.gender}" data-status="${a.status}" data-dob="${a.date_of_birth}" style="display:flex; flex-direction:column; gap:2px; cursor:help;">
            <strong style="color:var(--ink); font-size:13.5px;">${name} <span class="info-hover-icon">ⓘ</span></strong>
            <span style="font-family:var(--font-mono); font-size:11px; color:var(--primary); font-weight:600;">${a.animal_tag}</span>
          </div>
        </td>
        <td>
          <span data-info-entity="breed" data-breed="${a.breed_name}" style="cursor:help;">
            ${a.breed_name}<span class="info-hover-icon">ⓘ</span>
          </span>
        </td>
        <td>
          <span data-info-entity="gender" data-gender="${a.gender}" style="cursor:help;">
            ${a.gender}<span class="info-hover-icon">ⓘ</span>
          </span>
        </td>
        <td>
          <code data-info-entity="dob" data-dob="${a.date_of_birth}" style="cursor:help;">
            ${a.date_of_birth}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <span class="badge ${badgeClass}" data-info-entity="animal_status" data-status="${a.status}" style="cursor:help;">
            ${a.status}<span class="info-hover-icon">ⓘ</span>
          </span>
        </td>
        <td>
          <button class="action-btn-del" data-info-entity="btn_delete_animal" data-name="${name}" data-id="${a.animal_id}" onclick="confirmDelete('animal', ${a.animal_id}, '${name} (${a.animal_tag})')">
            Delete<span class="info-hover-icon">ⓘ</span>
          </button>
        </td>
      </tr>
    `;
  }).join("");
}

function filterAnimals() {
  const search = document.getElementById("animal-search-input").value.toLowerCase().trim();
  const status = document.getElementById("animal-status-filter").value;

  const filtered = allAnimals.filter(a => {
    const name = getCattleName(a.animal_id).toLowerCase();
    const matchSearch = a.animal_tag.toLowerCase().includes(search) || 
                        a.breed_name.toLowerCase().includes(search) || 
                        name.includes(search);
    const matchStatus = (status === "ALL") || (a.status === status);
    return matchSearch && matchStatus;
  });

  renderAnimalsTable(filtered);
}

// Modal: Add Animal
function openAddAnimalModal() {
  document.getElementById("add-animal-modal").classList.remove("hidden");
  document.getElementById("animal-tag-input").focus();
}

function closeAddAnimalModal() {
  document.getElementById("add-animal-modal").classList.add("hidden");
  document.getElementById("add-animal-form").reset();
}

async function submitAnimalForm(event) {
  event.preventDefault();
  const submitBtn = document.getElementById("btn-save-animal");
  submitBtn.disabled = true;
  submitBtn.innerText = "Executing INSERT...";

  const payload = {
    animal_tag: document.getElementById("animal-tag-input").value.trim(),
    breed_id: parseInt(document.getElementById("animal-breed-select").value, 10),
    gender: document.getElementById("animal-gender-select").value,
    date_of_birth: document.getElementById("animal-dob-input").value,
    status: document.getElementById("animal-status-select").value
  };

  try {
    const res = await fetch("/api/animals", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Insert failed");

    closeAddAnimalModal();
    showTxLog("INSERT ANIMAL", data.message, "animal", data.before_count, data.after_count, "+1");
    loadAnimals();
    loadDashboardData();
  } catch (err) {
    alert(`MySQL Error: ${err.message}`);
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerText = "Execute SQL INSERT";
  }
}

// ============================================================================
// 3. Milk Collection (Sessions & Yields)
// ============================================================================
async function loadMilkRecords() {
  const tbody = document.getElementById("milk-tbody");
  tbody.innerHTML = '<tr><td colspan="8" class="loading-state">Querying milking_session & milk_yield from MySQL 8.0...</td></tr>';

  try {
    const res = await fetch("/api/milk-records?limit=100");
    if (!res.ok) throw new Error(`HTTP ${res.status}: Failed to fetch milk records`);
    const data = await res.json();
    allMilkRecords = data.records;

    const countPill = document.getElementById("milk-count-pill");
    if (countPill) countPill.innerText = `${data.total} Harvest Lots`;

    renderMilkTable(allMilkRecords);
  } catch (err) {
    console.error("Milk records load failed:", err);
    tbody.innerHTML = `<tr><td colspan="8" class="loading-state" style="color: var(--danger)">Failed to load milk records. (${err.message})</td></tr>`;
  }
}

function renderMilkTable(list) {
  const tbody = document.getElementById("milk-tbody");
  if (!list || list.length === 0) {
    tbody.innerHTML = '<tr><td colspan="8" class="loading-state">No matching milk records found.</td></tr>';
    return;
  }

  tbody.innerHTML = list.map(m => {
    const name = getCattleName(m.animal_id);
    return `
      <tr>
        <td>
          <code data-info-entity="session_pk" data-id="${m.session_id}" style="cursor:help;">
            #${m.session_id}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <div data-info-entity="cattle" data-id="${m.animal_id}" data-tag="${m.animal_tag}" data-name="${name}" data-breed="${m.breed_name}" style="display:flex; flex-direction:column; gap:2px; cursor:help;">
            <strong style="color:var(--ink); font-size:13.5px;">${name} <span class="info-hover-icon">ⓘ</span></strong>
            <span style="font-family:var(--font-mono); font-size:11px; color:var(--primary); font-weight:600;">${m.animal_tag}</span>
          </div>
        </td>
        <td>
          <span data-info-entity="breed" data-breed="${m.breed_name}" style="cursor:help;">
            ${m.breed_name}<span class="info-hover-icon">ⓘ</span>
          </span>
        </td>
        <td>
          <code data-info-entity="session_date" data-date="${m.session_date}" style="cursor:help;">
            ${m.session_date}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <code data-info-entity="session_time" data-time="${m.session_time}" style="cursor:help;">
            ${m.session_time}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <span class="badge badge-info" data-info-entity="shift_badge" data-shift="${m.session_type}" style="cursor:help;">
            ${m.session_type}<span class="info-hover-icon">ⓘ</span>
          </span>
        </td>
        <td>
          <strong data-info-entity="quantity_metric" data-qty="${parseFloat(m.quantity_litres).toFixed(1)}" style="color: var(--primary); cursor:help;">
            ${parseFloat(m.quantity_litres).toFixed(1)} L<span class="info-hover-icon">ⓘ</span>
          </strong>
        </td>
        <td>
          <button class="action-btn-del" data-info-entity="btn_delete_milk" data-id="${m.session_id}" onclick="confirmDelete('milk', ${m.session_id}, 'Session #${m.session_id} (${name})')">
            Delete<span class="info-hover-icon">ⓘ</span>
          </button>
        </td>
      </tr>
    `;
  }).join("");
}

function filterMilkRecords() {
  const query = document.getElementById("milk-search-input").value.toLowerCase().trim();
  const filtered = allMilkRecords.filter(m => {
    const name = getCattleName(m.animal_id).toLowerCase();
    return m.animal_tag.toLowerCase().includes(query) ||
           m.breed_name.toLowerCase().includes(query) ||
           m.session_type.toLowerCase().includes(query) ||
           m.session_date.includes(query) ||
           name.includes(query);
  });
  renderMilkTable(filtered);
}

function populateMilkAnimalDropdown() {
  const select = document.getElementById("milk-animal-select");
  if (!select) return;
  select.innerHTML = '<option value="">Select cattle...</option>';

  const femaleAnimals = allAnimals.filter(a => a.gender === "Female" && a.status === "Active");
  const listToUse = femaleAnimals.length > 0 ? femaleAnimals : allAnimals;

  listToUse.forEach(a => {
    const name = getCattleName(a.animal_id);
    const opt = document.createElement("option");
    opt.value = a.animal_id;
    opt.textContent = `${name} (${a.animal_tag} • ${a.breed_name}) - ID #${a.animal_id}`;
    select.appendChild(opt);
  });
}

// Modal: Add Milk
function openAddMilkModal() {
  populateMilkAnimalDropdown();
  document.getElementById("add-milk-modal").classList.remove("hidden");
}

function closeAddMilkModal() {
  document.getElementById("add-milk-modal").classList.add("hidden");
  document.getElementById("add-milk-form").reset();
  const today = new Date().toISOString().split("T")[0];
  document.getElementById("milk-date-input").value = today;
}

async function submitMilkForm(event) {
  event.preventDefault();
  const submitBtn = document.getElementById("btn-save-milk");
  submitBtn.disabled = true;
  submitBtn.innerText = "Committing Transaction...";

  const payload = {
    animal_id: parseInt(document.getElementById("milk-animal-select").value, 10),
    session_date: document.getElementById("milk-date-input").value,
    session_time: document.getElementById("milk-time-input").value,
    session_type: document.getElementById("milk-shift-select").value,
    quantity_litres: parseFloat(document.getElementById("milk-qty-input").value)
  };

  try {
    const res = await fetch("/api/milk-records", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Insert failed");

    closeAddMilkModal();
    showTxLog("COMMIT 2-TABLE INSERT", data.message, "milk_yield", data.before_count, data.after_count, "+1");
    loadMilkRecords();
    loadDashboardData();
    loadAvailableYields();
  } catch (err) {
    alert(`MySQL Error: ${err.message}`);
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerText = "Commit 2-Table Transaction";
  }
}

// ============================================================================
// 4. Quality Control Lab
// ============================================================================
async function loadQualityRecords() {
  const tbody = document.getElementById("quality-tbody");
  tbody.innerHTML = '<tr><td colspan="9" class="loading-state">Fetching laboratory assays from quality_test...</td></tr>';

  try {
    const res = await fetch("/api/quality-records");
    if (!res.ok) throw new Error("Failed to load quality records");
    allQualityRecords = await res.json();

    if (allQualityRecords.length === 0) {
      tbody.innerHTML = '<tr><td colspan="9" class="loading-state">No quality test records found.</td></tr>';
      return;
    }

    tbody.innerHTML = allQualityRecords.map(q => {
      const isGradeA = q.quality_rating === "Grade A Premium";
      const badgeClass = isGradeA ? "badge-success" : "badge-info";
      const name = getCattleName(q.animal_id);

      return `
        <tr>
          <td>
            <code data-info-entity="quality_pk" data-id="${q.test_id}" style="cursor:help;">
              #${q.test_id}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <code data-info-entity="yield_lot_ref" data-id="${q.yield_id}" style="cursor:help;">
              Lot #${q.yield_id}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <div data-info-entity="cattle" data-id="${q.animal_id}" data-tag="${q.animal_tag}" data-name="${name}" style="display:flex; flex-direction:column; gap:2px; cursor:help;">
              <strong style="color:var(--ink); font-size:13px;">${name} <span class="info-hover-icon">ⓘ</span></strong>
              <span style="font-family:var(--font-mono); font-size:11px; color:var(--primary); font-weight:600;">${q.animal_tag}</span>
            </div>
          </td>
          <td>
            <code data-info-entity="test_date" data-date="${q.test_date}" style="cursor:help;">
              ${q.test_date}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <strong data-info-entity="fat_metric" data-fat="${q.fat_percentage}" style="cursor:help;">
              ${q.fat_percentage}%<span class="info-hover-icon">ⓘ</span>
            </strong>
          </td>
          <td>
            <span data-info-entity="snf_metric" data-snf="${q.snf_percentage}" style="cursor:help;">
              ${q.snf_percentage}%<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td>
            <code data-info-entity="density_metric" data-density="${q.density}" style="cursor:help;">
              ${q.density}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <span class="badge ${badgeClass}" data-info-entity="quality_rating" data-rating="${q.quality_rating}" style="cursor:help;">
              ${q.quality_rating}<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td>
            <button class="action-btn-del" data-info-entity="btn_delete_quality" data-id="${q.test_id}" onclick="confirmDelete('quality', ${q.test_id}, 'Test #${q.test_id} (Lot #${q.yield_id})')">
              Delete<span class="info-hover-icon">ⓘ</span>
            </button>
          </td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Quality fetch error:", err);
    tbody.innerHTML = `<tr><td colspan="9" class="loading-state" style="color: var(--danger)">Error: ${err.message}</td></tr>`;
  }
}

function openAddQualityModal() {
  loadAvailableYields();
  document.getElementById("add-quality-modal").classList.remove("hidden");
}

function closeAddQualityModal() {
  document.getElementById("add-quality-modal").classList.add("hidden");
  document.getElementById("add-quality-form").reset();
  const today = new Date().toISOString().split("T")[0];
  document.getElementById("quality-date-input").value = today;
}

async function submitQualityForm(event) {
  event.preventDefault();
  const submitBtn = document.getElementById("btn-save-quality");
  submitBtn.disabled = true;
  submitBtn.innerText = "Saving Assay...";

  const payload = {
    yield_id: parseInt(document.getElementById("quality-yield-select").value, 10),
    test_date: document.getElementById("quality-date-input").value,
    fat_percentage: parseFloat(document.getElementById("quality-fat-input").value),
    snf_percentage: parseFloat(document.getElementById("quality-snf-input").value),
    density: parseFloat(document.getElementById("quality-density-input").value)
  };

  try {
    const res = await fetch("/api/quality-records", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Quality assay insertion failed");

    closeAddQualityModal();
    showTxLog("COMMIT QUALITY TEST", data.message, "quality_test", data.before_count, data.after_count, "+1");
    loadQualityRecords();
    loadDashboardData();
  } catch (err) {
    alert(`MySQL Error: ${err.message}`);
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerText = "Save Assay in quality_test";
  }
}

// ============================================================================
// 5. Feed & Warehouse Management
// ============================================================================
async function loadFeedRecords() {
  const itemsTbody = document.getElementById("feed-items-tbody");
  const issuesTbody = document.getElementById("feed-issues-tbody");

  itemsTbody.innerHTML = '<tr><td colspan="5" class="loading-state">Loading warehouse stock...</td></tr>';
  issuesTbody.innerHTML = '<tr><td colspan="6" class="loading-state">Loading dispensation logs...</td></tr>';

  try {
    const res = await fetch("/api/feed-records");
    if (!res.ok) throw new Error("Failed to load feed data");
    const data = await res.json();
    allFeedInventory = data.inventory;

    // Populate Feed modal items
    const feedSelect = document.getElementById("feed-item-select");
    if (feedSelect) {
      feedSelect.innerHTML = '<option value="">Select feed commodity...</option>';
      allFeedInventory.forEach(f => {
        const opt = document.createElement("option");
        opt.value = f.feed_id;
        opt.textContent = `${f.feed_name} (${f.available_quantity} ${f.unit} available)`;
        feedSelect.appendChild(opt);
      });
    }

    // Catalog items
    itemsTbody.innerHTML = allFeedInventory.map(f => {
      const isLow = f.stock_status === "Reorder Required";
      const badge = isLow ? `<span class="badge badge-danger" data-info-entity="feed_alert" data-feed="${f.feed_name}" style="cursor:help;">Reorder Alert<span class="info-hover-icon">ⓘ</span></span>` : `<span class="badge badge-success" data-info-entity="feed_sufficient" data-feed="${f.feed_name}" style="cursor:help;">Sufficient<span class="info-hover-icon">ⓘ</span></span>`;
      return `
        <tr>
          <td>
            <strong data-info-entity="feed_item" data-name="${f.feed_name}" data-qty="${f.available_quantity}" data-unit="${f.unit}" style="cursor:help;">
              ${f.feed_name}<span class="info-hover-icon">ⓘ</span>
            </strong>
          </td>
          <td>
            <code data-info-entity="feed_unit" data-unit="${f.unit}" style="cursor:help;">
              ${f.unit}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <strong data-info-entity="feed_stock_val" data-qty="${f.available_quantity}" data-unit="${f.unit}" style="color: ${isLow ? 'var(--danger)' : 'var(--ink)'}; cursor:help;">
              ${f.available_quantity}<span class="info-hover-icon">ⓘ</span>
            </strong>
          </td>
          <td>
            <span data-info-entity="feed_reorder_level" data-level="${f.reorder_level}" style="cursor:help;">
              ${f.reorder_level}<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td>${badge}</td>
        </tr>
      `;
    }).join("");

    // Recent issues
    issuesTbody.innerHTML = data.recent_issues.map(iss => {
      const name = getCattleName(iss.animal_id);
      return `
      <tr>
        <td>
          <code data-info-entity="issue_pk" data-id="${iss.issue_id}" style="cursor:help;">
            #${iss.issue_id}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <strong data-info-entity="feed_item" data-name="${iss.feed_name}" style="cursor:help;">
            ${iss.feed_name}<span class="info-hover-icon">ⓘ</span>
          </strong>
        </td>
        <td>
          <div data-info-entity="cattle" data-id="${iss.animal_id}" data-tag="${iss.animal_tag}" data-name="${name}" style="display:flex; flex-direction:column; gap:2px; cursor:help;">
            <strong style="color:var(--ink); font-size:13px;">${name} <span class="info-hover-icon">ⓘ</span></strong>
            <span style="font-family:var(--font-mono); font-size:11px; color:var(--primary); font-weight:600;">${iss.animal_tag}</span>
          </div>
        </td>
        <td>
          <code data-info-entity="issue_date" data-date="${iss.issue_date}" style="cursor:help;">
            ${iss.issue_date}<span class="info-hover-icon">ⓘ</span>
          </code>
        </td>
        <td>
          <strong data-info-entity="dispensed_qty" data-qty="${iss.quantity}" data-unit="${iss.unit}" style="cursor:help;">
            ${iss.quantity} ${iss.unit}<span class="info-hover-icon">ⓘ</span>
          </strong>
        </td>
        <td>
          <button class="action-btn-del" data-info-entity="btn_delete_feed" data-id="${iss.issue_id}" onclick="confirmDelete('feed', ${iss.issue_id}, 'Feed Issue #${iss.issue_id} (${iss.feed_name})')">
            Cancel<span class="info-hover-icon">ⓘ</span>
          </button>
        </td>
      </tr>
      `;
    }).join("");

  } catch (err) {
    console.error("Feed data fetch error:", err);
  }
}

function populateFeedAnimalDropdown() {
  const select = document.getElementById("feed-animal-select");
  if (!select) return;
  select.innerHTML = '<option value="">Select cattle...</option>';

  allAnimals.forEach(a => {
    const name = getCattleName(a.animal_id);
    const opt = document.createElement("option");
    opt.value = a.animal_id;
    opt.textContent = `${name} (${a.animal_tag} • ${a.breed_name})`;
    select.appendChild(opt);
  });
}

function openAddFeedModal() {
  loadFeedRecords();
  populateFeedAnimalDropdown();
  document.getElementById("add-feed-modal").classList.remove("hidden");
}

function closeAddFeedModal() {
  document.getElementById("add-feed-modal").classList.add("hidden");
  document.getElementById("add-feed-form").reset();
  const today = new Date().toISOString().split("T")[0];
  document.getElementById("feed-date-input").value = today;
}

async function submitFeedForm(event) {
  event.preventDefault();
  const submitBtn = document.getElementById("btn-save-feed");
  submitBtn.disabled = true;
  submitBtn.innerText = "Dispensing Feed...";

  const payload = {
    feed_id: parseInt(document.getElementById("feed-item-select").value, 10),
    animal_id: parseInt(document.getElementById("feed-animal-select").value, 10),
    issue_date: document.getElementById("feed-date-input").value,
    quantity: parseFloat(document.getElementById("feed-qty-input").value)
  };

  try {
    const res = await fetch("/api/feed-issues", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Feed dispensation failed");

    closeAddFeedModal();
    showTxLog("FEED ISSUE COMMITTED", data.message, "feed_issue", data.before_count, data.after_count, "+1");
    loadFeedRecords();
    loadDashboardData();
  } catch (err) {
    alert(`Stock Guard Alert: ${err.message}`);
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerText = "Dispense Feed (Decrements Stock)";
  }
}

// ============================================================================
// 6. Commercial Sales & Sell Milk (3NF)
// ============================================================================
async function loadSalesRecords() {
  const tbody = document.getElementById("sales-tbody");
  tbody.innerHTML = '<tr><td colspan="9" class="loading-state">Reconciling 3NF sale invoices and payments...</td></tr>';

  try {
    const res = await fetch("/api/sales-records");
    if (!res.ok) throw new Error("Failed to load sales invoices");
    const sales = await res.json();

    tbody.innerHTML = sales.map(s => {
      const isPaid = s.balance_due <= 0;
      const statusBadge = isPaid
        ? '<span class="badge badge-success" data-info-entity="sale_settled" style="cursor:help;">Settled<span class="info-hover-icon">ⓘ</span></span>'
        : '<span class="badge badge-warning" data-info-entity="sale_pending" style="cursor:help;">Balance Due<span class="info-hover-icon">ⓘ</span></span>';

      return `
        <tr>
          <td>
            <code data-info-entity="sale_pk" data-id="${s.sale_id}" style="cursor:help;">
              INV-${String(s.sale_id).padStart(4, '0')}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <strong data-info-entity="buyer_entity" data-buyer="${s.buyer_name}" data-contact="${s.contact}" style="cursor:help;">
              ${s.buyer_name}<span class="info-hover-icon">ⓘ</span>
            </strong>
          </td>
          <td>
            <span data-info-entity="buyer_phone" data-phone="${s.contact}" style="cursor:help;">
              ${s.contact}<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td>
            <code data-info-entity="invoice_date" data-date="${s.sale_date}" style="cursor:help;">
              ${s.sale_date}<span class="info-hover-icon">ⓘ</span>
            </code>
          </td>
          <td>
            <strong data-info-entity="sale_total_val" data-amount="${s.total_amount}" style="cursor:help;">
              ₹${s.total_amount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}<span class="info-hover-icon">ⓘ</span>
            </strong>
          </td>
          <td>
            <span data-info-entity="sale_paid_val" data-amount="${s.amount_paid}" style="cursor:help;">
              ₹${s.amount_paid.toLocaleString('en-IN', { minimumFractionDigits: 2 })}<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td style="color: ${isPaid ? 'var(--ink-muted)' : 'var(--warning)'}">
            <span data-info-entity="sale_balance_val" data-balance="${s.balance_due}" style="cursor:help;">
              ₹${s.balance_due.toLocaleString('en-IN', { minimumFractionDigits: 2 })}<span class="info-hover-icon">ⓘ</span>
            </span>
          </td>
          <td>${statusBadge}</td>
          <td>
            <button class="action-btn-del" data-info-entity="btn_delete_sale" data-id="${s.sale_id}" onclick="confirmDelete('sale', ${s.sale_id}, 'Invoice INV-${String(s.sale_id).padStart(4, '0')} (${s.buyer_name})')">
              Delete<span class="info-hover-icon">ⓘ</span>
            </button>
          </td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Sales fetch error:", err);
    tbody.innerHTML = `<tr><td colspan="9" class="loading-state" style="color: var(--danger)">Error: ${err.message}</td></tr>`;
  }
}

function openAddSaleModal() {
  loadBuyers();
  loadAvailableYields();
  document.getElementById("add-sale-modal").classList.remove("hidden");
}

function closeAddSaleModal() {
  document.getElementById("add-sale-modal").classList.add("hidden");
  document.getElementById("add-sale-form").reset();
  const today = new Date().toISOString().split("T")[0];
  document.getElementById("sale-date-input").value = today;
  calculateSaleTotal();
}

function handleYieldSelectChange() {
  const select = document.getElementById("sale-yield-select");
  const selectedOpt = select.options[select.selectedIndex];
  if (selectedOpt && selectedOpt.dataset.qty) {
    const qtyInput = document.getElementById("sale-qty-input");
    qtyInput.value = selectedOpt.dataset.qty;
    calculateSaleTotal();
  }
}

function calculateSaleTotal() {
  const qty = parseFloat(document.getElementById("sale-qty-input").value) || 0;
  const rate = parseFloat(document.getElementById("sale-rate-input").value) || 0;
  const total = qty * rate;
  document.getElementById("sale-total-preview").value = `₹${total.toFixed(2)}`;
}

async function submitSaleForm(event) {
  event.preventDefault();
  const submitBtn = document.getElementById("btn-save-sale");
  submitBtn.disabled = true;
  submitBtn.innerText = "Committing 3NF Sale...";

  const payload = {
    buyer_id: parseInt(document.getElementById("sale-buyer-select").value, 10),
    yield_id: parseInt(document.getElementById("sale-yield-select").value, 10),
    sale_date: document.getElementById("sale-date-input").value,
    quantity_sold: parseFloat(document.getElementById("sale-qty-input").value),
    rate_per_litre: parseFloat(document.getElementById("sale-rate-input").value),
    payment_amount: parseFloat(document.getElementById("sale-pay-amount").value || 0),
    payment_method: document.getElementById("sale-pay-method").value
  };

  try {
    const res = await fetch("/api/sales", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Sale transaction failed");

    closeAddSaleModal();
    showTxLog("3NF SALE INVOICE COMMITTED", data.message, "sale", data.before_count, data.after_count, "+1");
    loadSalesRecords();
    loadDashboardData();
  } catch (err) {
    alert(`MySQL Transaction Error: ${err.message}`);
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerText = "Commit Sale (Sale + Sale Item)";
  }
}

// ============================================================================
// 7. Interactive SQL Studio
// ============================================================================
function loadSQLPreset(key) {
  const query = SQL_PRESETS[key];
  if (query) {
    document.getElementById("sql-query-input").value = query;
  }
}

async function runSQLQuery() {
  const sqlInput = document.getElementById("sql-query-input");
  const telemetry = document.getElementById("sql-telemetry-text");
  const resultsContainer = document.getElementById("sql-results-container");
  const runBtn = document.getElementById("btn-run-sql");

  const queryText = sqlInput.value.trim();
  if (!queryText) return;

  runBtn.disabled = true;
  telemetry.innerText = "Executing on MySQL 8.0...";

  try {
    const res = await fetch("/api/sql-console", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ sql: queryText })
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Query execution failed");

    telemetry.innerText = `Success • ${data.execution_time_ms} ms (${data.row_count !== undefined ? data.row_count + ' rows' : data.affected_rows + ' affected'})`;

    if (data.columns && data.rows) {
      renderSQLResults(data.columns, data.rows);
    } else {
      resultsContainer.innerHTML = `
        <div style="padding: 24px; color: var(--primary); font-family: var(--font-mono); font-size: 13px;">
          ✓ Statement executed successfully. Rows affected: ${data.affected_rows} (in ${data.execution_time_ms} ms)
        </div>
      `;
    }

  } catch (err) {
    telemetry.innerText = "Query Error";
    resultsContainer.innerHTML = `
      <div style="padding: 24px; color: var(--danger); font-family: var(--font-mono); font-size: 13px;">
        ✕ MySQL Error: ${err.message}
      </div>
    `;
  } finally {
    runBtn.disabled = false;
  }
}

function renderSQLResults(columns, rows) {
  const container = document.getElementById("sql-results-container");
  if (rows.length === 0) {
    container.innerHTML = '<div class="empty-sql-prompt">Query returned 0 rows.</div>';
    return;
  }

  let html = `
    <div class="table-responsive" style="max-height: 380px; overflow-y: auto;">
      <table class="studio-table">
        <thead>
          <tr>
            ${columns.map(c => `<th>${c}</th>`).join("")}
          </tr>
        </thead>
        <tbody>
          ${rows.map(r => `
            <tr>
              ${columns.map(c => {
                const val = r[c] !== null && r[c] !== undefined ? r[c] : '<span style="color:var(--ink-faint)">NULL</span>';
                return `<td>${val}</td>`;
              }).join("")}
            </tr>
          `).join("")}
        </tbody>
      </table>
    </div>
  `;
  container.innerHTML = html;
}

// ============================================================================
// Deletion Handlers with Referential Integrity Confirmation
// ============================================================================
function confirmDelete(type, id, label) {
  pendingDelete = { type, id, label };
  const modal = document.getElementById("confirm-delete-modal");
  const title = document.getElementById("delete-modal-title");
  const desc = document.getElementById("delete-modal-desc");
  const btn = document.getElementById("btn-confirm-delete");

  if (type === "animal") {
    title.innerText = `Delete Cattle: ${label}`;
    desc.innerHTML = `Are you sure you want to permanently delete cattle <strong>${label}</strong> (ID: #${id}) from <code>animal</code>?`;
  } else if (type === "milk") {
    title.innerText = `Delete Milking Session: #${id}`;
    desc.innerHTML = `Are you sure you want to delete session <strong>#${id}</strong>? This also purges the associated yield record from <code>milk_yield</code>.`;
  } else if (type === "sale") {
    title.innerText = `Delete Commercial Invoice: #${id}`;
    desc.innerHTML = `Are you sure you want to delete invoice <strong>${label}</strong>? This cascades into <code>sale_item</code> and <code>payment</code> records.`;
  } else if (type === "quality") {
    title.innerText = `Delete Quality Assay: #${id}`;
    desc.innerHTML = `Are you sure you want to delete quality assay <strong>${label}</strong> from <code>quality_test</code>?`;
  } else if (type === "feed") {
    title.innerText = `Cancel Feed Dispensation: #${id}`;
    desc.innerHTML = `Are you sure you want to cancel feed dispensation <strong>${label}</strong>? This automatically returns the dispensed units back into warehouse stock.`;
  }

  btn.onclick = executeDelete;
  modal.classList.remove("hidden");
}

function closeDeleteModal() {
  document.getElementById("confirm-delete-modal").classList.add("hidden");
  pendingDelete = { type: null, id: null, label: null };
}

async function executeDelete() {
  const btn = document.getElementById("btn-confirm-delete");
  btn.disabled = true;
  btn.innerText = "Deleting...";

  const { type, id, label } = pendingDelete;
  
  let endpoint = "";
  let targetTable = "";

  if (type === "animal") {
    endpoint = `/api/animals/${id}`;
    targetTable = "animal";
  } else if (type === "milk") {
    endpoint = `/api/milk-records/${id}`;
    targetTable = "milk_yield";
  } else if (type === "sale") {
    endpoint = `/api/sales/${id}`;
    targetTable = "sale";
  } else if (type === "quality") {
    endpoint = `/api/quality-records/${id}`;
    targetTable = "quality_test";
  } else if (type === "feed") {
    endpoint = `/api/feed-issues/${id}`;
    targetTable = "feed_issue";
  }

  try {
    const res = await fetch(endpoint, { method: "DELETE" });
    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Delete operation failed");

    closeDeleteModal();
    showTxLog(`DELETE ${type.toUpperCase()}`, data.message, targetTable, data.before_count, data.after_count, "-1");

    if (type === "animal") {
      loadAnimals();
    } else if (type === "milk") {
      loadMilkRecords();
      loadAvailableYields();
    } else if (type === "sale") {
      loadSalesRecords();
    } else if (type === "quality") {
      loadQualityRecords();
    } else if (type === "feed") {
      loadFeedRecords();
    }
    loadDashboardData();
  } catch (err) {
    alert(`Delete Failed: ${err.message}`);
  } finally {
    btn.disabled = false;
    btn.innerText = "Execute SQL DELETE";
  }
}

// ============================================================================
// Live Transaction Audit Banner
// ============================================================================
function showTxLog(type, message, table, beforeVal, afterVal, delta) {
  const banner = document.getElementById("tx-log-container");
  document.getElementById("tx-type-tag").innerText = type;
  document.getElementById("tx-message").innerText = message;
  document.getElementById("tx-table-name").innerText = table;
  document.getElementById("tx-before-val").innerText = `${beforeVal} rows`;
  document.getElementById("tx-after-val").innerText = `${afterVal} rows`;
  document.getElementById("tx-delta-val").innerText = delta;

  banner.classList.remove("hidden");
}

function closeTxLog() {
  document.getElementById("tx-log-container").classList.add("hidden");
}

// ============================================================================
// 7. Barely Visible Info Hover & Intelligent DBMS Popover Engine
// ============================================================================

const INFO_CATALOG = {
  // Topbar & Branding
  schema_db: {
    category: "DATABASE CATALOG",
    pill: "MySQL InnoDB 8.0",
    title: "Catalog: dairy_farm_db",
    desc: "Central relational database schema hosting 14 normalized tables spanning livestock biology, milking shifts, feed stocks, quality assays, and commercial sales.",
    grid: { "Database": "dairy_farm_db", "Engine": "InnoDB", "Charset": "utf8mb4", "Host": "localhost:3306" },
    rule: "ACID Transactional Isolation: REPEATABLE READ"
  },
  badge_mysql: {
    category: "LIVE CONNECTION",
    pill: "Active Socket",
    title: "Active Schema: dairy_farm_db",
    desc: "Connected directly to live MySQL Server 8.0 running on localhost:3306 with zero mocking or in-memory emulation.",
    grid: { "Driver": "mysql-connector-python", "Pool Size": "5", "Timeout": "10s", "Port": "3306" },
    rule: "Direct TCP socket connection with real ACID transactions"
  },
  badge_3nf: {
    category: "SCHEMA INTEGRITY",
    pill: "Third Normal Form",
    title: "14 Tables • 100% 3NF Verified",
    desc: "Every non-key attribute is non-transitively dependent solely on primary candidate keys. Sales headers and line-items are isolated across 'sale' and 'sale_item'.",
    grid: { "1NF": "Atomic Column Values", "2NF": "Zero Partial Dependencies", "3NF": "Zero Transitive Dependencies" },
    rule: "Referential Integrity enforced via Foreign Key constraints"
  },
  theme_toggle: {
    category: "INTERFACE CONTROLLER",
    pill: "Dynamic CSS Tokens",
    title: "Light / Dark Theme Switcher",
    desc: "Switches between High-Contrast Clean Light Mode and Obsidian Dark Mode. State is persisted in localStorage.",
    grid: { "Default": "Light Theme", "Storage Key": "dairy_studio_theme", "Mode": "CSS Data Attribute" },
    rule: "Instant token swap without page reload"
  },
  btn_register_cattle: {
    category: "TRANSACTION DISPATCHER",
    pill: "Atomic INSERT",
    title: "Register Cattle Modal",
    desc: "Launches cattle registration dialog. Executes INSERT INTO animal with foreign key validation against table 'breed'.",
    grid: { "Target Table": "animal", "Primary Key": "animal_id (AUTO_INCREMENT)", "Foreign Key": "breed_id -> breed" },
    rule: "animal_tag must be unique across the herd"
  },
  btn_log_yield: {
    category: "TRANSACTION DISPATCHER",
    pill: "Atomic INSERT",
    title: "Log Milk Yield Modal",
    desc: "Records daily milk harvest session. Inserts into milking_session and milk_yield within a single database transaction.",
    grid: { "Tables": "milking_session, milk_yield", "Validation": "quantity_litres > 0", "Shifts": "Morning / Evening" },
    rule: "Enforces valid date and positive yield volume"
  },
  btn_sell_milk: {
    category: "COMMERCIAL TRANSACTION",
    pill: "3NF Multi-Table Commit",
    title: "Sell Milk (Commercial Invoice)",
    desc: "Generates commercial sale invoice. Commits records to 'sale', 'sale_item', and 'payment' tables atomically in MySQL.",
    grid: { "Header Table": "sale", "Line Items": "sale_item", "Receipts": "payment", "Trigger": "after_sale_item" },
    rule: "Automatic financial calculation: Total = Quantity * Unit Price"
  },
  btn_dispense_feed: {
    category: "TRANSACTION DISPATCHER",
    pill: "Trigger Enforced",
    title: "Dispense Feed Modal",
    desc: "Dispenses nutritional rations to cattle. Automatically reduces available warehouse inventory in table feed_item.",
    grid: { "Target Table": "feed_issue", "Trigger 1": "before_feed_issue (blocks overdraft)", "Trigger 2": "after_feed_issue (decrements stock)" },
    rule: "MySQL Trigger raises SQLSTATE 45000 if dispensed quantity > available stock"
  },

  // Sidebar Modules
  mod_dashboard: {
    category: "TELEMETRY ENGINE",
    pill: "Live SQL Rollups",
    title: "Enterprise Telemetry Dashboard",
    desc: "High-level operational metrics aggregated directly from MySQL InnoDB tables via live analytical SQL queries.",
    grid: { "Tables Involved": "animal, milk_yield, sale, feed_item", "Update Frequency": "Real-time on action" },
    rule: "Pulls un-cached, live aggregate state"
  },
  mod_herd: {
    category: "MASTER ENTITY",
    pill: "Table: animal",
    title: "Cattle Master Registry",
    desc: "Core biological livestock entity tracking ear tags, breed taxonomy, date of birth, sex, and health status.",
    grid: { "Primary Key": "animal_id", "Candidate Key": "animal_tag (UNIQUE)", "Foreign Key": "breed_id -> breed" },
    rule: "Maintains referential integrity with lactation sessions"
  },
  mod_milk: {
    category: "OPERATIONAL TRANSACTIONS",
    pill: "Tables: milking_session, milk_yield",
    title: "Milk Collection & Yield",
    desc: "Time-series production logging partitioned into Morning/Evening milking shifts for lactation yield analytics.",
    grid: { "Parent Table": "milking_session", "Child Table": "milk_yield", "Check Constraint": "quantity_litres > 0" },
    rule: "Atomic multi-table inserts track daily production"
  },
  mod_quality: {
    category: "LABORATORY METRICS",
    pill: "Table: quality_test",
    title: "Quality Control Lab",
    desc: "Analyzes harvested milk lots for commercial grade assessment based on Butterfat %, SNF %, and Density.",
    grid: { "Fat Range": "2.5% - 8.5%", "SNF Range": "7.5% - 10.5%", "Grade Standard": "Fat >= 3.5%, SNF >= 8.5%" },
    rule: "Determines Grade A Premium tier bonus"
  },
  mod_feed: {
    category: "INVENTORY & TRIGGERS",
    pill: "Tables: feed_item, feed_issue",
    title: "Feed & Nutrition Stock",
    desc: "Warehouse inventory management with MySQL triggers 'before_feed_issue' (blocks negative stock) and 'after_feed_issue' (updates stock).",
    grid: { "Trigger 1": "before_feed_issue (BEFORE INSERT)", "Trigger 2": "after_feed_issue (AFTER INSERT)" },
    rule: "Prevents warehouse inventory overdrafts"
  },
  mod_sales: {
    category: "FINANCIAL LEDGER",
    pill: "Tables: sale, sale_item, payment",
    title: "Commercial Sales & Accounts",
    desc: "3NF normalized commercial billing linking buyers, milk yields, itemized lot pricing, and payment receipts.",
    grid: { "Header": "sale", "Line Items": "sale_item", "Receipts": "payment", "Normal Form": "3NF" },
    rule: "Eliminates duplicate client addresses and price redundancies"
  },
  mod_sql: {
    category: "QUERY CONSOLE",
    pill: "Live SQL Runner",
    title: "Interactive SQL Studio",
    desc: "Direct execution console to run live SELECT queries, 7-table JOINs, subqueries, and aggregation reports directly on MySQL.",
    grid: { "Execution Mode": "Read-Only SELECT", "Presets": "Q29, Shift Aggregates, Quality Grades" },
    rule: "Safety guard blocks destructive DDL/DML in studio"
  },
  mod_schema: {
    category: "DATA DICTIONARY",
    pill: "information_schema",
    title: "Information Schema Inspector",
    desc: "Examines MySQL information_schema.tables and columns to inspect primary keys, foreign keys, and indexes in real time.",
    grid: { "Catalog": "information_schema", "Scope": "dairy_farm_db", "Table Count": "14" },
    rule: "Live introspection of metadata catalog"
  },
  db_conn: {
    category: "DATABASE CONNECTION",
    pill: "localhost:3306",
    title: "MySQL Server 8.0.46",
    desc: "Local database service running InnoDB storage engine with Repeatable-Read isolation level.",
    grid: { "Host": "127.0.0.1", "Port": "3306", "Storage Engine": "InnoDB", "Isolation": "Repeatable Read" },
    rule: "Full ACID transaction compliance"
  },

  // Dashboard KPIs
  kpi_herd: {
    category: "AGGREGATE METRIC",
    pill: "COUNT(*)",
    title: "Total Registered Headcount",
    desc: "Headcount of all cataloged cattle in the database. Indexed by unique ear tag identifiers for rapid O(1) retrieval.",
    grid: { "Query": "SELECT COUNT(*) FROM animal", "Indexed Column": "animal_tag (UNIQUE)", "Storage Engine": "InnoDB" },
    rule: "Includes active, sold, and transferred livestock"
  },
  kpi_milk: {
    category: "AGGREGATE METRIC",
    pill: "SUM(quantity_litres)",
    title: "Cumulative Milk Yield",
    desc: "Total volume of milk harvested across all historical morning and evening milking sessions in litres.",
    grid: { "Query": "SELECT SUM(quantity_litres) FROM milk_yield", "Unit": "Litres (L)", "Data Type": "DECIMAL(6,2)" },
    rule: "CHECK (quantity_litres BETWEEN 0.5 AND 50.0)"
  },
  kpi_revenue: {
    category: "FINANCIAL METRIC",
    pill: "3NF Reconciled",
    title: "Commercial Invoiced Revenue",
    desc: "Aggregated billable value from all sales invoices. Reconciled across line items via the after_sale_item MySQL trigger.",
    grid: { "Query": "SELECT SUM(total_amount) FROM sale", "Currency": "INR (₹)", "Trigger": "after_sale_item" },
    rule: "Reconciled against receipts in payment table"
  },
  kpi_feed: {
    category: "INVENTORY METRIC",
    pill: "Reorder Trigger",
    title: "Feed Reorder Alerts",
    desc: "Real-time count of feed stock items that have fallen below their safety reorder thresholds in the warehouse.",
    grid: { "Query": "COUNT(*) WHERE available_quantity <= reorder_level", "Table": "feed_item", "Trigger": "before_feed_issue" },
    rule: "Alerts triggered automatically when stock drops below threshold"
  },
  panel_shifts: {
    category: "SHIFT TELEMETRY",
    pill: "GROUP BY session_type",
    title: "Milking Shift Harvest Distribution",
    desc: "Aggregates milk collection volume partitioned by Morning and Evening milking shifts to evaluate lactation efficiency.",
    grid: { "Query": "GROUP BY ms.session_type", "Tables": "milking_session JOIN milk_yield", "Metrics": "Total Litres & Averages" },
    rule: "Allows farm operators to detect shift yield discrepancies"
  },
  panel_quality: {
    category: "LABORATORY ASSAY",
    pill: "Quality Standards",
    title: "Laboratory Quality Averages",
    desc: "Average butterfat percentage, solids-not-fat (SNF), and specific gravity density from laboratory assays.",
    grid: { "Table": "quality_test", "Avg Fat Benchmark": "3.50% - 4.50%", "Avg SNF Benchmark": "8.50% - 9.20%" },
    rule: "Fat >= 3.50% and SNF >= 8.50% qualifies for Grade A Premium bonus"
  },
  panel_breeds: {
    category: "TAXONOMY DISTRIBUTION",
    pill: "GROUP BY breed_id",
    title: "Top 5 Cattle Breeds by Population",
    desc: "Demographic distribution of cattle breeds in the herd, showing registered headcounts per breed classification.",
    grid: { "Query": "COUNT(a.animal_id) GROUP BY b.breed_name", "Foreign Key": "animal.breed_id -> breed.breed_id" },
    rule: "Biological classification: Dairy Cattle / Dual-Purpose / Draught"
  },

  // Table Column Schemas
  "th-ear-tag": {
    category: "PRIMARY & UNIQUE KEY",
    pill: "animal_id / animal_tag",
    title: "Cattle Ear Tag Identifier",
    desc: "Unique RFID ear tag assigned to livestock at birth or intake. Indexed for immediate O(1) B-tree lookups.",
    grid: { "Table": "animal", "Data Type": "VARCHAR(20) UNIQUE", "Constraints": "NOT NULL, UNIQUE INDEX" },
    rule: "Unique identifier across the entire farm herd"
  },
  "th-animal-name": {
    category: "BIOLOGICAL NAME",
    pill: "Human Identifier",
    title: "Registered Cattle Name",
    desc: "Traditional farm pedigree name associated with internal animal_id (e.g., Nandini, Ganga, Mangala).",
    grid: { "Display": "Cattle Name + RFID Tag", "Pedigree": "Registered Herd Lineage" },
    rule: "Assigned to eliminate ambiguous raw database integer IDs"
  },
  "th-breed": {
    category: "FOREIGN KEY RELATION",
    pill: "breed_id -> breed",
    title: "Breed Classification",
    desc: "Normalized foreign key linking animal to its biological breed registry (e.g., Gir, Sahiwal, Murrah, Jersey).",
    grid: { "Table": "animal", "Referenced Table": "breed(breed_id)", "On Delete": "RESTRICT" },
    rule: "Deletion of breed is blocked if cattle records reference it"
  },
  "th-gender": {
    category: "ENUM ATTRIBUTE",
    pill: "gender ENUM",
    title: "Biological Sex",
    desc: "Gender of the animal: ENUM('Female', 'Male'). Female cattle yield milk, while males are documented for breeding.",
    grid: { "Table": "animal", "Values": "'Female', 'Male'", "Default": "'Female'" },
    rule: "Only female cows generate active milking_session records"
  },
  "th-dob": {
    category: "DATE ATTRIBUTE",
    pill: "date_of_birth",
    title: "Date of Birth",
    desc: "Date of birth of the animal. Used to derive biological age, lactation cycle periods, and health timelines.",
    grid: { "Table": "animal", "Data Type": "DATE", "Format": "YYYY-MM-DD" },
    rule: "Must be a valid historical date <= CURRENT_DATE"
  },
  "th-status": {
    category: "LIFECYCLE STATE",
    pill: "status ENUM",
    title: "Livestock Lifecycle Status",
    desc: "Active operational state: 'Active' (in herd), 'Sold' (commercial liquidation), 'Deceased', or 'Transferred'.",
    grid: { "Table": "animal", "Domain": "'Active', 'Sold', 'Deceased', 'Transferred'", "Default": "'Active'" },
    rule: "Sold or deceased animals are excluded from daily milking schedules"
  },
  "th-action": {
    category: "DATABASE OPERATION",
    pill: "Verified DML",
    title: "Interactive Database Actions",
    desc: "Interactive CRUD controls executing atomic SQL INSERT or DELETE statements with full foreign key validation.",
    grid: { "Supported": "DELETE, CASCADE, RESTORE", "Audit": "Before & After Delta Logging" },
    rule: "Referential integrity checked by MySQL engine before execution"
  },
  "th-yield-id": {
    category: "PRIMARY KEY",
    pill: "yield_id (PK)",
    title: "Harvest Lot ID",
    desc: "Primary key in table milk_yield representing an individual cow's measured yield in a given milking session.",
    grid: { "Table": "milk_yield", "Data Type": "INT AUTO_INCREMENT", "FK Link": "session_id -> milking_session" },
    rule: "Atomic lot yield linked to commercial sale items and quality tests"
  },
  "th-session-date": {
    category: "TEMPORAL LOG",
    pill: "session_date (DATE)",
    title: "Milking Harvest Date",
    desc: "Calendar date when the milking session was conducted and logged.",
    grid: { "Table": "milking_session", "Data Type": "DATE", "Format": "YYYY-MM-DD" },
    rule: "Recorded at shift commencement"
  },
  "th-session-time": {
    category: "TIME ATTRIBUTE",
    pill: "session_time (TIME)",
    title: "Harvest Timestamp",
    desc: "Exact clock time when the automated milking parlour completed the extraction session.",
    grid: { "Table": "milking_session", "Data Type": "TIME" },
    rule: "Morning (05:00-08:00) / Evening (16:00-19:00)"
  },
  "th-session-type": {
    category: "ENUM SESSION",
    pill: "session_type ENUM",
    title: "Milking Shift Type",
    desc: "Distinguishes between 'Morning' and 'Evening' shift harvest volumes for diurnal comparison.",
    grid: { "Table": "milking_session", "Values": "'Morning', 'Evening'" },
    rule: "Aggregated in dashboard shifts distribution panel"
  },
  "th-quantity-litres": {
    category: "DECIMAL MEASURE",
    pill: "quantity_litres",
    title: "Harvest Volume in Litres",
    desc: "Liquid milk extracted in litres measured to 2 decimal places with physical flow meters.",
    grid: { "Table": "milk_yield", "Data Type": "DECIMAL(5,2)", "Check": "CHECK (quantity_litres > 0)" },
    rule: "Enforces positive yield; zero or negative yields are rejected"
  },
  "th-test-id": {
    category: "PRIMARY KEY",
    pill: "test_id (PK)",
    title: "Laboratory Assay ID",
    desc: "Primary key in table quality_test representing an official biochemical quality audit of a milk lot.",
    grid: { "Table": "quality_test", "Data Type": "INT AUTO_INCREMENT", "FK Link": "yield_id -> milk_yield" },
    rule: "Certified laboratory record determining commercial pricing grade"
  },
  "th-fat": {
    category: "BIOCHEMICAL PARAMETER",
    pill: "fat_percentage",
    title: "Butterfat Percentage (%)",
    desc: "Fat solids percentage in harvested milk. Crucial metric for dairy pricing in India (FAT-based payment).",
    grid: { "Table": "quality_test", "Data Type": "DECIMAL(4,2)", "Normal Range": "3.20% - 6.50%" },
    rule: "Butterfat >= 3.50% qualifies for Grade A rating"
  },
  "th-snf": {
    category: "BIOCHEMICAL PARAMETER",
    pill: "snf_percentage",
    title: "Solids-Not-Fat Percentage (SNF %)",
    desc: "Protein, lactose, and essential mineral solids content excluding fat.",
    grid: { "Table": "quality_test", "Data Type": "DECIMAL(4,2)", "Standard Minimum": "8.50%" },
    rule: "FSSAI legal benchmark: SNF must meet or exceed 8.50%"
  },
  "th-density": {
    category: "PHYSICAL PROPERTY",
    pill: "density",
    title: "Specific Gravity Density",
    desc: "Specific gravity relative to pure water measured with a certified lactometer at 20°C.",
    grid: { "Table": "quality_test", "Data Type": "DECIMAL(5,3)", "Standard Range": "1.026 - 1.032" },
    rule: "Detects water adulteration or skimming in real time"
  },
  "th-quality-grade": {
    category: "DERIVED CLASSIFICATION",
    pill: "CASE Rating",
    title: "Quality Classification Rating",
    desc: "Computed tier: 'Grade A Premium' when Fat >= 3.5% & SNF >= 8.5%, otherwise 'Standard Grade'.",
    grid: { "Logic": "CASE WHEN fat>=3.5 AND snf>=8.5 THEN Grade A", "Impact": "+10% price premium per litre" },
    rule: "Automated business logic evaluation"
  },
  "th-feed-item": {
    category: "INVENTORY MASTER",
    pill: "feed_id / feed_name",
    title: "Feed Commodity Name",
    desc: "Nutritional fodder or concentrate ration stored in the dairy warehouse (e.g. Napier Green Fodder, Wheat Bran).",
    grid: { "Table": "feed_item", "Data Type": "VARCHAR(100)", "Unit": "kg, quintals" },
    rule: "Monitored against warehouse reorder safety levels"
  },
  "th-unit": {
    category: "MEASUREMENT UNIT",
    pill: "unit (VARCHAR)",
    title: "Inventory Unit of Measure",
    desc: "Metric or commercial measurement unit (e.g., kg, litres, bundles).",
    grid: { "Table": "feed_item", "Data Type": "VARCHAR(20)" },
    rule: "Standardizes quantity calculations"
  },
  "th-feed-stock": {
    category: "INVENTORY BALANCE",
    pill: "available_quantity",
    title: "Available Warehouse Stock",
    desc: "Current on-hand warehouse inventory. Updated in real time whenever rations are dispensed.",
    grid: { "Table": "feed_item", "Data Type": "DECIMAL(8,2)", "Trigger": "after_feed_issue" },
    rule: "Trigger before_feed_issue prevents stock dropping below zero"
  },
  "th-reorder-level": {
    category: "SAFETY THRESHOLD",
    pill: "reorder_level",
    title: "Reorder Safety Level",
    desc: "Minimum buffer quantity below which automated replenishment alerts are flagged.",
    grid: { "Table": "feed_item", "Data Type": "DECIMAL(8,2)" },
    rule: "Dashboard KPI counts items where available_quantity <= reorder_level"
  },
  "th-feed-status": {
    category: "INVENTORY STATUS",
    pill: "Stock Indicator",
    title: "Stock Availability Status",
    desc: "Visual indicator: 'Sufficient' or 'Reorder Alert' depending on whether available quantity is below reorder level.",
    grid: { "Status Options": "Sufficient / Reorder Required" },
    rule: "Alerts operational managers to place purchase orders"
  },
  "th-issue-id": {
    category: "PRIMARY KEY",
    pill: "issue_id (PK)",
    title: "Feed Dispensation ID",
    desc: "Primary key in table feed_issue tracking the issuance of feed to a specific cow.",
    grid: { "Table": "feed_issue", "Data Type": "INT AUTO_INCREMENT", "FK Link": "feed_id, animal_id" },
    rule: "Fires trigger after_feed_issue upon INSERT"
  },
  "th-invoice-id": {
    category: "PRIMARY KEY",
    pill: "sale_id (PK)",
    title: "Sales Invoice Identifier",
    desc: "Header primary key in 3NF table sale representing a commercial transaction with a dairy cooperative.",
    grid: { "Table": "sale", "Data Type": "INT AUTO_INCREMENT", "FK Link": "buyer_id -> buyer" },
    rule: "Cascades to line items in sale_item and payments in payment"
  },
  "th-buyer": {
    category: "CLIENT RELATION",
    pill: "buyer_id -> buyer",
    title: "Buyer / Dairy Cooperative",
    desc: "Registered commercial client receiving bulk milk shipments (e.g., Amul, Mother Dairy, Heritage Foods).",
    grid: { "Table": "buyer", "Columns": "buyer_name, contact, address" },
    rule: "3NF entity isolating buyer attributes from transaction line items"
  },
  "th-contact": {
    category: "CLIENT CONTACT",
    pill: "contact (VARCHAR)",
    title: "Buyer Contact Number",
    desc: "Verified telephone or mobile contact number for invoice billing and coordination.",
    grid: { "Table": "buyer", "Column": "contact" },
    rule: "Used for delivery and billing notifications"
  },
  "th-invoice-date": {
    category: "TRANSACTION DATE",
    pill: "sale_date (DATE)",
    title: "Commercial Invoice Date",
    desc: "Calendar date on which the commercial milk sale transaction occurred.",
    grid: { "Table": "sale", "Data Type": "DATE" },
    rule: "Determines accounting period and payment due terms"
  },
  "th-billed-total": {
    category: "AGGREGATED FINANCIAL",
    pill: "total_amount",
    title: "Billed Invoice Total (₹)",
    desc: "Total currency amount invoiced for all milk lots sold in this commercial transaction.",
    grid: { "Table": "sale", "Data Type": "DECIMAL(10,2)", "Trigger": "after_sale_item" },
    rule: "Reconciled from line items: SUM(quantity_sold * unit_price)"
  },
  "th-amount-paid": {
    category: "CASH RECEIPT",
    pill: "SUM(payment.amount)",
    title: "Total Amount Received (₹)",
    desc: "Total monetary receipts paid by the buyer towards this specific invoice.",
    grid: { "Table": "payment", "Data Type": "DECIMAL(10,2)", "Modes": "UPI, Cash, Bank Transfer" },
    rule: "Linked via sale_id; supports multiple partial installment payments"
  },
  "th-balance-due": {
    category: "OUTSTANDING CREDIT",
    pill: "Derived Balance",
    title: "Outstanding Balance Due (₹)",
    desc: "Remaining unpaid amount calculated as: Billed Total - Amount Paid.",
    grid: { "Formula": "total_amount - amount_paid", "Status": "₹0.00 denotes fully settled" },
    rule: "Triggers accounts receivable credit follow-up if balance > 0"
  }
};

const TABLE_HEADER_SCHEMAS = {
  "breed name": "th-breed",
  "registered headcount": "th-count",
  "biological category": "th-category",
  "ear tag / id": "th-ear-tag",
  "cattle name": "th-animal-name",
  "breed": "th-breed",
  "sex": "th-gender",
  "gender": "th-gender",
  "date of birth": "th-dob",
  "status": "th-status",
  "action": "th-action",
  "actions": "th-action",
  "yield id": "th-yield-id",
  "cattle / ear tag": "th-ear-tag",
  "ear tag & cattle": "th-ear-tag",
  "harvest date": "th-session-date",
  "harvest time": "th-session-time",
  "milking shift": "th-session-type",
  "shift / session": "th-session-type",
  "quantity (litres)": "th-quantity-litres",
  "assay id": "th-test-id",
  "harvest milk lot": "th-yield-id",
  "butterfat %": "th-fat",
  "snf solids %": "th-snf",
  "specific density": "th-density",
  "quality rating": "th-quality-grade",
  "commodity name": "th-feed-item",
  "feed item": "th-feed-item",
  "unit measure": "th-unit",
  "available stock": "th-feed-stock",
  "reorder level": "th-reorder-level",
  "inventory status": "th-feed-status",
  "issue #": "th-issue-id",
  "dispensed date": "th-session-date",
  "quantity": "th-quantity-litres",
  "invoice #": "th-invoice-id",
  "buyer / co-operative": "th-buyer",
  "contact": "th-contact",
  "invoice date": "th-invoice-date",
  "billed total": "th-billed-total",
  "amount paid": "th-amount-paid",
  "balance due": "th-balance-due"
};

function resolveInfoData(el) {
  if (!el) return null;

  // 1. Direct or closest data-info-key
  const keyEl = el.closest("[data-info-key]");
  if (keyEl) {
    const key = keyEl.getAttribute("data-info-key");
    if (INFO_CATALOG[key]) return INFO_CATALOG[key];
  }

  // 2. Direct or closest data-info-entity
  const entEl = el.closest("[data-info-entity]");
  if (entEl) {
    const ent = entEl.getAttribute("data-info-entity");
    return buildEntityInfo(ent, entEl);
  }

  return null;
}

function buildEntityInfo(ent, el) {
  switch (ent) {
    case "animal_pk": {
      const id = el.getAttribute("data-id");
      const name = getCattleName(id);
      return {
        category: "PRIMARY KEY",
        pill: "animal.animal_id",
        title: `Internal Cattle PK: #${id}`,
        desc: `Surrogate primary key auto-incremented by MySQL InnoDB storage engine. Uniquely represents ${name} in the system.`,
        grid: { "Table": "animal", "Column": "animal_id", "Type": "INT AUTO_INCREMENT", "Key": "PRIMARY KEY" },
        rule: "Referenced by foreign keys in milking_session and feed_issue"
      };
    }
    case "cattle": {
      const id = el.getAttribute("data-id");
      const tag = el.getAttribute("data-tag") || "TAG";
      const name = el.getAttribute("data-name") || getCattleName(id);
      const breed = el.getAttribute("data-breed") || "Dairy Cattle";
      const gender = el.getAttribute("data-gender") || "Female";
      const status = el.getAttribute("data-status") || "Active";
      const dob = el.getAttribute("data-dob") || "Recorded";
      return {
        category: "LIVESTOCK MASTER",
        pill: `Ear Tag: ${tag}`,
        title: `${name} (#${id} • ${tag})`,
        desc: `Registered dairy cow in active farm inventory. Biological records, lactation cycles, and health logs are linked to this cow.`,
        grid: { "Pedigree Name": name, "Ear Tag": tag, "Breed": breed, "Gender": gender, "Status": status, "Born": dob },
        rule: "3NF master entity with zero duplicate cattle attributes"
      };
    }
    case "breed": {
      const breed = el.getAttribute("data-breed") || "Standard";
      return {
        category: "TAXONOMY REGISTRY",
        pill: "breed(breed_id)",
        title: `Breed: ${breed}`,
        desc: `Biological cattle breed classification. Foreign key constraint prevents orphan animals and restricts deletion of referenced breeds.`,
        grid: { "Table": "breed", "Breed Name": breed, "Category": "Dairy Cattle", "On Delete": "RESTRICT" },
        rule: "Foreign key validation in animal.breed_id"
      };
    }
    case "gender": {
      const gender = el.getAttribute("data-gender") || "Female";
      return {
        category: "BIOLOGICAL SEX",
        pill: "gender ENUM",
        title: `Gender: ${gender}`,
        desc: `Cattle biological gender. Female cows participate in milk yield harvesting and lactation analytics.`,
        grid: { "Table": "animal", "Values": "'Female', 'Male'", "Milking Role": gender === 'Female' ? 'Active Lactation' : 'Sire / Breeding' },
        rule: "Validation enforced by MySQL ENUM constraint"
      };
    }
    case "dob": {
      const dob = el.getAttribute("data-dob") || "YYYY-MM-DD";
      return {
        category: "DATE ATTRIBUTE",
        pill: "date_of_birth",
        title: `Birth Date: ${dob}`,
        desc: `Official birth record date in table animal. Used to compute age, lactation milestones, and breeding readiness.`,
        grid: { "Table": "animal", "Column": "date_of_birth", "Type": "DATE" },
        rule: "Must be a valid historical date"
      };
    }
    case "animal_status": {
      const status = el.getAttribute("data-status") || "Active";
      return {
        category: "LIFECYCLE STATE",
        pill: "status ENUM",
        title: `Lifecycle State: ${status}`,
        desc: status === "Active" 
          ? "Animal is in prime health and actively eligible for daily milking sessions and standard nutritional rations."
          : `Animal marked as ${status}. Excluded from daily automated milking parlour harvest queues.`,
        grid: { "Table": "animal", "Column": "status", "State": status, "Operational": status === "Active" ? "Enabled" : "Archived" },
        rule: "State changes preserve historical milk yield logs"
      };
    }
    case "session_pk": {
      const id = el.getAttribute("data-id");
      return {
        category: "PRIMARY KEY",
        pill: "milking_session.session_id",
        title: `Milking Session #${id}`,
        desc: `Primary key of milking session header linking animal, shift, date, and extracted volume.`,
        grid: { "Table": "milking_session", "Type": "INT AUTO_INCREMENT", "Key": "PRIMARY" },
        rule: "Atomic parent record for milk_yield child lots"
      };
    }
    case "shift_badge": {
      const shift = el.getAttribute("data-shift") || "Shift";
      return {
        category: "MILKING SHIFT",
        pill: "session_type",
        title: `${shift} Milking Shift`,
        desc: `${shift} extraction session. Morning milking typically accounts for 50-55% of daily farm volume due to nocturnal rest.`,
        grid: { "Shift": shift, "Table": "milking_session", "Interval": shift === "Morning" ? "05:00 - 08:00" : "16:00 - 19:00" },
        rule: "Enforced via ENUM('Morning', 'Evening')"
      };
    }
    case "quantity_metric": {
      const qty = el.getAttribute("data-qty") || "0.0";
      return {
        category: "DECIMAL MEASURE",
        pill: "quantity_litres",
        title: `Harvest Yield: ${qty} L`,
        desc: `Measured volume of extracted milk in litres. Enforced with MySQL check constraint to reject non-positive quantities.`,
        grid: { "Table": "milk_yield", "Volume": `${qty} Litres`, "Check": "CHECK (quantity_litres > 0)" },
        rule: "Physical flow-meter calibrated yield logging"
      };
    }
    case "quality_pk": {
      const id = el.getAttribute("data-id");
      return {
        category: "PRIMARY KEY",
        pill: "quality_test.test_id",
        title: `Laboratory Assay #${id}`,
        desc: `Certified quality assurance test verifying biochemical composition and purity of a specific milk lot.`,
        grid: { "Table": "quality_test", "Key": "test_id (PK)", "Reference": "yield_id -> milk_yield" },
        rule: "Quality audit required prior to commercial bulk dispatch"
      };
    }
    case "yield_lot_ref": {
      const id = el.getAttribute("data-id");
      return {
        category: "FOREIGN KEY LINK",
        pill: "yield_id -> milk_yield",
        title: `Harvest Lot Ref: #${id}`,
        desc: `Direct foreign key reference pointing to the specific milk yield lot tested by this laboratory assay.`,
        grid: { "Foreign Key": "quality_test.yield_id", "Referenced": "milk_yield.yield_id" },
        rule: "Maintains referential integrity between production and QC"
      };
    }
    case "fat_metric": {
      const fat = el.getAttribute("data-fat") || "0.0";
      return {
        category: "BIOCHEMICAL ASSAY",
        pill: "fat_percentage",
        title: `Butterfat: ${fat}%`,
        desc: `Lipid concentration in milk. Crucial metric for dairy pricing in India where co-operatives pay a rate per kg fat.`,
        grid: { "Assay": "Butterfat %", "Value": `${fat}%`, "Grade A Threshold": ">= 3.50%" },
        rule: "Standard cow milk: 3.5% to 4.5% butterfat"
      };
    }
    case "snf_metric": {
      const snf = el.getAttribute("data-snf") || "0.0";
      return {
        category: "BIOCHEMICAL ASSAY",
        pill: "snf_percentage",
        title: `SNF Solids: ${snf}%`,
        desc: `Solids-Not-Fat (protein, lactose, and minerals). Legal regulatory minimum in India set by FSSAI is 8.50%.`,
        grid: { "Assay": "SNF %", "Value": `${snf}%`, "FSSAI Benchmark": ">= 8.50%" },
        rule: "Below 8.50% triggers water dilution investigation"
      };
    }
    case "density_metric": {
      const den = el.getAttribute("data-density") || "1.030";
      return {
        category: "PHYSICAL DENSITY",
        pill: "density",
        title: `Specific Density: ${den}`,
        desc: `Lactometer specific gravity reading measured at 20°C. Standard pure milk ranges from 1.028 to 1.034.`,
        grid: { "Metric": "Specific Gravity", "Value": den, "Benchmark": "1.028 - 1.034" },
        rule: "Values < 1.026 indicate water adulteration"
      };
    }
    case "quality_rating": {
      const rating = el.getAttribute("data-rating") || "Standard";
      const isGradeA = rating === "Grade A Premium";
      return {
        category: "GRADE CLASSIFICATION",
        pill: isGradeA ? "Tier 1: Premium" : "Tier 2: Standard",
        title: `Rating: ${rating}`,
        desc: isGradeA
          ? "Certified Grade A Premium milk: Meets both Fat >= 3.50% and SNF >= 8.50%. Earns a 10% premium bonus in commercial sales."
          : "Standard Grade milk: Meets regulatory requirements for commercial consumption and processing.",
        grid: { "Grade": rating, "Fat Check": isGradeA ? "Pass (>=3.5%)" : "Standard", "SNF Check": isGradeA ? "Pass (>=8.5%)" : "Standard" },
        rule: "Computed via SQL CASE expression on assay parameters"
      };
    }
    case "feed_item": {
      const name = el.getAttribute("data-name") || "Feed";
      const qty = el.getAttribute("data-qty") || "0";
      const unit = el.getAttribute("data-unit") || "kg";
      return {
        category: "WAREHOUSE COMMODITY",
        pill: "feed_item",
        title: `Feed: ${name}`,
        desc: `Nutritional ration stored in dairy inventory. Fodder allocations are tracked to monitor per-cow feed conversion efficiency.`,
        grid: { "Commodity": name, "Stock": `${qty} ${unit}`, "Table": "feed_item" },
        rule: "Decremented automatically by trigger after_feed_issue"
      };
    }
    case "feed_stock_val": {
      const qty = el.getAttribute("data-qty") || "0";
      const unit = el.getAttribute("data-unit") || "kg";
      return {
        category: "INVENTORY QUANTITY",
        pill: "available_quantity",
        title: `Available Stock: ${qty} ${unit}`,
        desc: `Current warehouse stock level. Decremented by AFTER INSERT trigger on feed_issue.`,
        grid: { "Table": "feed_item", "Stock": `${qty} ${unit}`, "Trigger": "after_feed_issue" },
        rule: "Trigger before_feed_issue prevents stock dropping below zero"
      };
    }
    case "feed_reorder_level": {
      const lvl = el.getAttribute("data-level") || "0";
      return {
        category: "SAFETY THRESHOLD",
        pill: "reorder_level",
        title: `Reorder Threshold: ${lvl}`,
        desc: `Safety stock buffer quantity. When warehouse available inventory drops to or below this level, reorder alerts are triggered.`,
        grid: { "Table": "feed_item", "Column": "reorder_level", "Threshold": lvl },
        rule: "Monitored in real-time by dashboard KPI rollup"
      };
    }
    case "feed_alert": {
      const feed = el.getAttribute("data-feed") || "Feed";
      return {
        category: "INVENTORY ALERT",
        pill: "Stock Low",
        title: `Reorder Required: ${feed}`,
        desc: `Current stock has fallen below the minimum safety buffer! Immediate replenishment purchase order is required.`,
        grid: { "Commodity": feed, "State": "Below Safety Level", "Action": "Issue Purchase Order" },
        rule: "Fires warning indicator in warehouse management console"
      };
    }
    case "feed_sufficient": {
      const feed = el.getAttribute("data-feed") || "Feed";
      return {
        category: "INVENTORY STATUS",
        pill: "Stock Safe",
        title: `Stock Safe: ${feed}`,
        desc: `Warehouse stock is healthy and comfortably exceeds the minimum safety reorder threshold.`,
        grid: { "Commodity": feed, "State": "Sufficient Buffer" },
        rule: "Dispensation requests can proceed without overdraft risk"
      };
    }
    case "issue_pk": {
      const id = el.getAttribute("data-id");
      return {
        category: "PRIMARY KEY",
        pill: "feed_issue.issue_id",
        title: `Dispensation Log #${id}`,
        desc: `Log record of feed issued to cattle. Execution verified by MySQL trigger before_feed_issue to prevent inventory overdrafts.`,
        grid: { "Table": "feed_issue", "Trigger 1": "before_feed_issue", "Trigger 2": "after_feed_issue" },
        rule: "Auto-decrements available inventory in table feed_item"
      };
    }
    case "dispensed_qty": {
      const qty = el.getAttribute("data-qty") || "0";
      const unit = el.getAttribute("data-unit") || "kg";
      return {
        category: "DISPENSED RATION",
        pill: "quantity",
        title: `Dispensed: ${qty} ${unit}`,
        desc: `Quantity of feed issued to cattle in this transaction. Subtracted from available warehouse stock.`,
        grid: { "Table": "feed_issue", "Amount": `${qty} ${unit}`, "Trigger": "after_feed_issue" },
        rule: "Verified against available stock prior to INSERT"
      };
    }
    case "sale_pk": {
      const id = el.getAttribute("data-id");
      return {
        category: "3NF INVOICE HEADER",
        pill: "sale.sale_id",
        title: `Invoice #${id}`,
        desc: `Commercial sales invoice header in 3NF table sale. Linked to itemized lots in sale_item and payment receipts in payment.`,
        grid: { "Table": "sale", "Normal Form": "3NF", "Line Items": "sale_item", "Receipts": "payment" },
        rule: "Foreign key cascades handle billing cleanup"
      };
    }
    case "buyer_entity": {
      const buyer = el.getAttribute("data-buyer") || "Buyer";
      const contact = el.getAttribute("data-contact") || "";
      return {
        category: "CLIENT PROFILE",
        pill: "buyer(buyer_id)",
        title: `Buyer: ${buyer}`,
        desc: `Registered commercial dairy co-operative or institutional milk buyer in table buyer.`,
        grid: { "Table": "buyer", "Name": buyer, "Contact": contact },
        rule: "Isolated from transaction line items to satisfy 3NF"
      };
    }
    case "sale_total_val": {
      const amt = el.getAttribute("data-amount") || "0.00";
      return {
        category: "INVOICED TOTAL",
        pill: "total_amount",
        title: `Billed Total: ₹${parseFloat(amt).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`,
        desc: `Computed invoice sum calculated from SUM(quantity_sold * unit_price) across all line items in sale_item.`,
        grid: { "Table": "sale", "Trigger": "after_sale_item", "Amount": `₹${amt}` },
        rule: "Reconciled with receipts in payment table"
      };
    }
    case "sale_paid_val": {
      const amt = el.getAttribute("data-amount") || "0.00";
      return {
        category: "CASH RECEIPT",
        pill: "payment.amount",
        title: `Amount Paid: ₹${parseFloat(amt).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`,
        desc: `Cumulative cash receipts logged in table payment matching this sale invoice. Supports multiple partial payments.`,
        grid: { "Table": "payment", "Foreign Key": "sale_id -> sale", "Amount": `₹${amt}` },
        rule: "Reduces outstanding balance due"
      };
    }
    case "sale_balance_val": {
      const bal = el.getAttribute("data-balance") || "0.00";
      const isPaid = parseFloat(bal) <= 0;
      return {
        category: "ACCOUNT BALANCE",
        pill: isPaid ? "Settled" : "Outstanding Credit",
        title: `Balance Due: ₹${parseFloat(bal).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`,
        desc: isPaid
          ? "This invoice has been fully paid and settled. Outstanding accounts receivable balance is ₹0.00."
          : `Outstanding credit balance of ₹${bal} awaiting collection from the buyer.`,
        grid: { "Formula": "total_amount - amount_paid", "Status": isPaid ? "Settled" : "Pending" },
        rule: "Reflected in live commercial revenue audit"
      };
    }
    case "sale_settled": {
      return {
        category: "SETTLEMENT STATE",
        pill: "Settled (100% Paid)",
        title: "Invoice Status: Settled",
        desc: "All billed charges for this commercial invoice have been reconciled and collected into table payment.",
        grid: { "Outstanding": "₹0.00", "State": "Settled", "Receipts": "Reconciled" },
        rule: "Commercial ledger verified"
      };
    }
    case "sale_pending": {
      return {
        category: "SETTLEMENT STATE",
        pill: "Balance Due",
        title: "Invoice Status: Balance Due",
        desc: "Invoice has an outstanding balance due. Partial or zero payment has been received to date.",
        grid: { "State": "Accounts Receivable", "Action": "Collect Payment" },
        rule: "Follow-up required with dairy co-operative"
      };
    }
    case "btn_delete_animal": {
      const name = el.getAttribute("data-name") || "Animal";
      return {
        category: "DML OPERATION",
        pill: "DELETE animal",
        title: `Delete Cattle: ${name}`,
        desc: `Executes SQL DELETE statement on table animal. Verifies foreign key constraints and audits before/after record count deltas.`,
        grid: { "Target Table": "animal", "Integrity Check": "ON DELETE RESTRICT", "Audit": "Delta Logging" },
        rule: "Confirmation dialog prevents accidental data deletion"
      };
    }
    case "btn_delete_milk": {
      return {
        category: "DML OPERATION",
        pill: "DELETE milking_session",
        title: "Delete Milking Session",
        desc: "Executes cascading DELETE statement in MySQL, removing the milking session and child milk yield record.",
        grid: { "Tables": "milking_session, milk_yield", "Cascade": "ON DELETE CASCADE" },
        rule: "Updates cumulative yield metrics across telemetry"
      };
    }
    case "btn_delete_quality": {
      return {
        category: "DML OPERATION",
        pill: "DELETE quality_test",
        title: "Delete Laboratory Assay",
        desc: "Deletes laboratory test record from table quality_test with live before/after audit verification.",
        grid: { "Target Table": "quality_test", "Audit": "Delta Banner" },
        rule: "Recalculates average butterfat and SNF telemetry"
      };
    }
    case "btn_delete_feed": {
      return {
        category: "DML OPERATION",
        pill: "DELETE feed_issue",
        title: "Cancel Feed Dispensation",
        desc: "Cancels feed dispensation log and automatically restores the issued quantity back to warehouse stock in feed_item.",
        grid: { "Action": "DELETE feed_issue + UPDATE feed_item", "Stock Restore": "Automatic" },
        rule: "Ensures physical warehouse stock matches database balance"
      };
    }
    case "btn_delete_sale": {
      return {
        category: "DML OPERATION",
        pill: "DELETE sale",
        title: "Delete Commercial Invoice",
        desc: "Deletes invoice header from table sale. Cascades to delete line items in sale_item and receipts in payment.",
        grid: { "Cascade Tables": "sale_item, payment", "Integrity": "Foreign Key Cascade" },
        rule: "Reconciles cumulative revenue telemetry"
      };
    }
    case "shift_stat": {
      const shift = el.getAttribute("data-shift") || "Shift";
      const litres = el.getAttribute("data-litres") || "0";
      return {
        category: "SHIFT ANALYTICS",
        pill: "GROUP BY session_type",
        title: `${shift} Shift Harvest`,
        desc: `Total volume of liquid milk extracted across all cattle during the ${shift} milking shift.`,
        grid: { "Shift": shift, "Harvested Volume": `${litres} Litres`, "Table": "milk_yield" },
        rule: "Aggregated in real-time from MySQL"
      };
    }
    case "kpi_avg_fat": {
      const val = el.getAttribute("data-val") || "3.9";
      return {
        category: "LAB AGGREGATE",
        pill: "AVG(fat_percentage)",
        title: `Average Butterfat: ${val}%`,
        desc: `Arithmetic mean of butterfat percentage across all certified laboratory assays in quality_test.`,
        grid: { "Query": "SELECT AVG(fat_percentage) FROM quality_test", "Value": `${val}%`, "Target": ">= 3.50%" },
        rule: "Exceeds standard Grade A benchmark"
      };
    }
    case "kpi_avg_snf": {
      const val = el.getAttribute("data-val") || "8.7";
      return {
        category: "LAB AGGREGATE",
        pill: "AVG(snf_percentage)",
        title: `Average SNF Solids: ${val}%`,
        desc: `Arithmetic mean of solids-not-fat percentage across all assays in quality_test.`,
        grid: { "Query": "SELECT AVG(snf_percentage) FROM quality_test", "Value": `${val}%`, "Legal Minimum": "8.50%" },
        rule: "Complies with FSSAI dairy standards"
      };
    }
    case "kpi_avg_density": {
      const val = el.getAttribute("data-val") || "1.030";
      return {
        category: "PHYSICAL MEASURE",
        pill: "AVG(density)",
        title: `Specific Density: ${val}`,
        desc: `Mean lactometer density reading across all verified milk test assays.`,
        grid: { "Value": val, "Benchmark Range": "1.028 - 1.034" },
        rule: "Indicates unadulterated milk supply"
      };
    }
    case "breed_count": {
      const breed = el.getAttribute("data-breed") || "Breed";
      const count = el.getAttribute("data-count") || "0";
      return {
        category: "HERD DEMOGRAPHICS",
        pill: "COUNT(animal_id)",
        title: `${breed}: ${count} Head`,
        desc: `Total registered cattle headcount for ${breed} breed in the active dairy farm herd.`,
        grid: { "Breed": breed, "Headcount": `${count} Head`, "Table": "animal" },
        rule: "Queried via COUNT(*) GROUP BY breed_id"
      };
    }
    case "breed_category": {
      return {
        category: "TAXONOMY CLASSIFICATION",
        pill: "Dairy Cattle",
        title: "Category: Dairy Cattle",
        desc: "Specialized dairy cattle breeds selected for high lactation yield, disease resistance, and heat tolerance.",
        grid: { "Category": "Dairy Cattle", "Milk Purpose": "Commercial Production" },
        rule: "Classified in table breed"
      };
    }
    default:
      return null;
  }
}

function renderPopoverContent(data) {
  const popover = document.getElementById("global-info-popover");
  if (!popover || !data) return;

  document.getElementById("popover-category").innerText = data.category || "DBMS METRIC";
  document.getElementById("popover-pill").innerText = data.pill || "InnoDB 8.0";
  document.getElementById("popover-title").innerText = data.title || "Information";
  document.getElementById("popover-desc").innerText = data.desc || "";

  const gridEl = document.getElementById("popover-grid");
  if (data.grid && Object.keys(data.grid).length > 0) {
    gridEl.innerHTML = Object.entries(data.grid).map(([k, v]) => `
      <span class="popover-grid-label">${k}:</span>
      <span class="popover-grid-val">${v}</span>
    `).join("");
    gridEl.style.display = "grid";
  } else {
    gridEl.innerHTML = "";
    gridEl.style.display = "none";
  }

  const ruleEl = document.getElementById("popover-rule");
  const ruleText = document.getElementById("popover-rule-text");
  if (data.rule) {
    ruleText.innerText = data.rule;
    ruleEl.style.display = "flex";
  } else {
    ruleEl.style.display = "none";
  }
}

function positionPopover(e) {
  const popover = document.getElementById("global-info-popover");
  if (!popover) return;

  const width = popover.offsetWidth || 320;
  const height = popover.offsetHeight || 180;
  const padding = 14;

  let x = e.clientX + padding;
  let y = e.clientY + padding;

  // Horizontal collision detection
  if (x + width > window.innerWidth - 12) {
    x = e.clientX - width - padding;
  }
  // Vertical collision detection
  if (y + height > window.innerHeight - 12) {
    y = e.clientY - height - padding;
  }

  // Guard screen boundaries
  if (x < 12) x = 12;
  if (y < 12) y = 12;

  popover.style.left = `${x}px`;
  popover.style.top = `${y}px`;
}

function showPopover(data, e) {
  const popover = document.getElementById("global-info-popover");
  if (!popover || !data) return;

  renderPopoverContent(data);
  positionPopover(e);
  popover.classList.add("popover-visible");
}

function hidePopover() {
  const popover = document.getElementById("global-info-popover");
  if (popover) {
    popover.classList.remove("popover-visible");
  }
}

function enhanceAllElementsWithInfoHover() {
  // 1. Enhance elements with [data-info-key]
  document.querySelectorAll("[data-info-key]").forEach(el => {
    if (!el.querySelector(".info-hover-icon") && !el.classList.contains("info-hover-icon")) {
      const icon = document.createElement("span");
      icon.className = "info-hover-icon";
      icon.innerText = "ⓘ";
      icon.title = "View DBMS Info";
      el.appendChild(icon);
    }
  });

  // 2. Enhance all table headers in all studio tables
  document.querySelectorAll("table.studio-table th").forEach(th => {
    if (th.querySelector(".info-hover-icon")) return;

    const rawText = th.innerText.trim().toLowerCase();
    let matchedKey = null;

    for (const [pattern, key] of Object.entries(TABLE_HEADER_SCHEMAS)) {
      if (rawText.includes(pattern)) {
        matchedKey = key;
        break;
      }
    }

    if (matchedKey) {
      th.setAttribute("data-info-key", matchedKey);
      const icon = document.createElement("span");
      icon.className = "info-hover-icon";
      icon.innerText = "ⓘ";
      icon.title = "View Schema Definition";
      th.appendChild(icon);
    }
  });
}

function initInfoHoverEngine() {
  // Initial scan and enhancement
  enhanceAllElementsWithInfoHover();

  let activeHoverEl = null;

  // Global delegated mouseover listener
  document.addEventListener("mouseover", (e) => {
    const target = e.target.closest("[data-info-key], [data-info-entity], .info-hover-icon");
    if (!target) return;

    activeHoverEl = target;
    const data = resolveInfoData(target);
    if (data) {
      showPopover(data, e);
    }
  });

  // Global mousemove listener for smooth tracking
  document.addEventListener("mousemove", (e) => {
    if (!activeHoverEl) return;
    positionPopover(e);
  });

  // Global mouseout listener
  document.addEventListener("mouseout", (e) => {
    if (!activeHoverEl) return;
    const related = e.relatedTarget;
    if (!related || !activeHoverEl.contains(related)) {
      activeHoverEl = null;
      hidePopover();
    }
  });
}

