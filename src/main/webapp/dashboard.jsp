<%@ page language="java"

         contentType="text/html; charset=UTF-8"

         pageEncoding="UTF-8"%>


<%@ page import="java.util.List" %>

<%@ page import="java.util.ArrayList" %>

<%@ page import="com.clinicalert.model.Medicine" %>

<%@ page import="com.clinicalert.model.StockTransaction" %>

<%@ page import="com.clinicalert.model.User" %>


<%


    User currentUser = (User) session.getAttribute("currentUser");

    String staffId = (String) session.getAttribute("staffId");

    String staffName = (String) session.getAttribute("staffName");

    String userRole = (String) session.getAttribute("userRole");


    if (currentUser != null) {

        if (staffId == null || staffId.isEmpty()) staffId = currentUser.getStaffId();

        if (staffName == null || staffName.isEmpty()) staffName = currentUser.getName();

        if (userRole == null || userRole.isEmpty()) userRole = currentUser.getRole();

    }


    if (staffId == null) {

        staffId = "";

    }


    if (staffName == null || staffName.trim().isEmpty()) {

        staffName = "User";

    }


    if (userRole == null || userRole.trim().isEmpty()) {

        userRole = "Staff";

    }


    boolean isAdmin = currentUser != null ? currentUser.isAdministrative() : true;


    Integer totalMedicinesObj

            = (Integer) request.getAttribute("totalMedicines");


    Integer expiringCountObj

            = (Integer) request.getAttribute("expiringCount");


    Integer stockInTodayObj

            = (Integer) request.getAttribute("stockInToday");


    Integer stockOutTodayObj

            = (Integer) request.getAttribute("stockOutToday");


    int totalMedicines

            = totalMedicinesObj != null

                    ? totalMedicinesObj

                    : 0;


    int expiringCount

            = expiringCountObj != null

                    ? expiringCountObj

                    : 0;


    int stockInToday

            = stockInTodayObj != null

                    ? stockInTodayObj

                    : 0;


    int stockOutToday

            = stockOutTodayObj != null

                    ? stockOutTodayObj

                    : 0;


    List<Medicine> medicines

            = (List<Medicine>) request.getAttribute("medicines");


    if (medicines == null) {

        medicines = new ArrayList<Medicine>();

    }


    List<Medicine> expiringList

            = (List<Medicine>) request.getAttribute("expiringList");


    if (expiringList == null) {

        expiringList = new ArrayList<Medicine>();

    }


    List<Medicine> expiredList

            = (List<Medicine>) request.getAttribute("expiredList");


    if (expiredList == null) {

        expiredList = new ArrayList<Medicine>();

    }


    List<StockTransaction> recentTransactions

            = (List<StockTransaction>) request.getAttribute("recentTransactions");


    if (recentTransactions == null) {

        recentTransactions = new ArrayList<StockTransaction>();

    }


    int inStockCount = 0;

    int lowStockCount = 0;

    int outOfStockCount = 0;


    for (Medicine medicine : medicines) {


        int currentStock

                = medicine.getCurrentStock();


        int minimumStock

                = medicine.getMinStock();


        if (currentStock <= 0) {


            outOfStockCount++;


        } else if (currentStock <= minimumStock) {


            lowStockCount++;


        } else {


            inStockCount++;

        }

    }


    int stockOverviewTotal

            = inStockCount

            + lowStockCount

            + outOfStockCount;


    double inStockPercentage = 0.0;

    double lowStockPercentage = 0.0;

    double outOfStockPercentage = 0.0;


    if (stockOverviewTotal > 0) {


        inStockPercentage

                = (inStockCount * 100.0)

                / stockOverviewTotal;


        lowStockPercentage

                = (lowStockCount * 100.0)

                / stockOverviewTotal;


        outOfStockPercentage

                = (outOfStockCount * 100.0)

                / stockOverviewTotal;

    }


    int recentLimit

            = Math.min(5, recentTransactions.size());


%>


<!DOCTYPE html>


