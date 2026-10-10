<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.clinicalert.dao.UserDAO" %>
<%@ page import="com.clinicalert.model.User" %>

<%
    UserDAO loginUserDAO = new UserDAO();
    List<User> loginStaffList = loginUserDAO.getAllUsers();
%>

<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>
            Login - Clinic Alert: Smart Medicine Management System
        </title>

        <link rel="stylesheet"
              href="css/style.css">

        <script>

            function togglePassword() {

                var passInput =
                        document.getElementById("password");

                var showBtn =
                        document.getElementById("showToggleBtn");

                if (passInput.type === "password") {

                    passInput.type = "text";

                    showBtn.innerText = "Hide";

                } else {

                    passInput.type = "password";

                    showBtn.innerText = "Show";

                }

            }

        </script>

    </head>

    <body
        style="
        margin: 0;
        padding: 0;
        background: #ffffff;
        ">

        <div class="login-container">

            <div class="login-left-banner">

                <div class="login-brand-box">

                    <div class="login-logo-img">

                        <svg
                            width="68"
                            height="68"
                            viewBox="0 0 64 64"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg">

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

                        <line
                            x1="40"
                            y1="41"
                            x2="46"
                            y2="41"
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

                    <div class="login-brand-title">

                        Clinic<span> Alert</span>

                    </div>

                    <div class="login-brand-subtitle">

                        Smart Medicine Management System

                    </div>

                </div>

            </div>

            <div class="login-right-form">

                <div class="login-box">

                    <h2>
                        Welcome Back!
                    </h2>

                    <p class="subtext">
                        Please login to continue
                    </p>

                    <% if (request.getAttribute("errorMessage") != null) {%>

                    <div
                        style="
                        padding: 12px 16px;
                        background-color: #FEF2F2;
                        color: #991B1B;
                        border: 1px solid #FCA5A5;
                        border-radius: 8px;
                        font-size: 13px;
                        margin-bottom: 18px;
                        "
                        >

                        <%= request.getAttribute("errorMessage")%>

                    </div>

                    <% } %>

                    <% if ("logged_out".equals(request.getParameter("msg"))) { %>

                    <div
                        style="
                        padding: 12px 16px;
                        background-color: #ECFDF5;
                        color: #065F46;
                        border: 1px solid #A7F3D0;
                        border-radius: 8px;
                        font-size: 13px;
                        margin-bottom: 18px;
                        "
                        >

                        You have successfully logged out.

                    </div>

                    <% } %>

                    <form
                        action="auth"
                        method="POST"
                        >

                        <div class="form-group">

                            <label for="staffId">
                                Staff ID
                            </label>

                            <input
                                type="text"
                                id="staffId"
                                name="staffId"
                                class="form-control"
                                placeholder="Enter Staff ID"
                                autocomplete="username"
                                required
                                >

                        </div>

                        <div class="form-group">

                            <label for="password">
                                Password
                            </label>

                            <div
                                style="
                                position: relative;
                                "
                                >

                                <input
                                    type="password"
                                    id="password"
                                    name="password"
                                    class="form-control"
                                    placeholder="Enter Password"
                                    autocomplete="current-password"
                                    required
                                    style="
                                    padding-right: 60px;
                                    "
                                    >

                                <button
                                    type="button"
                                    id="showToggleBtn"
                                    onclick="togglePassword()"
                                    style="
                                    position: absolute;
                                    right: 10px;
                                    top: 50%;
                                    transform: translateY(-50%);
                                    background: none;
                                    border: none;
                                    font-size: 12px;
                                    font-weight: 600;
                                    color: #0066FF;
                                    cursor: pointer;
                                    "
                                    >

                                    Show

                                </button>

                            </div>

                        </div>

                        <div
                            style="
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            margin-top: 14px;
                            margin-bottom: 24px;
                            font-size: 13px;
                            "
                            >

                            <label
                                style="
                                display: flex;
                                align-items: center;
                                gap: 8px;
                                cursor: pointer;
                                color: #475569;
                                "
                                >

                                <input
                                    type="checkbox"
                                    name="rememberMe"
                                    style="
                                    accent-color: #0066FF;
                                    "
                                    >

                                Remember me

                            </label>

                            <a
                                href="#"
                                onclick="return false;"
                                style="
                                color: #0066FF;
                                text-decoration: none;
                                font-weight: 500;
                                "
                                >

                                Forgot Password?

                            </a>

                        </div>

                        <button
                            type="submit"
                            class="btn-primary"
                            style="
                            width: 100%;
                            justify-content: center;
                            padding: 12px;
                            font-size: 14px;
                            letter-spacing: 0.5px;
                            "
                            >

                            LOGIN

                        </button>

                    </form>

                    <div class="sample-ids-box">

                        <strong>
                            Staff Login
                        </strong>

                        <div
                            style="
                            margin-top: 4px;
                            display: flex;
                            flex-direction: column;
                            gap: 2px;
                            "
                            >

                            <%
                                if (loginStaffList != null && !loginStaffList.isEmpty()) {
                                    for (User staff : loginStaffList) {
                                        if (staff == null || staff.getStaffId() == null || staff.getStaffId().trim().isEmpty()) {
                                            continue;
                                        }
                            %>

                            <span>
                                <strong>
                                    <%= staff.getStaffId()%>
                                </strong>

                                - <%= staff.getName()%>
                                <% if (staff.getRole() != null && !staff.getRole().trim().isEmpty()) {%>
                                (<%= staff.getRole()%>)
                                <% } %>
                            </span>

                            <%
                                }
                            } else {
                            %>

                            <span>
                                No staff accounts available.
                            </span>

                            <%
                                }
                            %>

                        </div>

                    </div>

                </div>

            </div>

        </div>

    </div>

</body>

</html>