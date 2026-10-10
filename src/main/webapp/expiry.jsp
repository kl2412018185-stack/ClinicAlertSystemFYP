<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.clinicalert.model.StockTransaction" %>
<%@ page import="com.clinicalert.model.User" %>
<%
    User user = (User) session.getAttribute("currentUser");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String staffName = user.getName();
    String userRole = user.getRole();

    if (staffName == null || staffName.trim().isEmpty()) {
        staffName = "User";
    }

    if (userRole == null || userRole.trim().isEmpty()) {
        userRole = "Staff";
    }

    boolean isAdmin = user.isAdministrative();
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Expiry Alert - Clinic Alert System</title>
        <link rel="stylesheet" href="css/style.css">
        <script>
            function switchExpiryTab(days) {
                var baseUrl = "<%= request.getContextPath()%>/expiry";

                if (days === "all") {
                    window.location.href = baseUrl;
                } else {
                    window.location.href = baseUrl + "?filter=" + days;
                }
            }
        </script>
    </head>
    <body>

        <div class="app-container">
            <aside class="sidebar">
                <div class="sidebar-brand">
                    <div class="brand-icon-wrapper">
                        <svg width="26" height="26" viewBox="0 0 64 64" fill="none">
                        <rect x="18" y="20" width="28" height="36" rx="6" fill="#0A2540" />
                        <rect x="23" y="14" width="18" height="6" rx="2" fill="#0066FF" />
                        <rect x="29" y="32" width="6" height="14" rx="1.5" fill="#10B981" />
                        <rect x="25" y="36" width="14" height="6" rx="1.5" fill="#10B981" />
                        <rect x="36" y="24" width="18" height="26" rx="3" fill="#FFFFFF" stroke="#0A2540" stroke-width="2" />
                        <line x1="40" y1="31" x2="50" y2="31" stroke="#0066FF" stroke-width="2" stroke-linecap="round" />
                        <line x1="40" y1="36" x2="48" y2="36" stroke="#0066FF" stroke-width="2" stroke-linecap="round" />
                        <circle cx="16" cy="18" r="7" fill="#10B981" />
                        <path d="M13 18C13 14 19 14 19 18C19 22 13 22 13 18Z" fill="#FFFFFF" />
                        </svg>
                    </div>
                    <div class="brand-titles">
                        <h1>Clinic<span class="highlight"> Alert</span></h1>
                        <p>Smart Medicine Management System</p>
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

                            <rect x="3" y="3"
                                  width="7"
                                  height="7"></rect>

                            <rect x="14" y="3"
                                  width="7"
                                  height="7"></rect>

                            <rect x="14" y="14"
                                  width="7"
                                  height="7"></rect>

                            <rect x="3" y="14"
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

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

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
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

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
                       class="nav-link active">

                        <div class="nav-link-content">

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

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
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

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
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

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

                        <svg
                            viewBox="0 0 24 24"
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
                        <h2>Expiry Alert</h2>
                    </div>
                    <div class="user-profile-badge">
                        <div class="user-avatar-circle">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                        </div>
                        <span>
                            <%= staffName%>
                            (<%= userRole%>)
                        </span>
                    </div>
                </header>

                <div class="content-container">
                    <div class="panel-card">
                        <%
                            String expMsg = request.getParameter("msg");
                            if ("disposed".equals(expMsg)) {
                        %>
                        <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#ECFDF5;color:#047857;border:1px solid #A7F3D0;">
                            Expired stock disposed. A Stock Out record was added to the history.
                        </div>
                        <%
                        } else if ("notfound".equals(expMsg)) {
                        %>
                        <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#FFF8E1;color:#92400E;border:1px solid #F2C94C;">
                            That batch is no longer expired or has no stock left.
                        </div>
                        <%
                        } else if ("error".equals(expMsg) || "stockerror".equals(expMsg)) {
                        %>
                        <div style="margin-bottom:16px;padding:12px 14px;border-radius:8px;background:#FEF2F2;color:#B91C1C;border:1px solid #FECACA;">
                            <%= "stockerror".equals(expMsg)
                                    ? "The disposal was recorded, but the medicine stock could not be updated. Please check the Medicine page."
                                    : "Unable to dispose of this batch."%>
                        </div>
                        <%
                            }
                        %>
                        <div class="tabs-container">
                            <button
                                type="button"
                                class="tab-btn <%= "30".equals(request.getAttribute("activeFilter")) ? "active" : ""%>"
                                onclick="switchExpiryTab('30')">
                                Near Expiry (30 Days)
                            </button>

                            <button
                                type="button"
                                class="tab-btn <%= "60".equals(request.getAttribute("activeFilter")) ? "active" : ""%>"
                                onclick="switchExpiryTab('60')">
                                Near Expiry (60 Days)
                            </button>

                            <button
                                type="button"
                                class="tab-btn <%= "90".equals(request.getAttribute("activeFilter")) ? "active" : ""%>"
                                onclick="switchExpiryTab('90')">
                                Near Expiry (90 Days)
                            </button>

                            <button
                                type="button"
                                class="tab-btn <%= "expired".equals(request.getAttribute("activeFilter")) ? "active" : ""%>"
                                onclick="switchExpiryTab('expired')">
                                Expired
                            </button>
                        </div>

                        <div class="table-responsive">
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th style="width: 50px;">No.</th>
                                        <th>Medicine Name</th>
                                        <th>Batch No.</th>
                                        <th>Expiry Date</th>
                                        <th>Days Left</th>
                                        <th>Qty</th>
                                        <th style="text-align: center; width: 160px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>

                                    <%
                                        List<StockTransaction> expiryList
                                                = (List<StockTransaction>) request.getAttribute("expiryList");

                                        if (expiryList != null && !expiryList.isEmpty()) {

                                            int rowNo = 1;

                                            for (StockTransaction batch : expiryList) {

                                                java.time.LocalDate parsedExpiry
                                                        = java.time.LocalDate.parse(batch.getExpiryDate());

                                                long daysLeft
                                                        = java.time.temporal.ChronoUnit.DAYS.between(
                                                                java.time.LocalDate.now(),
                                                                parsedExpiry
                                                        );

                                                String daysColor;

                                                if (daysLeft <= 0) {
                                                    daysColor = "#EF4444";
                                                } else if (daysLeft <= 30) {
                                                    daysColor = "#EF4444";
                                                } else {
                                                    daysColor = "#D97706";
                                                }

                                                String expiryDate
                                                        = parsedExpiry.format(
                                                                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")
                                                        );

                                                String daysText
                                                        = daysLeft <= 0
                                                                ? "Expired"
                                                                : String.valueOf(daysLeft);
                                    %>
                                    <tr>

                                        <td>
                                            <%= rowNo++%>
                                        </td>

                                        <td>
                                            <strong>
                                                <%= batch.getMedicineName() == null
                                                        ? "-"
                                                        : batch.getMedicineName()%>
                                            </strong>
                                        </td>

                                        <td>
                                            <%= batch.getBatchNo() == null || batch.getBatchNo().trim().isEmpty()
                                                    ? "-"
                                                    : batch.getBatchNo()%>
                                        </td>

                                        <td>
                                            <%= expiryDate%>
                                        </td>

                                        <td
                                            style="color: <%= daysColor%>; font-weight: 700;"
                                            >
                                            <%= daysText%>
                                        </td>

                                        <td>
                                            <%= batch.getQuantity()%>
                                        </td>

                                        <td style="text-align: center;">

                                            <a
                                                href="<%= request.getContextPath()%>/stockout"
                                                class="view-all-link"
                                                >
                                                View
                                            </a>

                                            <%
                                                if (isAdmin && daysLeft <= 0) {
                                                    String dItem = batch.getMedicineId() == null ? "" : batch.getMedicineId().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;");
                                                    String dBatch = batch.getBatchNo() == null ? "" : batch.getBatchNo().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;");
                                            %>
                                            <form action="<%= request.getContextPath()%>/expiry" method="POST" style="display:inline;margin:0 0 0 10px;"
                                                  onsubmit="return confirm('Dispose of <%= batch.getQuantity()%> <%= batch.getUnit() == null ? "" : batch.getUnit().replace("'", "")%> of this expired batch?\nA Stock Out record (Expired - Disposed) will be added and the medicine stock reduced. This cannot be undone.');">
                                                <input type="hidden" name="action" value="dispose">
                                                <input type="hidden" name="itemId" value="<%= dItem%>">
                                                <input type="hidden" name="batchNo" value="<%= dBatch%>">
                                                <button type="submit"
                                                        style="padding:5px 12px;border:1px solid #FECACA;border-radius:8px;background:#FEF2F2;color:#B91C1C;font-weight:600;font-size:13px;cursor:pointer;">
                                                    Dispose
                                                </button>
                                            </form>
                                            <%
                                                }
                                            %>

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
                                                    No expiry records found
                                                </h4>

                                                <p>
                                                    There are no batches matching the selected expiry filter.
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
