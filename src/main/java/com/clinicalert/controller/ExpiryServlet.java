package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.dao.TransactionDAO;
import com.clinicalert.model.StockTransaction;
import com.clinicalert.model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ExpiryServlet", urlPatterns = {"/expiry", "/expirydate"})
public class ExpiryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private TransactionDAO transactionDAO;
    private MedicineDAO medicineDAO;

    @Override
    public void init() {
        transactionDAO = new TransactionDAO();
        medicineDAO = new MedicineDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        String filter = request.getParameter("filter");

        if (filter == null || filter.trim().isEmpty()) {
            filter = "30";
        }

        List<StockTransaction> filtered =
                transactionDAO.getExpiringBatches(filter);

        request.setAttribute(
                "expiryList",
                filtered
        );

        request.setAttribute(
                "activeFilter",
                filter != null ? filter : "all"
        );

        request.getRequestDispatcher("/expiry.jsp")
                .forward(request, response);
    }

    // Records a normal Stock Out for the remaining quantity with
    // the reason "Expired - Disposed", so stock goes down and the
    // history/audit trail is kept. Admin roles only.
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null
                ? null
                : (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!user.isAdminRole()) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only admin roles can dispose of expired stock."
            );
            return;
        }

        String base = request.getContextPath() + "/expiry?filter=expired&msg=";

        if (!"dispose".equals(request.getParameter("action"))) {
            response.sendRedirect(base + "error");
            return;
        }

        String itemId = request.getParameter("itemId");
        String batchNo = request.getParameter("batchNo");

        if (itemId == null || itemId.trim().isEmpty()
                || batchNo == null || batchNo.trim().isEmpty()) {
            response.sendRedirect(base + "error");
            return;
        }

        // Work out the quantity left on the server, never trust the page
        StockTransaction target = null;
        for (StockTransaction batch : transactionDAO.getExpiringBatches("expired")) {
            if (itemId.trim().equalsIgnoreCase(batch.getMedicineId() == null ? "" : batch.getMedicineId().trim())
                    && batchNo.trim().equalsIgnoreCase(batch.getBatchNo() == null ? "" : batch.getBatchNo().trim())) {
                target = batch;
                break;
            }
        }

        if (target == null || target.getQuantity() <= 0) {
            response.sendRedirect(base + "notfound");
            return;
        }

        int quantity = target.getQuantity();
        String staffId = user.getStaffId();

        StockTransaction txn = new StockTransaction(
                "TXN-" + System.currentTimeMillis(),
                "STK-OUT-" + (int) (Math.random() * 9000 + 1000),
                "OUT",
                target.getMedicineId(),
                target.getMedicineName(),
                target.getBatchNo(),
                quantity,
                target.getUnit(),
                LocalDate.now().toString(),
                null,
                "Expired - Disposed",
                "Disposed after expiry date " + target.getExpiryDate(),
                staffId
        );

        if (!transactionDAO.addTransaction(txn)) {
            response.sendRedirect(base + "error");
            return;
        }

        if (!medicineDAO.adjustStock(target.getMedicineId(), -quantity)) {
            response.sendRedirect(base + "stockerror");
            return;
        }

        response.sendRedirect(base + "disposed");
    }
}
