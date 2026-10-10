package com.clinicalert.controller;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.model.Medicine;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Login is enforced for every request by {@link com.clinicalert.util.AuthFilter}.
 * Deleting is POST-only (a GET link must never change data).
 */
@WebServlet(name = "MedicineServlet", urlPatterns = {"/medicine", "/medicine/add", "/medicine/edit", "/medicine/delete"})
public class MedicineServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MedicineDAO medicineDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/medicine/delete".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Use POST to delete a medicine.");
            return;
        }

        List<Medicine> list = medicineDAO.getAllMedicines();
        request.setAttribute("medicines", list);
        request.getRequestDispatcher("/medicine.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/medicine/delete".equals(request.getServletPath())) {
            String id = request.getParameter("id");
            if (id == null || id.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/medicine?msg=error");
                return;
            }
            boolean deleted = medicineDAO.deleteMedicine(id.trim());
            response.sendRedirect(request.getContextPath() + "/medicine?msg=" + (deleted ? "deleted" : "error"));
            return;
        }

        String medicineId = request.getParameter("medicineId");
        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String batchNo = request.getParameter("batchNo");
        String unit = request.getParameter("unit");
        String supplier = request.getParameter("supplier");
        String expiryDate = request.getParameter("expiryDate");
        String description = request.getParameter("description");
        String location = request.getParameter("location") != null ? request.getParameter("location") : "Main Pharmacy";

        int currentStock;
        int minStock;
        double unitPrice;
        try {
            currentStock = Integer.parseInt(request.getParameter("quantity").trim());
            minStock = Integer.parseInt(request.getParameter("minStock").trim());
            String price = request.getParameter("unitPrice");
            unitPrice = price != null && !price.trim().isEmpty() ? Double.parseDouble(price.trim()) : 1.00;
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect(request.getContextPath() + "/medicine?msg=invalid");
            return;
        }

        if (currentStock < 0 || minStock < 0 || unitPrice < 0) {
            response.sendRedirect(request.getContextPath() + "/medicine?msg=invalid");
            return;
        }

        Medicine med = new Medicine(medicineId, name, category, batchNo, unit, currentStock, minStock, supplier, expiryDate, description, unitPrice, location);

        boolean ok;
        if (medicineId != null && !medicineId.isEmpty() && medicineDAO.getMedicineById(medicineId) != null) {
            ok = medicineDAO.updateMedicine(med);
        } else {
            ok = medicineDAO.addMedicine(med);
        }

        response.sendRedirect(request.getContextPath() + "/medicine?msg=" + (ok ? "saved" : "error"));
    }
}
