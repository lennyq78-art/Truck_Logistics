/* ==========================================================================
   Truck Logistics Live Dashboard - JavaScript Application Logic
   ========================================================================== */

const API_BASE = ""; // Relative URL since static files are served by FastAPI

// State cache
let fleetTrucks = [];
let activeTripsList = [];
let allTripsList = [];
let fleetMap = null;
let mapMarkers = {};

document.addEventListener("DOMContentLoaded", () => {
  initFleetMap();
  loadDashboardData();
  // Auto refresh active trips every 5 seconds for live dashboard map updates
  setInterval(() => {
    fetchActiveTrips();
  }, 5000);
});

// --- Initialize Leaflet Map ---
function initFleetMap() {
  const mapElem = document.getElementById("map-container");
  if (!mapElem || typeof L === "undefined") return;

  // Center map on Sri Lanka (7.8731, 80.7718)
  fleetMap = L.map("map-container").setView([7.8731, 80.7718], 8);

  // Dark Map Tiles
  L.tileLayer("https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png", {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/">CARTO</a>',
    subdomains: "abcd",
    maxZoom: 19
  }).addTo(fleetMap);
}

function updateMapMarkers() {
  if (!fleetMap || typeof L === "undefined") return;

  const currentTripIds = new Set();

  activeTripsList.forEach(trip => {
    currentTripIds.add(trip.id);
    const truck = trip.truck || fleetTrucks.find(t => t.id === trip.truck_id) || {};
    const plate = truck.plate_number || `Truck #${trip.truck_id}`;
    const driver = truck.driver_name || "Driver";
    const lat = trip.current_lat || 6.9271;
    const lng = trip.current_lng || 79.8612;

    const popupContent = `
      <div style="color: #0f172a; font-family: sans-serif; padding: 4px;">
        <strong style="font-size: 14px;">🚚 ${escapeHtml(plate)}</strong><br/>
        <span style="font-size: 12px; color: #475569;">Driver: ${escapeHtml(driver)}</span><br/>
        <span style="font-size: 12px; color: #16a34a; font-weight: bold;">Route: ${escapeHtml(trip.start_location)} ➔ ${escapeHtml(trip.end_location)}</span>
      </div>
    `;

    if (mapMarkers[trip.id]) {
      // Update position and popup
      mapMarkers[trip.id].setLatLng([lat, lng]);
      mapMarkers[trip.id].getPopup().setContent(popupContent);
    } else {
      // Custom green truck icon
      const customIcon = L.divIcon({
        className: 'custom-map-marker',
        html: `<div style="background: #10b981; color: white; padding: 6px 10px; border-radius: 20px; font-weight: bold; font-size: 12px; box-shadow: 0 0 12px rgba(16,185,129,0.8); border: 2px solid white; display: flex; align-items: center; gap: 4px;">🚚 ${escapeHtml(plate)}</div>`,
        iconSize: [110, 32],
        iconAnchor: [55, 16]
      });

      const marker = L.marker([lat, lng], { icon: customIcon }).addTo(fleetMap);
      marker.bindPopup(popupContent);
      mapMarkers[trip.id] = marker;
    }
  });

  // Remove markers for trips that are no longer active
  Object.keys(mapMarkers).forEach(tripId => {
    if (!currentTripIds.has(parseInt(tripId))) {
      fleetMap.removeLayer(mapMarkers[tripId]);
      delete mapMarkers[tripId];
    }
  });
}

// --- Fetch All Dashboard Data ---
async function loadDashboardData() {
  await Promise.all([
    fetchTrucks(),
    fetchActiveTrips(),
    fetchTripHistory()
  ]);
}

// 1. Fetch Fleet Trucks
async function fetchTrucks() {
  try {
    const res = await fetch(`${API_BASE}/trucks`);
    if (!res.ok) throw new Error("Failed to load trucks");
    fleetTrucks = await res.json();
    renderFleetTable();
    updateTruckDropdown();
    document.getElementById("metric-fleet-count").textContent = fleetTrucks.length;
  } catch (err) {
    showToast(err.message, "error");
  }
}

// 2. Fetch Active Trips
async function fetchActiveTrips() {
  try {
    const res = await fetch(`${API_BASE}/trips/active`);
    if (!res.ok) throw new Error("Failed to load active trips");
    activeTripsList = await res.json();
    renderActiveTrips();
    updateMapMarkers();
    document.getElementById("metric-active-count").textContent = activeTripsList.length;
    // Re-update truck dropdown to hide trucks that currently have active trips
    updateTruckDropdown();
  } catch (err) {
    showToast(err.message, "error");
  }
}

