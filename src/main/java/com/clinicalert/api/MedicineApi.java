package com.clinicalert.api;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.model.Medicine;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(
        name = "MedicineApi",
        urlPatterns = {"/api/medicines/*"}
)
public class MedicineApi extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MedicineDAO medicineDAO;

    @Override
    public void init() {
        medicineDAO = new MedicineDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {

            List<Medicine> medicines
                    = medicineDAO.getAllMedicines();

            StringBuilder json = new StringBuilder();

            json.append("[");

            for (int i = 0; i < medicines.size(); i++) {

                if (i > 0) {
                    json.append(",");
                }

                json.append(
                        medicineToJson(medicines.get(i))
                );
            }

            json.append("]");

            response.setStatus(
                    HttpServletResponse.SC_OK
            );

            out.print(json.toString());
            out.flush();

            return;
        }

        String medicineId
                = pathInfo.substring(1);

        if (medicineId.trim().isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Medicine ID is required."
            );

            return;
        }

        Medicine medicine
                = medicineDAO.getMedicineById(
                        medicineId
                );

        if (medicine != null) {

            response.setStatus(
                    HttpServletResponse.SC_OK
            );

            out.print(
                    medicineToJson(medicine)
            );

            out.flush();

            return;
        }

        sendError(
                response,
                HttpServletResponse.SC_NOT_FOUND,
                "Medicine not found."
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        if (pathInfo != null
                && !pathInfo.equals("/")
                && !pathInfo.isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "POST must use /api/medicines"
            );

            return;
        }

        String jsonBody
                = readRequestBody(request);

        if (jsonBody.isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Request body is required."
            );

            return;
        }

        JsonObject json;
        try {
            json = JsonParser.parseString(jsonBody).getAsJsonObject();
        } catch (Exception e) {
            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid JSON body."
            );
            return;
        }

        String name = getString(json, "name", "");
        String category = getString(json, "category", "");
        String batchNo = getString(json, "batchNo", "");
        String unit = getString(json, "unit", "");
        int currentStock = getInt(json, "currentStock", 0);
        int minStock = getInt(json, "minStock", 10);
        String supplier = getString(json, "supplier", "");
        String expiryDate = getString(json, "expiryDate", "");
        String description = getString(json, "description", "");
        String location = getString(json, "location", "Main Pharmacy");
        double unitPrice = getDouble(json, "unitPrice", 0.0);

        if (name == null
                || name.trim().isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Medicine name is required."
            );

            return;
        }

        if (currentStock < 0) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Current stock cannot be negative."
            );

            return;
        }

        if (minStock < 0) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Minimum stock cannot be negative."
            );

            return;
        }

        String medicineId
                = medicineDAO.generateNextItemId();

        Medicine medicine
                = new Medicine();

        medicine.setMedicineId(
                medicineId
        );

        medicine.setName(
                name.trim()
        );

        medicine.setCategory(
                category == null ? "" : category.trim()
        );

        medicine.setBatchNo(
                batchNo == null ? "" : batchNo.trim()
        );

        medicine.setUnit(
                unit == null ? "" : unit.trim()
        );

        medicine.setCurrentStock(
                currentStock
        );

        medicine.setMinStock(
                minStock
        );

        medicine.setSupplier(
                supplier == null ? "" : supplier.trim()
        );

        medicine.setExpiryDate(
                expiryDate == null ? "" : expiryDate.trim()
        );

        medicine.setDescription(
                description == null ? "" : description.trim()
        );

        medicine.setLocation(
                location == null || location.trim().isEmpty() ? "Main Pharmacy" : location.trim()
        );

        medicine.setUnitPrice(
                unitPrice
        );

        boolean success
                = medicineDAO.addMedicine(
                        medicine
                );

        if (success) {

            response.setStatus(
                    HttpServletResponse.SC_CREATED
            );

            out.print(
                    medicineToJson(medicine)
            );

            out.flush();

            return;
        }

        sendError(
                response,
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Failed to add medicine."
        );
    }

    @Override
    protected void doPut(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        String pathInfo
                = request.getPathInfo();

        if (pathInfo == null
                || pathInfo.equals("/")
                || pathInfo.trim().isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Medicine ID is required."
            );

            return;
        }

        String medicineId
                = pathInfo.substring(1);

        Medicine existingMedicine
                = medicineDAO.getMedicineById(
                        medicineId
                );

        if (existingMedicine == null) {

            sendError(
                    response,
                    HttpServletResponse.SC_NOT_FOUND,
                    "Medicine not found."
            );

            return;
        }

        String jsonBody
                = readRequestBody(request);

        if (jsonBody.isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Request body is required."
            );

            return;
        }

        JsonObject json;
        try {
            json = JsonParser.parseString(jsonBody).getAsJsonObject();
        } catch (Exception e) {
            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid JSON body."
            );
            return;
        }

        String name = getString(json, "name", existingMedicine.getName());
        String category = getString(json, "category", existingMedicine.getCategory());
        String batchNo = getString(json, "batchNo", existingMedicine.getBatchNo());
        String unit = getString(json, "unit", existingMedicine.getUnit());
        int currentStock = getInt(json, "currentStock", existingMedicine.getCurrentStock());
        int minStock = getInt(json, "minStock", existingMedicine.getMinStock());
        String supplier = getString(json, "supplier", existingMedicine.getSupplier());
        String expiryDate = getString(json, "expiryDate", existingMedicine.getExpiryDate());
        String description = getString(json, "description", existingMedicine.getDescription());
        String location = getString(json, "location", existingMedicine.getLocation());
        double unitPrice = getDouble(json, "unitPrice", existingMedicine.getUnitPrice());

        if (name == null
                || name.trim().isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Medicine name is required."
            );

            return;
        }

        if (currentStock < 0) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Current stock cannot be negative."
            );

            return;
        }

        if (minStock < 0) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Minimum stock cannot be negative."
            );

            return;
        }

        existingMedicine.setName(
                name.trim()
        );

        if (category != null) {
            existingMedicine.setCategory(category.trim());
        }

        if (batchNo != null) {
            existingMedicine.setBatchNo(batchNo.trim());
        }

        if (unit != null) {
            existingMedicine.setUnit(unit.trim());
        }

        existingMedicine.setCurrentStock(
                currentStock
        );

        existingMedicine.setMinStock(
                minStock
        );

        if (supplier != null) {
            existingMedicine.setSupplier(supplier.trim());
        }

        if (expiryDate != null) {
            existingMedicine.setExpiryDate(expiryDate.trim());
        }

        if (description != null) {
            existingMedicine.setDescription(description.trim());
        }

        if (location != null && !location.trim().isEmpty()) {
            existingMedicine.setLocation(location.trim());
        }

        existingMedicine.setUnitPrice(
                unitPrice
        );

        boolean success
                = medicineDAO.updateMedicine(
                        existingMedicine
                );

        if (success) {

            Medicine updatedMedicine
                    = medicineDAO.getMedicineById(
                            medicineId
                    );

            if (updatedMedicine == null) {
                updatedMedicine
                        = existingMedicine;
            }

            response.setStatus(
                    HttpServletResponse.SC_OK
            );

            out.print(
                    medicineToJson(
                            updatedMedicine
                    )
            );

            out.flush();

            return;
        }

        sendError(
                response,
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Failed to update medicine."
        );
    }

    @Override
    protected void doDelete(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        String pathInfo
                = request.getPathInfo();

        if (pathInfo == null
                || pathInfo.equals("/")
                || pathInfo.trim().isEmpty()) {

            sendError(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Medicine ID is required."
            );

            return;
        }

        String medicineId
                = pathInfo.substring(1);

        Medicine existingMedicine
                = medicineDAO.getMedicineById(
                        medicineId
                );

        if (existingMedicine == null) {

            sendError(
                    response,
                    HttpServletResponse.SC_NOT_FOUND,
                    "Medicine not found."
            );

            return;
        }

        boolean success
                = medicineDAO.deleteMedicine(
                        medicineId
                );

        if (success) {

            response.setStatus(
                    HttpServletResponse.SC_OK
            );

            out.print(
                    "{\"message\":\"Medicine deleted successfully.\","
                    + "\"medicineId\":\""
                    + escapeJson(medicineId)
                    + "\"}"
            );

            out.flush();

            return;
        }

        sendError(
                response,
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Failed to delete medicine."
        );
    }

    private String readRequestBody(
            HttpServletRequest request)
            throws IOException {

        StringBuilder body
                = new StringBuilder();

        BufferedReader reader
                = request.getReader();

        String line;

        while ((line = reader.readLine()) != null) {
            body.append(line);
        }

        return body.toString().trim();
    }

    private String medicineToJson(
            Medicine medicine) {

        StringBuilder json
                = new StringBuilder();

        json.append("{");

        json.append("\"medicineId\":\"")
                .append(
                        escapeJson(
                                medicine.getMedicineId()
                        )
                )
                .append("\",");

        json.append("\"name\":\"")
                .append(
                        escapeJson(
                                medicine.getName()
                        )
                )
                .append("\",");

        json.append("\"category\":\"")
                .append(
                        escapeJson(
                                medicine.getCategory()
                        )
                )
                .append("\",");

        json.append("\"batchNo\":\"")
                .append(
                        escapeJson(
                                medicine.getBatchNo()
                        )
                )
                .append("\",");

        json.append("\"unit\":\"")
                .append(
                        escapeJson(
                                medicine.getUnit()
                        )
                )
                .append("\",");

        json.append("\"currentStock\":")
                .append(
                        medicine.getCurrentStock()
                )
                .append(",");

        json.append("\"minStock\":")
                .append(
                        medicine.getMinStock()
                )
                .append(",");

        json.append("\"supplier\":\"")
                .append(
                        escapeJson(
                                medicine.getSupplier()
                        )
                )
                .append("\",");

        json.append("\"expiryDate\":\"")
                .append(
                        escapeJson(
                                medicine.getExpiryDate()
                        )
                )
                .append("\",");

        json.append("\"description\":\"")
                .append(
                        escapeJson(
                                medicine.getDescription()
                        )
                )
                .append("\",");

        json.append("\"unitPrice\":")
                .append(
                        medicine.getUnitPrice()
                )
                .append(",");

        json.append("\"location\":\"")
                .append(
                        escapeJson(
                                medicine.getLocation()
                        )
                )
                .append("\",");

        json.append("\"status\":\"")
                .append(
                        escapeJson(
                                medicine.getStatus()
                        )
                )
                .append("\"");

        json.append("}");

        return json.toString();
    }

    private void sendError(
            HttpServletResponse response,
            int status,
            String message)
            throws IOException {

        response.setStatus(status);

        PrintWriter out
                = response.getWriter();

        out.print(
                "{\"error\":\""
                + escapeJson(message)
                + "\"}"
        );

        out.flush();
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("\t", "\\t");
    }

    private String getString(JsonObject obj, String key, String defaultValue) {
        if (obj != null && obj.has(key) && !obj.get(key).isJsonNull()) {
            return obj.get(key).getAsString();
        }
        return defaultValue;
    }

    private int getInt(JsonObject obj, String key, int defaultValue) {
        if (obj != null && obj.has(key) && !obj.get(key).isJsonNull()) {
            try {
                return obj.get(key).getAsInt();
            } catch (Exception ignored) {
            }
        }
        return defaultValue;
    }

    private double getDouble(JsonObject obj, String key, double defaultValue) {
        if (obj != null && obj.has(key) && !obj.get(key).isJsonNull()) {
            try {
                return obj.get(key).getAsDouble();
            } catch (Exception ignored) {
            }
        }
        return defaultValue;
    }
}
