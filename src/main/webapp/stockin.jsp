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
%>
<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>
            Stock In - Clinic Alert System
        </title>

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
                color: #0066FF;
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

        <script>

            function updateMedicineInfo(selectElem) {

                var option = selectElem.options[selectElem.selectedIndex];

                var currentStock = document.getElementById("currentStock");
                var unit = document.getElementById("stockUnit");
                var unitDisplay = document.getElementById("stockUnitDisplay");
                var category = document.getElementById("medicineCategory");
                var receivedUnitDisplay = document.getElementById("receivedUnitDisplay");
                var receivedUnit = document.getElementById("receivedUnit");

                if (!option || !option.value) {
                    currentStock.innerText = "0";
                    unit.innerText = "-";
                    unitDisplay.innerText = "-";
                    category.innerText = "-";
                    receivedUnitDisplay.value = "";
                    receivedUnit.value = "";
                    return;
                }

                currentStock.innerText = option.getAttribute("data-stock") || "0";
                unit.innerText = option.getAttribute("data-unit") || "-";
                unitDisplay.innerText = option.getAttribute("data-unit") || "-";
                category.innerText = option.getAttribute("data-category") || "-";

                var selectedUnit = option.getAttribute("data-unit") || "";
                receivedUnitDisplay.value = selectedUnit;
                receivedUnit.value = selectedUnit;

                // Pre-select the medicine's usual supplier (staff can still change it)
                var supplierSelect = document.getElementById("supplierSelect");
                var usualSupplier = option.getAttribute("data-supplier") || "";
                if (supplierSelect && usualSupplier) {
                    supplierSelect.value = usualSupplier;
                    if (supplierSelect.value !== usualSupplier) {
                        supplierSelect.value = "";
                    }
                }
            }

            function validateStockIn() {

                var quantity =
                        parseInt(
                                document.getElementById("quantity").value
                                );

                if (isNaN(quantity) || quantity <= 0) {

                    alert(
                            "Please enter a valid quantity."
                            );

                    return false;

                }

                var expiry =
                        document.getElementById("expiryDate").value;

                if (expiry === "") {

                    alert(
                            "Please select the expiry date."
                            );

                    return false;

                }

                return true;

            }

            function resetStockInfo() {

                document.getElementById("currentStock")
                        .innerText = "0";

                document.getElementById("stockUnit")
                        .innerText = "-";

                document.getElementById("stockUnitDisplay")
                        .innerText = "-";

                document.getElementById("medicineCategory")
                        .innerText = "-";

                document.getElementById("receivedUnitDisplay")
                        .value = "";

                document.getElementById("receivedUnit")
                        .value = "";

            }

            document.addEventListener("DOMContentLoaded", function () {
                var urlParams = new URLSearchParams(window.location.search);
                var targetMedId = urlParams.get("medicineId") || urlParams.get("id");
                if (targetMedId) {
                    var medSelect = document.querySelector("select[name='medicineId']");
                    if (medSelect) {
                        medSelect.value = targetMedId;
                        updateMedicineInfo(medSelect);
                    }
                }
            });

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

                        <rect
                            x="18"
                            y="20"
                            width="28"
                            height="36"
                            rx="6"
                            fill="#0A2540"/>

                        <rect
                            x="23"
                            y="14"
                            width="18"
                            height="6"
                            rx="2"
                            fill="#0066FF"/>

                        <rect
                            x="29"
                            y="32"
                            width="6"
                            height="14"
                            rx="1.5"
                            fill="#10B981"/>

                        <rect
                            x="25"
                            y="36"
                            width="14"
                            height="6"
                            rx="1.5"
                            fill="#10B981"/>

                        <rect
                            x="36"
                            y="24"
                            width="18"
                            height="26"
                            rx="3"
                            fill="#FFFFFF"
                            stroke="#0A2540"
                            stroke-width="2"/>

                        <line
                            x1="40"
                            y1="31"
                            x2="50"
                            y2="31"
                            stroke="#0066FF"
                            stroke-width="2"
                            stroke-linecap="round"/>

                        <line
                            x1="40"
                            y1="36"
                            x2="48"
                            y2="36"
                            stroke="#0066FF"
                            stroke-width="2"
                            stroke-linecap="round"/>

                        <circle
                            cx="16"
                            cy="18"
                            r="7"
                            fill="#10B981"/>

                        <path
                            d="M13 18C13 14 19 14 19 18C19 22 13 22 13 18Z"
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

                            <rect x="3"
                                  y="3"
                                  width="7"
                                  height="7"/>

                            <rect x="14"
                                  y="3"
                                  width="7"
                                  height="7"/>

                            <rect x="14"
                                  y="14"
                                  width="7"
                                  height="7"/>

                            <rect x="3"
                                  y="14"
                                  width="7"
                                  height="7"/>

                            </svg>

                            <span>
                                Dashboard
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/medicine"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/>

                            <path d="m8.5 8.5 7 7"/>

                            </svg>

                            <span>
                                Medicine
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/stockin"
                       class="nav-link active">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path d="M12 3v12"/>

                            <path d="m8 11 4 4 4-4"/>

                            <path
                                d="M8 5H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-4"/>

                            </svg>

                            <span>
                                Stock In
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/stockout"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <path d="M12 21V9"></path>

                            <path d="m16 13-4-4-4 4"></path>

                            <path d="M16 19h4a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h4"></path>

                            </svg>

                            <span>
                                Stock Out
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/lowstock"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>

                            <line x1="12"
                                  y1="9"
                                  x2="12"
                                  y2="13"/>

                            <line x1="12"
                                  y1="17"
                                  x2="12.01"
                                  y2="17"/>

                            </svg>

                            <span>
                                Low Stock Alert
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/expiry"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <circle cx="12"
                                    cy="12"
                                    r="10"/>

                            <polyline points="12 6 12 12 16 14"/>

                            </svg>

                            <span>
                                Expiry Alert
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

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

                            <span>
                                Restock Orders
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/reports"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>

                            <polyline points="14 2 14 8 20 8"/>

                            <line x1="16"
                                  y1="13"
                                  x2="8"
                                  y2="13"/>

                            <line x1="16"
                                  y1="17"
                                  x2="8"
                                  y2="17"/>

                            <polyline points="10 9 9 9 8 9"/>

                            </svg>

                            <span>
                                Reports
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/profile"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>

                            <circle cx="12"
                                    cy="7"
                                    r="4"/>

                            </svg>

                            <span>
                                Profile
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <% if (isAdmin) {%>

                    <a href="<%= request.getContextPath()%>/usermanagement"
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>

                            <circle cx="9"
                                    cy="7"
                                    r="4"/>

                            <path
                                d="M22 21v-2a4 4 0 0 0-3-3.87"/>

                            <path
                                d="M16 3.13a4 4 0 0 1 0 7.75"/>

                            </svg>

                            <span>
                                User Management
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

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
                             height="18"
                             style="width:18px !important; height:18px !important; flex:0 0 18px !important;">

                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                        <polyline points="16 17 21 12 16 7"></polyline>
                        <line x1="21" y1="12" x2="9" y2="12"></line>

                        </svg>

                        <span style="display:inline !important; font-size:13px !important;">
                            Logout
                        </span>

                    </button>

                </div>

            </aside>

            <main class="main-wrapper">

                <header class="top-navbar">

                    <div class="page-title">

                        <h2>
                            Stock In
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

                            <path
                                d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>

                            <circle
                                cx="12"
                                cy="7"
                                r="4"/>

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
                                    Add Stock
                                </h3>

                            </div>

                            <%
                                String errorMessage = (String) request.getAttribute("errorMessage");
                                String msg = request.getParameter("msg");
                                if (errorMessage != null && !errorMessage.isEmpty()) {
                            %>
                            <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#FEF2F2;color:#B91C1C;border:1px solid #FECACA;">
                                <%= errorMessage%>
                            </div>
                            <%
                                }
                                if ("success".equals(msg)) {
                            %>
                            <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#ECFDF5;color:#047857;border:1px solid #A7F3D0;">
                                Stock In recorded successfully.
                            </div>
                            <%
                                }
                                if ("batchdeleted".equals(msg)) {
                            %>
                            <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#ECFDF5;color:#047857;border:1px solid #A7F3D0;">
                                Batch deleted and medicine stock adjusted.
                            </div>
                            <%
                                }
                                if ("batcherror".equals(msg)) {
                            %>
                            <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#FEF2F2;color:#B91C1C;border:1px solid #FECACA;">
                                Unable to delete the batch.
                            </div>
                            <%
                                }
                            %>

                            <form
                                action="<%= request.getContextPath()%>/stockin"
                                method="POST"
                                onsubmit="return validateStockIn();"
                                >

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>

                                            Medicine Name

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <select
                                            name="medicineId"
                                            class="form-control"
                                            onchange="updateMedicineInfo(this)"
                                            required
                                            >

                                            <option value="">
                                                Select medicine
                                            </option>

                                            <%
                                                java.util.List<com.clinicalert.model.Medicine> medicineList
                                                        = (java.util.List<com.clinicalert.model.Medicine>) request.getAttribute("medicines");

                                                if (medicineList != null) {
                                                    for (com.clinicalert.model.Medicine medicine : medicineList) {
                                            %>
                                            <option value="<%= medicine.getMedicineId()%>"
                                                    data-stock="<%= medicine.getCurrentStock()%>"
                                                    data-unit="<%= medicine.getUnit() == null ? "" : medicine.getUnit()%>"
                                                    data-category="<%= medicine.getCategory() == null ? "" : medicine.getCategory()%>"
                                                    data-supplier="<%= medicine.getSupplier() == null ? "" : medicine.getSupplier().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;")%>">
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

                                        <input
                                            type="text"
                                            name="batchNo"
                                            class="form-control"
                                            placeholder="e.g. B260805-001"
                                            required
                                            >

                                    </div>

                                </div>

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>
                                            Category
                                        </label>

                                        <div
                                            class="form-control"
                                            id="medicineCategory"
                                            style="
                                            display:flex;
                                            align-items:center;
                                            background:#F8FAFC;
                                            "
                                            >
                                            -
                                        </div>

                                    </div>

                                    <div class="form-group">

                                        <label>
                                            Unit
                                        </label>

                                        <div
                                            class="form-control"
                                            id="stockUnit"
                                            style="
                                            display:flex;
                                            align-items:center;
                                            background:#F8FAFC;
                                            "
                                            >
                                            -
                                        </div>

                                    </div>

                                </div>

                                <div class="stock-info-box">

                                    <div class="stock-info-item">

                                        <span class="label">
                                            Current Stock
                                        </span>

                                        <span
                                            class="val"
                                            id="currentStock"
                                            >
                                            0
                                        </span>

                                    </div>

                                    <div
                                        class="stock-info-item"
                                        style="text-align:right;"
                                        >

                                        <span class="label">
                                            Stock Unit
                                        </span>

                                        <span
                                            class="val"
                                            id="stockUnitDisplay"
                                            >
                                            -
                                        </span>

                                    </div>

                                </div>

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>

                                            Quantity Received

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
                                            required
                                            >

                                    </div>

                                    <div class="form-group">

                                        <label>

                                            Unit

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <input
                                            type="text"
                                            id="receivedUnitDisplay"
                                            class="form-control"
                                            placeholder="Select medicine first"
                                            readonly
                                            required
                                            style="background:#F8FAFC;"
                                            >

                                        <input
                                            type="hidden"
                                            name="unit"
                                            id="receivedUnit"
                                            >

                                    </div>

                                </div>

                                <div class="form-group">

                                    <label>

                                        Supplier

                                        <span class="required">
                                            *
                                        </span>

                                    </label>

                                    <select
                                        name="supplier"
                                        id="supplierSelect"
                                        class="form-control"
                                        required
                                        >

                                        <option value="">
                                            Select supplier
                                        </option>

                                        <%
                                            java.util.List<com.clinicalert.model.Supplier> supplierList
                                                    = (java.util.List<com.clinicalert.model.Supplier>) request.getAttribute("suppliers");

                                            if (supplierList != null) {
                                                for (com.clinicalert.model.Supplier s : supplierList) {
                                                    String sName = s.getSupplierName() == null ? "" : s.getSupplierName();
                                        %>
                                        <option value="<%= sName.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;")%>">
                                            <%= sName.replace("&", "&amp;").replace("<", "&lt;")%>
                                        </option>
                                        <%
                                                }
                                            }
                                        %>

                                    </select>

                                </div>

                                <div class="form-grid-2">

                                    <div class="form-group">

                                        <label>

                                            Received Date

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <input
                                            type="date"
                                            name="receivedDate"
                                            class="form-control"
                                            value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())%>"
                                            required
                                            >

                                    </div>

                                    <div class="form-group">

                                        <label>

                                            Expiry Date

                                            <span class="required">
                                                *
                                            </span>

                                        </label>

                                        <input
                                            type="date"
                                            id="expiryDate"
                                            name="expiryDate"
                                            class="form-control"
                                            required
                                            >

                                    </div>

                                </div>

                                <div class="form-group">

                                    <label>
                                        Remarks
                                    </label>

                                    <textarea
                                        name="remarks"
                                        class="form-control"
                                        rows="3"
                                        placeholder="Enter remarks (optional)"
                                        style="resize:vertical;"
                                        ></textarea>

                                </div>

                                <div
                                    style="
                                    display:flex;
                                    justify-content:flex-end;
                                    gap:12px;
                                    margin-top:24px;
                                    "
                                    >

                                    <button
                                        type="reset"
                                        class="btn-secondary"
                                        onclick="resetStockInfo()"
                                        >
                                        Reset
                                    </button>

                                    <button
                                        type="submit"
                                        class="btn-primary"
                                        >
                                        Add Stock
                                    </button>

                                </div>

                            </form>

                        </div>

                        <div class="panel-card">

                            <div class="panel-header">

                                <h3>
                                    Recent Stock In
                                </h3>

                            </div>

                            <div>

                                <%
                                    java.util.List<com.clinicalert.model.StockTransaction> stockInHistory
                                            = (java.util.List<com.clinicalert.model.StockTransaction>) request.getAttribute("stockInHistory");

                                    if (stockInHistory != null && !stockInHistory.isEmpty()) {
                                        int recentCount = Math.min(stockInHistory.size(), 5);

                                        for (int i = 0; i < recentCount; i++) {
                                            com.clinicalert.model.StockTransaction txn = stockInHistory.get(i);
                                %>
                                <div class="recent-item">

                                    <div class="recent-date">
                                        <%= txn.getDate() == null || txn.getDate().isEmpty() ? "-" : txn.getDate()%>
                                    </div>

                                    <div class="recent-name">
                                        <%= txn.getMedicineName() == null ? "-" : txn.getMedicineName()%>
                                    </div>

                                    <div class="recent-quantity">
                                        +<%= txn.getQuantity()%> <%= txn.getUnit() == null || txn.getUnit().isEmpty() ? "units" : txn.getUnit()%>
                                    </div>

                                    <div class="recent-staff">
                                        <%= txn.getRecordedBy() == null || txn.getRecordedBy().isEmpty() ? "-" : txn.getRecordedBy()%>
                                    </div>

                                </div>
                                <%
                                    }
                                } else {
                                %>
                                <div class="recent-item">
                                    <div class="recent-name">No stock-in records found.</div>
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
                                "
                                >

                                <a
                                    href="<%= request.getContextPath()%>/reports"
                                    class="view-all-link"
                                    >
                                    View All
                                </a>

                            </div>

                        </div>

                    </div>

                    <%
                        java.util.List<com.clinicalert.dao.MedicineDAO.BatchSummary> batchList
                                = (java.util.List<com.clinicalert.dao.MedicineDAO.BatchSummary>) request.getAttribute("batches");

                        if (isAdmin) {
                    %>
                    <div class="panel-card" style="margin-top:24px;">

                        <div class="panel-header">
                            <h3>Manage Batches</h3>
                        </div>

                        <p style="margin:0 0 14px;color:#64748B;font-size:13px;">
                            Deleting a batch permanently removes its Stock In and Stock Out records
                            and subtracts its remaining quantity from the medicine's current stock.
                        </p>

                        <div style="overflow-x:auto;">
                            <table style="width:100%;border-collapse:collapse;font-size:14px;">
                                <thead>
                                    <tr style="text-align:left;color:#64748B;border-bottom:1px solid #E2E8F0;">
                                        <th style="padding:10px 8px;">Medicine</th>
                                        <th style="padding:10px 8px;">Batch No</th>
                                        <th style="padding:10px 8px;">Expiry</th>
                                        <th style="padding:10px 8px;text-align:right;">Received</th>
                                        <th style="padding:10px 8px;text-align:right;">Issued</th>
                                        <th style="padding:10px 8px;text-align:right;">Remaining</th>
                                        <th style="padding:10px 8px;"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (batchList == null || batchList.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="7" style="padding:14px 8px;color:#64748B;">No batches found.</td>
                                    </tr>
                                    <%
                                    } else {
                                        for (com.clinicalert.dao.MedicineDAO.BatchSummary b : batchList) {
                                            String bName = b.getMedicineName() == null ? "" : b.getMedicineName();
                                            String bItem = b.getItemId() == null ? "" : b.getItemId();
                                            String bBatch = b.getBatchNo() == null ? "" : b.getBatchNo();
                                    %>
                                    <tr style="border-bottom:1px solid #F1F5F9;">
                                        <td style="padding:10px 8px;"><%= bName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")%> <span style="color:#94A3B8;">(<%= bItem.replace("&", "&amp;").replace("<", "&lt;")%>)</span></td>
                                        <td style="padding:10px 8px;"><%= bBatch.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")%></td>
                                        <td style="padding:10px 8px;"><%= b.getExpiryDate().isEmpty() ? "-" : b.getExpiryDate()%></td>
                                        <td style="padding:10px 8px;text-align:right;"><%= b.getReceived()%></td>
                                        <td style="padding:10px 8px;text-align:right;"><%= b.getIssued()%></td>
                                        <td style="padding:10px 8px;text-align:right;"><%= b.getRemaining()%></td>
                                        <td style="padding:10px 8px;text-align:right;">
                                            <form action="<%= request.getContextPath()%>/stockin" method="POST" style="margin:0;"
                                                  onsubmit="return confirm('Delete batch ' + this.batchNo.value + ' of ' + this.itemId.value + '?\nThis removes its Stock In/Out records and subtracts <%= b.getRemaining()%> from current stock. This cannot be undone.');">
                                                <input type="hidden" name="action" value="deleteBatch">
                                                <input type="hidden" name="itemId" value="<%= bItem.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;")%>">
                                                <input type="hidden" name="batchNo" value="<%= bBatch.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;")%>">
                                                <button type="submit"
                                                        style="padding:6px 12px;border:1px solid #FECACA;border-radius:8px;background:#FEF2F2;color:#B91C1C;font-weight:600;cursor:pointer;">
                                                    Delete batch
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>

                    </div>
                    <%
                        }
                    %>

                </div>

            </main>

        </div>

        <jsp:include page="logout.jsp" />

    </body>

</html>