// 3. Fetch Full Trip History
async function fetchTripHistory() {
  try {
    const res = await fetch(`${API_BASE}/trips`);
    if (!res.ok) throw new Error("Failed to load trip history");
    allTripsList = await res.json();
    renderTripHistory();

    const completed = allTripsList.filter(t => t.status === "completed");
    document.getElementById("metric-completed-count").textContent = completed.length;

    const totalRev = completed.reduce((acc, t) => acc + (t.fare || 0), 0);
    document.getElementById("metric-revenue").textContent = `LKR ${totalRev.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  } catch (err) {
    showToast(err.message, "error");
  }
}

// --- Render Functions ---

function renderActiveTrips() {
  const container = document.getElementById("active-trips-container");
  if (activeTripsList.length === 0) {
    container.innerHTML = `
      <div class="empty-state" style="grid-column: 1 / -1;">
        <span style="font-size: 2rem; display: block; margin-bottom: 0.5rem;">🅿️</span>
        <p>No active trips right now. Dispatch a truck using the form on the right!</p>
      </div>
    `;
    return;
  }

  container.innerHTML = activeTripsList.map(trip => {
    const truck = trip.truck || fleetTrucks.find(t => t.id === trip.truck_id) || {};
    const rate = truck.rate_per_km || 0;
    const plate = truck.plate_number || `Truck #${trip.truck_id}`;
    const driver = truck.driver_name || "Assigned Driver";

    return `
      <div class="trip-card">
        <div>
          <div class="trip-card-header">
            <span class="truck-plate">🚚 ${escapeHtml(plate)}</span>
            <span class="pulse-badge">ACTIVE</span>
          </div>
          <div class="driver-name">👤 Driver: ${escapeHtml(driver)}</div>
          <div class="route-info" style="margin-top: 0.75rem;">
            <span class="route-loc">${escapeHtml(trip.start_location)}</span>
            <span class="route-arrow">➔</span>
            <span class="route-loc">${escapeHtml(trip.end_location)}</span>
          </div>
        </div>
        <div class="trip-card-footer">
          <div class="rate-badge">Rate: <span>LKR ${rate}/km</span></div>
          <button class="btn btn-sm btn-success" onclick="openEndTripModal(${trip.id}, '${escapeHtml(plate)}', '${escapeHtml(trip.start_location)}', '${escapeHtml(trip.end_location)}', ${rate})">
            🏁 End Trip
          </button>
        </div>
      </div>
    `;
  }).join("");
}

function updateTruckDropdown() {
  const select = document.getElementById("start-truck-select");
  const activeTruckIds = new Set(activeTripsList.map(t => t.truck_id));

  select.innerHTML = '<option value="">-- Choose Available Truck --</option>' +
    fleetTrucks.map(t => {
      const isActive = activeTruckIds.has(t.id);
      const disabledAttr = isActive ? "disabled" : "";
      const label = `${t.plate_number} - ${t.driver_name} (LKR ${t.rate_per_km}/km)${isActive ? " [ON TRIP]" : ""}`;
      return `<option value="${t.id}" ${disabledAttr}>${escapeHtml(label)}</option>`;
    }).join("");
}

function renderFleetTable() {
  const tbody = document.getElementById("fleet-table-body");
  const activeTruckIds = new Set(activeTripsList.map(t => t.truck_id));

  if (fleetTrucks.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="empty-state">No trucks registered yet. Click "Add New Truck" to add one!</td></tr>`;
    return;
  }

  tbody.innerHTML = fleetTrucks.map(t => {
    const isActive = activeTruckIds.has(t.id);
    const statusTag = isActive 
      ? `<span class="status-tag active">🟢 On Trip</span>`
      : `<span class="status-tag completed">🅿️ Available</span>`;

    return `
      <tr>
        <td>#${t.id}</td>
        <td><strong>${escapeHtml(t.plate_number)}</strong></td>
        <td>${escapeHtml(t.driver_name)}</td>
        <td style="color: #f59e0b; font-weight: 600;">LKR ${t.rate_per_km.toFixed(2)}</td>
        <td>${statusTag}</td>
      </tr>
    `;
  }).join("");
}

function renderTripHistory() {
  const tbody = document.getElementById("trips-history-body");
  if (allTripsList.length === 0) {
    tbody.innerHTML = `<tr><td colspan="4" class="empty-state">No trips logged yet.</td></tr>`;
    return;
  }

  tbody.innerHTML = allTripsList.slice(0, 10).map(t => {
    const truck = t.truck || fleetTrucks.find(tr => tr.id === t.truck_id) || {};
    const plate = truck.plate_number || `Truck #${t.truck_id}`;
    const fareText = t.fare ? `LKR ${t.fare.toLocaleString(undefined, { minimumFractionDigits: 2 })}` : "-";
    const statusClass = t.status === "active" ? "active" : "completed";
    const statusLabel = t.status === "active" ? "Active" : "Completed";

    return `
      <tr>
        <td>#${t.id}</td>
        <td>
          <div style="font-weight: 600;">${escapeHtml(plate)}</div>
          <div style="font-size: 0.775rem; color: var(--text-muted);">${escapeHtml(t.start_location)} ➔ ${escapeHtml(t.end_location)}</div>
        </td>
        <td style="color: #f59e0b; font-weight: 700;">${fareText}</td>
        <td><span class="status-tag ${statusClass}">${statusLabel}</span></td>
      </tr>
    `;
  }).join("");
}

