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
            Medicine - Clinic Alert: Smart Medicine Management System
        </title>

        <link rel="stylesheet"
              href="css/style.css">

        <style>
            .med-tile {
                background: #FFFFFF;
                border: 1px solid #E2E8F0;
                border-radius: 10px;
                padding: 11px 14px;
                display: flex;
                flex-direction: column;
                gap: 4px;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
                transition: all 0.15s ease;
            }

            .med-tile:hover {
                border-color: #CBD5E1;
                background: #FAFAFA;
            }

            .med-tile-label {
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: #64748B;
                font-weight: 600;
            }

            .med-tile-value {
                font-size: 13.5px;
                color: #0F172A;
                word-break: break-word;
            }

            .med-detail-status {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 4px 11px;
                border-radius: 9999px;
                font-size: 12px;
                font-weight: 600;
                white-space: nowrap;
            }

            .status-success {
                background: #ECFDF5;
                color: #047857;
                border: 1px solid #A7F3D0;
            }

            .status-warning {
                background: #FFFBEB;
                color: #B45309;
                border: 1px solid #FDE68A;
            }

            .status-critical {
                background: #FEF2F2;
                color: #B91C1C;
                border: 1px solid #FECACA;
            }

            .status-dot-pulse {
                width: 7px;
                height: 7px;
                border-radius: 50%;
                display: inline-block;
            }

            .dot-green {
                background: #10B981;
            }

            .dot-amber {
                background: #F59E0B;
            }

            .dot-red {
                background: #EF4444;
            }
        </style>

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
                            fill="#0A2540" />

                        <rect
                            x="23"
                            y="14"
                            width="18"
                            height="6"
                            rx="2"
                            fill="#0066FF" />

                        <rect
                            x="29"
                            y="32"
                            width="6"
                            height="14"
                            rx="1.5"
                            fill="#10B981" />

                        <rect
                            x="25"
                            y="36"
                            width="14"
                            height="6"
                            rx="1.5"
                            fill="#10B981" />

                        <rect
                            x="36"
                            y="24"
                            width="18"
                            height="26"
                            rx="3"
                            fill="#FFFFFF"
                            stroke="#0A2540"
                            stroke-width="2" />

                        <line
                            x1="40"
                            y1="31"
                            x2="50"
                            y2="31"
                            stroke="#0066FF"
                            stroke-width="2"
                            stroke-linecap="round" />

                        <line
                            x1="40"
                            y1="36"
                            x2="48"
                            y2="36"
                            stroke="#0066FF"
                            stroke-width="2"
                            stroke-linecap="round" />

                        <circle
                            cx="16"
                            cy="18"
                            r="7"
                            fill="#10B981" />

                        <path
                            d="M13 18C13 14 19 14 19 18C19 22 13 22 13 18Z"
                            fill="#FFFFFF" />

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
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <rect x="3"
                                  y="3"
                                  width="7"
                                  height="7"></rect>

                            <rect x="14"
                                  y="3"
                                  width="7"
                                  height="7"></rect>

                            <rect x="14"
                                  y="14"
                                  width="7"
                                  height="7"></rect>

                            <rect x="3"
                                  y="14"
                                  width="7"
                                  height="7"></rect>

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
                       class="nav-link active">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"></path>

                            <path d="m8.5 8.5 7 7"></path>

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
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <path d="M12 3v12"></path>

                            <path d="m8 11 4 4 4-4"></path>

                            <path d="M8 5H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-4"></path>

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

                            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path>

                            <line x1="12"
                                  y1="9"
                                  x2="12"
                                  y2="13"></line>

                            <line x1="12"
                                  y1="17"
                                  x2="12.01"
                                  y2="17"></line>

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
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <circle cx="12"
                                    cy="12"
                                    r="10"></circle>

                            <polyline points="12 6 12 12 16 14"></polyline>

                            </svg>

                            <span>
                                Expiry Alert
                            </span>

                        </div>

                        <span class="chevron-icon">
                            &rsaquo;
                        </span>

                    </a>

                    <a href="<%= request.getContextPath()%>/restock"
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
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>

                            <polyline points="14 2 14 8 20 8"></polyline>

                            <line x1="16"
                                  y1="13"
                                  x2="8"
                                  y2="13"></line>

                            <line x1="16"
                                  y1="17"
                                  x2="8"
                                  y2="17"></line>

                            <polyline points="10 9 9 9 8 9"></polyline>

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
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>

                            <circle cx="12"
                                    cy="7"
                                    r="4"></circle>

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
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">

                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>

                            <circle cx="9"
                                    cy="7"
                                    r="4"></circle>

                            <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>

                            <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>

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

                        <line x1="21"
                              y1="12"
                              x2="9"
                              y2="12"></line>

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
                            Medicine
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

                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>

                            <circle cx="12"
                                    cy="7"
                                    r="4"></circle>

                            </svg>

                        </div>

                        <span>
                            <%= staffName%> (<%= userRole%>)
                        </span>

                    </div>

                </header>

                <div class="content-container">

                    <div
                        style="
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 20px;
                        "
                        >

                        <div>

                            <h1
                                style="
                                margin: 0;
                                font-size: 22px;
                                font-weight: 700;
                                color: #1E293B;
                                "
                                >
                                Medicine Inventory
                            </h1>

                            <p
                                style="
                                margin: 5px 0 0;
                                font-size: 13px;
                                color: #64748B;
                                "
                                >
                                Manage and monitor medicine information
                            </p>

                        </div>

                        <button
                            type="button"
                            class="btn-primary"
                            onclick="openAddMedicineModal()"
                            >

                            <span
                                style="
                                font-size: 18px;
                                line-height: 1;
                                "
                                >
                                +
                            </span>

                            Add Medicine

                        </button>

                    </div>

                    <div class="panel-card"
                         style="margin-bottom: 20px;">

                        <div
                            style="
                            display: flex;
                            gap: 12px;
                            align-items: center;
                            flex-wrap: wrap;
                            "
                            >

                            <div
                                style="
                                position: relative;
                                flex: 1;
                                min-width: 220px;
                                "
                                >

                                <input
                                    type="text"
                                    id="medicineSearch"
                                    class="form-control"
                                    placeholder="Search medicine name, batch no..."
                                    onkeyup="filterMedicineTable()"
                                    style="padding-left: 38px;"
                                    >

                                <svg
                                    style="
                                    position: absolute;
                                    left: 12px;
                                    top: 50%;
                                    transform: translateY(-50%);
                                    color: #94A3B8;
                                    "
                                    width="17"
                                    height="17"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    >

                                <circle cx="11"
                                        cy="11"
                                        r="8"></circle>

                                <line x1="21"
                                      y1="21"
                                      x2="16.65"
                                      y2="16.65"></line>

                                </svg>

                            </div>

                            <select
                                id="categoryFilter"
                                class="form-control"
                                onchange="filterMedicineTable()"
                                style="width: 180px;"
                                >

                                <option value="">
                                    All Units
                                </option>

                            </select>

                        </div>

                    </div>

                    <div class="panel-card">

                        <div class="panel-header">

                            <h3>
                                Medicine List
                            </h3>

                            <span
                                style="
                                font-size: 13px;
                                color: #64748B;
                                "
                                >
                                <span id="medicineCount">Loading medicines...</span>
                            </span>

                        </div>

                        <style>
                            /* Nine columns now: keep the list compact so Action stays visible */
                            #medicineTable th,
                            #medicineTable td {
                                padding-left: 10px;
                                padding-right: 10px;
                            }
                            #medicineTable .badge {
                                white-space: nowrap;
                            }
                        </style>

                        <div class="table-responsive">

                            <table class="custom-table"
                                   id="medicineTable">

                                <thead>

                                    <tr>

                                        <th>
                                            Medicine Name
                                        </th>

                                        <th>
                                            Batch No.
                                        </th>

                                        <th>
                                            Category
                                        </th>

                                        <th>
                                            Supplier
                                        </th>

                                        <th>
                                            Unit
                                        </th>

                                        <th>
                                            Current Stock
                                        </th>

                                        <th>
                                            Min Stock
                                        </th>

                                        <th>
                                            Status
                                        </th>

                                        <th>
                                            Action
                                        </th>

                                    </tr>

                                </thead>

                                <tbody id="medicineTableBody">
                                    <tr><td colspan="9" style="text-align:center;padding:30px;color:#64748B;">Loading medicines...</td></tr>
                                </tbody>

                            </table>

                        </div>

                    </div>

                </div>

            </main>

        </div>

        <div id="addMedicineModal"
             class="modal-backdrop"
             style="display:none;">

            <div class="modal-card" style="max-width: 540px; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.12), 0 8px 10px -6px rgba(0,0,0,0.08);">

                <div class="modal-header" style="padding: 16px 22px; background: #FFFFFF; border-bottom: 1px solid #F1F5F9; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 38px; height: 38px; border-radius: 10px; background: #EFF6FF; color: #2563EB; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="12" y1="5" x2="12" y2="19"></line>
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            </svg>
                        </div>
                        <div>
                            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0F172A; line-height: 1.2;">
                                Add New Medicine
                            </h3>
                            <span style="font-size: 12px; color: #64748B;">
                                Enter medicine specifications & inventory details
                            </span>
                        </div>
                    </div>
                    <button
                        type="button"
                        class="modal-close"
                        onclick="closeAddMedicineModal()"
                        style="width: 32px; height: 32px; border-radius: 8px; border: none; background: #F8FAFC; color: #64748B; font-size: 18px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s;"
                        >
                        &times;
                    </button>
                </div>

                <form onsubmit="saveMedicine(event)">

                    <div class="modal-body" style="padding: 20px 22px; max-height: calc(85vh - 130px); overflow-y: auto;">

                        <div class="form-group" style="margin-bottom: 14px;">
                            <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                Medicine Name <span class="required" style="color: #EF4444;">*</span>
                            </label>
                            <input
                                type="text"
                                id="addMedicineName"
                                class="form-control"
                                placeholder="e.g. Paracetamol 500mg"
                                required
                                style="border-radius: 8px; font-size: 13.5px; padding: 9px 12px;"
                                >
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Batch No. <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <input
                                    type="text"
                                    id="addBatchNo"
                                    class="form-control"
                                    placeholder="e.g. BT2026001"
                                    required
                                    style="font-family: monospace; font-size: 13px; border-radius: 8px; padding: 9px 12px;"
                                    >
                            </div>

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Category <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <select
                                    id="addCategory"
                                    class="form-control"
                                    required
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                                    <option value="">Select Category</option>
                                    <option value="Analgesic">Analgesic</option>
                                    <option value="Antibiotic">Antibiotic</option>
                                    <option value="Anticoagulant">Anticoagulant</option>
                                    <option value="Antidiabetic">Antidiabetic</option>
                                    <option value="Antifungal">Antifungal</option>
                                    <option value="Antihistamine">Antihistamine</option>
                                    <option value="Antiplatelet">Antiplatelet</option>
                                    <option value="Antiseptic">Antiseptic</option>
                                    <option value="Antiviral">Antiviral</option>
                                    <option value="Cardiovascular">Cardiovascular</option>
                                    <option value="Corticosteroid">Corticosteroid</option>
                                    <option value="Dermatology">Dermatology</option>
                                    <option value="Endocrine">Endocrine</option>
                                    <option value="Gastrointestinal">Gastrointestinal</option>
                                    <option value="Lipid Lowering">Lipid Lowering</option>
                                    <option value="Ophthalmic">Ophthalmic</option>
                                    <option value="Respiratory">Respiratory</option>
                                    <option value="Supplement">Supplement</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>

                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Unit <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <select
                                    id="addUnit"
                                    class="form-control"
                                    required
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                                    <option value="">Select Unit</option>
                                    <option value="Tablet">Tablet</option>
                                    <option value="Capsule">Capsule</option>
                                    <option value="Syrup">Syrup</option>
                                    <option value="Suspension">Suspension</option>
                                    <option value="Inhaler">Inhaler</option>
                                    <option value="Cream">Cream</option>
                                    <option value="Eye Drops">Eye Drops</option>
                                    <option value="Sachet">Sachet</option>
                                    <option value="Suppository">Suppository</option>
                                    <option value="Vial">Vial</option>
                                    <option value="Solution">Solution</option>
                                    <option value="Bottle">Bottle</option>
                                    <option value="Box">Box</option>
                                    <option value="Strip">Strip</option>
                                    <option value="Piece">Piece</option>
                                </select>
                            </div>

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Minimum Stock <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <input
                                    type="number"
                                    id="addMinStock"
                                    class="form-control"
                                    min="0"
                                    placeholder="e.g. 20"
                                    required
                                    style="border-radius: 8px; font-size: 13.5px; padding: 9px 12px;"
                                    >
                            </div>

                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Supplier
                                </label>
                                <input
                                    type="text"
                                    id="addSupplier"
                                    class="form-control"
                                    placeholder="e.g. HealthPlus Supplies"
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                            </div>

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Expiry Date
                                </label>
                                <input
                                    type="date"
                                    id="addExpiryDate"
                                    class="form-control"
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                            </div>

                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                Description & Notes
                            </label>
                            <textarea
                                id="addDescription"
                                class="form-control"
                                rows="3"
                                placeholder="Enter clinical notes, dosage instructions, or remarks..."
                                style="border-radius: 8px; font-size: 13px; padding: 9px 12px; resize: vertical;"
                                ></textarea>
                        </div>

                    </div>

                    <div class="modal-footer" style="padding: 14px 22px; background: #F8FAFC; border-top: 1px solid #E2E8F0; display: flex; align-items: center; justify-content: flex-end; gap: 10px;">
                        <button
                            type="button"
                            class="btn-secondary"
                            onclick="closeAddMedicineModal()"
                            style="padding: 8px 16px; border-radius: 8px; font-size: 13px;"
                            >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            class="btn-primary"
                            style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 600;"
                            >
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                            <span>Save Medicine</span>
                        </button>
                    </div>

                </form>

            </div>

        </div>

        <div id="viewMedicineModal"
             class="modal-backdrop"
             style="display:none;">

            <div class="modal-card" style="max-width: 560px; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.12), 0 8px 10px -6px rgba(0,0,0,0.08);">

                <div class="modal-header" style="padding: 16px 22px; background: #FFFFFF; border-bottom: 1px solid #F1F5F9; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 40px; height: 40px; border-radius: 10px; background: #EFF6FF; color: #2563EB; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"></path>
                            <path d="m8.5 8.5 7 7"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0F172A; line-height: 1.2;">
                                Medicine Details
                            </h3>
                            <span style="font-size: 12px; color: #64748B;">
                                Inventory specifications & batch record
                            </span>
                        </div>
                    </div>
                    <button
                        type="button"
                        class="modal-close"
                        onclick="closeViewMedicineModal()"
                        style="width: 32px; height: 32px; border-radius: 8px; border: none; background: #F8FAFC; color: #64748B; font-size: 18px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s;"
                        >
                        &times;
                    </button>
                </div>

                <div class="modal-body" style="padding: 20px 22px; max-height: calc(85vh - 130px); overflow-y: auto;">

                    <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 12px; padding: 14px 16px; margin-bottom: 14px;">
                        <div style="display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; margin-bottom: 10px;">
                            <div style="flex: 1;">
                                <h4 id="viewName" style="margin: 0 0 6px; font-size: 16px; font-weight: 700; color: #0F172A; line-height: 1.3;">-</h4>
                                <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
                                    <span id="viewIdBadge" style="background: #E2E8F0; color: #334155; font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 6px;">-</span>
                                    <span id="viewCategory" style="background: #EEF2F6; color: #475569; font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 6px;">-</span>
                                </div>
                            </div>
                            <div id="viewStatus" class="med-detail-status status-success">
                                <span class="status-dot-pulse dot-green"></span>
                                In Stock
                            </div>
                        </div>

                        <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid #E2E8F0;">
                            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; margin-bottom: 6px;">
                                <span style="color: #64748B; font-weight: 500;">Stock Health Level</span>
                                <span id="viewStockProgressLabel" style="font-size: 12px; font-weight: 600; color: #059669;">Optimal Stock</span>
                            </div>
                            <div style="width: 100%; height: 7px; background: #E2E8F0; border-radius: 9999px; overflow: hidden;">
                                <div id="viewStockProgress" style="width: 75%; height: 100%; background: #10B981; border-radius: 9999px; transition: width 0.3s ease;"></div>
                            </div>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">

                        <div class="med-tile">
                            <span class="med-tile-label">Current Stock</span>
                            <div id="viewStock" class="med-tile-value" style="color: #0F172A; font-size: 15px; font-weight: 700;">-</div>
                        </div>

                        <div class="med-tile">
                            <span class="med-tile-label">Minimum Stock</span>
                            <div id="viewMinStock" class="med-tile-value" style="color: #475569; font-size: 14px; font-weight: 600;">-</div>
                        </div>

                        <div class="med-tile">
                            <span class="med-tile-label">Batch No.</span>
                            <div id="viewBatch" class="med-tile-value" style="color: #0F172A; font-family: monospace; font-size: 13.5px; font-weight: 600;">-</div>
                        </div>

                        <div class="med-tile">
                            <span class="med-tile-label">Dispense Unit</span>
                            <div id="viewUnit" class="med-tile-value" style="color: #475569; font-size: 13.5px; font-weight: 500;">-</div>
                        </div>

                        <div class="med-tile">
                            <span class="med-tile-label">Expiry Date</span>
                            <div id="viewExpiryDate" class="med-tile-value" style="color: #0F172A; font-size: 13.5px; font-weight: 600;">-</div>
                        </div>

                        <div class="med-tile">
                            <span class="med-tile-label">Storage Location</span>
                            <div id="viewLocation" class="med-tile-value" style="color: #475569; font-size: 13.5px; font-weight: 500;">-</div>
                        </div>

                    </div>

                </div>

                <div class="modal-footer" style="padding: 14px 22px; background: #F8FAFC; border-top: 1px solid #E2E8F0; display: flex; align-items: center; justify-content: flex-end; gap: 10px;">
                    <button
                        type="button"
                        class="btn-secondary"
                        onclick="closeViewMedicineModal()"
                        style="padding: 8px 16px; border-radius: 8px; font-size: 13px;"
                        >
                        Close
                    </button>
                    <a
                        id="viewModalRestockBtn"
                        href="#"
                        class="btn-primary"
                        style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13px; text-decoration: none; font-weight: 600;"
                        >
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="12" y1="5" x2="12" y2="19"></line>
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                        </svg>
                        <span>Stock In</span>
                    </a>
                </div>

            </div>

        </div>

        <div id="editMedicineModal"
             class="modal-backdrop"
             style="display:none;">

            <div class="modal-card" style="max-width: 540px; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.12), 0 8px 10px -6px rgba(0,0,0,0.08);">

                <div class="modal-header" style="padding: 16px 22px; background: #FFFFFF; border-bottom: 1px solid #F1F5F9; display: flex; align-items: center; justify-content: space-between;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 38px; height: 38px; border-radius: 10px; background: #EFF6FF; color: #2563EB; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 20h9"></path>
                            <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0F172A; line-height: 1.2;">
                                Edit Medicine
                            </h3>
                            <span style="font-size: 12px; color: #64748B;">
                                Update specifications, minimum stock, or description
                            </span>
                        </div>
                    </div>
                    <button
                        type="button"
                        class="modal-close"
                        onclick="closeEditMedicineModal()"
                        style="width: 32px; height: 32px; border-radius: 8px; border: none; background: #F8FAFC; color: #64748B; font-size: 18px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s;"
                        >
                        &times;
                    </button>
                </div>

                <form onsubmit="updateMedicine(event)">

                    <div class="modal-body" style="padding: 20px 22px; max-height: calc(85vh - 130px); overflow-y: auto;">

                        <div style="display: flex; align-items: center; justify-content: space-between; background: #F8FAFC; padding: 10px 14px; border-radius: 10px; border: 1px solid #E2E8F0; margin-bottom: 16px;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 11px; color: #64748B; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Medicine ID:</span>
                                <span id="editMedicineIdBadge" style="background: #E2E8F0; color: #0F172A; font-family: monospace; font-size: 12px; font-weight: 700; padding: 2px 8px; border-radius: 5px;">-</span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 6px;">
                                <span style="font-size: 11px; color: #64748B; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Current Stock:</span>
                                <span id="editCurrentStockBadge" style="color: #2563EB; font-size: 13px; font-weight: 700;">-</span>
                            </div>
                        </div>

                        <div class="form-group" style="margin-bottom: 14px;">
                            <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                Medicine Name <span class="required" style="color: #EF4444;">*</span>
                            </label>
                            <input
                                type="text"
                                id="editMedicineName"
                                class="form-control"
                                placeholder="e.g. Paracetamol 500mg"
                                required
                                style="border-radius: 8px; font-size: 13.5px; padding: 9px 12px;"
                                >
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Batch No.
                                </label>
                                <input
                                    type="text"
                                    id="editBatchNo"
                                    class="form-control"
                                    readonly
                                    style="background: #F1F5F9; color: #64748B; cursor: not-allowed; font-family: monospace; font-size: 13px; border-radius: 8px; padding: 9px 12px;"
                                    title="Batch number is tied to inventory records"
                                    >
                            </div>

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Category <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <select
                                    id="editCategory"
                                    class="form-control"
                                    required
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                                    <option value="">Select Category</option>
                                    <option value="Analgesic">Analgesic</option>
                                    <option value="Antibiotic">Antibiotic</option>
                                    <option value="Anticoagulant">Anticoagulant</option>
                                    <option value="Antidiabetic">Antidiabetic</option>
                                    <option value="Antifungal">Antifungal</option>
                                    <option value="Antihistamine">Antihistamine</option>
                                    <option value="Antiplatelet">Antiplatelet</option>
                                    <option value="Antiseptic">Antiseptic</option>
                                    <option value="Antiviral">Antiviral</option>
                                    <option value="Cardiovascular">Cardiovascular</option>
                                    <option value="Corticosteroid">Corticosteroid</option>
                                    <option value="Dermatology">Dermatology</option>
                                    <option value="Endocrine">Endocrine</option>
                                    <option value="Gastrointestinal">Gastrointestinal</option>
                                    <option value="Lipid Lowering">Lipid Lowering</option>
                                    <option value="Ophthalmic">Ophthalmic</option>
                                    <option value="Respiratory">Respiratory</option>
                                    <option value="Supplement">Supplement</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>

                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Unit <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <select
                                    id="editUnit"
                                    class="form-control"
                                    required
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                                    <option value="">Select Unit</option>
                                    <option value="Tablet">Tablet</option>
                                    <option value="Capsule">Capsule</option>
                                    <option value="Syrup">Syrup</option>
                                    <option value="Suspension">Suspension</option>
                                    <option value="Inhaler">Inhaler</option>
                                    <option value="Cream">Cream</option>
                                    <option value="Eye Drops">Eye Drops</option>
                                    <option value="Sachet">Sachet</option>
                                    <option value="Suppository">Suppository</option>
                                    <option value="Vial">Vial</option>
                                    <option value="Solution">Solution</option>
                                    <option value="Bottle">Bottle</option>
                                    <option value="Box">Box</option>
                                    <option value="Strip">Strip</option>
                                    <option value="Piece">Piece</option>
                                </select>
                            </div>

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Minimum Stock <span class="required" style="color: #EF4444;">*</span>
                                </label>
                                <input
                                    type="number"
                                    id="editMinStock"
                                    class="form-control"
                                    min="0"
                                    required
                                    style="border-radius: 8px; font-size: 13.5px; padding: 9px 12px;"
                                    >
                            </div>

                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Supplier
                                </label>
                                <input
                                    type="text"
                                    id="editSupplier"
                                    class="form-control"
                                    placeholder="e.g. HealthPlus Supplies"
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                            </div>

                            <div class="form-group" style="margin-bottom: 0;">
                                <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                    Expiry Date
                                </label>
                                <input
                                    type="date"
                                    id="editExpiryDate"
                                    class="form-control"
                                    style="border-radius: 8px; font-size: 13px; padding: 9px 12px;"
                                    >
                            </div>

                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label style="font-size: 12.5px; font-weight: 600; color: #334155; margin-bottom: 6px;">
                                Description & Notes
                            </label>
                            <textarea
                                id="editDescription"
                                class="form-control"
                                rows="3"
                                placeholder="Enter clinical notes, dosage instructions, or remarks..."
                                style="border-radius: 8px; font-size: 13px; padding: 9px 12px; resize: vertical;"
                                ></textarea>
                        </div>

                    </div>

                    <div class="modal-footer" style="padding: 14px 22px; background: #F8FAFC; border-top: 1px solid #E2E8F0; display: flex; align-items: center; justify-content: flex-end; gap: 10px;">
                        <button
                            type="button"
                            class="btn-secondary"
                            onclick="closeEditMedicineModal()"
                            style="padding: 8px 16px; border-radius: 8px; font-size: 13px;"
                            >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            class="btn-primary"
                            style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 600;"
                            >
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                            <span>Update Medicine</span>
                        </button>
                    </div>

                </form>

            </div>

        </div>

        <jsp:include page="logout.jsp" />

        <script>
            var API_BASE = "<%= request.getContextPath()%>/api/medicines";
            var medicineList = [];
            var editingMedicineId = null;

            function loadMedicines() {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", API_BASE, true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState !== 4)
                        return;
                    var tbody = document.getElementById("medicineTableBody");
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            medicineList = JSON.parse(xhr.responseText);
                            renderMedicineTable(medicineList);
                        } catch (e) {
                            console.error(e);
                            showMedicineError("Invalid medicine API response.");
                        }
                    } else {
                        console.error("Medicine API HTTP status:", xhr.status, xhr.responseText);
                        showMedicineError("Failed to load medicine data. HTTP " + xhr.status + ".");
                    }
                };
                xhr.onerror = function () {
                    showMedicineError("Cannot connect to the Medicine API.");
                };
                xhr.send();
            }

            function showMedicineError(message) {
                document.getElementById("medicineCount").innerText = "Unable to load";
                document.getElementById("medicineTableBody").innerHTML =
                        '<tr><td colspan="9" style="text-align:center;padding:30px;color:#B91C1C;">' +
                        escapeHtml(message) + '</td></tr>';
            }

            function populateUnitFilter(list) {
                var select = document.getElementById("categoryFilter");
                var selected = select.value;
                var seen = {};
                var names = [];

                for (var i = 0; i < list.length; i++) {
                    var c = (list[i].unit || "").trim();
                    if (c && !seen[c.toLowerCase()]) {
                        seen[c.toLowerCase()] = true;
                        names.push(c);
                    }
                }
                names.sort(function (a, b) {
                    return a.toLowerCase() < b.toLowerCase() ? -1 : 1;
                });

                select.innerHTML = "";
                var all = document.createElement("option");
                all.value = "";
                all.text = "All Units";
                select.appendChild(all);

                for (var j = 0; j < names.length; j++) {
                    var opt = document.createElement("option");
                    opt.value = names[j];
                    opt.text = names[j];
                    select.appendChild(opt);
                }

                // keep the current choice after a reload (e.g. after editing a medicine)
                select.value = seen[selected.toLowerCase()] ? selected : "";
            }

            function renderMedicineTable(list) {
                populateUnitFilter(list);
                var tbody = document.getElementById("medicineTableBody");
                document.getElementById("medicineCount").innerText =
                        list.length + (list.length === 1 ? " medicine" : " medicines");

                if (list.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="9" style="text-align:center;padding:30px;color:#64748B;">No medicine found.</td></tr>';
                    return;
                }

                var html = "";
                for (var i = 0; i < list.length; i++) {
                    var m = list[i];
                    var status = m.status || "In Stock";
                    var style = "";
                    var dot = "";
                    var badgeClass = "stockin";

                    if (status === "Critical Low" || status === "Expired") {
                        badgeClass = "";
                        style = "background:#FEF2F2;color:#B91C1C;";
                        dot = "background:#EF4444;";
                    } else if (status === "Low Stock" || status === "Expiring Soon") {
                        badgeClass = "";
                        style = "background:#FFF7ED;color:#C2410C;";
                        dot = "background:#F97316;";
                    }

                    var id = escapeJs(m.medicineId || "");

                    html += '<tr>';
                    html += '<td><strong>' + escapeHtml(m.name || "-") + '</strong></td>';
                    html += '<td>' + escapeHtml(m.batchNo || "-") + '</td>';
                    html += '<td>' + escapeHtml(m.category || "-") + '</td>';
                    html += '<td>' + escapeHtml(m.supplier || "-") + '</td>';
                    html += '<td>' + escapeHtml(m.unit || "-") + '</td>';
                    html += '<td>' + Number(m.currentStock || 0) + '</td>';
                    html += '<td>' + Number(m.minStock || 0) + '</td>';
                    html += '<td><span class="badge ' + badgeClass + '" style="' + style + '">' +
                            '<span class="badge-dot" style="' + dot + '"></span>' +
                            escapeHtml(status) + '</span></td>';
                    html += '<td style="white-space:nowrap;">';
                    html += '<button type="button" class="btn-secondary" onclick="viewMedicineById(\'' + id + '\')">View</button> ';
                    html += '<button type="button" class="btn-secondary" onclick="editMedicineById(\'' + id + '\')">Edit</button> ';
                    html += '<button type="button" class="btn-danger" onclick="deleteMedicine(\'' + id + '\')">Delete</button>';
                    html += '</td></tr>';
                }

                tbody.innerHTML = html;
                filterMedicineTable();
            }

            function getMedicineById(id, callback) {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", API_BASE + "/" + encodeURIComponent(id), true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState !== 4)
                        return;
                    var result = null;
                    try {
                        result = JSON.parse(xhr.responseText);
                    } catch (e) {
                    }
                    if (xhr.status >= 200 && xhr.status < 300) {
                        callback(null, result);
                    } else {
                        callback(new Error((result && result.error) ? result.error : "HTTP " + xhr.status), null);
                    }
                };
                xhr.onerror = function () {
                    callback(new Error("Cannot connect to the Medicine API."), null);
                };
                xhr.send();
            }

            function viewMedicineById(id) {
                getMedicineById(id, function (error, medicine) {
                    if (error) {
                        alert("Failed to load medicine details.\n\n" + error.message);
                        return;
                    }
                    var medId = medicine.medicineId || id || "-";
                    var name = medicine.name || "-";
                    var batch = medicine.batchNo || "-";
                    var category = medicine.category || "-";
                    var unit = medicine.unit || "-";
                    var stock = Number(medicine.currentStock == null ? 0 : medicine.currentStock);
                    var minStock = Number(medicine.minStock == null ? 0 : medicine.minStock);
                    var status = medicine.status || "In Stock";
                    var location = medicine.location || "Main Pharmacy";

                    document.getElementById("viewName").innerText = name;
                    var idBadge = document.getElementById("viewIdBadge");
                    if (idBadge)
                        idBadge.innerText = medId;

                    document.getElementById("viewCategory").innerText = category;
                    document.getElementById("viewBatch").innerText = batch;
                    document.getElementById("viewUnit").innerText = unit;
                    document.getElementById("viewStock").innerText = stock + (unit !== "-" ? " " + unit : "");
                    document.getElementById("viewMinStock").innerText = minStock + (unit !== "-" ? " " + unit : "");

                    document.getElementById("viewExpiryDate").innerText =
                            formatExpiryDate(medicine.expiryDate);

                    var locElem = document.getElementById("viewLocation");
                    if (locElem)
                        locElem.innerText = location;

                    var statusElem = document.getElementById("viewStatus");
                    if (statusElem) {
                        statusElem.className = "med-detail-status";
                        var dotClass = "dot-green";
                        if (status === "Critical Low" || status === "Expired") {
                            statusElem.className += " status-critical";
                            dotClass = "dot-red";
                        } else if (status === "Low Stock" || status === "Expiring Soon") {
                            statusElem.className += " status-warning";
                            dotClass = "dot-amber";
                        } else {
                            statusElem.className += " status-success";
                            dotClass = "dot-green";
                        }
                        statusElem.innerHTML = '<span class="status-dot-pulse ' + dotClass + '"></span>' + escapeHtml(status);
                    }

                    var progressBar = document.getElementById("viewStockProgress");
                    var progressLabel = document.getElementById("viewStockProgressLabel");
                    if (progressBar && progressLabel) {
                        var percent = minStock > 0 ? Math.min(100, Math.round((stock / (minStock * 1.5)) * 100)) : 100;
                        progressBar.style.width = Math.max(6, percent) + "%";
                        if (stock <= minStock * 0.3) {
                            progressBar.style.backgroundColor = "#EF4444";
                            progressLabel.innerHTML = '<span style="color:#DC2626;font-weight:600;">Critical Deficit</span> (' + stock + ' / ' + minStock + ' min)';
                        } else if (stock <= minStock) {
                            progressBar.style.backgroundColor = "#F59E0B";
                            progressLabel.innerHTML = '<span style="color:#D97706;font-weight:600;">Below Minimum</span> (' + stock + ' / ' + minStock + ' min)';
                        } else {
                            progressBar.style.backgroundColor = "#10B981";
                            progressLabel.innerHTML = '<span style="color:#059669;font-weight:600;">Optimal Stock</span> (' + stock + ' / ' + minStock + ' min)';
                        }
                    }

                    var restockBtn = document.getElementById("viewModalRestockBtn");
                    if (restockBtn) {
                        restockBtn.href = "<%= request.getContextPath()%>/stockin?medicineId=" + encodeURIComponent(medId);
                    }

                    document.getElementById("viewMedicineModal").style.display = "flex";
                });
            }

            function formatExpiryDate(value) {
                if (!value || String(value).trim() === "") {
                    return "No expiry date recorded";
                }

                var raw = String(value).trim();

                var parts = raw.split("-");
                if (parts.length === 3 &&
                        parts[0].length === 4 &&
                        parts[1].length === 2 &&
                        parts[2].length === 2) {

                    return parts[2] + "/" + parts[1] + "/" + parts[0];
                }

                return raw;
            }

            function closeViewMedicineModal() {
                document.getElementById("viewMedicineModal").style.display = "none";
            }

            function openAddMedicineModal() {
                document.getElementById("addMedicineModal").style.display = "flex";
            }

            function closeAddMedicineModal() {
                document.getElementById("addMedicineModal").style.display = "none";
                document.getElementById("addMedicineName").value = "";
                document.getElementById("addBatchNo").value = "";
                document.getElementById("addCategory").value = "";
                document.getElementById("addUnit").value = "";
                document.getElementById("addMinStock").value = "";
                var sup = document.getElementById("addSupplier");
                if (sup)
                    sup.value = "";
                var exp = document.getElementById("addExpiryDate");
                if (exp)
                    exp.value = "";
                document.getElementById("addDescription").value = "";
            }

            function saveMedicine(event) {
                event.preventDefault();

                var sup = document.getElementById("addSupplier");
                var exp = document.getElementById("addExpiryDate");

                var medicine = {
                    name: document.getElementById("addMedicineName").value.trim(),
                    batchNo: document.getElementById("addBatchNo").value.trim(),
                    category: document.getElementById("addCategory").value,
                    unit: document.getElementById("addUnit").value,
                    currentStock: 0,
                    minStock: Number(document.getElementById("addMinStock").value),
                    supplier: sup ? sup.value.trim() : "",
                    expiryDate: exp ? exp.value.trim() : "",
                    description: document.getElementById("addDescription").value.trim(),
                    unitPrice: 0,
                    location: "Main Pharmacy"
                };

                sendMedicineRequest("POST", API_BASE, medicine, function (error, result) {
                    if (error) {
                        alert("Failed to add medicine.\n\n" + error.message);
                        return;
                    }
                    alert("Medicine added successfully.\n\nMedicine ID: " + (result.medicineId || ""));
                    closeAddMedicineModal();
                    loadMedicines();
                });
            }

            function setSelectValueWithFallback(selectElem, value) {
                if (!selectElem)
                    return;
                var val = (value || "").trim();
                if (!val) {
                    selectElem.selectedIndex = 0;
                    return;
                }
                selectElem.value = val;
                if (selectElem.selectedIndex === -1) {
                    var opt = document.createElement("option");
                    opt.value = val;
                    opt.textContent = val;
                    opt.selected = true;
                    selectElem.appendChild(opt);
                }
            }

            function editMedicineById(id) {
                getMedicineById(id, function (error, medicine) {
                    if (error) {
                        alert("Failed to load medicine for editing.\n\n" + error.message);
                        return;
                    }
                    editingMedicineId = medicine.medicineId || id;

                    var medIdBadge = document.getElementById("editMedicineIdBadge");
                    if (medIdBadge)
                        medIdBadge.innerText = editingMedicineId || "-";

                    var stockBadge = document.getElementById("editCurrentStockBadge");
                    if (stockBadge)
                        stockBadge.innerText = (medicine.currentStock == null ? 0 : medicine.currentStock) + " " + (medicine.unit || "units");

                    document.getElementById("editMedicineName").value = medicine.name || "";
                    document.getElementById("editBatchNo").value = medicine.batchNo || "";

                    setSelectValueWithFallback(document.getElementById("editCategory"), medicine.category);
                    setSelectValueWithFallback(document.getElementById("editUnit"), medicine.unit);

                    document.getElementById("editMinStock").value = medicine.minStock == null ? 0 : medicine.minStock;
                    var editSup = document.getElementById("editSupplier");
                    if (editSup)
                        editSup.value = medicine.supplier || "";
                    var editExp = document.getElementById("editExpiryDate");
                    if (editExp)
                        editExp.value = medicine.expiryDate || "";
                    document.getElementById("editDescription").value = medicine.description || "";
                    document.getElementById("editMedicineModal").style.display = "flex";
                });
            }

            function closeEditMedicineModal() {
                document.getElementById("editMedicineModal").style.display = "none";
                editingMedicineId = null;
            }

            function updateMedicine(event) {
                event.preventDefault();
                if (!editingMedicineId) {
                    alert("No medicine selected.");
                    return;
                }

                var existing = null;
                for (var i = 0; i < medicineList.length; i++) {
                    if (String(medicineList[i].medicineId) === String(editingMedicineId)) {
                        existing = medicineList[i];
                        break;
                    }
                }

                var editSup = document.getElementById("editSupplier");
                var editExp = document.getElementById("editExpiryDate");

                var medicine = {
                    name: document.getElementById("editMedicineName").value.trim(),
                    batchNo: document.getElementById("editBatchNo").value.trim(),
                    category: document.getElementById("editCategory").value,
                    unit: document.getElementById("editUnit").value,
                    currentStock: existing ? Number(existing.currentStock || 0) : 0,
                    minStock: Number(document.getElementById("editMinStock").value),
                    supplier: editSup ? editSup.value.trim() : (existing ? (existing.supplier || "") : ""),
                    expiryDate: editExp ? editExp.value.trim() : (existing ? (existing.expiryDate || "") : ""),
                    description: document.getElementById("editDescription").value.trim(),
                    unitPrice: existing ? Number(existing.unitPrice || 0) : 0,
                    location: existing ? (existing.location || "Main Pharmacy") : "Main Pharmacy"
                };

                sendMedicineRequest("PUT", API_BASE + "/" + encodeURIComponent(editingMedicineId), medicine, function (error) {
                    if (error) {
                        alert("Failed to update medicine.\n\n" + error.message);
                        return;
                    }
                    alert("Medicine updated successfully.");
                    closeEditMedicineModal();
                    loadMedicines();
                });
            }

            function deleteMedicine(id) {
                var medicine = null;
                for (var i = 0; i < medicineList.length; i++) {
                    if (String(medicineList[i].medicineId) === String(id)) {
                        medicine = medicineList[i];
                        break;
                    }
                }
                var name = medicine ? medicine.name : id;
                if (!confirm("Are you sure you want to delete this medicine?\n\n" + name))
                    return;

                sendMedicineRequest("DELETE", API_BASE + "/" + encodeURIComponent(id), null, function (error) {
                    if (error) {
                        alert("Failed to delete medicine.\n\n" + error.message);
                        return;
                    }
                    alert("Medicine deleted successfully.");
                    loadMedicines();
                });
            }

            function sendMedicineRequest(method, url, data, callback) {
                var xhr = new XMLHttpRequest();
                xhr.open(method, url, true);
                xhr.setRequestHeader("Content-Type", "application/json");
                xhr.onreadystatechange = function () {
                    if (xhr.readyState !== 4)
                        return;
                    var result = null;
                    try {
                        result = xhr.responseText ? JSON.parse(xhr.responseText) : {};
                    } catch (e) {
                        result = {};
                    }
                    if (xhr.status >= 200 && xhr.status < 300) {
                        callback(null, result);
                    } else {
                        callback(new Error(result.error || ("HTTP " + xhr.status)), null);
                    }
                };
                xhr.onerror = function () {
                    callback(new Error("Cannot connect to the Medicine API."), null);
                };
                xhr.send(data == null ? null : JSON.stringify(data));
            }

            function filterMedicineTable() {
                var search = document.getElementById("medicineSearch").value.toLowerCase().trim();
                var unit = document.getElementById("categoryFilter").value.toLowerCase().trim();
                var rows = document.getElementById("medicineTableBody").getElementsByTagName("tr");

                for (var i = 0; i < rows.length; i++) {
                    var cells = rows[i].getElementsByTagName("td");
                    if (cells.length < 9)
                        continue;
                    var rowText = rows[i].innerText.toLowerCase();
                    var unitText = cells[4].innerText.toLowerCase().trim();   // Unit column
                    rows[i].style.display = rowText.indexOf(search) > -1 &&
                            (unit === "" || unitText === unit) ? "" : "none";
                }
            }

            function escapeHtml(value) {
                return String(value)
                        .replace(/&/g, "&amp;")
                        .replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;")
                        .replace(/\"/g, "&quot;")
                        .replace(/'/g, "&#039;");
            }

            function escapeJs(value) {
                return String(value).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
            }

            window.onclick = function (event) {
                var ids = ["addMedicineModal", "viewMedicineModal", "editMedicineModal"];
                for (var i = 0; i < ids.length; i++) {
                    var modal = document.getElementById(ids[i]);
                    if (event.target === modal)
                        modal.style.display = "none";
                }
            };

            document.addEventListener("DOMContentLoaded", function () {
                loadMedicines();
            });
        </script>

    </body>

</html>