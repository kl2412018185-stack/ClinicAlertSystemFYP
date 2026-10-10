<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#039;");
    }
%>

<%
    com.clinicalert.model.User currentUser
            = (com.clinicalert.model.User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String staffId = currentUser.getStaffId();
    String staffName = currentUser.getName();
    String userRole = currentUser.getRole();

    if (staffName == null || staffName.trim().isEmpty()) {
        staffName = "User";
    }

    if (userRole == null || userRole.trim().isEmpty()) {
        userRole = "Staff";
    }

    boolean isAdmin = currentUser.isAdministrative();

    java.util.function.Function<String, String> escapeJs = value -> {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("</", "<\\/");
    };

%>

<!DOCTYPE html>

<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>Stock Out - Clinic Alert System</title>

        <link rel="stylesheet"
              href="css/style.css">

        <style>

            .stock-info-box {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                padding: 16px 18px;
                margin: 18px 0;
                background: #F8FAFC;
                border: 1px solid #E2E8F0;
                border-radius: 10px;
            }

            .stock-info-item {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }

            .stock-info-item .label {
                font-size: 11px;
                color: #64748B;
                font-weight: 500;
            }

            .stock-info-item .val {
                font-size: 18px;
                color: #0F172A;
                font-weight: 700;
            }

            .recent-item {
                padding-bottom: 14px;
                margin-bottom: 14px;
                border-bottom: 1px solid #E2E8F0;
            }

            .recent-item:last-child {
                border-bottom: none;
                margin-bottom: 0;
            }

            .recent-date {
                color: #64748B;
                font-size: 11.5px;
            }

            .recent-name {
                font-weight: 700;
                color: #0F172A;
                margin: 3px 0;
                font-size: 13px;
            }

            .recent-quantity {
                color: #64748B;
                font-size: 12px;
            }

            .recent-staff {
                color: #EF4444;
                font-size: 11.5px;
                font-weight: 600;
                margin-top: 3px;
            }

            @media (max-width: 850px) {

                .grid-3-2 {
                    grid-template-columns: 1fr !important;
                }

                .form-grid-2 {
                    grid-template-columns: 1fr !important;
                }

                .stock-info-box {
                    grid-template-columns: 1fr;
                }
            }

        </style>

        <%            StringBuilder medicineJsonBuilder = new StringBuilder("[");
            java.util.List<com.clinicalert.model.Medicine> jsMedicineList
                    = (java.util.List<com.clinicalert.model.Medicine>) request.getAttribute("medicines");

            java.util.Map<String, java.util.List<com.clinicalert.dao.MedicineDAO.StockBatch>> jsStockBatches
                    = (java.util.Map<String, java.util.List<com.clinicalert.dao.MedicineDAO.StockBatch>>) request.getAttribute("stockBatches");

            boolean isFirst = true;
            if (jsMedicineList != null) {
                for (com.clinicalert.model.Medicine jsMedicine : jsMedicineList) {

                    String jsMedicineId = jsMedicine.getMedicineId() == null ? "" : jsMedicine.getMedicineId();
                    String jsMedicineName = jsMedicine.getName() == null ? "" : jsMedicine.getName();
                    String jsUnit = jsMedicine.getUnit() == null ? "" : jsMedicine.getUnit();

                    java.util.List<com.clinicalert.dao.MedicineDAO.StockBatch> jsBatches
                            = jsStockBatches == null ? null : jsStockBatches.get(jsMedicineId);

                    if (jsBatches != null && !jsBatches.isEmpty()) {
                        for (com.clinicalert.dao.MedicineDAO.StockBatch jsBatch : jsBatches) {
                            String jsBatchNo = jsBatch.getBatchNo() == null ? "" : jsBatch.getBatchNo();
                            String jsExpiry = jsBatch.getExpiryDate() == null ? "" : jsBatch.getExpiryDate();
                            if (!isFirst) {
                                medicineJsonBuilder.append(",");
                            }
                            isFirst = false;
                            medicineJsonBuilder.append("{")
                                    .append("\"id\":\"").append(escapeJs.apply(jsMedicineId)).append("\",")
                                    .append("\"name\":\"").append(escapeJs.apply(jsMedicineName)).append("\",")
                                    .append("\"batch\":\"").append(escapeJs.apply(jsBatchNo)).append("\",")
                                    .append("\"stock\":\"").append(jsBatch.getQuantity()).append("\",")
                                    .append("\"unit\":\"").append(escapeJs.apply(jsUnit)).append("\",")
                                    .append("\"expiry\":\"").append(escapeJs.apply(jsExpiry)).append("\"")
                                    .append("}");
                        }
                    } else {
                        String jsBatchNo = jsMedicine.getBatchNo() == null ? "" : jsMedicine.getBatchNo();
                        String jsExpiry = jsMedicine.getExpiryDate() == null ? "" : jsMedicine.getExpiryDate();
                        if (!isFirst) {
                            medicineJsonBuilder.append(",");
                        }
                        isFirst = false;
                        medicineJsonBuilder.append("{")
                                .append("\"id\":\"").append(escapeJs.apply(jsMedicineId)).append("\",")
                                .append("\"name\":\"").append(escapeJs.apply(jsMedicineName)).append("\",")
                                .append("\"batch\":\"").append(escapeJs.apply(jsBatchNo)).append("\",")
                                .append("\"stock\":\"").append(jsMedicine.getCurrentStock()).append("\",")
                                .append("\"unit\":\"").append(escapeJs.apply(jsUnit)).append("\",")
                                .append("\"expiry\":\"").append(escapeJs.apply(jsExpiry)).append("\"")
                                .append("}");
                    }
                }
            }
            medicineJsonBuilder.append("]");
        %>

        <script id="medicineDataRaw" type="application/json"><%= medicineJsonBuilder.toString()%></script>

        <script>

            var medicineData = [];
            try {
                var rawMedicineDataElem = document.getElementById("medicineDataRaw");
                if (rawMedicineDataElem && rawMedicineDataElem.textContent) {
                    medicineData = JSON.parse(rawMedicineDataElem.textContent);
                }
            } catch (e) {
                console.error("Error parsing medicine data:", e);
            }

            function escapeHtml(value) {

                return String(value || "")
                        .replace(/&/g, "&amp;")
                        .replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;")
                        .replace(/"/g, "&quot;")
                        .replace(/'/g, "&#039;");
            }

            function updateStockInfo(selectElem) {

                var selectedOption =
                        selectElem.options[selectElem.selectedIndex];

                var stock =
                        document.getElementById("availStock");

                var expiry =
                        document.getElementById("expDate");

                var unitDisplay =
                        document.getElementById("stockUnitDisplay");

                var batchSelect =
                        document.getElementById("batchNo");

                var hiddenUnit =
                        document.getElementById("stockUnit");

                stock.innerText = "0";
                expiry.innerText = "-";
                unitDisplay.innerText = "-";

                if (hiddenUnit) {
                    hiddenUnit.value = "";
                }

                if (!selectedOption ||
                        !selectedOption.value) {

                    batchSelect.innerHTML =
                            '<option value="">Select batch</option>';

                    return;
                }

                var selectedMedicineId =
                        selectedOption.value;

                var selectedMedicineName =
                        selectedOption.getAttribute("data-name") || "";

                var matchingBatches = [];

                for (var i = 0; i < medicineData.length; i++) {

                    var med = medicineData[i];

                    if (
                            med.id === selectedMedicineId
                            &&
                            med.batch !== ""
                            ) {

                        matchingBatches.push(med);

                    }

                }

                batchSelect.innerHTML =
                        '<option value="">Select batch</option>';

                for (var j = 0; j < matchingBatches.length; j++) {

                    var batch = matchingBatches[j];

                    var option =
                            document.createElement("option");

                    option.value =
                            batch.batch;

                    option.textContent = batch.batch;

                    option.setAttribute(
                            "data-stock",
                            batch.stock
                            );

                    option.setAttribute(
                            "data-unit",
                            batch.unit
                            );

                    option.setAttribute(
                            "data-expiry",
                            batch.expiry
                            );

                    option.setAttribute(
                            "data-medicine-id",
                            batch.id
                            );

                    batchSelect.appendChild(option);
                }

                if (matchingBatches.length > 0) {

                    batchSelect.selectedIndex = 0;

                    updateBatchInfo(batchSelect);

                } else {

                    var stockValue =
                            selectedOption.getAttribute("data-stock")
                            || "0";

                    var unitValue =
                            selectedOption.getAttribute("data-unit")
                            || "";

                    var expiryValue =
                            selectedOption.getAttribute("data-expiry")
                            || "-";

                    var batchValue =
                            selectedOption.getAttribute("data-batch")
                            || "";

                    stock.innerText =
                            stockValue;

                    expiry.innerText =
                            expiryValue;

                    unitDisplay.innerText =
                            unitValue || "-";

                    hiddenUnit.value =
                            unitValue;

                    if (batchValue !== "") {

                        batchSelect.innerHTML =
                                '<option value="' +
                                escapeHtml(batchValue) +
                                '">' +
                                escapeHtml(batchValue) +
                                '</option>';

                    } else {

                        batchSelect.innerHTML =
                                '<option value="">No batch recorded</option>';

                    }
                }
            }

            function updateBatchInfo(batchSelect) {

                var option =
                        batchSelect.options[
                                batchSelect.selectedIndex
                        ];

                if (!option || !option.value) {

                    document.getElementById("availStock")
                            .innerText = "0";

                    document.getElementById("expDate")
                            .innerText = "-";

                    document.getElementById("stockUnitDisplay")
                            .innerText = "-";

                    document.getElementById("stockUnit")
                            .value = "";

                    return;
                }

                var stock =
                        option.getAttribute("data-stock")
                        || "0";

                var unit =
                        option.getAttribute("data-unit")
                        || "";

                var expiry =
                        option.getAttribute("data-expiry")
                        || "-";

                document.getElementById("availStock")
                        .innerText = stock;

                document.getElementById("expDate")
                        .innerText = expiry;

                document.getElementById("stockUnitDisplay")
                        .innerText = unit || "-";

                document.getElementById("stockUnit")
                        .value = unit;

                var medicineId =
                        option.getAttribute("data-medicine-id");

                var medicineSelect =
                        document.querySelector(
                                'select[name="medicineId"]'
                                );

                if (medicineId &&
                        medicineSelect) {

                    medicineSelect.value =
                            medicineId;
                }
            }

            function validateStockOut() {

                var reason =
                        document.getElementById("reason");

                var additionalRemarks =
                        document.getElementById("additionalRemarks");

                if (reason && additionalRemarks) {

                    var hiddenRemarks =
                            document.getElementById("combinedRemarks");

                    if (!hiddenRemarks) {

                        hiddenRemarks =
                                document.createElement("input");

                        hiddenRemarks.type =
                                "hidden";

                        hiddenRemarks.name =
                                "remarks";

                        hiddenRemarks.id =
                                "combinedRemarks";

                        document.querySelector(
                                'form[action$="/stockout"]'
                                ).appendChild(hiddenRemarks);
                    }

                    var reasonText =
                            reason.value || "";

                    var extraText =
                            additionalRemarks.value || "";

                    hiddenRemarks.value =
                            extraText.trim() === ""
                            ? reasonText
                            : reasonText + " - " + extraText;
                }

                var quantity =
                        parseInt(
                                document.getElementById(
                                        "quantity"
                                        ).value
                                );

                var available =
                        parseInt(
                                document.getElementById(
                                        "availStock"
                                        ).innerText
                                );

                if (isNaN(quantity) ||
                        quantity <= 0) {

                    alert(
                            "Please enter a valid quantity."
                            );

                    return false;
                }

                if (isNaN(available) ||
                        available <= 0) {

                    alert(
                            "Selected batch has no available stock."
                            );

                    return false;
                }

                if (quantity > available) {

                    alert(
                            "Stock Out quantity cannot exceed available stock (" +
                            available +
                            ")."
                            );

                    return false;
                }

                var batch =
                        document.getElementById(
                                "batchNo"
                                ).value;

                if (!batch ||
                        batch.trim() === "") {

                    alert(
                            "Please select a batch."
                            );

                    return false;
                }

                return true;
            }

            function resetStockInfo() {

                document.getElementById(
                        "availStock"
                        ).innerText = "0";

                document.getElementById(
                        "expDate"
                        ).innerText = "-";

                document.getElementById(
                        "stockUnitDisplay"
                        ).innerText = "-";

                document.getElementById(
                        "stockUnit"
                        ).value = "";

                var batchSelect =
                        document.getElementById(
                                "batchNo"
                                );

                if (batchSelect) {

                    batchSelect.innerHTML =
                            '<option value="">Select batch</option>';
                }
            }

            function openLogoutModal() {

                document.getElementById(
                        "logoutModal"
                        ).style.display = "flex";
            }

            function closeLogoutModal() {

                document.getElementById(
                        "logoutModal"
                        ).style.display = "none";
            }

            window.onclick = function (event) {

                var modal =
                        document.getElementById(
                                "logoutModal"
                                );

                if (event.target === modal) {

                    modal.style.display = "none";
                }
            };

            window.addEventListener(
                    "DOMContentLoaded",
                    function () {

                        var medicineSelect =
                                document.querySelector(
                                        'select[name="medicineId"]'
                                        );

                        if (medicineSelect && medicineSelect.value) {
                            updateStockInfo(medicineSelect);
                        }
                    }
            );

        </script>

    </head>

    <body>

        <div class="app-container">

            <aside class="sidebar">

                <div class="sidebar-brand">

                    <div class="brand-icon-wrapper">

                        <svg width="26"
                             height="26"
                             viewBox="0 0 64 64"
                             fill="none">

                        <rect x="18"
                              y="20"
                              width="28"
                              height="36"
                              rx="6"
                              fill="#0A2540"/>

                        <rect x="23"
                              y="14"
                              width="18"
                              height="6"
                              rx="2"
                              fill="#0066FF"/>

                        <rect x="29"
                              y="32"
                              width="6"
                              height="14"
                              rx="1.5"
                              fill="#10B981"/>

                        <rect x="25"
                              y="36"
                              width="14"
                              height="6"
                              rx="1.5"
                              fill="#10B981"/>

                        <rect x="36"
                              y="24"
                              width="18"
                              height="26"
                              rx="3"
                              fill="#FFFFFF"
                              stroke="#0A2540"
                              stroke-width="2"/>

                        <line x1="40"
                              y1="31"
                              x2="50"
                              y2="31"
                              stroke="#0066FF"
                              stroke-width="2"
                              stroke-linecap="round"/>

                        <line x1="40"
                              y1="36"
                              x2="48"
                              y2="36"
                              stroke="#0066FF"
                              stroke-width="2"
                              stroke-linecap="round"/>

                        <circle cx="16"
                                cy="18"
                                r="7"
                                fill="#10B981"/>

                        <path d="M13 18C13 14 19 14 19 18C19 22 13 22 13 18Z"
                              fill="#FFFFFF"/>

                        </svg>

                    </div>

                    <div class="brand-titles">

                        <h1>
                            Clinic<span class="highlight"> Alert</span>
                        </h1>

                        <p>
                            Smart Medicine Management System
                        </p>

                    </div>

                </div>

                <nav class="sidebar-nav">

                    <a href="<%= request.getContextPath()%>/dashboard"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <rect x="3" y="3" width="7" height="7"/>
                            <rect x="14" y="3" width="7" height="7"/>
                            <rect x="14" y="14" width="7" height="7"/>
                            <rect x="3" y="14" width="7" height="7"/>

                            </svg>

                            <span>Dashboard</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/medicine"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/>
                            <path d="m8.5 8.5 7 7"/>

                            </svg>

                            <span>Medicine</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/stockin"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="M12 3v12"/>
                            <path d="m8 11 4 4 4-4"/>
                            <path d="M8 5H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-4"/>

                            </svg>

                            <span>Stock In</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/stockout"
                       class="nav-link active">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="M12 21V9"/>
                            <path d="m16 13-4-4-4 4"/>
                            <path d="M16 19h4a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h4"/>

                            </svg>

                            <span>Stock Out</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/lowstock"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
                            <line x1="12" y1="9" x2="12" y2="13"/>
                            <line x1="12" y1="17" x2="12.01" y2="17"/>

                            </svg>

                            <span>Low Stock Alert</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/expiry"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <circle cx="12" cy="12" r="10"/>
                            <polyline points="12 6 12 12 16 14"/>

                            </svg>

                            <span>Expiry Alert</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="restock"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">
                            <circle cx="8" cy="21" r="1"></circle>
                            <circle cx="19" cy="21" r="1"></circle>
                            <path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"></path>
                            </svg>

                            <span>Restock Orders</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/reports"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                            <polyline points="14 2 14 8 20 8"/>
                            <line x1="16" y1="13" x2="8" y2="13"/>
                            <line x1="16" y1="17" x2="8" y2="17"/>
                            <polyline points="10 9 9 9 8 9"></polyline>

                            </svg>

                            <span>Reports</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <a href="<%= request.getContextPath()%>/profile"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>

                            </svg>

                            <span>Profile</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <% if (isAdmin) {%>

                    <a href="<%= request.getContextPath()%>/usermanagement"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                            <circle cx="9" cy="7" r="4"/>
                            <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
                            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>

                            </svg>

                            <span>User Management</span>

                        </div>

                        <span class="chevron-icon">&rsaquo;</span>

                    </a>

                    <% }%>

                </nav>

                <div class="sidebar-footer">

                    <button
                        class="logout-btn"
                        type="button"
                        onclick="openLogoutModal()"
                        style="width:auto !important; min-width:0 !important; height:40px !important; padding:8px 14px !important; margin:0 auto !important; display:flex !important; align-items:center !important; justify-content:center !important; gap:8px !important; font-size:13px !important; line-height:1 !important; border-radius:8px !important;">

                        <svg viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round"
                             width="18"
                             height="18">

                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                        <polyline points="16 17 21 12 16 7"/>
                        <line x1="21" y1="12" x2="9" y2="12"/>

                        </svg>

                        <span>
                            Logout
                        </span>

                    </button>

                </div>

            </aside>

            <main class="main-wrapper">

                <header class="top-navbar">

                    <div class="page-title">

                        <h2>
                            Stock Out
                        </h2>

                    </div>

                    <div class="user-profile-badge">

                        <div class="user-avatar-circle">

                            <svg width="14"
                                 height="14"
                                 viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2">

                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>

                            </svg>

                        </div>

                        <span>
                            <%= staffName%> (<%= userRole%>)
                        </span>

                    </div>

                </header>

                <div class="content-container">

                    <div class="grid-3-2">

                        <div class="panel-card">

                            <div class="panel-header">

                                <h3>
                                    Stock Out Dispensing
                                </h3>

                            </div>

                            <%
                                String errorMessage = (String) request.getAttribute("errorMessage");
                                String msg = request.getParameter("msg");
                                if (errorMessage != null && !errorMessage.isEmpty()) {
                            %>
                            <div style="margin:0 0 16px 0;padding:12px 14px;border-radius:8px;background:#FEF2F2;color:#B91C1C;border:1px solid #FECACA;font-size:13px;font-weight:500;">
                                <%= errorMessage%>
                            </div>
                            <%
                                }
                                if ("success".equals(msg)) {
                            %>
                            <div style="margin:0 0 16px 0;padding:12px 14px;border-radius:8px;background:#ECFDF5;color:#047857;border:1px solid #A7F3D0;font-size:13px;font-weight:500;">
                                Stock Out recorded successfully.
                            </div>
                            <%
                                }
                            %>

                            <form
                                action="<%= request.getContextPath()%>/stockout"
                                method="POST"
                                onsubmit="return validateStockOut();">

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>

                                            Medicine

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <select
                                            name="medicineId"
                                            class="form-control"
                                            onchange="updateStockInfo(this)"
                                            required>

                                            <option value="">
                                                Select medicine
                                            </option>

                                            <%
                                                java.util.List<com.clinicalert.model.Medicine> medicineList
                                                        = (java.util.List<com.clinicalert.model.Medicine>) request.getAttribute("medicines");

                                                if (medicineList != null) {

                                                    for (com.clinicalert.model.Medicine medicine
                                                            : medicineList) {

                                                        String medicineUnit
                                                                = medicine.getUnit() == null
                                                                ? ""
                                                                : medicine.getUnit();

                                                        String medicineBatch
                                                                = medicine.getBatchNo() == null
                                                                ? ""
                                                                : medicine.getBatchNo();

                                                        String medicineExpiry
                                                                = medicine.getExpiryDate() == null
                                                                ? ""
                                                                : medicine.getExpiryDate();

                                            %>

                                            <option
                                                value="<%= medicine.getMedicineId()%>"
                                                data-name="<%= escapeHtml(medicine.getName())%>"
                                                data-stock="<%= medicine.getCurrentStock()%>"
                                                data-unit="<%= escapeHtml(medicineUnit)%>"
                                                data-batch="<%= escapeHtml(medicineBatch)%>"
                                                data-expiry="<%= escapeHtml(medicineExpiry)%>">

                                                <%= medicine.getName()%>

                                            </option>

                                            <%
                                                    }
                                                }
                                            %>

                                        </select>

                                    </div>

                                    <div class="form-group">

                                        <label>

                                            Batch No.

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <select
                                            name="batchNo"
                                            id="batchNo"
                                            class="form-control"
                                            onchange="updateBatchInfo(this)"
                                            required>

                                            <option value="">
                                                Select medicine first
                                            </option>

                                        </select>

                                    </div>

                                </div>

                                <div class="stock-info-box">

                                    <div class="stock-info-item">

                                        <span class="label">
                                            Available Stock
                                        </span>

                                        <span
                                            class="val"
                                            id="availStock">

                                            0

                                        </span>

                                        <span
                                            class="label"
                                            style="margin-top:6px;">

                                            Unit:
                                            <span id="stockUnitDisplay">
                                                -
                                            </span>

                                        </span>

                                    </div>

                                    <div
                                        class="stock-info-item"
                                        style="text-align:right;">

                                        <span class="label">
                                            Expiry Date
                                        </span>

                                        <span
                                            class="val"
                                            id="expDate"
                                            style="color:#0066FF;">

                                            -

                                        </span>

                                    </div>

                                </div>

                                <input
                                    type="hidden"
                                    name="unit"
                                    id="stockUnit"
                                    value="">

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>

                                            Quantity

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <input
                                            type="number"
                                            id="quantity"
                                            name="quantity"
                                            class="form-control"
                                            placeholder="Enter quantity"
                                            min="1"
                                            required>

                                    </div>

                                    <div class="form-group">

                                        <label>

                                            Reason

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <select
                                            name="reason"
                                            id="reason"
                                            class="form-control"
                                            required>

                                            <option value="">
                                                Select reason
                                            </option>

                                            <option value="Prescription Dispense">
                                                Prescription Dispense
                                            </option>

                                            <option value="Emergency Outpatient Triage">
                                                Emergency Outpatient Triage
                                            </option>

                                            <option value="Damaged / Broken Packaging">
                                                Damaged / Broken Packaging
                                            </option>

                                            <option value="Quarantine & Destruction">
                                                Quarantine & Destruction
                                            </option>
                                            
                                            <option value="Quarantine & Destruction">
                                                Near expiry/Expired
                                            </option>

                                        </select>

                                    </div>

                                </div>

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>

                                            Requested By

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <input
                                            type="text"
                                            class="form-control"
                                            value="<%= currentUser.getStaffId()%> - <%= currentUser.getName()%>"
                                            readonly>

                                    </div>

                                    <div class="form-group">

                                        <label>
                                            Remarks
                                        </label>

                                        <input
                                            type="text"
                                            name="additionalRemarks"
                                            id="additionalRemarks"
                                            class="form-control"
                                            placeholder="Enter remarks (optional)">

                                    </div>

                                </div>

                                <div
                                    style="
                                    display:flex;
                                    justify-content:flex-end;
                                    gap:12px;
                                    margin-top:24px;
                                    ">

                                    <button
                                        type="reset"
                                        class="btn-secondary"
                                        onclick="resetStockInfo()">

                                        Reset

                                    </button>

                                    <button
                                        type="submit"
                                        class="btn-primary">

                                        Save

                                    </button>

                                </div>

                            </form>

                        </div>

                        <div class="panel-card">

                            <div class="panel-header">

                                <h3>
                                    Recent Stock Out
                                </h3>

                            </div>

                            <div>

                                <%
                                    java.util.List<com.clinicalert.model.StockTransaction> stockOutHistory
                                            = (java.util.List<com.clinicalert.model.StockTransaction>) request.getAttribute("stockOutHistory");

                                    if (stockOutHistory != null
                                            && !stockOutHistory.isEmpty()) {

                                        int recentCount
                                                = Math.min(
                                                        stockOutHistory.size(),
                                                        5
                                                );

                                        for (int i = 0;
                                                i < recentCount;
                                                i++) {

                                            com.clinicalert.model.StockTransaction txn
                                                    = stockOutHistory.get(i);

                                %>

                                <div class="recent-item">

                                    <div class="recent-date">

                                        <%= txn.getDate() == null
                                                || txn.getDate().isEmpty()
                                                ? "-"
                                                : txn.getDate()%>

                                    </div>

                                    <div class="recent-name">

                                        <%= txn.getMedicineName() == null
                                                ? "-"
                                                : txn.getMedicineName()%>

                                    </div>

                                    <div class="recent-quantity">

                                        -<%= txn.getQuantity()%>

                                        <%= txn.getUnit() == null
                                                || txn.getUnit().isEmpty()
                                                ? "units"
                                                : txn.getUnit()%>

                                    </div>

                                    <div class="recent-staff">

                                        <%= txn.getRecordedBy() == null
                                                || txn.getRecordedBy().isEmpty()
                                                ? "-"
                                                : txn.getRecordedBy()%>

                                    </div>

                                    <%
                                        if (txn.getBatchNo() != null
                                                && !txn.getBatchNo().isEmpty()) {
                                    %>

                                    <div
                                        style="
                                        color:#64748B;
                                        font-size:11px;
                                        margin-top:2px;
                                        ">

                                        Batch:
                                        <%= txn.getBatchNo()%>

                                    </div>

                                    <%
                                        }
                                    %>

                                </div>

                                <%
                                    }

                                } else {
                                %>

                                <div class="recent-item">

                                    <div class="recent-name">

                                        No stock-out records found.

                                    </div>

                                </div>

                                <%
                                    }
                                %>

                            </div>

                            <div
                                style="
                                text-align:center;
                                margin-top:20px;
                                padding-top:14px;
                                border-top:1px solid #E2E8F0;
                                ">

                                <a
                                    href="<%= request.getContextPath()%>/reports"
                                    class="view-all-link">

                                    View All

                                </a>

                            </div>

                        </div>

                    </div>

                </div>

            </main>

        </div>

        <div
            id="logoutModal"
            class="modal-backdrop"
            style="display:none;">

            <div
                class="modal-card"
                style="
                max-width:400px;
                text-align:center;
                ">

                <div
                    style="
                    width:55px;
                    height:55px;
                    margin:0 auto 15px;
                    border-radius:14px;
                    background:#FEF2F2;
                    color:#EF4444;
                    display:flex;
                    align-items:center;
                    justify-content:center;
                    ">

                    <svg
                        width="26"
                        height="26"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2">

                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/>
                    <line x1="21" y1="12" x2="9" y2="12"/>

                    </svg>

                </div>

                <h3>
                    Logout
                </h3>

                <p>
                    Are you sure you want to logout?
                </p>

                <div
                    style="
                    display:flex;
                    gap:10px;
                    margin-top:20px;
                    ">

                    <button
                        type="button"
                        class="btn-secondary"
                        onclick="closeLogoutModal()"
                        style="
                        flex:1;
                        justify-content:center;
                        ">

                        Cancel

                    </button>

                    <a
                        href="<%= request.getContextPath()%>/logout"
                        class="btn-danger"
                        style="
                        flex:1;
                        justify-content:center;
                        text-decoration:none;
                        display:flex;
                        align-items:center;
                        ">

                        Logout

                    </a>

                </div>

            </div>

        </div>

    </body>

</html>