// --- Event Handlers ---

async function handleStartTrip(e) {
  e.preventDefault();
  const truckId = document.getElementById("start-truck-select").value;
  const startLoc = document.getElementById("start-location-input").value;
  const endLoc = document.getElementById("end-location-input").value;

  if (!truckId) {
    showToast("Please select an available truck", "error");
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/trips/start`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        truck_id: parseInt(truckId),
        start_location: startLoc,
        end_location: endLoc
      })
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Failed to start trip");

    showToast(`Trip #${data.id} started successfully!`, "success");
    document.getElementById("start-trip-form").reset();
    await loadDashboardData();
  } catch (err) {
    showToast(err.message, "error");
  }
}

// --- End Trip Modal Logic ---
function openEndTripModal(tripId, plate, startLoc, endLoc, ratePerKm) {
  document.getElementById("end-modal-trip-id").value = tripId;
  document.getElementById("end-modal-rate").value = ratePerKm;
  document.getElementById("end-modal-truck").textContent = plate;
  document.getElementById("end-modal-route").textContent = `${startLoc} ➔ ${endLoc}`;
  document.getElementById("end-modal-rate-display").textContent = `LKR ${ratePerKm}/km`;
  
  document.getElementById("end-distance-input").value = "";
  document.getElementById("fare-preview-amount").textContent = "LKR 0.00";
  
  document.getElementById("end-trip-modal").classList.add("active");
}

function closeEndTripModal() {
  document.getElementById("end-trip-modal").classList.remove("active");
}

function updateFarePreview() {
  const dist = parseFloat(document.getElementById("end-distance-input").value) || 0;
  const rate = parseFloat(document.getElementById("end-modal-rate").value) || 0;
  const total = dist * rate;
  document.getElementById("fare-preview-amount").textContent = `LKR ${total.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

async function handleEndTrip(e) {
  e.preventDefault();
  const tripId = document.getElementById("end-modal-trip-id").value;
  const dist = parseFloat(document.getElementById("end-distance-input").value);

  if (!dist || dist <= 0) {
    showToast("Please enter a valid distance in kilometers", "error");
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/trips/${tripId}/end`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ distance_km: dist })
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Failed to end trip");

    showToast(`Trip #${data.id} completed! Final Fare: LKR ${data.fare.toLocaleString()}`, "success");
    closeEndTripModal();
    await loadDashboardData();
  } catch (err) {
    showToast(err.message, "error");
  }
}

// --- Add Truck Modal Logic ---
function openAddTruckModal() {
  document.getElementById("add-truck-form").reset();
  document.getElementById("add-truck-modal").classList.add("active");
}

function closeAddTruckModal() {
  document.getElementById("add-truck-modal").classList.remove("active");
}

async function handleAddTruck(e) {
  e.preventDefault();
  const plate = document.getElementById("truck-plate-input").value;
  const driver = document.getElementById("truck-driver-input").value;
  const rate = parseFloat(document.getElementById("truck-rate-input").value);

  try {
    const res = await fetch(`${API_BASE}/trucks`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        plate_number: plate,
        driver_name: driver,
        rate_per_km: rate
      })
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || "Failed to add truck");

    showToast(`Truck ${data.plate_number} added to fleet!`, "success");
    closeAddTruckModal();
    await loadDashboardData();
  } catch (err) {
    showToast(err.message, "error");
  }
}

// --- Helper Utilities ---
function showToast(message, type = "success") {
  const container = document.getElementById("toast-container");
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <span>${type === "success" ? "✅" : "⚠️"}</span>
    <span>${escapeHtml(message)}</span>
  `;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = "0";
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
