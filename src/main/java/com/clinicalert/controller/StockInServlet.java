package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.dao.RestockDAO;
import com.clinicalert.dao.TransactionDAO;
import com.clinicalert.model.Medicine;
import com.clinicalert.model.StockTransaction;
import com.clinicalert.model.User;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "StockInServlet", urlPatterns = {"/stockin"})
public class StockInServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private MedicineDAO medicineDAO;
    private TransactionDAO transactionDAO;
    private RestockDAO restockDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
        transactionDAO = new TransactionDAO();
        restockDAO = new RestockDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("currentUser") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        request.setAttribute(
                "medicines",
                medicineDAO.getAllMedicines()
        );

        request.setAttribute(
                "stockInHistory",
                transactionDAO.getTransactionsByType("IN")
        );

        request.setAttribute(
                "batches",
                medicineDAO.getBatchSummaries()
        );

        request.setAttribute(
                "suppliers",
                restockDAO.getActiveSuppliers()
        );

        request.getRequestDispatcher("/stockin.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("currentUser") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }

        User currentUser
                = (User) session.getAttribute("currentUser");

        if ("deleteBatch".equals(request.getParameter("action"))) {
            if (!currentUser.isAdminRole()) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Only admin roles can delete a batch."
                );
                return;
            }

            boolean deleted = medicineDAO.deleteBatch(
                    request.getParameter("itemId"),
                    request.getParameter("batchNo")
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/stockin?msg="
                    + (deleted ? "batchdeleted" : "batcherror")
            );
            return;
        }

        String recordedBy = currentUser.getStaffId();

        if (recordedBy == null
                || recordedBy.trim().isEmpty()) {
            request.setAttribute(
                    "errorMessage",
                    "Unable to identify the logged-in user."
            );

            loadStockInPage(request, response);

            return;
        }

        String medicineId
                = request.getParameter("medicineId");

        String batchNo
                = request.getParameter("batchNo");

        String quantityParam
                = request.getParameter("quantity");

        String unit
                = request.getParameter("unit");

        String supplier
                = request.getParameter("supplier");

        String receivedDate
                = request.getParameter("receivedDate");

        String expiryDate
                = request.getParameter("expiryDate");

        String remarks
                = request.getParameter("remarks");

        if (medicineId == null
                || medicineId.trim().isEmpty()) {
            request.setAttribute(
                    "errorMessage",
                    "Please select a medicine."
            );

            loadStockInPage(request, response);

            return;
        }

        int quantity;

        try {
            quantity = Integer.parseInt(quantityParam);
        } catch (Exception e) {
            request.setAttribute(
                    "errorMessage",
                    "Please enter a valid quantity."
            );

            loadStockInPage(request, response);

            return;
        }

        if (quantity <= 0) {
            request.setAttribute(
                    "errorMessage",
                    "Quantity must be greater than 0."
            );

            loadStockInPage(request, response);

            return;
        }

        Medicine med
                = medicineDAO.getMedicineById(medicineId);

        if (med == null) {
            request.setAttribute(
                    "errorMessage",
                    "Medicine not found."
            );

            loadStockInPage(request, response);

            return;
        }

        String medName = med.getName();

        StockTransaction txn
                = new StockTransaction(
                        "TXN-"
                        + System.currentTimeMillis(),
                        "STK-IN-"
                        + (int) (Math.random() * 9000 + 1000),
                        "IN",
                        medicineId,
                        medName,
                        batchNo,
                        quantity,
                        unit,
                        receivedDate,
                        expiryDate,
                        supplier,
                        remarks,
                        recordedBy
                );

        boolean transactionAdded
                = transactionDAO.addTransaction(txn);

        if (!transactionAdded) {
            request.setAttribute(
                    "errorMessage",
                    "Failed to record Stock In transaction."
            );

            loadStockInPage(request, response);

            return;
        }

        boolean stockUpdated
                = medicineDAO.adjustStock(
                        medicineId,
                        quantity
                );

        if (!stockUpdated) {
            request.setAttribute(
                    "errorMessage",
                    "Stock transaction recorded, "
                    + "but stock quantity could not be updated."
            );

            loadStockInPage(request, response);

            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/stockin?msg=success"
        );
    }

    private void loadStockInPage(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute(
                "medicines",
                medicineDAO.getAllMedicines()
        );

        request.setAttribute(
                "stockInHistory",
                transactionDAO.getTransactionsByType("IN")
        );

        request.setAttribute(
                "batches",
                medicineDAO.getBatchSummaries()
        );

        request.setAttribute(
                "suppliers",
                restockDAO.getActiveSuppliers()
        );

        request.getRequestDispatcher("/stockin.jsp")
                .forward(request, response);
    }
}
