<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.lang.reflect.Method" %>

<%!
    private Object readProperty(Object obj, String... getters) {
        if (obj == null) {
            return null;
        }

        for (String getter : getters) {
            try {
                Method m = obj.getClass().getMethod(getter);
                return m.invoke(obj);
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private String text(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private int number(Object value) {
        if (value == null) {
            return 0;
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (Exception e) {
            try {
                return (int) Double.parseDouble(String.valueOf(value));
            } catch (Exception ignored) {
                return 0;
            }
        }
    }

    private Date toDate(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Date) {
            return (Date) value;
        }

        String s = String.valueOf(value);
        String[] patterns = {
            "yyyy-MM-dd",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss",
            "dd/MM/yyyy"
        };

        for (String pattern : patterns) {
            try {
                return new SimpleDateFormat(pattern).parse(s);
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private String formatDate(Object value) {
        Date d = toDate(value);
        if (d == null) {
            return text(value);
        }
        return new SimpleDateFormat("dd/MM/yyyy").format(d);
    }

    private boolean dateInRange(Object value, Date from, Date to) {
        Date d = toDate(value);
        if (d == null) {
            return false;
        }

        return !d.before(from) && !d.after(to);
    }

    private Date parseInputDate(String value, Date fallback) {
        try {
            return new SimpleDateFormat("yyyy-MM-dd").parse(value);
        } catch (Exception e) {
            return fallback;
        }
    }
%>

<%
    String ctx = request.getContextPath();

    String reportType = request.getParameter("reportType");
    if (reportType == null || reportType.trim().isEmpty()) {
        reportType = "Stock In Report";
    }

    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");

    // Default range: the last 90 days up to today, so new entries show up
    if (dateFrom == null || dateFrom.trim().isEmpty()) {
        dateFrom = java.time.LocalDate.now().minusDays(90).toString();
    }
    if (dateTo == null || dateTo.trim().isEmpty()) {
        dateTo = java.time.LocalDate.now().toString();
    }

    Date fromDate = parseInputDate(dateFrom, new Date(0));
    Date toDate = parseInputDate(dateTo, new Date());

    List<?> transactions = (List<?>) request.getAttribute("transactions");
    List<?> medicines = (List<?>) request.getAttribute("medicines");
    List<?> lowStock = (List<?>) request.getAttribute("lowStock");
    List<?> expiring = (List<?>) request.getAttribute("expiring");

    if (transactions == null) {
        transactions = Collections.emptyList();
    }
    if (medicines == null) {
        medicines = Collections.emptyList();
    }
    if (lowStock == null) {
        lowStock = Collections.emptyList();
    }
    if (expiring == null) {
        expiring = Collections.emptyList();
    }

    com.clinicalert.model.User currentUser =
            (com.clinicalert.model.User) session.getAttribute("currentUser");

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

    int totalTransactions = 0;
    int totalQuantity = 0;

    List<Object[]> rows = new ArrayList<>();

    if ("Stock In Report".equals(reportType) || "Stock Out Report".equals(reportType)) {

        for (Object tx : transactions) {

            Object typeObj = readProperty(tx,
                    "getTransactionType",
                    "getType",
                    "getTransactionTypeCode");

            String type = text(typeObj).toUpperCase();

            boolean isIn = "IN".equals(type) || type.contains("STOCK IN");
            boolean isOut = "OUT".equals(type) || type.contains("STOCK OUT");

            if ("Stock In Report".equals(reportType) && !isIn) {
                continue;
            }
            if ("Stock Out Report".equals(reportType) && !isOut) {
                continue;
            }

            Object dateObj = readProperty(tx,
                    "getTransactionDate",
                    "getDate",
                    "getRecordedDate",
                    "getStockInDate",
                    "getStockOutDate");

            if (!dateInRange(dateObj, fromDate, toDate)) {
                continue;
            }

            Object medicineName = readProperty(tx,
                    "getMedicineName",
                    "getMedicine",
                    "getName");

            Object batchNo = readProperty(tx,
                    "getBatchNo",
                    "getBatchNumber");

            Object quantity = readProperty(tx,
                    "getQuantity",
                    "getQuantityReceived",
                    "getQuantityOut",
                    "getQuantityIssued");

            Object supplier = readProperty(tx,
                    "getSupplierOrRecipient",
                    "getSupplier");

            Object recordedBy = readProperty(tx,
                    "getRecordedBy",
                    "getReceivedBy",
                    "getIssuedBy",
                    "getStaffName",
                    "getUserId");

            Object reason = readProperty(tx,
                    "getReason",
                    "getRemarks");

            int qty = number(quantity);

            String fifthColumn;
            String sixthColumn;

            if ("Stock In Report".equals(reportType)) {
                fifthColumn = text(supplier);
                sixthColumn = text(recordedBy);
            } else {
                fifthColumn = text(reason);
                sixthColumn = text(recordedBy);
            }

            rows.add(new Object[]{
                dateObj,
                medicineName,
                batchNo,
                qty,
                fifthColumn,
                sixthColumn
            });

            totalTransactions++;
            totalQuantity += qty;
        }

    } else if ("Stock Balance Report".equals(reportType)) {

        for (Object med : medicines) {
            Object medicineName = readProperty(med,
                    "getMedicineName",
                    "getName");

            Object itemId = readProperty(med,
                    "getItemId",
                    "getItemID");

            Object currentStock = readProperty(med,
                    "getCurrentStock",
                    "getStock");

            Object minimumStock = readProperty(med,
                    "getMinStock",
                    "getMinimumStock");

            Object unit = readProperty(med, "getUnit");
            Object status = readProperty(med, "getStatus");

            int stock = number(currentStock);

            rows.add(new Object[]{
                null,
                medicineName,
                itemId,
                stock,
                "Min: " + number(minimumStock) + " " + text(unit),
                text(status)
            });

            totalTransactions++;
            totalQuantity += stock;
        }

    } else if ("Low Stock Report".equals(reportType)) {

        for (Object med : lowStock) {
            Object medicineName = readProperty(med,
                    "getMedicineName",
                    "getName");

            Object itemId = readProperty(med,
                    "getItemId",
                    "getItemID");

            Object currentStock = readProperty(med,
                    "getCurrentStock",
                    "getStock");

            Object minimumStock = readProperty(med,
                    "getMinStock",
                    "getMinimumStock");

            Object unit = readProperty(med, "getUnit");

            int stock = number(currentStock);

            rows.add(new Object[]{
                null,
                medicineName,
                itemId,
                stock,
                "Min: " + number(minimumStock),
                text(unit)
            });

            totalTransactions++;
            totalQuantity += stock;
        }

    } else if ("Expiry Report".equals(reportType)) {

        for (Object med : expiring) {

            Object expiry = readProperty(med,
                    "getExpiryDate");

            Object daysLeft = readProperty(med,
                    "getDaysLeft");

            Object medicineName = readProperty(med,
                    "getMedicineName",
                    "getName");

            Object batchNo = readProperty(med,
                    "getBatchNo",
                    "getBatchNumber");

            Object currentStock = readProperty(med,
                    "getCurrentStock",
                    "getStock");

            Object status = readProperty(med, "getStatus");

            rows.add(new Object[]{
                expiry,
                medicineName,
                batchNo,
                number(currentStock),
                text(daysLeft) + " days",
                text(status)
            });

            totalTransactions++;
            totalQuantity += number(currentStock);
        }

    } else if ("Top 10 Medicines Report".equals(reportType)) {

        Map<String, Integer> usage = new HashMap<>();
        Map<String, String> names = new HashMap<>();

        for (Object tx : transactions) {

            Object typeObj = readProperty(tx,
                    "getTransactionType",
                    "getType",
                    "getTransactionTypeCode");

            String type = text(typeObj).toUpperCase();

            boolean isOut = "OUT".equals(type) || type.contains("STOCK OUT");
            if (!isOut) {
                continue;
            }

            Object dateObj = readProperty(tx,
                    "getTransactionDate",
                    "getDate",
                    "getRecordedDate",
                    "getStockOutDate");

            if (!dateInRange(dateObj, fromDate, toDate)) {
                continue;
            }

            String medicineName = text(readProperty(tx,
                    "getMedicineName",
                    "getMedicine",
                    "getName"));

            int qty = number(readProperty(tx,
                    "getQuantity",
                    "getQuantityOut",
                    "getQuantityIssued"));

            if (medicineName.trim().isEmpty()) {
                continue;
            }

            usage.put(medicineName, usage.getOrDefault(medicineName, 0) + qty);
            names.put(medicineName, medicineName);
        }

        List<Map.Entry<String, Integer>> sorted
                = new ArrayList<>(usage.entrySet());

        sorted.sort(( a,     b) -> Integer.compare(b.getValue(), a.getValue()));

        int limit = Math.min(10, sorted.size());

        for (int i = 0; i < limit; i++) {
            Map.Entry<String, Integer> e = sorted.get(i);

            rows.add(new Object[]{
                null,
                names.get(e.getKey()),
                "Rank " + (i + 1),
                e.getValue(),
                "Stock Out",
                ""
            });

            totalTransactions++;
            totalQuantity += e.getValue();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Reports - Clinic Alert System</title>

        <link rel="stylesheet" href="<%= ctx%>/css/style.css">

        <style>
            .report-layout {
                display:grid;
                grid-template-columns:2fr 1fr;
                gap:20px;
                margin-bottom:24px;
            }

            .report-type-list {
                list-style:none;
                padding:0;
                margin:0;
            }

            .report-type-list li {
                padding:11px 12px;
                border-bottom:1px solid #E2E8F0;
                font-size:13.5px;
                color:#334155;
            }

            .report-type-list li:last-child {
                border-bottom:none;
            }

            .report-type-list li::before {
                content:"•";
                margin-right:10px;
                color:#0066FF;
                font-weight:bold;
            }

            .report-result {
                margin-top:24px;
            }

            .report-summary {
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px;
                margin-bottom:20px;
            }

            .summary-box {
                padding:16px;
                border:1px solid #E2E8F0;
                border-radius:10px;
                background:#F8FAFC;
            }

            .summary-label {
                font-size:12px;
                color:#64748B;
                margin-bottom:6px;
            }

            .summary-value {
                font-size:20px;
                font-weight:700;
                color:#0F172A;
            }

            .required {
                color:#EF4444;
            }

            .report-actions {
                display:flex;
                gap:8px;
            }

            .btn-danger {
                border:none;
                background:#EF4444;
                color:white;
                padding:8px 14px;
                border-radius:7px;
                cursor:pointer;
                font-size:12px;
                font-weight:600;
            }

            @media(max-width:900px) {
                .report-layout {
                    grid-template-columns:1fr;
                }

                .report-summary {
                    grid-template-columns:1fr;
                }
            }

            @media print {
                .sidebar,
                .top-navbar,
                .report-form-card,
                .report-types-card,
                .report-actions {
                    display:none !important;
                }

                .main-wrapper {
                    width:100%;
                    margin:0;
                }

                .content-container {
                    padding:0;
                }
            }
        </style>
    </head>

    <body>

        <div class="app-container">

            <aside class="sidebar">

                <div class="sidebar-brand">
                    <div class="brand-icon-wrapper">
                        <svg width="26" height="26" viewBox="0 0 64 64" fill="none">
                        <rect x="18" y="20" width="28" height="36" rx="6" fill="#0A2540"/>
                        <rect x="23" y="14" width="18" height="6" rx="2" fill="#0066FF"/>
                        <rect x="29" y="32" width="6" height="14" rx="1.5" fill="#10B981"/>
                        <rect x="25" y="36" width="14" height="6" rx="1.5" fill="#10B981"/>
                        <rect x="36" y="24" width="18" height="26" rx="3" fill="#FFFFFF" stroke="#0A2540" stroke-width="2"/>
                        <line x1="40" y1="31" x2="50" y2="31" stroke="#0066FF" stroke-width="2" stroke-linecap="round"/>
                        <line x1="40" y1="36" x2="48" y2="36" stroke="#0066FF" stroke-width="2" stroke-linecap="round"/>
                        <circle cx="16" cy="18" r="7" fill="#10B981"/>
                        <path d="M13 18C13 14 19 14 19 18C19 22 13 22 13 18Z" fill="#FFFFFF"/>
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
                       class="nav-link">

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
                       class="nav-link active">

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
                        onclick="document.getElementById('logoutModal').style.display = 'flex'"
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
                        <h2>Reports</h2>
                    </div>

                    <div class="user-profile-badge">
                        <div class="user-avatar-circle">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                        </div>
                        <span>
                            <%= staffName%>
                            (<%= userRole%>)
                        </span>                    </div>

                </header>

                <div class="content-container">

                    <div style="margin-bottom:20px;">
                        <h1 style="margin:0;font-size:22px;font-weight:700;color:#1E293B;">
                            Inventory Reports
                        </h1>

                        <p style="margin:5px 0 0;font-size:13px;color:#64748B;">
                            Generate and review medicine inventory reports.
                        </p>
                    </div>

                    <div class="report-layout">

                        <div class="panel-card report-form-card">

                            <div class="panel-header">
                                <h3>Generate Inventory Report</h3>
                            </div>

                            <form method="get"
                                  action="<%= ctx%>/reports"
                                  id="reportForm">

                                <div class="form-group">

                                    <label for="reportType">
                                        Report Type
                                        <span class="required">*</span>
                                    </label>

                                    <select id="reportType"
                                            name="reportType"
                                            class="form-control"
                                            required>

                                        <option value="">Select report</option>

                                        <option value="Stock In Report"
                                                <%= "Stock In Report".equals(reportType) ? "selected" : ""%>>
                                            Stock In Report
                                        </option>

                                        <option value="Stock Out Report"
                                                <%= "Stock Out Report".equals(reportType) ? "selected" : ""%>>
                                            Stock Out Report
                                        </option>

                                        <option value="Stock Balance Report"
                                                <%= "Stock Balance Report".equals(reportType) ? "selected" : ""%>>
                                            Stock Balance Report
                                        </option>

                                        <option value="Expiry Report"
                                                <%= "Expiry Report".equals(reportType) ? "selected" : ""%>>
                                            Expiry Report
                                        </option>

                                        <option value="Low Stock Report"
                                                <%= "Low Stock Report".equals(reportType) ? "selected" : ""%>>
                                            Low Stock Report
                                        </option>

                                        <option value="Top 10 Medicines Report"
                                                <%= "Top 10 Medicines Report".equals(reportType) ? "selected" : ""%>>
                                            Top 10 Medicines Report
                                        </option>

                                    </select>
                                </div>

                                <div class="form-grid-2">

                                    <div class="form-group">
                                        <label for="fromDate">
                                            From Date
                                            <span class="required">*</span>
                                        </label>

                                        <input type="date"
                                               id="fromDate"
                                               name="dateFrom"
                                               class="form-control"
                                               value="<%= dateFrom%>"
                                               required>
                                    </div>

                                    <div class="form-group">
                                        <label for="toDate">
                                            To Date
                                            <span class="required">*</span>
                                        </label>

                                        <input type="date"
                                               id="toDate"
                                               name="dateTo"
                                               class="form-control"
                                               value="<%= dateTo%>"
                                               required>
                                    </div>

                                </div>

                                <div style="margin-top:20px;display:flex;justify-content:flex-end;">
                                    <button type="submit" class="btn-primary">
                                        Generate Report
                                    </button>
                                </div>

                            </form>
                        </div>

                        <div class="panel-card report-types-card">

                            <div class="panel-header">
                                <h3>Report Types</h3>
                            </div>

                            <ul class="report-type-list">
                                <li>Stock In Report</li>
                                <li>Stock Out Report</li>
                                <li>Stock Balance Report</li>
                                <li>Expiry Report</li>
                                <li>Low Stock Report</li>
                                <li>Top 10 Medicines Report</li>
                            </ul>

                        </div>

                    </div>

                    <div id="reportResultSection" class="panel-card report-result">

                        <div class="panel-header">

                            <div>
                                <h3 id="reportTitle">
                                    Report Preview: <%= reportType%>
                                </h3>

                                <p id="reportPeriod"
                                   style="margin:4px 0 0;font-size:12px;color:#64748B;">
                                    <%= dateFrom.replace("-", "/").replace("-", "/")%>
                                    -
                                    <%= dateTo.replace("-", "/").replace("-", "/")%>
                                </p>
                            </div>

                            <div class="report-actions">

                                <button type="button"
                                        class="btn-secondary"
                                        onclick="window.print()">
                                    Print
                                </button>

                                <button type="button"
                                        class="btn-primary"
                                        onclick="exportCSV()">
                                    Export CSV
                                </button>

                            </div>

                        </div>

                        <div class="report-summary">

                            <div class="summary-box">
                                <div class="summary-label">
                                    <%= "Stock Balance Report".equals(reportType) ? "Total Medicines"
                                            : "Low Stock Report".equals(reportType) ? "Low Stock Items"
                                            : "Expiry Report".equals(reportType) ? "Expiry Items"
                                            : "Top 10 Medicines Report".equals(reportType) ? "Top Medicines"
                                            : "Total Transactions"%>
                                </div>
                                <div class="summary-value"><%= totalTransactions%></div>
                            </div>

                            <div class="summary-box">
                                <div class="summary-label">Total Quantity</div>
                                <div class="summary-value"><%= totalQuantity%></div>
                            </div>

                            <div class="summary-box">
                                <div class="summary-label">Generated By</div>
                                <div class="summary-value" style="font-size:15px;">
                                    <%= staffId%>
                                </div>
                            </div>

                        </div>

                        <div class="table-responsive">

                            <table class="custom-table" id="reportTable">

                                <thead>
                                    <tr>

                                        <th>
                                            <%= "Top 10 Medicines Report".equals(reportType) ? "Rank"
                                                    : ("Stock Balance Report".equals(reportType) || "Low Stock Report".equals(reportType)) ? "-"
                                                    : "Date"%>
                                        </th>
                                        <th>Medicine Name</th>
                                        <th>Batch No.</th>
                                        <th>Quantity</th>

                                        <% if ("Stock Out Report".equals(reportType)) { %>
                                        <th>Reason</th>
                                        <th>Issued By</th>
                                            <% } else if ("Stock Balance Report".equals(reportType)) { %>
                                        <th>Minimum Stock</th>
                                        <th>Status</th>
                                            <% } else if ("Low Stock Report".equals(reportType)) { %>
                                        <th>Minimum Stock</th>
                                        <th>Unit</th>
                                            <% } else if ("Expiry Report".equals(reportType)) { %>
                                        <th>Days / Info</th>
                                        <th>Status</th>
                                            <% } else if ("Top 10 Medicines Report".equals(reportType)) { %>
                                        <th>Type</th>
                                        <th></th>
                                            <% } else { %>
                                        <th>Supplier</th>
                                        <th>Received By</th>
                                            <% } %>

                                    </tr>
                                </thead>

                                <tbody>

                                    <% if (rows.isEmpty()) { %>

                                    <tr>
                                        <td colspan="6" style="text-align:center;color:#64748B;padding:25px;">
                                            No data found for the selected report and date range.
                                        </td>
                                    </tr>

                                    <% } else { %>

                                    <% for (Object[] row : rows) { %>

                                    <tr>

                                        <td>
                                            <% if ("Top 10 Medicines Report".equals(reportType)) {%>
                                            <%= text(row[2])%>
                                            <% } else if ("Stock Balance Report".equals(reportType) || "Low Stock Report".equals(reportType)) { %>
                                            -
                                            <% } else {%>
                                            <%= formatDate(row[0])%>
                                            <% }%>
                                        </td>

                                        <td>
                                            <strong><%= text(row[1])%></strong>
                                        </td>

                                        <td>
                                            <%= text(row[2])%>
                                        </td>

                                        <td>
                                            <%= row[3]%>
                                        </td>

                                        <td>
                                            <%= ("Stock In Report".equals(reportType) || "Stock Out Report".equals(reportType)) && text(row[4]).trim().isEmpty() ? "-" : text(row[4])%>
                                        </td>

                                        <td>
                                            <%= ("Stock In Report".equals(reportType) || "Stock Out Report".equals(reportType)) && text(row[5]).trim().isEmpty() ? "-" : text(row[5])%>
                                        </td>

                                    </tr>

                                    <% } %>

                                    <% }%>

                                </tbody>

                            </table>

                        </div>

                    </div>

                </div>

            </main>

        </div>

        <jsp:include page="logout.jsp" />

        <script>
            function exportCSV() {

                var table = document.getElementById("reportTable");
                var rows = table.querySelectorAll("tr");
                var csv = [];

                for (var i = 0; i < rows.length; i++) {

                    var cells = rows[i].querySelectorAll("th, td");
                    var row = [];

                    for (var j = 0; j < cells.length; j++) {

                        var value = cells[j].innerText
                                .replace(/\r?\n|\r/g, " ")
                                .replace(/"/g, '""');

                        row.push('"' + value + '"');
                    }

                    csv.push(row.join(","));
                }

                var blob = new Blob(
                        [csv.join("\n")],
                        {type: "text/csv;charset=utf-8;"}
                );

                var url = URL.createObjectURL(blob);
                var link = document.createElement("a");

                link.href = url;
                link.download = "clinic_alert_<%= reportType.replace(" ", "_")%>.csv";

                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);

                URL.revokeObjectURL(url);
            }
        </script>

    </body>
</html>
