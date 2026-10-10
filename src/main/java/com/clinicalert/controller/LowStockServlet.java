package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "LowStockServlet", urlPatterns = {"/lowstock"})
public class LowStockServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MedicineDAO medicineDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setAttribute("lowStockMedicines", medicineDAO.getLowStockMedicines());
        request.getRequestDispatcher("/lowstock.jsp").forward(request, response);
    }
}
