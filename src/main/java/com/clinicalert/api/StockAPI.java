package com.clinicalert.api;

import com.clinicalert.dao.MedicineDAO;
import com.clinicalert.dao.TransactionDAO;
import com.clinicalert.model.Medicine;
import com.clinicalert.model.StockTransaction;

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
    name = "StockAPI",
    urlPatterns = {"/api/stock/*"}
)
public class StockAPI extends HttpServlet {

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

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        String pathInfo =
                request.getPathInfo();

        List<StockTransaction> transactions;

        if (pathInfo == null
                || pathInfo.equals("/")
                || pathInfo.isEmpty()) {

            transactions =
                    transactionDAO.getAllTransactions();

        } else if (pathInfo.equalsIgnoreCase("/in")) {

            transactions =
                    transactionDAO.getTransactionsByType("IN");

        } else if (pathInfo.equalsIgnoreCase("/out")) {

            transactions =
                    transactionDAO.getTransactionsByType("OUT");

        } else {

            sendError(
                response,
                HttpServletResponse.SC_NOT_FOUND,
                "Stock API endpoint not found."
            );

            return;
        }

        StringBuilder json =
                new StringBuilder();

        json.append("[");

        for (int i = 0;
                i < transactions.size();
                i++) {

            if (i > 0) {
                json.append(",");
            }

            json.append(
                transactionToJson(
                    transactions.get(i)
                )
            );
        }

        json.append("]");

        response.setStatus(
            HttpServletResponse.SC_OK
        );

        out.print(
            json.toString()
        );

