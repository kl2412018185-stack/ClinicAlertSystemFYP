package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.dao.TransactionDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ReportServlet", urlPatterns = {"/reports", "/report"})
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MedicineDAO medicineDAO;
    private TransactionDAO transactionDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
        transactionDAO = new TransactionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String reportType = request.getParameter("reportType");
        String dateFrom = request.getParameter("dateFrom");
        String dateTo = request.getParameter("dateTo");

        request.setAttribute("medicines", medicineDAO.getAllMedicines());
        request.setAttribute("transactions", transactionDAO.getAllTransactions());
        request.setAttribute("lowStock", medicineDAO.getLowStockMedicines());
        request.setAttribute("expiring", medicineDAO.getExpiringSoonMedicines(60));
        request.setAttribute("reportType", reportType != null ? reportType : "INVENTORY_SUMMARY");
        request.setAttribute("dateFrom", dateFrom != null ? dateFrom : "2026-08-01");
        request.setAttribute("dateTo", dateTo != null ? dateTo : "2026-08-15");

        request.getRequestDispatcher("/reports.jsp").forward(request, response);
    }
}