<html lang="en">


    <head>


        <meta charset="UTF-8">


        <meta name="viewport"

              content="width=device-width, initial-scale=1.0">


        <title>

            Dashboard - Clinic Alert: Smart Medicine Management System

        </title>


        <link rel="stylesheet"

              href="css/style.css">


        <style>

            .topbar-action-btn {

                display: inline-flex !important;

                align-items: center;

                justify-content: center;

                width: 38px;

                height: 38px;

                min-width: 38px;

                border-radius: 50%;

                background: #ffffff;

                border: 1px solid #dfe7ee;

                color: #475569;

                cursor: pointer;

                position: relative !important;

                padding: 0;

                box-shadow: 0 1px 3px rgba(15, 23, 42, 0.05);

                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);

                outline: none;

            }

            .topbar-action-btn:hover {

                background: #f8fafc;

                border-color: #cbd5e1;

                color: #0066FF;

                box-shadow: 0 3px 8px rgba(0, 102, 255, 0.12);

                transform: translateY(-1.5px);

            }

            .topbar-action-btn:active {

                transform: translateY(0) scale(0.95);

                background: #eff6ff;

            }

            .refresh-btn .refresh-icon {

                transition: transform 0.4s ease;

            }

            .refresh-btn:hover .refresh-icon {

                transform: rotate(60deg);

            }

            .refresh-btn.spinning .refresh-icon {

                animation: spinRefresh 0.6s cubic-bezier(0.4, 0, 0.2, 1) infinite;

            }

            @keyframes spinRefresh {

                0% { transform: rotate(0deg); }

                100% { transform: rotate(360deg); }

            }

            .panel-card-fixed {

                display: flex;

                flex-direction: column;

                height: 100%;

            }

            .expiry-scroll-area {

                flex: 1;

                max-height: 270px;

                overflow-y: auto;

                padding-right: 6px;

                scrollbar-width: thin;

                scrollbar-color: #CBD5E1 transparent;

            }

            .expiry-scroll-area::-webkit-scrollbar {

                width: 5px;

            }

            .expiry-scroll-area::-webkit-scrollbar-track {

                background: transparent;

            }

            .expiry-scroll-area::-webkit-scrollbar-thumb {

                background: #CBD5E1;

                border-radius: 4px;

            }

            .expiry-scroll-area::-webkit-scrollbar-thumb:hover {

                background: #94A3B8;

            }

            .badge-hidden {

                display: none !important;

            }

            .has-border-bottom {

                border-bottom: 1px solid #eef2f5 !important;

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

                            Clinic<span class="highlight">Alert</span>

                        </h1>


                        <p>

                            Smart Medicine Management System

                        </p>


                    </div>


                </div>


                <nav class="sidebar-nav">


                    <a href="dashboard"

                       class="nav-link active">


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

                            ›

                        </span>


                    </a>


                    <a href="medicine"

                       class="nav-link">


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

                            ›

                        </span>


                    </a>


                    <a href="stockin"

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

                            ›

                        </span>


                    </a>


                    <a href="stockout"

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

                            ›

                        </span>


                    </a>


                    <a href="lowstock"

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

                            ›

                        </span>


                    </a>


                    <a href="expiry"

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

                            ›

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

                            ›

                        </span>


                    </a>


                    <a href="reports"

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

                            ›

                        </span>


                    </a>


                    <a href="profile"

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

                            ›

                        </span>


                    </a>


                    <% if (isAdmin) { %>


                    <a href="usermanagement"

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

                            ›

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


                    <div>

                        <div

                            style="

                            font-size:21px;

                            font-weight:700;

                            color:#102b43;

                            letter-spacing:-0.2px;

                            "

                            >

                            Dashboard

                        </div>

                    </div>


                    <div class="topbar-actions"

                         style="display:flex; flex-direction:row; flex-wrap:nowrap; align-items:center; justify-content:flex-end; gap:8px; width:auto; height:100%; white-space:nowrap;">


                        <button

                            type="button"

                            class="topbar-icon topbar-action-btn refresh-btn"

                            title="Refresh dashboard"

                            aria-label="Refresh dashboard"

                            onclick="handleRefresh(this)">

                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"

                                 stroke-width="2"

                                 stroke-linecap="round"

                                 stroke-linejoin="round"

                                 class="refresh-icon">

                                <path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path>

                                <path d="M21 3v5h-5"></path>

                                <path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path>

                                <path d="M3 21v-5h5"></path>

                            </svg>

                        </button>


                        <%

                            int totalNotificationCount = lowStockCount + expiringCount;

                        %>

                        <button

                            type="button"

                            class="topbar-icon topbar-action-btn notification-btn"

                            title="Notifications"

                            aria-label="Notifications"

                            onclick="toggleNotifications()">


                            <span id="notificationBadge"

                                  class="<%= totalNotificationCount == 0 ? "badge-hidden" : "" %>"

                                  style="

                                  position:absolute !important;

                                  top:-4px !important;

                                  right:-4px !important;

                                  min-width:18px;

                                  height:18px;

                                  padding:0 5px;

                                  border-radius:10px;

                                  background:#EF4444;

                                  border:2px solid #ffffff;

                                  color:#fff;

                                  font-size:10px;

                                  font-weight:700;

                                  line-height:14px;

                                  text-align:center;

                                  box-sizing:border-box;

                                  z-index:2;

                                  box-shadow:0 1px 3px rgba(239, 68, 68, 0.4);

                                  "><%= totalNotificationCount%></span>


                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"

                                 stroke-width="2"

                                 stroke-linecap="round"

                                 stroke-linejoin="round">

                            <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"></path>

                            <path d="M10 21h4"></path>

                            </svg>

                        </button>


                        <a

                            href="profile"

                            class="user-profile-badge"

                            title="Open profile"

                            style="text-decoration:none; cursor:pointer;">


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
                                <%= staffName%>
                                (<%= userRole%>)
                            </span>


                        </a>


                    </div>


                </header>


                <div

                    id="dashboardNotificationPanel"

                    style="

                    display:none;

                    position:fixed;

                    top:86px;

                    right:28px;

                    width:320px;

                    background:#ffffff;

                    border:1px solid #dfe7ee;

                    border-radius:10px;

                    box-shadow:0 10px 28px rgba(17,43,63,.14);

                    z-index:9999;

                    overflow:hidden;

                    "

                    >


                    <div

                        style="

                        padding:14px 16px;

                        border-bottom:1px solid #e8edf2;

                        color:#173149;

                        font-size:13px;

                        font-weight:700;

                        "

                        >

                        Notifications

                    </div>


                    <% if (lowStockCount > 0) { %>

                    <a

                        href="lowstock"

                        class="<%= expiringCount > 0 ? "has-border-bottom" : "" %>"

                        style="

                        display:flex;

                        gap:10px;

                        padding:13px 16px;

                        color:#53677a;

                        text-decoration:none;

                        "

                        >

                        <span

                            style="

                            width:8px;

                            height:8px;

                            min-width:8px;

                            margin-top:5px;

                            border-radius:50%;

                            background:#e1a52f;

                            "

                            ></span>


                        <span>

                            <strong

                                style="display:block; color:#243b50; font-size:12px;"

                                >

                                <%= lowStockCount%> Low Stock Item<%= lowStockCount == 1 ? "" : "s"%>

                            </strong>


                            <small

                                style="display:block; margin-top:3px; color:#7b8b9a; font-size:10.5px;"

                                >

                                Review medicines below minimum stock.

                            </small>

                        </span>

                    </a>

                    <% } %>


                    <% if (expiringCount > 0) { %>

                    <a

                        href="expiry"

                        style="

                        display:flex;

                        gap:10px;

                        padding:13px 16px;

                        color:#53677a;

                        text-decoration:none;

                        "

                        >

                        <span

                            style="

                            width:8px;

                            height:8px;

                            min-width:8px;

                            margin-top:5px;

                            border-radius:50%;

                            background:#d95353;

                            "

                            ></span>


                        <span>

                            <strong

                                style="display:block; color:#243b50; font-size:12px;"

                                >

                                <%= expiringCount%> Near Expiry

                            </strong>


                            <small

                                style="display:block; margin-top:3px; color:#7b8b9a; font-size:10.5px;"

                                >

                                View medicines expiring within 30 days.

                            </small>

                        </span>

                    </a>

                    <% } %>


                    <% if (lowStockCount == 0 && expiringCount == 0) { %>

                    <div

                        style="

                        padding:24px 16px;

                        text-align:center;

                        color:#64748b;

                        font-size:12px;

                        "

                        >

                        <div style="font-size:22px; margin-bottom:6px;">🎉</div>

                        <strong style="display:block; color:#243b50; font-size:13px;">No Active Alerts</strong>

                        <small style="display:block; margin-top:4px; color:#7b8b9a; font-size:11px;">

                            All medicines have sufficient stock and valid expiry dates.

                        </small>

                    </div>

                    <% } %>


                </div>


                <div class="content-container">


                    <div class="kpi-grid-5">


                        <div class="kpi-card blue">


                            <div class="kpi-title">

                                Total Medicines

                            </div>


                            <div class="kpi-value">

                                <%= totalMedicines%>

                            </div>


                            <div class="kpi-subtitle">

                                Active medicines

                            </div>


                        </div>


                        <div class="kpi-card orange">


                            <div class="kpi-title">

                                Low Stock

                            </div>


                            <div class="kpi-value"

                                 style="color: #D97706;">


                                <%= lowStockCount%>


                            </div>


                            <div class="kpi-subtitle">

                                Require attention

                            </div>


                        </div>


                        <div class="kpi-card red">


                            <div class="kpi-title">

                                Near Expiry

                            </div>


                            <div class="kpi-value"

                                 style="color: #EF4444;">


                                <%= expiringCount%>


                            </div>


                            <div class="kpi-subtitle">

                                Within 30 days

                            </div>


                        </div>


                        <div class="kpi-card green">


                            <div class="kpi-title">

                                Today's Stock In

                            </div>


                            <div class="kpi-value"

                                 style="color: #10B981;">


                                <%= stockInToday%>


                            </div>


                            <div class="kpi-subtitle">

                                Transactions

                            </div>


                        </div>


                        <div class="kpi-card purple">


                            <div class="kpi-title">

                                Today's Stock Out

                            </div>


                            <div class="kpi-value"

                                 style="color: #8B5CF6;">


                                <%= stockOutToday%>


                            </div>


                            <div class="kpi-subtitle">

                                Transactions

                            </div>


                        </div>


                    </div>


                    <div class="grid-2">


                        <div class="panel-card panel-card-fixed">


                            <div class="panel-header">


                                <h3>

                                    Stock Overview

                                </h3>


                            </div>


                            <div class="chart-container" style="flex: 1; display: flex; align-items: center; justify-content: space-around; margin: auto 0; padding: 10px 0;">


                                <div class="donut-graphic">


                                    <div class="donut-inner">


                                        <span class="total-num">

                                            <%= totalMedicines%>

                                        </span>


                                        <span class="total-label">

                                            Total Medicines

                                        </span>


                                    </div>


                                </div>


                                <div class="legend-list">


                                    <div class="legend-item">


                                        <span class="dot blue"></span>


                                        <span>


                                            In Stock


                                            <strong>

                                                <%= inStockCount%>

                                                (<%= String.format(

                                                        "%.1f",

                                                        inStockPercentage

                                                )%>%)

                                            </strong>


                                        </span>


                                    </div>


                                    <div class="legend-item">


                                        <span class="dot orange"></span>


                                        <span>


                                            Low Stock


                                            <strong>

                                                <%= lowStockCount%>

                                                (<%= String.format(

                                                        "%.1f",

                                                        lowStockPercentage

                                                )%>%)

                                            </strong>


                                        </span>


                                    </div>


                                    <div class="legend-item">


                                        <span class="dot red"></span>


                                        <span>


                                            Out of Stock


                                            <strong>

                                                <%= outOfStockCount%>

                                                (<%= String.format(

                                                        "%.1f",

                                                        outOfStockPercentage

                                                )%>%)

                                            </strong>


                                        </span>


                                    </div>


                                </div>


                            </div>


                        </div>


                        <div class="panel-card panel-card-fixed">


                            <div class="panel-header">


                                <h3>

                                    Expiry Overview

                                </h3>


                            </div>


                            <div class="expiry-scroll-area">


                                <div class="expiry-list">


                                    <%

                                        if (!expiredList.isEmpty()) {

                                    %>


                                    <div class="expiry-row">

                                        <div style="display:flex;align-items:center;gap:8px;">

                                            <span class="dot" style="background:#EF4444;"></span>

                                            <span>Already Expired</span>

                                        </div>

                                        <span class="count"><%= expiredList.size()%></span>

                                    </div>


                                    <%

                                        for (int i = 0; i < Math.min(10, expiredList.size()); i++) {

                                            Medicine xm = expiredList.get(i);

                                            long overdue = Math.abs(xm.getDaysLeft());

                                            String xName = xm.getName() == null ? "-" : xm.getName().replace("&", "&amp;").replace("<", "&lt;");

                                            String xBatch = xm.getBatchNo() == null ? "-" : xm.getBatchNo().replace("&", "&amp;").replace("<", "&lt;");

                                            String xUnit = xm.getUnit() == null ? "" : xm.getUnit().replace("&", "&amp;").replace("<", "&lt;");

                                    %>

                                    <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;padding:10px 0;border-bottom:1px dashed #E2E8F0;">

                                        <div style="min-width:0;">

                                            <div style="font-weight:600;font-size:14px;"><%= xName%></div>

                                            <div style="font-size:12px;color:#64748B;">Batch <%= xBatch%> · <%= xm.getCurrentStock()%> <%= xUnit%> still in stock</div>

                                        </div>

                                        <div style="text-align:right;white-space:nowrap;">

                                            <div style="font-size:13px;"><%= xm.getExpiryDate()%></div>

                                            <div style="font-size:12px;font-weight:600;color:#B91C1C;">Expired <%= overdue == 0 ? "today" : overdue + " day" + (overdue == 1 ? "" : "s") + " ago"%></div>

                                        </div>

                                    </div>

                                    <%

                                        }

                                    %>

                                    <div style="height:16px;"></div>

                                    <%

                                        }

                                    %>


                                    <div class="expiry-row">


                                        <div

                                            style="

                                            display: flex;

                                            align-items: center;

                                            gap: 8px;

                                            "

                                            >


                                            <span class="dot orange"></span>


                                            <span>

                                                Within 30 Days

                                            </span>


                                        </div>


                                        <span class="count">

                                            <%= expiringCount%>

                                        </span>


                                    </div>


                                    <%

                                        if (expiringList.isEmpty()) {

                                    %>

                                    <div style="margin-top:12px;padding:12px;border-radius:8px;background:#F8FAFC;color:#64748B;font-size:13px;">

                                        No medicines expiring within the next 30 days.

                                    </div>

                                    <%

                                        } else {

                                            for (int i = 0; i < Math.min(10, expiringList.size()); i++) {

                                                Medicine em = expiringList.get(i);

                                                long daysLeft = em.getDaysLeft();

                                                String emName = em.getName() == null ? "-" : em.getName().replace("&", "&amp;").replace("<", "&lt;");

                                                String emBatch = em.getBatchNo() == null ? "-" : em.getBatchNo().replace("&", "&amp;").replace("<", "&lt;");

                                                String emUnit = em.getUnit() == null ? "" : em.getUnit().replace("&", "&amp;").replace("<", "&lt;");

                                    %>

                                    <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;padding:10px 0;border-bottom:1px dashed #E2E8F0;">

                                        <div style="min-width:0;">

                                            <div style="font-weight:600;font-size:14px;"><%= emName%></div>

                                            <div style="font-size:12px;color:#64748B;">Batch <%= emBatch%> · <%= em.getCurrentStock()%> <%= emUnit%></div>

                                        </div>

                                        <div style="text-align:right;white-space:nowrap;">

                                            <div style="font-size:13px;"><%= em.getExpiryDate()%></div>

                                            <div style="font-size:12px;font-weight:600;color:#C2410C;"><%= daysLeft%> day<%= daysLeft == 1 ? "" : "s"%> left</div>

                                        </div>

                                    </div>

                                    <%

                                            }

                                        }

                                    %>


                                </div>


                            </div>


                            <div style="margin-top:auto;padding-top:14px;text-align:right;">

                                <a href="<%= request.getContextPath()%>/expiry" style="font-size:13px;font-weight:600;color:#2563EB;text-decoration:none;">

                                    View all expiry alerts ›

                                </a>

                            </div>


                        </div>


                    </div>


                    <div class="panel-card">


                        <div class="panel-header">


                            <h3>

                                Recent Transactions

                            </h3>


                            <a href="reports"

                               class="view-all-link">


                                View All


                            </a>


                        </div>


                        <div class="table-responsive">


                            <table class="custom-table">


                                <thead>


                                    <tr>


                                        <th>

                                            Date

                                        </th>


                                        <th>

                                            Type

                                        </th>


                                        <th>

                                            Medicine

                                        </th>


                                        <th>

                                            Batch No.

                                        </th>


                                        <th>

                                            Qty

                                        </th>


                                        <th>

                                            Staff

                                        </th>


                                    </tr>


                                </thead>


                                <tbody>


                                    <%

                                        if (recentLimit == 0) {

                                    %>


                                    <tr>


                                        <td colspan="6"

                                            style="

                                            text-align: center;

                                            padding: 30px;

                                            color: #64748B;

                                            ">


                                            No transactions found.


                                        </td>


                                    </tr>


                                    <%

                                    } else {


                                        for (int i = 0;

                                                i < recentLimit;

                                                i++) {


                                            StockTransaction txn

                                                    = recentTransactions.get(i);


                                            boolean isStockIn

                                                    = "IN".equalsIgnoreCase(

                                                            txn.getType()

                                                    );


                                            String displayType

                                                    = isStockIn

                                                            ? "Stock In"

                                                            : "Stock Out";


                                            String transactionDate

                                                    = txn.getDate();


                                            String medicineName

                                                    = txn.getMedicineName();


                                            String batchNo

                                                    = txn.getBatchNo();


                                            String recordedBy

                                                    = txn.getRecordedBy();


                                            if (transactionDate == null

                                                    || transactionDate.trim().isEmpty()) {


                                                transactionDate = "-";

                                            }


                                            if (medicineName == null

                                                    || medicineName.trim().isEmpty()) {


                                                medicineName = "-";

                                            }


                                            if (batchNo == null

                                                    || batchNo.trim().isEmpty()) {


                                                batchNo = "-";

                                            }


                                            if (recordedBy == null

                                                    || recordedBy.trim().isEmpty()) {


                                                recordedBy = "-";

                                            }

                                    %>


                                    <tr>


                                        <td>

                                            <%= transactionDate%>

                                        </td>


                                        <td>


                                            <span class="badge <%= isStockIn

                                                    ? "stockin"

                                                    : "stockout"%>">


                                                <span class="badge-dot"></span>


                                                <%= displayType%>


                                            </span>


                                        </td>


                                        <td>


                                            <strong>

                                                <%= medicineName%>

                                            </strong>


                                        </td>


                                        <td>

                                            <%= batchNo%>

                                        </td>


                                        <td>

                                            <%= txn.getQuantity()%>

                                        </td>


                                        <td>

                                            <%= recordedBy%>

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


                </div>


            </main>


        </div>


        <jsp:include page="logout.jsp" />


        <script>

            function toggleSidebar() {

                var sidebar = document.querySelector(".sidebar");

                var mainWrapper = document.querySelector(".main-wrapper");


                if (!sidebar || !mainWrapper) {

                    return;

                }


                var collapsed = sidebar.getAttribute("data-collapsed") === "true";


                if (!collapsed) {

                    sidebar.setAttribute("data-collapsed", "true");


                    sidebar.style.width = "78px";

                    sidebar.style.flex = "0 0 78px";


                    mainWrapper.style.marginLeft = "0";

                    mainWrapper.style.width = "calc(100% - 78px)";


                    var brandTitles = document.querySelector(".brand-titles");

                    if (brandTitles) {

                        brandTitles.style.display = "none";

                    }


                    document.querySelectorAll(".nav-link-content span, .chevron-icon").forEach(function (el) {

                        el.style.display = "none";

                    });


                    var logoutText = document.querySelector(".logout-btn span");

                    if (logoutText) {

                        logoutText.style.display = "none";

                    }


                    document.querySelectorAll(".nav-link, .logout-btn").forEach(function (el) {

                        el.style.justifyContent = "center";

                        el.style.paddingLeft = "0";

                        el.style.paddingRight = "0";

                    });


                } else {

                    sidebar.setAttribute("data-collapsed", "false");


                    sidebar.style.width = "";

                    sidebar.style.flex = "";


                    mainWrapper.style.marginLeft = "";

                    mainWrapper.style.width = "";


                    var brandTitles = document.querySelector(".brand-titles");

                    if (brandTitles) {

                        brandTitles.style.display = "";

                    }


                    document.querySelectorAll(".nav-link-content span, .chevron-icon").forEach(function (el) {

                        el.style.display = "";

                    });


                    var logoutText = document.querySelector(".logout-btn span");

                    if (logoutText) {

                        logoutText.style.display = "";

                    }


                    document.querySelectorAll(".nav-link, .logout-btn").forEach(function (el) {

                        el.style.justifyContent = "";

                        el.style.paddingLeft = "";

                        el.style.paddingRight = "";

                    });

                }

            }


            function handleRefresh(btn) {

                if (btn) {

                    btn.classList.add("spinning");

                }

                setTimeout(function () {

                    window.location.href = 'dashboard';

                }, 320);

            }


            function toggleNotifications() {

                var panel = document.getElementById("dashboardNotificationPanel");

                var badge = document.getElementById("notificationBadge");


                if (!panel) {

                    return;

                }


                var opening = panel.style.display === "none" || panel.style.display === "";


                panel.style.display = opening ? "block" : "none";


                if (opening && badge) {

                    badge.style.display = "none";

                    try {

                        var count = badge.textContent.trim();

                        localStorage.setItem("clinicAlertsLastSeenCount", count);

                    } catch (e) {

                        console.error("Failed to save notification state:", e);

                    }

                }

            }


            function toggleAppearance() {

                var body = document.body;


                if (body.getAttribute("data-soft-mode") === "true") {

                    body.setAttribute("data-soft-mode", "false");


                    body.style.background = "";

                    var main = document.querySelector(".main-wrapper");

                    if (main) {

                        main.style.background = "";

                    }


                } else {

                    body.setAttribute("data-soft-mode", "true");


                    body.style.background = "#eef3f7";

                    var main = document.querySelector(".main-wrapper");

                    if (main) {

                        main.style.background = "#eef3f7";

                    }

                }

            }


            document.addEventListener("click", function (event) {

                var panel = document.getElementById("dashboardNotificationPanel");

                var notificationButton = event.target.closest(".topbar-icon");


                if (!panel || !notificationButton) {

                    return;

                }


                var isNotification =

                        notificationButton.getAttribute("title") === "Notifications";


                if (!isNotification) {

                    return;

                }


                event.stopPropagation();

            });


            document.addEventListener("click", function (event) {

                var panel = document.getElementById("dashboardNotificationPanel");


                if (!panel || panel.style.display !== "block") {

                    return;

                }


                if (!event.target.closest("#dashboardNotificationPanel")

                        && !(event.target.closest(".topbar-icon")

                                && event.target.closest(".topbar-icon").getAttribute("title") === "Notifications")) {


                    panel.style.display = "none";

                }

            });

        </script>


        <script>

            document.addEventListener("DOMContentLoaded", function () {

                var badge = document.getElementById("notificationBadge");

                if (!badge) {

                    return;

                }


                var currentCount = badge.textContent.trim();

                var lastSeenCount = null;


                try {

                    lastSeenCount = localStorage.getItem("clinicAlertsLastSeenCount");

                } catch (e) {

                    console.error("Failed to read notification state:", e);

                }


                if (currentCount === "0" || lastSeenCount === currentCount) {

                    badge.style.display = "none";

                }

            });

        </script>


    </body>


</html>