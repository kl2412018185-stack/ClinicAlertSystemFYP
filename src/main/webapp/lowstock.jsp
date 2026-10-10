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
            Low Stock Alert - Clinic Alert System
        </title>

        <link rel="stylesheet"
              href="css/style.css">

        <style>

            .low-stock-count {
                display: inline-flex;
                align-items: center;
                justify-content: center;

                min-width: 24px;
                height: 24px;

                padding: 0 7px;

                margin-left: 8px;

                border-radius: 20px;

                background: #FEF2F2;
                color: #EF4444;

                font-size: 11px;
                font-weight: 700;
            }

            .stock-val-warning {
                color: #D97706 !important;
                font-weight: 700;
                font-size: 13.5px;
            }

            .stock-val-critical {
                color: #DC2626 !important;
                font-weight: 700;
                font-size: 13.5px;
            }

            .stock-val-out {
                color: #991B1B !important;
                font-weight: 700;
                font-size: 13.5px;
            }

            .stock-badge {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 3px 10px;
                border-radius: 9999px;
                font-size: 11.5px;
                font-weight: 600;
                white-space: nowrap;
            }

            .stock-badge-warning {
                background-color: #FEF3C7;
                color: #B45309;
                border: 1px solid #FDE68A;
            }

            .stock-badge-critical {
                background-color: #FEE2E2;
                color: #B91C1C;
                border: 1px solid #FECACA;
            }

            .stock-badge-out {
                background-color: #450A0A;
                color: #FEE2E2;
                border: 1px solid #7F1D1D;
            }

            .stock-dot {
                width: 6px;
                height: 6px;
                border-radius: 50%;
                display: inline-block;
            }

            .dot-warning {
                background-color: #D97706;
            }

            .dot-critical {
                background-color: #DC2626;
            }

            .dot-out {
                background-color: #EF4444;
            }

            .btn-restock-action {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 5px;
                padding: 6px 12px;
                background: #2563EB;
                color: #ffffff !important;
                border-radius: 6px;
                font-size: 12px;
                font-weight: 600;
                text-decoration: none !important;
                transition: all 0.15s ease-in-out;
                box-shadow: 0 1px 2px rgba(37, 99, 235, 0.2);
            }

            .btn-restock-action:hover {
                background: #1D4ED8;
                transform: translateY(-1px);
                box-shadow: 0 3px 6px rgba(37, 99, 235, 0.3);
            }

            .btn-restock-action:active {
                transform: translateY(0);
            }

            .view-all-link {
                color: #0066FF;
                text-decoration: none;
                font-weight: 600;
                font-size: 13px;
            }

            .view-all-link:hover {
                text-decoration: underline;
            }

            .empty-state {
                text-align: center;
                padding: 50px 20px;
                color: #64748B;
            }

            .empty-state svg {
                width: 45px;
                height: 45px;
                margin-bottom: 12px;
                color: #10B981;
            }

            .empty-state h4 {
                margin: 0 0 5px;
                color: #0F172A;
                font-size: 15px;
            }

            .empty-state p {
                margin: 0;
                font-size: 13px;
            }

            @media (max-width: 900px) {

                .table-responsive {
                    overflow-x: auto;
                }

                .custom-table {
                    min-width: 750px;
                }

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

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <rect
                                x="3"
                                y="3"
                                width="7"
                                height="7"></rect>

                            <rect
                                x="14"
                                y="3"
                                width="7"
                                height="7"></rect>

                            <rect
                                x="14"
                                y="14"
                                width="7"
                                height="7"></rect>

                            <rect
                                x="3"
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
                       class="nav-link">

                        <div class="nav-link-content">

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"></path>

                            <path
                                d="m8.5 8.5 7 7"></path>

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

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M12 3v12"></path>

                            <path
                                d="m8 11 4 4 4-4"></path>

                            <path
                                d="M8 5H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-4"></path>

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
                       class="nav-link active">

                        <div class="nav-link-content">

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path>

                            <line
                                x1="12"
                                y1="9"
                                x2="12"
                                y2="13"></line>

                            <line
                                x1="12"
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

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <circle
                                cx="12"
                                cy="12"
                                r="10"></circle>

                            <polyline
                                points="12 6 12 12 16 14"></polyline>

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

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>

                            <polyline
                                points="14 2 14 8 20 8"></polyline>

                            <line
                                x1="16"
                                y1="13"
                                x2="8"
                                y2="13"></line>

                            <line
                                x1="16"
                                y1="17"
                                x2="8"
                                y2="17"></line>

                            <polyline
                                points="10 9 9 9 8 9"></polyline>

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

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>

                            <circle
                                cx="12"
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

                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

                            <path
                                d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>

                            <circle
                                cx="9"
                                cy="7"
                                r="4"></circle>

                            <path
                                d="M22 21v-2a4 4 0 0 0-3-3.87"></path>

                            <path
                                d="M16 3.13a4 4 0 0 1 0 7.75"></path>

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
                            Low Stock Alert
                        </h2>

                    </div>

                    <div class="user-profile-badge">

                        <div class="user-avatar-circle">

                            <svg
                                width="14"
                                height="14"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2">

                            <path
                                d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>

                            <circle
                                cx="12"
                                cy="7"
                                r="4"></circle>

                            </svg>

                        </div>

                        <span>
                            <%= staffName%>
                            (<%= userRole%>)
                        </span>

                    </div>

                </header>

                <div class="content-container">

                    <div class="panel-card">

                        <div class="panel-header">

                            <h3 style="display: flex; align-items: center; gap: 4px;">
                                Low Stock Alert
                                <%
                                    java.util.List<?> lowStockCountList
                                            = (java.util.List<?>) request.getAttribute("lowStockMedicines");

                                    int lowStockCount
                                            = lowStockCountList == null ? 0 : lowStockCountList.size();
                                %>
                                <span class="low-stock-count">
                                    <%= lowStockCount%>
                                </span>
                            </h3>

                            <a href="<%= request.getContextPath()%>/stockin"
                               class="view-all-link"
                               style="display: flex; align-items: center; gap: 4px;">
                                <span>Go to Stock In &rsaquo;</span>
                            </a>

                        </div>

                        <div class="table-responsive">

                            <table class="custom-table">

                                <thead>

                                    <tr>

                                        <th style="width: 50px; text-align: center;">
                                            No.
                                        </th>

                                        <th>
                                            Medicine Name
                                        </th>

                                        <th style="text-align: center;">
                                            Current Stock
                                        </th>

                                        <th style="text-align: center;">
                                            Min. Stock
                                        </th>

                                        <th style="text-align: center;">
                                            Unit
                                        </th>

                                        <th style="text-align: center;">
                                            Status
                                        </th>

                                        <th style="text-align: center; width: 110px;">
                                            Action
                                        </th>

                                    </tr>

                                </thead>

                                <tbody>

                                    <%
                                        java.util.List<com.clinicalert.model.Medicine> lowStockMedicines
                                                = (java.util.List<com.clinicalert.model.Medicine>) request.getAttribute("lowStockMedicines");

                                        if (lowStockMedicines != null && !lowStockMedicines.isEmpty()) {

                                            int rowNo = 1;

                                            for (com.clinicalert.model.Medicine medicine : lowStockMedicines) {

                                                int currentStock = medicine.getCurrentStock();
                                                int minStock = medicine.getMinStock();
                                                int shortage = Math.max(0, minStock - currentStock);
                                                boolean isOutOfStock = currentStock == 0;
                                                boolean isCritical = currentStock <= (minStock * 0.3) || isOutOfStock;

                                                String stockValClass = isOutOfStock
                                                        ? "stock-val-out"
                                                        : (isCritical ? "stock-val-critical" : "stock-val-warning");
                                    %>
                                    <tr>

                                        <td style="text-align: center; color: var(--text-muted); font-weight: 500;">
                                            <%= rowNo++%>
                                        </td>

                                        <td>
                                            <div style="display: flex; flex-direction: column;">
                                                <strong style="color: var(--text-dark); font-size: 13.5px;">
                                                    <%= medicine.getName() == null ? "-" : medicine.getName()%>
                                                </strong>
                                                <span style="font-size: 11.5px; color: var(--text-muted); margin-top: 2px;">
                                                    <%= medicine.getMedicineId() != null ? medicine.getMedicineId() : ""%>
                                                    <%= (medicine.getCategory() != null && !medicine.getCategory().isEmpty()) ? " &bull; " + medicine.getCategory() : ""%>
                                                </span>
                                            </div>
                                        </td>

                                        <td style="text-align: center;">
                                            <span class="<%= stockValClass%>">
                                                <%= currentStock%>
                                            </span>
                                        </td>

                                        <td style="text-align: center; color: #64748B; font-weight: 500;">
                                            <%= minStock%>
                                        </td>

                                        <td style="text-align: center; color: #64748B;">
                                            <%= medicine.getUnit() == null || medicine.getUnit().isEmpty()
                                                    ? "-"
                                                    : medicine.getUnit()%>
                                        </td>

                                        <td style="text-align: center;">
                                            <% if (isOutOfStock) { %>
                                                <span class="stock-badge stock-badge-out">
                                                    <span class="stock-dot dot-out"></span> Out of Stock
                                                </span>
                                            <% } else if (isCritical) { %>
                                                <span class="stock-badge stock-badge-critical">
                                                    <span class="stock-dot dot-critical"></span> Critical (-<%= shortage%>)
                                                </span>
                                            <% } else { %>
                                                <span class="stock-badge stock-badge-warning">
                                                    <span class="stock-dot dot-warning"></span> Low (-<%= shortage%>)
                                                </span>
                                            <% } %>
                                        </td>

                                        <td style="text-align: center;">

                                            <a
                                                href="<%= request.getContextPath()%>/stockin?medicineId=<%= medicine.getMedicineId() != null ? medicine.getMedicineId() : ""%>"
                                                class="btn-restock-action"
                                                title="Restock <%= medicine.getName() == null ? "" : medicine.getName()%>"
                                                >
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
                                                    <line x1="12" y1="5" x2="12" y2="19"></line>
                                                    <line x1="5" y1="12" x2="19" y2="12"></line>
                                                </svg>
                                                <span>Restock</span>
                                            </a>

                                        </td>

                                    </tr>
                                    <%
                                        }

                                    } else {
                                    %>
                                    <tr>

                                        <td colspan="7">

                                            <div class="empty-state">

                                                <svg
                                                    viewBox="0 0 24 24"
                                                    fill="none"
                                                    stroke="currentColor"
                                                    stroke-width="2"
                                                    >
                                                <path d="M20 6 9 17l-5-5"></path>
                                                </svg>

                                                <h4>
                                                    All stock levels are healthy
                                                </h4>

                                                <p>
                                                    No medicines are currently below the minimum stock level.
                                                </p>

                                            </div>

                                        </td>

                                    </tr>
                                    <%
                                        }
                                    %>

                                </tbody>

                            </table>

                        </div>

                    </div>

                </div>

            </main>

        </div>

        <jsp:include page="logout.jsp" />

    </body>

</html>