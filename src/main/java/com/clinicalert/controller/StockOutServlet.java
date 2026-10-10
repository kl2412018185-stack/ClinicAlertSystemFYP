package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.dao.TransactionDAO;
import com.clinicalert.model.Medicine;
import com.clinicalert.model.StockTransaction;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(
        name = "StockOutServlet",
        urlPatterns = {"/stockout"}
)
public class StockOutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private MedicineDAO medicineDAO;
    private TransactionDAO transactionDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
        transactionDAO = new TransactionDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        loadPageData(request);

        request.getRequestDispatcher(
                "/stockout.jsp"
        ).forward(
                request,
                response
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        String medicineId
                = request.getParameter("medicineId");

        String batchNo
                = request.getParameter("batchNo");

        String quantityParam
                = request.getParameter("quantity");

        String unit
                = request.getParameter("unit");

        String date
                = request.getParameter("date");

        String remarks
                = request.getParameter("remarks");

        if (remarks == null || remarks.trim().isEmpty()) {
            remarks = request.getParameter("additionalRemarks");
        }

        if (remarks == null) {
            remarks = "";
        }

        String reason
                = request.getParameter("reason");

        if (reason == null || reason.trim().isEmpty()) {
            reason = "Prescription Dispense";
        }

        if (date == null
                || date.trim().isEmpty()) {
            date = LocalDate.now().toString();
        }

        // Always attribute to the logged-in user, never to a
        // client-supplied staff id or a hard-coded default.
        HttpSession session = request.getSession(false);

        String recordedBy = session == null
                ? null
                : (String) session.getAttribute("staffId");

        if (recordedBy == null
                || recordedBy.trim().isEmpty()) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );

            return;
        }

        if (medicineId == null
                || medicineId.trim().isEmpty()) {
            forwardWithError(
                    request,
                    response,
                    "Please select a medicine."
            );

            return;
        }

        if (batchNo == null
                || batchNo.trim().isEmpty()) {
            forwardWithError(
                    request,
                    response,
                    "Please select a batch."
            );

            return;
        }

        int quantity;

        try {
            quantity
                    = Integer.parseInt(
                            quantityParam
                    );
        } catch (Exception e) {
            forwardWithError(
                    request,
                    response,
                    "Please enter a valid quantity."
            );

            return;
        }

        if (quantity <= 0) {
            forwardWithError(
                    request,
                    response,
                    "Quantity must be greater than 0."
            );

            return;
        }

        Medicine med
                = medicineDAO.getMedicineById(
                        medicineId
                );

        if (med == null) {
            forwardWithError(
                    request,
                    response,
                    "Medicine not found."
            );

            return;
        }

        int batchStock
                = medicineDAO.getBatchStock(
                        medicineId,
                        batchNo
                );

        if (batchStock <= 0) {
            forwardWithError(
                    request,
                    response,
                    "Selected batch has no available stock."
            );

            return;
        }

        if (quantity > batchStock) {
            String medicineUnit
                    = med.getUnit();

            if (medicineUnit == null) {
                medicineUnit = "";
            }

            forwardWithError(
                    request,
                    response,
                    "Stock Out quantity cannot exceed "
                    + "available stock for batch "
                    + batchNo
                    + " ("
                    + batchStock
                    + " "
                    + medicineUnit
                    + ")."
            );

            return;
        }

        if (unit == null
                || unit.trim().isEmpty()) {
            unit = med.getUnit();
        }

        if (unit == null) {
            unit = "";
        }

        StockTransaction txn
                = new StockTransaction(
                        "TXN-"
                        + System.currentTimeMillis(),
                        "STK-OUT-"
                        + (int) (Math.random()
                        * 9000
                        + 1000),
                        "OUT",
                        medicineId,
                        med.getName(),
                        batchNo,
                        quantity,
                        unit,
                        date,
                        null,
                        reason,
                        remarks,
                        recordedBy
                );

        boolean transactionAdded
                = transactionDAO.addTransaction(
                        txn
                );

        if (!transactionAdded) {
            forwardWithError(
                    request,
                    response,
                    "Failed to record Stock Out transaction."
            );

            return;
        }

        boolean stockUpdated
                = medicineDAO.adjustStock(
                        medicineId,
                        -quantity
                );

        if (!stockUpdated) {
            forwardWithError(
                    request,
                    response,
                    "Stock transaction recorded, "
                    + "but stock quantity could not be updated."
            );

            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/stockout?msg=success"
        );
    }

    private void loadPageData(
            HttpServletRequest request) {
        List<Medicine> medicines
                = medicineDAO.getAllMedicines();

        request.setAttribute(
                "medicines",
                medicines
        );

        Map<String, List<MedicineDAO.StockBatch>> stockBatches
                = medicineDAO.getAllStockBatches();

        request.setAttribute(
                "stockBatches",
                stockBatches
        );

        request.setAttribute(
                "stockOutHistory",
                transactionDAO.getTransactionsByType("OUT")
        );
    }

    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws ServletException, IOException {
        request.setAttribute(
                "errorMessage",
                message
        );

        loadPageData(request);

        request.getRequestDispatcher(
                "/stockout.jsp"
        ).forward(
                request,
                response
        );
    }
}
