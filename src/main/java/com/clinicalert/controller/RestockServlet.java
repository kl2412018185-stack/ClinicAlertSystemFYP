package com.clinicalert.controller;

import com.clinicalert.dao.*;
import com.clinicalert.model.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.*;

@WebServlet(name = "RestockServlet", urlPatterns = {"/restock"})
public class RestockServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private RestockDAO restockDAO;
    private MedicineDAO medicineDAO;

    public void init() {
        restockDAO = new RestockDAO();
        medicineDAO = new MedicineDAO();
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = getUser(req.getSession(false));
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.setAttribute("suppliers", restockDAO.getActiveSuppliers());
        req.setAttribute("medicines", medicineDAO.getAllMedicines());
        req.setAttribute("orders", restockDAO.getAllOrders());
        if ("po".equalsIgnoreCase(req.getParameter("view"))) {
            try {
                req.setAttribute("purchaseOrder", restockDAO.getOrderById(Integer.parseInt(req.getParameter("id"))));
            } catch (Exception e) {
                req.setAttribute("errorMessage", "Invalid purchase order.");
            }
        }
        req.getRequestDispatcher("/restock.jsp").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = getUser(req.getSession(false));
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String a = req.getParameter("action");
        try {
            if ("create".equals(a)) {
                create(req, u);
                resp.sendRedirect(req.getContextPath() + "/restock?msg=created");
                return;
            }
            if ("approve".equals(a) || "reject".equals(a)) {
                if (!"Doctor".equalsIgnoreCase(u.getRole())) {
                    resp.sendError(403, "Only a Doctor can approve or reject restock requests.");
                    return;
                }
                boolean ok = restockDAO.updateApproval(Integer.parseInt(req.getParameter("orderId")), Integer.parseInt(u.getId()), "approve".equals(a), req.getParameter("remarks"));
                resp.sendRedirect(req.getContextPath() + "/restock?msg=" + (ok ? ("approve".equals(a) ? "approved" : "rejected") : "notchanged"));
                return;
            }
            if ("ordered".equals(a)) {
                boolean ok = restockDAO.markOrdered(Integer.parseInt(req.getParameter("orderId")));
                resp.sendRedirect(req.getContextPath() + "/restock?msg=" + (ok ? "ordered" : "notchanged"));
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/restock");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMessage", e.getMessage() == null ? "Unable to process restock request." : e.getMessage());
            doGet(req, resp);
        }
    }

    private void create(HttpServletRequest req, User u) throws Exception {
        int supplier = Integer.parseInt(req.getParameter("supplierId"));
        Date od = Date.valueOf(req.getParameter("orderDate"));
        String ex = req.getParameter("expectedDeliveryDate");
        Date ed = ex == null || ex.trim().isEmpty() ? null : Date.valueOf(ex);
        String[] mids = req.getParameterValues("medicineId"), qs = req.getParameterValues("quantity"), ps = req.getParameterValues("unitPrice");
        if (mids == null || qs == null) {
            throw new IllegalArgumentException("Please add at least one medicine.");
        }
        List<RestockOrderItem> items = new ArrayList<>();
        for (int i = 0; i < mids.length; i++) {
            if (mids[i] == null || mids[i].trim().isEmpty()) {
                continue;
            }
            RestockOrderItem it = new RestockOrderItem();
            it.setMedicineId(mids[i].trim());
            it.setQuantity(Integer.parseInt(qs[i]));
            String pr = ps != null && i < ps.length ? ps[i] : "0";
            it.setUnitPrice(new BigDecimal(pr == null || pr.trim().isEmpty() ? "0" : pr));
            items.add(it);
        }
        restockDAO.createOrder(supplier, Integer.parseInt(u.getId()), od, ed, items);
    }

    private User getUser(HttpSession s) {
        return s == null ? null : (User) s.getAttribute("currentUser");
    }
}
