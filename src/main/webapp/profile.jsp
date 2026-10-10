<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%

    javax.servlet.http.HttpSession currentSession
            = request.getSession(false);

    if (currentSession == null
            || currentSession.getAttribute("currentUser") == null) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    com.clinicalert.model.User user
            = (com.clinicalert.model.User) currentSession.getAttribute("currentUser");

    String staffId = user.getStaffId();
    String staffName = user.getName();
    String role = user.getRole();
    String email = user.getEmail();
    String phone = user.getPhone();

    if (staffName == null) {
        staffName = "";
    }
    if (role == null) {
        role = "";
    }
    if (email == null) {
        email = "";
    }
    if (phone == null) {
        phone = "";
    }

    boolean isAdmin
            = user != null ? user.isAdministrative() : true;

    String successMessage
            = (String) request.getAttribute("successMessage");

    String errorMessage
            = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>
            Profile - Clinic Alert System
        </title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/style.css">

    </head>

    <body>

        <div class="app-container">

            <aside class="sidebar">

                <div class="sidebar-brand">

                    <div class="brand-icon-wrapper">

                        <svg
                            width="26"
                            height="26"
                            viewBox="0 0 64 64"
                            fill="none"
                            >

                        <rect
                            x="18"
                            y="20"
                            width="28"
                            height="36"
                            rx="6"
                            fill="#0A2540"
                            />

                        <rect
                            x="23"
                            y="14"
                            width="18"
                            height="6"
                            rx="2"
                            fill="#0066FF"
                            />

                        <rect
                            x="29"
                            y="32"
                            width="6"
                            height="14"
                            rx="1.5"
                            fill="#10B981"
                            />

                        <rect
                            x="25"
                            y="36"
                            width="14"
                            height="6"
                            rx="1.5"
                            fill="#10B981"
                            />

                        <rect
                            x="36"
                            y="24"
                            width="18"
                            height="26"
                            rx="3"
                            fill="#FFFFFF"
                            stroke="#0A2540"
                            stroke-width="2"
                            />

                        <line
                            x1="40"
                            y1="31"
                            x2="50"
                            y2="31"
                            stroke="#0066FF"
                            stroke-width="2"
                            stroke-linecap="round"
                            />

                        <line
                            x1="40"
                            y1="36"
                            x2="48"
                            y2="36"
                            stroke="#0066FF"
                            stroke-width="2"
                            stroke-linecap="round"
                            />

                        <circle
                            cx="16"
                            cy="18"
                            r="7"
                            fill="#10B981"
                            />

                        <path
                            d="M13 18C13 14 19 14 19 18C19 22 13 22 13 18Z"
                            fill="#FFFFFF"
                            />

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
                       class="nav-link active">

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

                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">

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

                        <h2>
                            Profile
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
                            <span>
                                <%= staffName%> (<%= role%>)
                            </span>
                        </span>

                    </div>

                </header>

                <div class="content-container">

                    <div style="margin-bottom:20px;">

                        <h1
                            style="
                            margin:0;
                            font-size:22px;
                            font-weight:700;
                            color:#1E293B;
                            "
                            >
                            My Profile
                        </h1>

                        <p
                            style="
                            margin:5px 0 0;
                            font-size:13px;
                            color:#64748B;
                            "
                            >
                            View and update your staff profile information.
                        </p>

                    </div>

                    <% if (successMessage != null) {%>

                    <div
                        style="
                        margin-bottom:18px;
                        padding:12px 15px;
                        border-radius:8px;
                        background:#ECFDF5;
                        border:1px solid #A7F3D0;
                        color:#047857;
                        font-size:13px;
                        "
                        >
                        <%= successMessage%>
                    </div>

                    <% } %>

                    <% if (errorMessage != null) {%>

                    <div
                        style="
                        margin-bottom:18px;
                        padding:12px 15px;
                        border-radius:8px;
                        background:#FEF2F2;
                        border:1px solid #FECACA;
                        color:#B91C1C;
                        font-size:13px;
                        "
                        >
                        <%= errorMessage%>
                    </div>

                    <% }%>

                    <div
                        class="panel-card"
                        style="max-width:850px;"
                        >

                        <div class="panel-header">

                            <div>

                                <h3>
                                    Staff Profile Information
                                </h3>

                                <p
                                    style="
                                    margin:4px 0 0;
                                    font-size:12px;
                                    color:#64748B;
                                    "
                                    >
                                    Your information is loaded from the system account.
                                </p>

                            </div>

                        </div>

                        <form
                            action="<%= request.getContextPath()%>/profile"
                            method="POST"
                            onsubmit="return validateProfileForm();"
                            >

                            <div class="form-grid-2">

                                <div class="form-group">

                                    <label>
                                        Staff ID
                                    </label>

                                    <input
                                        type="text"
                                        class="form-control"
                                        value="<%= staffId%>"
                                        disabled
                                        >

                                </div>

                                <div class="form-group">

                                    <label>
                                        Role
                                    </label>

                                    <input
                                        type="text"
                                        class="form-control"
                                        value="<%= role%>"
                                        disabled
                                        >

                                </div>

                            </div>

                            <div class="form-grid-2">

                                <div class="form-group">

                                    <label for="name">
                                        Full Name
                                    </label>

                                    <input
                                        type="text"
                                        id="name"
                                        class="form-control"
                                        name="name"
                                        value="<%= staffName%>"
                                        required
                                        maxlength="100"
                                        >

                                </div>

                                <div class="form-group">

                                    <label for="phone">
                                        Phone No.
                                    </label>

                                    <input
                                        type="text"
                                        id="phone"
                                        class="form-control"
                                        name="phone"
                                        value="<%= phone%>"
                                        maxlength="30"
                                        >

                                </div>

                            </div>

                            <div class="form-grid-2">

                                <div class="form-group">

                                    <label for="email">
                                        Email
                                    </label>

                                    <input
                                        type="email"
                                        id="email"
                                        class="form-control"
                                        name="email"
                                        value="<%= email%>"
                                        maxlength="150"
                                        >

                                </div>

                                <div class="form-group">

                                    <label>
                                        Password
                                    </label>

                                    <a
                                        href="<%= request.getContextPath()%>/changepassword"
                                        class="btn-secondary"
                                        style="
                                        width:100%;
                                        justify-content:center;
                                        text-decoration:none;
                                        "
                                        >
                                        Change Password
                                    </a>

                                </div>

                            </div>

                            <div
                                style="
                                margin-top:24px;
                                display:flex;
                                justify-content:flex-end;
                                "
                                >

                                <button
                                    type="submit"
                                    class="btn-primary"
                                    style="
                                    padding:10px 24px;
                                    "
                                    >
                                    Update Profile
                                </button>

                            </div>

                        </form>

                    </div>

                </div>

            </main>

        </div>

        <jsp:include page="logout.jsp" />

        <script>

            function validateProfileForm() {

                var name =
                        document.getElementById("name").value.trim();

                if (name === "") {

                    alert("Full Name cannot be empty.");

                    return false;
                }

                return true;
            }

        </script>

    </body>

</html>