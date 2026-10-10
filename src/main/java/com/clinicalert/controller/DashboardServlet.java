package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.dao.TransactionDAO;
import com.clinicalert.model.Medicine;
import com.clinicalert.model.StockTransaction;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private MedicineDAO medicineDAO;
    private TransactionDAO transactionDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
        transactionDAO = new TransactionDAO();
    }

    // Turns expiring/expired batch rows into Medicine objects for the JSP
    private List<Medicine> toMedicines(List<StockTransaction> batches) {
        List<Medicine> result = new ArrayList<>();
        for (StockTransaction batch : batches) {
            Medicine m = new Medicine();
            m.setMedicineId(batch.getMedicineId());
            m.setName(batch.getMedicineName());
            m.setBatchNo(batch.getBatchNo());
            m.setUnit(batch.getUnit());
            m.setCurrentStock(batch.getQuantity());
            m.setExpiryDate(batch.getExpiryDate());
            result.add(m);
        }
        return result;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        List<Medicine> allMedicines =
                medicineDAO.getAllMedicines();

        List<Medicine> lowStockMedicines =
                medicineDAO.getLowStockMedicines();

        List<StockTransaction> expiringBatches =
                transactionDAO.getExpiringBatches("30");

        List<Medicine> expiringMedicines = toMedicines(expiringBatches);

        // Batches already past their expiry date that still have stock
        List<Medicine> expiredMedicines
                = toMedicines(transactionDAO.getExpiringBatches("expired"));

        int totalCount =
                allMedicines.size();

        int lowStockCount =
                lowStockMedicines.size();

        int expiringCount =
                expiringBatches.size();

        int stockInToday =
                transactionDAO.getTodayStockInCount();

        int stockOutToday =
                transactionDAO.getTodayStockOutCount();

        request.setAttribute(
                "totalMedicines",
                totalCount
        );

        request.setAttribute(
                "lowStockCount",
                lowStockCount
        );

        request.setAttribute(
                "expiringCount",
                expiringCount
        );

        request.setAttribute(
                "stockInToday",
                stockInToday
        );

        request.setAttribute(
                "stockOutToday",
                stockOutToday
        );

        request.setAttribute(
                "medicines",
                allMedicines
        );

        request.setAttribute(
                "lowStockList",
                lowStockMedicines
        );

        request.setAttribute(
                "expiringList",
                expiringMedicines
        );

        request.setAttribute(
                "expiredList",
                expiredMedicines
        );

        request.setAttribute(
                "recentTransactions",
                transactionDAO.getAllTransactions()
        );

        request.getRequestDispatcher(
                "/dashboard.jsp"
        ).forward(request, response);
    }
}