        out.flush();
    }


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out =
                response.getWriter();

        String pathInfo =
                request.getPathInfo();

        if (pathInfo == null
                || pathInfo.equals("/")
                || pathInfo.isEmpty()) {

            sendError(
                response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Use /api/stock/in or /api/stock/out."
            );

            return;
        }

        String type;

        if (pathInfo.equalsIgnoreCase("/in")) {

            type = "IN";

        } else if (pathInfo.equalsIgnoreCase("/out")) {

            type = "OUT";

        } else {

            sendError(
                response,
                HttpServletResponse.SC_NOT_FOUND,
                "Stock API endpoint not found."
            );

            return;
        }



        String jsonBody =
                readRequestBody(request);

        if (jsonBody.isEmpty()) {

            sendError(
                response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Request body is required."
            );

            return;
        }



        String medicineId =
                getJsonString(
                    jsonBody,
                    "medicineId"
                );

        String batchNo =
                getJsonString(
                    jsonBody,
                    "batchNo"
                );

        String unit =
                getJsonString(
                    jsonBody,
                    "unit"
                );

        String date =
                getJsonString(
                    jsonBody,
                    "date"
                );

        String expiryDate =
                getJsonString(
                    jsonBody,
                    "expiryDate"
                );

        String supplierOrRecipient =
                getJsonString(
                    jsonBody,
                    "supplierOrRecipient"
                );

        String reasonOrRemarks =
                getJsonString(
                    jsonBody,
                    "reasonOrRemarks"
                );

        String recordedBy =
                getJsonString(
                    jsonBody,
                    "recordedBy"
                );

        int quantity =
                getJsonInt(
                    jsonBody,
                    "quantity",
                    0
                );



        if (medicineId == null
                || medicineId.trim().isEmpty()) {

            sendError(
                response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Medicine ID is required."
            );

            return;
        }

        if (quantity <= 0) {

            sendError(
                response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Quantity must be greater than 0."
            );

            return;
        }



        Medicine medicine =
                medicineDAO.getMedicineById(
                    medicineId
                );

        if (medicine == null) {

            sendError(
                response,
                HttpServletResponse.SC_NOT_FOUND,
                "Medicine not found."
            );

            return;
        }



        if ("OUT".equals(type)
                && quantity
                    > medicine.getCurrentStock()) {

            sendError(
                response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Insufficient stock. Current stock is "
                + medicine.getCurrentStock()
                + "."
            );

            return;
        }



        StockTransaction transaction =
                new StockTransaction();

        transaction.setType(type);

        transaction.setMedicineId(
            medicineId
        );

        transaction.setMedicineName(
            medicine.getName()
        );

        transaction.setBatchNo(
            batchNo == null
                ? ""
                : batchNo.trim()
        );

        transaction.setQuantity(
            quantity
        );

        transaction.setUnit(
            unit == null
                ? medicine.getUnit()
                : unit.trim()
        );

        transaction.setDate(
            date == null
                ? ""
                : date.trim()
        );

        transaction.setExpiryDate(
            expiryDate == null
                ? ""
                : expiryDate.trim()
        );

        transaction.setSupplierOrRecipient(
            supplierOrRecipient == null
                ? ""
                : supplierOrRecipient.trim()
        );

        transaction.setReasonOrRemarks(
            reasonOrRemarks == null
                ? ""
                : reasonOrRemarks.trim()
        );

        transaction.setRecordedBy(
            recordedBy == null
                ? ""
                : recordedBy.trim()
        );



        boolean transactionSuccess =
                transactionDAO.addTransaction(
                    transaction
                );

        if (!transactionSuccess) {

            sendError(
                response,
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Failed to record stock transaction."
            );

            return;
        }



        int stockChange;

        if ("IN".equals(type)) {

            stockChange = quantity;

        } else {

            stockChange = -quantity;
        }

        boolean stockUpdated =
                medicineDAO.adjustStock(
                    medicineId,
                    stockChange
                );

        if (!stockUpdated) {

            sendError(
                response,
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Transaction recorded but failed to update current stock."
            );

            return;
        }



        Medicine updatedMedicine =
                medicineDAO.getMedicineById(
                    medicineId
                );

        int updatedStock = 0;

        if (updatedMedicine != null) {
            updatedStock =
                    updatedMedicine.getCurrentStock();
        }



        response.setStatus(
            HttpServletResponse.SC_CREATED
        );

        out.print(
            "{"
            + "\"message\":\""
            + ("IN".equals(type)
                ? "Stock In recorded successfully."
                : "Stock Out recorded successfully.")
            + "\","
            + "\"type\":\""
            + type
            + "\","
            + "\"medicineId\":\""
            + escapeJson(medicineId)
            + "\","
            + "\"medicineName\":\""
            + escapeJson(medicine.getName())
            + "\","
            + "\"quantity\":"
            + quantity
            + ","
            + "\"currentStock\":"
            + updatedStock
            + "}"
        );

        out.flush();
    }


    private String transactionToJson(
            StockTransaction transaction) {

        StringBuilder json =
                new StringBuilder();

        json.append("{");

        json.append("\"id\":\"")
            .append(
                escapeJson(
                    transaction.getId()
                )
            )
            .append("\",");

        json.append("\"transactionRef\":\"")
            .append(
                escapeJson(
                    transaction.getTransactionRef()
                )
            )
            .append("\",");

        json.append("\"type\":\"")
            .append(
                escapeJson(
                    transaction.getType()
                )
            )
            .append("\",");

        json.append("\"medicineId\":\"")
            .append(
                escapeJson(
                    transaction.getMedicineId()
                )
            )
            .append("\",");

        json.append("\"medicineName\":\"")
            .append(
                escapeJson(
                    transaction.getMedicineName()
                )
            )
            .append("\",");

        json.append("\"batchNo\":\"")
            .append(
                escapeJson(
                    transaction.getBatchNo()
                )
            )
            .append("\",");

        json.append("\"quantity\":")
            .append(
                transaction.getQuantity()
            )
            .append(",");

        json.append("\"unit\":\"")
            .append(
                escapeJson(
                    transaction.getUnit()
                )
            )
            .append("\",");

        json.append("\"date\":\"")
            .append(
                escapeJson(
                    transaction.getDate()
                )
            )
            .append("\",");

        json.append("\"expiryDate\":\"")
            .append(
                escapeJson(
                    transaction.getExpiryDate()
                )
            )
            .append("\",");

        json.append("\"supplierOrRecipient\":\"")
            .append(
                escapeJson(
                    transaction.getSupplierOrRecipient()
                )
            )
            .append("\",");

        json.append("\"reasonOrRemarks\":\"")
            .append(
                escapeJson(
                    transaction.getReasonOrRemarks()
                )
            )
            .append("\",");

        json.append("\"recordedBy\":\"")
            .append(
                escapeJson(
                    transaction.getRecordedBy()
                )
            )
            .append("\"");

        json.append("}");

        return json.toString();
    }


    private String readRequestBody(
            HttpServletRequest request)
            throws IOException {

        StringBuilder body =
                new StringBuilder();

        BufferedReader reader =
                request.getReader();

        String line;

        while ((line = reader.readLine()) != null) {
            body.append(line);
        }

        return body.toString().trim();
    }


    private String getJsonString(
            String json,
            String key) {

        String search =
                "\"" + key + "\"";

        int keyIndex =
                json.indexOf(search);

        if (keyIndex == -1) {
            return null;
        }

        int colonIndex =
                json.indexOf(
                    ":",
                    keyIndex
                );

        if (colonIndex == -1) {
            return null;
        }

        int firstQuote =
                json.indexOf(
                    "\"",
                    colonIndex + 1
                );

        if (firstQuote == -1) {
            return null;
        }

        int secondQuote =
                json.indexOf(
                    "\"",
                    firstQuote + 1
                );

        if (secondQuote == -1) {
            return null;
        }

        return json.substring(
            firstQuote + 1,
            secondQuote
        );
    }


    private int getJsonInt(
            String json,
            String key,
            int defaultValue) {

        String search =
                "\"" + key + "\"";

        int keyIndex =
                json.indexOf(search);

        if (keyIndex == -1) {
            return defaultValue;
        }

        int colonIndex =
                json.indexOf(
                    ":",
                    keyIndex
                );

        if (colonIndex == -1) {
            return defaultValue;
        }

        int start =
                colonIndex + 1;

        while (start < json.length()
                && Character.isWhitespace(
                    json.charAt(start)
                )) {

            start++;
        }

        int end = start;

        while (end < json.length()
                && (
                    Character.isDigit(
                        json.charAt(end)
                    )
                    || json.charAt(end) == '-'
                )) {

            end++;
        }

        if (start == end) {
            return defaultValue;
        }

        try {

            return Integer.parseInt(
                json.substring(
                    start,
                    end
                )
            );

        } catch (NumberFormatException e) {

            return defaultValue;
        }
    }


    private void sendError(
            HttpServletResponse response,
            int status,
            String message)
            throws IOException {

        response.setStatus(status);

        PrintWriter out =
                response.getWriter();

        out.print(
            "{\"error\":\""
            + escapeJson(message)
            + "\"}"
        );

        out.flush();
    }


    private String escapeJson(
            String value) {

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
}