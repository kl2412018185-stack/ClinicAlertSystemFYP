<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.clinicalert.model.User" %>
<%@ page import="java.util.List" %>

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
    List<User> userList = (List<User>) request.getAttribute("userList");
%>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>User Management - Clinic Alert System</title>
        <link rel="stylesheet" href="css/style.css">

        <script>
            function openAddUserModal() {
                document.getElementById("userModalTitle").innerText = "Add New User";
                document.getElementById("userForm").reset();
                document.getElementById("userModal").style.display = "flex";
            }

            function openEditUserModal(id, staffId, name, role, status) {
                document.getElementById("userModalTitle").innerText = "Edit User";
                document.getElementById("staffIdInput").value = staffId;
                document.getElementById("userNameInput").value = name;
                document.getElementById("userRoleInput").value = role;
                document.getElementById("userStatusInput").value = status;
                document.getElementById("userModal").style.display = "flex";
            }

            function closeUserModal() {
                document.getElementById("userModal").style.display = "none";
            }

            function deactivateUser(staffId) {
                if (confirm("Are you sure you want to deactivate user?")) {
                    window.location.href =
                            "<%= request.getContextPath()%>/users/toggle?id="
                            + encodeURIComponent(staffId);
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
                        <h1>Clinic <span class="highlight">Alert</span></h1>
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

                    <a href="<%= request.getContextPath()%>/reports" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">
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

                    <a href="<%= request.getContextPath()%>/profile" class="nav-link">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <span>Profile</span>
                        </div>
                        <span class="chevron-icon">&rsaquo;</span>
                    </a>

                    <% if (isAdmin) {%>
                    <a href="<%= request.getContextPath()%>/usermanagement" class="nav-link active">
                        <div class="nav-link-content">
                            <svg viewBox="0 0 24 24"
                                 fill="none"
                                 stroke="currentColor"
                                 stroke-width="2"
                                 stroke-linecap="round"
                                 stroke-linejoin="round">
                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                            <circle cx="9" cy="7" r="4"></circle>
                            <path d="M22 21v-2a2 2 0 0 0-3-3.87"></path>
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
                        <h2>User Management</h2>
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
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                        </div>

                        <span>
                            <%= staffName%> (<%= userRole%>)
                        </span>

                    </div>

                </header>


                <div class="content-container">

                    <div class="panel-card">

                        <div class="panel-header">

                            <h3>System Users</h3>

                            <button
                                class="btn-primary"
                                type="button"
                                onclick="openAddUserModal()">
                                + Add User
                            </button>

                        </div>


                        <div class="table-responsive">

                            <table class="custom-table">

                                <thead>

                                    <tr>
                                        <th style="width:50px;">No.</th>
                                        <th>Staff ID</th>
                                        <th>Full Name</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th style="text-align:center; width:100px;">
                                            Action
                                        </th>
                                    </tr>

                                </thead>


                                <tbody>

                                    <%
                                        if (userList != null && !userList.isEmpty()) {

                                            int no = 1;

                                            for (User systemUser : userList) {

                                                String safeName
                                                        = systemUser.getName() != null
                                                        ? systemUser.getName()
                                                                .replace("\\", "\\\\")
                                                                .replace("'", "\\'")
                                                        : "";

                                                String safeStaffId
                                                        = systemUser.getStaffId() != null
                                                        ? systemUser.getStaffId()
                                                                .replace("\\", "\\\\")
                                                                .replace("'", "\\'")
                                                        : "";

                                                String safeRole
                                                        = systemUser.getRole() != null
                                                        ? systemUser.getRole()
                                                                .replace("\\", "\\\\")
                                                                .replace("'", "\\'")
                                                        : "";

                                                String safeStatus
                                                        = systemUser.getStatus() != null
                                                        ? systemUser.getStatus()
                                                                .replace("\\", "\\\\")
                                                                .replace("'", "\\'")
                                                        : "";
                                    %>

                                    <tr>

                                        <td>
                                            <%= no++%>
                                        </td>

                                        <td>
                                            <strong>
                                                <%= systemUser.getStaffId()%>
                                            </strong>
                                        </td>

                                        <td>
                                            <%= systemUser.getName()%>
                                        </td>

                                        <td>
                                            <%= systemUser.getRole()%>
                                        </td>

                                        <td>

                                            <span class="badge <%= "Active".equalsIgnoreCase(systemUser.getStatus()) ? "active" : "inactive"%>">

                                                <span class="badge-dot"></span>

                                                <%= systemUser.getStatus()%>

                                            </span>

                                        </td>

                                        <td style="text-align:center;">

                                            <div class="action-group"
                                                 style="justify-content:center;">

                                                <button
                                                    type="button"
                                                    class="icon-btn edit"
                                                    onclick="openEditUserModal(
                                                            '<%= systemUser.getId()%>',
                                                            '<%= safeStaffId%>',
                                                            '<%= safeName%>',
                                                            '<%= safeRole%>',
                                                            '<%= safeStatus%>'
                                                            )">

                                                    <svg width="14"
                                                         height="14"
                                                         viewBox="0 0 24 24"
                                                         fill="none"
                                                         stroke="currentColor"
                                                         stroke-width="2">

                                                    <path d="M12 20h9"></path>

                                                    <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>

                                                    </svg>

                                                </button>


                                                <button
                                                    type="button"
                                                    class="icon-btn delete"
                                                    title="<%= "Active".equalsIgnoreCase(systemUser.getStatus()) ? "Deactivate User" : "Activate User"%>"
                                                    onclick="deactivateUser('<%= safeStaffId%>')">

                                                    <svg width="14"
                                                         height="14"
                                                         viewBox="0 0 24 24"
                                                         fill="none"
                                                         stroke="currentColor"
                                                         stroke-width="2">

                                                    <polyline points="3 6 5 6 21 6"></polyline>

                                                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>

                                                    </svg>

                                                </button>

                                            </div>

                                        </td>

                                    </tr>

                                    <%
                                        }

                                    } else {
                                    %>

                                    <tr>

                                        <td colspan="6"
                                            style="text-align:center; padding:30px; color:#64748b;">

                                            No users found.

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


        <div id="userModal"
             class="modal-backdrop"
             style="display:none;">

            <div class="modal-card">

                <div class="modal-header">

                    <h3 id="userModalTitle">
                        Add New User
                    </h3>

                    <button
                        type="button"
                        class="modal-close"
                        onclick="closeUserModal()">
                        &times;
                    </button>

                </div>


                <form
                    id="userForm"
                    action="<%= request.getContextPath()%>/usermanagement"
                    method="POST">

                    <div class="modal-body">

                        <div class="form-grid-2">

                            <div class="form-group">

                                <label>
                                    Staff ID
                                    <span class="required">*</span>
                                </label>

                                <input
                                    type="text"
                                    id="staffIdInput"
                                    name="staffId"
                                    class="form-control"
                                    placeholder="e.g. CA003"
                                    required>

                            </div>


                            <div class="form-group">

                                <label>
                                    Full Name
                                    <span class="required">*</span>
                                </label>

                                <input
                                    type="text"
                                    id="userNameInput"
                                    name="name"
                                    class="form-control"
                                    placeholder="Enter full name"
                                    required>

                            </div>

                        </div>


                        <div class="form-grid-2">

                            <div class="form-group">

                                <label>
                                    Role
                                    <span class="required">*</span>
                                </label>

                                <select
                                    id="userRoleInput"
                                    name="role"
                                    class="form-control"
                                    required>

                                    <option value="">
                                        Select role
                                    </option>

                                    <option value="Admin">
                                        Admin
                                    </option>

                                    <option value="Doctor">
                                        Doctor
                                    </option>

                                    <option value="Senior Assistant">
                                        Senior Assistant
                                    </option>

                                    <option value="Assistant">
                                        Assistant
                                    </option>

                                </select>

                            </div>


                            <div class="form-group">

                                <label>
                                    Password
                                    <span class="required">*</span>
                                </label>

                                <input
                                    type="password"
                                    name="password"
                                    class="form-control"
                                    placeholder="Enter password"
                                    required>

                            </div>

                        </div>


                        <div class="form-group">

                            <label>
                                Status
                            </label>

                            <select
                                id="userStatusInput"
                                name="status"
                                class="form-control">

                                <option value="Active">
                                    Active
                                </option>

                                <option value="Inactive">
                                    Inactive
                                </option>

                            </select>

                        </div>

                    </div>


                    <div class="modal-footer">

                        <button
                            type="button"
                            class="btn-secondary"
                            onclick="closeUserModal()">
                            Cancel
                        </button>

                        <button
                            type="submit"
                            class="btn-primary">
                            Save
                        </button>

                    </div>

                </form>

            </div>

        </div>


        <jsp:include page="logout.jsp" />

    </body>

</html>