<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.clinicalert.model.User" %>

<%
    User user = (User) session.getAttribute("currentUser");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    boolean isAdmin = user.isAdministrative();

    String staffName = user.getName();
    String userRole = user.getRole();

    if (staffName == null || staffName.trim().isEmpty()) {
        staffName = "User";
    }

    if (userRole == null || userRole.trim().isEmpty()) {
        userRole = "Staff";
    }

    String successMessage
            = (String) request.getAttribute("successMessage");

    String errorMessage
            = (String) request.getAttribute("errorMessage");

    Boolean passwordMismatch
            = (Boolean) request.getAttribute("passwordMismatch");
%>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Change Password - Clinic Alert System</title>
        <link rel="stylesheet" href="css/style.css">
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

                    <a href="<%= request.getContextPath()%>/dashboard" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="7" height="7"></rect>
                            <rect x="14" y="3" width="7" height="7"></rect>
                            <rect x="14" y="14" width="7" height="7"></rect>
                            <rect x="3" y="14" width="7" height="7"></rect>
                            </svg>
                            <span>Dashboard</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/medicine" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"></path>
                            <path d="m8.5 8.5 7 7"></path>
                            </svg>
                            <span>Medicine</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/stockin" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 3v12"></path>
                            <path d="m8 11 4 4 4-4"></path>
                            <path d="M8 5H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-4"></path>
                            </svg>
                            <span>Stock In</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/stockout" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 21V9"></path>
                            <path d="m16 13-4-4-4 4"></path>
                            <path d="M16 19h4a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h4"></path>
                            </svg>
                            <span>Stock Out</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/lowstock" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path>
                            <line x1="12" y1="9" x2="12" y2="13"></line>
                            <line x1="12" y1="17" x2="12.01" y2="17"></line>
                            </svg>
                            <span>Low Stock Alert</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/expiry" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"></circle>
                            <polyline points="12 6 12 12 16 14"></polyline>
                            </svg>
                            <span>Expiry Alert</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/restock" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="8" cy="21" r="1"></circle>
                            <circle cx="19" cy="21" r="1"></circle>
                            <path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"></path>
                            </svg>
                            <span>Restock Orders</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/reports" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                            <polyline points="14 2 14 8 20 8"></polyline>
                            <line x1="16" y1="13" x2="8" y2="13"></line>
                            <line x1="16" y1="17" x2="8" y2="17"></line>
                            <polyline points="10 9 9 9 8 9"></polyline>
                            </svg>
                            <span>Reports</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <a href="<%= request.getContextPath()%>/profile" class="nav-link active">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <span>Profile</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <% if (isAdmin) {%>

                    <a href="<%= request.getContextPath()%>/usermanagement" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                            <circle cx="9" cy="7" r="4"></circle>
                            <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>
                            <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
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
                        style="
                        width:auto !important;
                        min-width:0 !important;
                        height:40px !important;
                        padding:8px 14px !important;
                        margin:0 auto !important;
                        display:flex !important;
                        align-items:center !important;
                        justify-content:center !important;
                        gap:8px !important;
                        font-size:13px !important;
                        line-height:1 !important;
                        border-radius:8px !important;
                        "
                        >

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            width="18"
                            height="18"
                            style="
                            width:18px !important;
                            height:18px !important;
                            flex:0 0 18px !important;
                            "
                            >
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
                        <h2>Change Password</h2>
                    </div>

                    <div class="user-profile-badge">

                        <div class="user-avatar-circle">

                            <svg
                                width="14"
                                height="14"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                                >
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>

                        </div>

                        <span>
                            <%= user.getName()%>
                            (<%= user.getRole()%>)
                        </span>
                    </div>

                </header>

                <div class="content-container">

                    <div style="
                         display:grid;
                         grid-template-columns:minmax(0, 1.35fr) minmax(260px, 0.75fr);
                         gap:20px;
                         align-items:start;
                         ">

                        <div class="panel-card">

                            <div class="panel-header">
                                <h3>Update Your Password</h3>
                            </div>

                            <div style="
                                 padding-top:4px;
                                 margin-bottom:20px;
                                 color:#64748B;
                                 font-size:13px;
                                 line-height:1.5;
                                 ">
                                Keep your account secure by updating your password regularly.
                            </div>

                            <form id="changePasswordForm" action="changepassword" method="POST">

                                <div class="form-group">

                                    <label>
                                        Current Password
                                        <span class="required">*</span>
                                    </label>

                                    <input
                                        type="password"
                                        id="currentPassword"
                                        name="currentPassword"
                                        class="form-control"
                                        placeholder="Enter current password"
                                        required
                                        >

                                </div>

                                <div class="form-group">

                                    <label>
                                        New Password
                                        <span class="required">*</span>
                                    </label>

                                    <input
                                        type="password"
                                        id="newPassword"
                                        name="newPassword"
                                        class="form-control"
                                        placeholder="Enter new password"
                                        required
                                        >

                                </div>

                                <div class="form-group">

                                    <label>
                                        Confirm New Password
                                        <span class="required">*</span>
                                    </label>

                                    <input
                                        type="password"
                                        id="confirmPassword"
                                        name="confirmPassword"
                                        class="form-control"
                                        placeholder="Confirm new password"
                                        required
                                        >

                                    <div
                                        id="passwordMismatchMessage"
                                        style="
                                        display:none;
                                        color:#EF4444;
                                        font-size:12px;
                                        margin-top:6px;
                                        font-weight:500;
                                        "
                                        >
                                        * Password not match
                                    </div>

                                </div>

                                <div style="
                                     display:flex;
                                     justify-content:flex-end;
                                     margin-top:-8px;
                                     margin-bottom:4px;
                                     ">
                                    <button
                                        type="button"
                                        id="toggleAllPasswordsBtn"
                                        onclick="toggleAllPasswords()"
                                        style="
                                        border:none;
                                        background:none;
                                        color:#2563EB;
                                        font-size:12px;
                                        font-weight:600;
                                        cursor:pointer;
                                        padding:4px 0;
                                        "
                                        >
                                        Show All
                                    </button>
                                </div>

                                <div style="
                                     display:flex;
                                     gap:12px;
                                     margin-top:24px;
                                     ">

                                    <a
                                        href="profile"
                                        class="btn-secondary"
                                        style="text-decoration:none;"
                                        >
                                        Cancel
                                    </a>

                                    <button
                                        type="submit"
                                        class="btn-primary"
                                        >
                                        Update Password
                                    </button>

                                </div>

                            </form>

                        </div>

                        <div
                            class="panel-card"
                            style="
                            padding:0;
                            overflow:hidden;
                            "
                            >

                            <div style="
                                 padding:18px 20px;
                                 border-bottom:1px solid #E8EDF2;
                                 display:flex;
                                 align-items:center;
                                 gap:12px;
                                 ">

                                <div style="
                                     width:38px;
                                     height:38px;
                                     border-radius:10px;
                                     background:#EFF6FF;
                                     color:#2563EB;
                                     display:flex;
                                     align-items:center;
                                     justify-content:center;
                                     ">

                                    <svg
                                        width="20"
                                        height="20"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        >
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                    <path d="m9 12 2 2 4-4"></path>
                                    </svg>

                                </div>

                                <div>

                                    <h3 style="
                                        margin:0;
                                        font-size:15px;
                                        color:#173149;
                                        ">
                                        Password Security
                                    </h3>

                                    <p style="
                                       margin:3px 0 0;
                                       font-size:11.5px;
                                       color:#94A3B8;
                                       ">
                                        Recommended account practices
                                    </p>

                                </div>

                            </div>

                            <div style="padding:20px;">

                                <div style="
                                     display:flex;
                                     gap:11px;
                                     margin-bottom:18px;
                                     ">

                                    <div style="
                                         width:8px;
                                         height:8px;
                                         min-width:8px;
                                         border-radius:50%;
                                         background:#10B981;
                                         margin-top:5px;
                                         "></div>

                                    <div>

                                        <strong style="
                                                display:block;
                                                color:#334155;
                                                font-size:12.5px;
                                                ">
                                            Use at least 6 characters
                                        </strong>

                                        <span style="
                                              display:block;
                                              margin-top:3px;
                                              color:#7B8B9A;
                                              font-size:11.5px;
                                              line-height:1.45;
                                              ">
                                            Choose a password that is not easy to guess.
                                        </span>

                                    </div>

                                </div>

                                <div style="
                                     display:flex;
                                     gap:11px;
                                     margin-bottom:18px;
                                     ">

                                    <div style="
                                         width:8px;
                                         height:8px;
                                         min-width:8px;
                                         border-radius:50%;
                                         background:#10B981;
                                         margin-top:5px;
                                         "></div>

                                    <div>

                                        <strong style="
                                                display:block;
                                                color:#334155;
                                                font-size:12.5px;
                                                ">
                                            Avoid reused passwords
                                        </strong>

                                        <span style="
                                              display:block;
                                              margin-top:3px;
                                              color:#7B8B9A;
                                              font-size:11.5px;
                                              line-height:1.45;
                                              ">
                                            Use a password that is different from other accounts.
                                        </span>

                                    </div>

                                </div>

                                <div style="
                                     display:flex;
                                     gap:11px;
                                     ">

                                    <div style="
                                         width:8px;
                                         height:8px;
                                         min-width:8px;
                                         border-radius:50%;
                                         background:#10B981;
                                         margin-top:5px;
                                         "></div>

                                    <div>

                                        <strong style="
                                                display:block;
                                                color:#334155;
                                                font-size:12.5px;
                                                ">
                                            Keep your password private
                                        </strong>

                                        <span style="
                                              display:block;
                                              margin-top:3px;
                                              color:#7B8B9A;
                                              font-size:11.5px;
                                              line-height:1.45;
                                              ">
                                            Never share your password with other users.
                                        </span>

                                    </div>

                                </div>

                            </div>

                        </div>

                    </div>

                </div>

            </main>

        </div>

        <jsp:include page="logout.jsp" />

        <script>

            function toggleAllPasswords() {

                const passwordFields = [
                    document.getElementById("currentPassword"),
                    document.getElementById("newPassword"),
                    document.getElementById("confirmPassword")
                ];

                const button =
                        document.getElementById("toggleAllPasswordsBtn");

                const shouldShow = passwordFields.some(
                        function (field) {
                            return field && field.type === "password";
                        }
                );

                passwordFields.forEach(function (field) {

                    if (field) {
                        field.type =
                                shouldShow ? "text" : "password";
                    }

                });

                button.textContent =
                        shouldShow ? "Hide All" : "Show All";
            }


            document.addEventListener(
                    "DOMContentLoaded",
                    function () {

                        const newPassword =
                                document.getElementById(
                                        "newPassword"
                                        );

                        const confirmPassword =
                                document.getElementById(
                                        "confirmPassword"
                                        );

                        const mismatchMessage =
                                document.getElementById(
                                        "passwordMismatchMessage"
                                        );

                        const form =
                                document.getElementById(
                                        "changePasswordForm"
                                        );


                        function checkPasswordMatch() {

                            if (confirmPassword.value === "") {

                                mismatchMessage.style.display =
                                        "none";

                                return true;
                            }


                            if (
                                    newPassword.value
                                    !==
                                    confirmPassword.value
                                    ) {

                                mismatchMessage.style.display =
                                        "block";

                                return false;
                            }


                            mismatchMessage.style.display =
                                    "none";

                            return true;
                        }


                        newPassword.addEventListener(
                                "input",
                                checkPasswordMatch
                                );


                        confirmPassword.addEventListener(
                                "input",
                                checkPasswordMatch
                                );


                        form.addEventListener(
                                "submit",
                                function (event) {

                                    if (!checkPasswordMatch()) {

                                        event.preventDefault();

                                        confirmPassword.focus();
                                    }

                                }
                        );

                    }
            );

        </script>


        <%
            String msg
                    = request.getParameter("msg");

            if ("success".equals(msg)) {
        %>

        <script>
            alert("Password changed successfully.");
        </script>

        <%
            }
        %>


        <%
            if (errorMessage != null) {
        %>

        <script>
            alert("<%= errorMessage%>");
        </script>

        <%
            }
        %>


        <%
            if (Boolean.TRUE.equals(passwordMismatch)) {
        %>

        <script>

            document.addEventListener(
                    "DOMContentLoaded",
                    function () {

                        const mismatchMessage =
                                document.getElementById(
                                        "passwordMismatchMessage"
                                        );

                        if (mismatchMessage) {

                            mismatchMessage.style.display =
                                    "block";
                        }

                    }
            );

        </script>

        <%
            }
        %>

    </body>

</html>
