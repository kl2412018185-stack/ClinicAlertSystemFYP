<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.clinicalert.model.*" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String staffName = currentUser.getName();
        String userRole = currentUser.getRole();

        if (staffName == null || staffName.trim().isEmpty()) {
            staffName = "User";
        }

        if (userRole == null || userRole.trim().isEmpty()) {
            userRole = "Staff";
        }

        boolean isDoctor = "Doctor".equalsIgnoreCase(currentUser.getRole());
        boolean isAdmin = currentUser.isAdministrative();

    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<RestockOrder> orders = (List<RestockOrder>) request.getAttribute("orders");
    RestockOrder po = (RestockOrder) request.getAttribute("purchaseOrder");
    String pre = request.getParameter("medicineId");
    String msg = request.getParameter("msg");
    String err = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1.0">
        <title>Restock Orders - Clinic Alert System</title>
        <link rel="stylesheet" href="css/style.css">
        <style>
            .restock-grid{
                display:grid;
                grid-template-columns:repeat(2,1fr);
                gap:20px;
                margin-bottom:20px
            }
            .restock-card{
                background:#FFFFFF;
                border:1px solid var(--border-color);
                border-radius:12px;
                padding:22px;
                box-shadow:var(--shadow-card)
            }
            .restock-card h3{
                font-size:15px;
                font-weight:700;
                color:var(--text-dark);
                margin:0 0 18px;
                padding-bottom:12px;
                border-bottom:1px solid var(--border-light)
            }
            .form-row{
                display:grid;
                grid-template-columns:repeat(2,1fr);
                gap:16px;
                margin-bottom:2px
            }
            .form-group{
                display:flex;
                flex-direction:column;
                gap:6px;
                margin-bottom:14px
            }
            .form-group label{
                font-size:12.5px;
                font-weight:600;
                color:var(--text-dark)
            }
            .form-control{
                width:100%;
                box-sizing:border-box;
                padding:9px 12px;
                font-size:13px;
                border:1px solid var(--border-color);
                border-radius:8px;
                background:#FFFFFF;
                color:var(--text-dark);
                outline:none
            }
            .form-control:focus{
                border-color:var(--primary-blue);
                box-shadow:0 0 0 3px rgba(0,102,255,.1)
            }
            .item-row{
                display:grid;
                grid-template-columns:2fr .7fr .8fr 32px;
                gap:8px;
                margin-bottom:9px
            }
            .remove-item{
                border:0;
                background:#FEE2E2;
                color:#991B1B;
                border-radius:7px;
                cursor:pointer
            }
            .add-item{
                border:1px dashed var(--border-color);
                background:#F8FAFC;
                color:var(--text-dark);
                padding:9px 12px;
                border-radius:8px;
                cursor:pointer;
                font-size:13px;
                font-weight:600
            }
            .notice{
                padding:11px 14px;
                border-radius:8px;
                margin-bottom:15px;
                font-size:13px;
                font-weight:500
            }
            .success{
                background:#ECFDF5;
                color:#047857
            }
            .error{
                background:#FEF2F2;
                color:#B91C1C
            }
            .status{
                display:inline-block;
                padding:5px 9px;
                border-radius:999px;
                font-size:11px;
                font-weight:700
            }
            .pending{
                background:#FEF3C7;
                color:#92400E
            }
            .approved{
                background:#DCFCE7;
                color:#166534
            }
            .rejected{
                background:#FEE2E2;
                color:#991B1B
            }
            .ordered{
                background:#DBEAFE;
                color:#1D4ED8
            }
            .action{
                display:flex;
                gap:6px;
                flex-wrap:wrap;
                align-items:center
            }
            .small{
                border:0;
                border-radius:8px;
                padding:7px 10px;
                font-size:12px;
                font-weight:600;
                text-decoration:none;
                cursor:pointer
            }
            .approve{
                background:#DCFCE7;
                color:#166534
            }
            .reject{
                background:#FEE2E2;
                color:#991B1B
            }
            .po{
                background:#E0F2FE;
                color:#0369A1
            }
            .order{
                background:#DBEAFE;
                color:#1D4ED8
            }
            .po-page{
                background:#FFFFFF;
                max-width:900px;
                margin:auto;
                padding:40px;
                border:1px solid var(--border-color);
                border-radius:12px;
                box-shadow:var(--shadow-card)
            }
            .po-head{
                display:flex;
                justify-content:space-between;
                border-bottom:2px solid #0F172A;
                padding-bottom:18px
            }
            .po-title{
                font-size:28px;
                font-weight:800
            }
            .po-table{
                width:100%;
                border-collapse:collapse;
                margin-top:25px
            }
            .po-table th,.po-table td{
                border:1px solid #CBD5E1;
                padding:9px
            }
            .po-table th{
                background:#F8FAFC
            }
            .po-total{
                text-align:right;
                font-weight:800;
                margin-top:18px
            }
            @media(max-width:900px){
                .restock-grid,.form-row{
                    grid-template-columns:1fr
                }
                .item-row{
                    grid-template-columns:1fr 1fr 1fr 32px
                }
            }
            @media print{
                .sidebar,.top-navbar,.no-print{
                    display:none!important
                }
                .content-container{
                    padding:0!important
                }
                .po-page{
                    border:0
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
                        <circle cx="16" cy="18" r="7" fill="#10B981"/>
                        </svg>
                    </div>
                    <div class="brand-titles">
                        <h1>Clinic<span class="highlight"> Alert</span>
                        </h1>
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
                       class="nav-link active">

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
                        <h2>Restock Orders</h2>
                    </div>
                    <div class="user-profile-badge">
                        <div class="user-avatar-circle">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                        </div>
                        <span>
                            <%=staffName%> (<%=userRole%>)
                        </span>
                    </div>
                </header>
                <div class="content-container">
                    <% if ("created".equals(msg)) {%>
                    <div class="notice success">Restock request submitted. Waiting for Doctor approval.</div>
                    <%}
                        if ("approved".equals(msg)) {%>
                    <div class="notice success">Restock request approved.</div>
                    <%}
                        if ("rejected".equals(msg)) {%>
                    <div class="notice success">Restock request rejected.</div>
                    <%}
                        if ("ordered".equals(msg)) {%>
                    <div class="notice success">Purchase Order marked as Ordered.</div>
                    <%}
                        if (err != null) {%>
                    <div class="notice error">
                        <%=err%>
                    </div>
                    <% } %>
                    <% if (po != null) {%>
                    <div class="no-print" style="margin-bottom:12px">
                        <a class="small po" href="<%=request.getContextPath()%>/restock">← Back</a> <button class="small order" onclick="window.print()">Print Purchase Order</button>
                    </div>
                    <div class="po-page">
                        <div class="po-head">
                            <div>
                                <div class="po-title">PURCHASE ORDER</div>
                                <div>Clinic Alert: Smart Medicine Management System</div>
                            </div>
                            <div style="text-align:right">PO No: <strong>
                                    <%=po.getOrderNo()%>
                                </strong>
                                <br>Order Date: <%=po.getOrderDate()%>
                                <br>Status: <%=po.getStatus()%>
                            </div>
                        </div>
                        <p>
                            <strong>Supplier:</strong> <%=po.getSupplierName()%>
                            <br>
                            <strong>Requested By:</strong> <%=po.getRequesterName()%>
                            <br>
                            <strong>Expected Delivery:</strong> <%=po.getExpectedDeliveryDate() == null ? "-" : po.getExpectedDeliveryDate()%>
                        </p>
                        <table class="po-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Medicine</th>
                                    <th>Unit</th>
                                    <th>Qty</th>
                                    <th>Unit Price</th>
                                    <th>Subtotal</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%int n = 1;
                                    for (RestockOrderItem i : po.getItems()) {%>
                                <tr>
                                    <td>
                                        <%=n++%>
                                    </td>
                                    <td>
                                        <%=i.getMedicineName()%>
                                    </td>
                                    <td>
                                        <%=i.getUnit()%>
                                    </td>
                                    <td>
                                        <%=i.getQuantity()%>
                                    </td>
                                    <td>RM <%=i.getUnitPrice()%>
                                    </td>
                                    <td>RM <%=i.getSubtotal()%>
                                    </td>
                                </tr>
                                <% }%>
                            </tbody>
                        </table>
                        <div class="po-total">Grand Total: RM <%=po.getTotalAmount()%>
                        </div>
                        <p style="margin-top:35px;font-size:12px;color:#64748B">This Purchase Order is for medicine replenishment. No online payment is processed by Clinic Alert.</p>
                    </div>
                    <% } else {%>
                    <div class="restock-grid">
                        <div class="restock-card">
                            <h3>Create Restock Request</h3>
                            <form action="<%=request.getContextPath()%>/restock" method="post">
                                <input type="hidden" name="action" value="create">
                                <div class="form-group">
                                    <label>Supplier *</label>
                                    <select name="supplierId" class="form-control" required>
                                        <option value="">Select supplier</option>
                                        <%for (Supplier s : suppliers) {%>
                                        <option value="<%=s.getSupplierId()%>">
                                            <%=s.getSupplierName()%>
                                        </option>
                                        <% }%>
                                    </select>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label>Order Date *</label>
                                        <input type="date" name="orderDate" class="form-control" value="<%=new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())%>" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Expected Delivery</label>
                                        <input type="date" name="expectedDeliveryDate" class="form-control">
                                    </div>
                                </div>
                                <label style="font-weight:600;font-size:13px">Medicine Items *</label>
                                <div id="items" style="margin-top:8px">
                                    <div class="item-row">
                                        <select name="medicineId" class="form-control" required>
                                            <option value="">Medicine</option>
                                            <%for (Medicine m : medicines) {%>
                                            <option value="<%=m.getMedicineId()%>" <%=m.getMedicineId().equals(pre) ? "selected" : ""%>>
                                                <%=m.getName()%> (Stock: <%=m.getCurrentStock()%>)</option>
                                                <% } %>
                                        </select>
                                        <input name="quantity" type="number" min="1" class="form-control" placeholder="Qty" required>
                                        <input name="unitPrice" type="number" min="0" step="0.01" class="form-control" placeholder="Price">
                                        <button type="button" class="remove-item" onclick="removeItem(this)">×</button>
                                    </div>
                                </div>
                                <button type="button" class="add-item" onclick="addItem()">+ Add Medicine</button>
                                <div style="margin-top:18px">
                                    <button class="btn-primary" type="submit">Submit for Doctor Approval</button>
                                </div>
                            </form>
                        </div>
                        <div class="restock-card">
                            <h3>Approval Flow</h3>
                            <p style="color:#64748B;line-height:1.6">All logged-in staff can create a restock request. Only a <strong>Doctor</strong> can approve or reject it.</p>
                            <p style="line-height:2">
                                <strong>1.</strong> Create Request<br>
                                <strong>2.</strong> Doctor Review<br>
                                <strong>3.</strong> Approve / Reject<br>
                                <strong>4.</strong> Generate Purchase Order<br>
                                <strong>5.</strong> Supplier receives PO externally<br>
                                <strong>6.</strong> Medicine is recorded through Stock In</p>
                        </div>
                    </div>
                    <div class="panel-card" style="margin-top:20px">
                        <div class="panel-header">
                            <h3>Restock Requests</h3>
                        </div>
                        <div class="table-responsive">
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th>PO No.</th>
                                        <th>Supplier</th>
                                        <th>Requested By</th>
                                        <th>Date</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (orders != null && !orders.isEmpty()) {
                                            for (RestockOrder o : orders) {
                                                String sc = "pending";
                                                if ("Approved".equalsIgnoreCase(o.getStatus()))
                                                    sc = "approved";
                                                else if ("Rejected".equalsIgnoreCase(o.getStatus()))
                                                    sc = "rejected";
                                                else if ("Ordered".equalsIgnoreCase(o.getStatus()))
                                                    sc = "ordered";%>
                                    <tr>
                                        <td>
                                            <strong>
                                                <%=o.getOrderNo()%>
                                            </strong>
                                        </td>
                                        <td>
                                            <%=o.getSupplierName()%>
                                        </td>
                                        <td>
                                            <%=o.getRequesterName()%>
                                        </td>
                                        <td>
                                            <%=o.getOrderDate()%>
                                        </td>
                                        <td>RM <%=o.getTotalAmount()%>
                                        </td>
                                        <td>
                                            <span class="status <%=sc%>">
                                                <%=o.getStatus()%>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="action">
                                                <a class="small po" href="<%=request.getContextPath()%>/restock?view=po&id=<%=o.getOrderId()%>">View PO</a>
                                                <% if (isDoctor && "Pending Approval".equalsIgnoreCase(o.getStatus())) {%>
                                                <form method="post">
                                                    <input type="hidden" name="action" value="approve">
                                                    <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                                                    <button class="small approve">Approve</button>
                                                </form>
                                                <form method="post">
                                                    <input type="hidden" name="action" value="reject">
                                                    <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                                                    <button class="small reject">Reject</button>
                                                </form>
                                                <%}
                                                    if ("Approved".equalsIgnoreCase(o.getStatus())) {%>
                                                <form method="post">
                                                    <input type="hidden" name="action" value="ordered">
                                                    <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                                                    <button class="small order">Mark Ordered</button>
                                                </form>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <%}
                                    } else {%>
                                    <tr>
                                        <td colspan="7" style="text-align:center;padding:30px;color:#64748B">No restock requests yet.</td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <% }%>
                </div>
            </main>
        </div>
        <jsp:include page="logout.jsp" />

        <script>
            function addItem() {
                let c = document.getElementById('items'), r = c.querySelector('.item-row').cloneNode(true);
                r.querySelectorAll('input').forEach(x => x.value = '');
                r.querySelector('select').selectedIndex = 0;
                c.appendChild(r)
            }
            function removeItem(b) {
                let r = document.querySelectorAll('#items .item-row');
                if (r.length > 1)
                    b.parentElement.remove()
            }
        </script>
    </body>
</html>
