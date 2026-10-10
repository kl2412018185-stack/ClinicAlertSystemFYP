package com.clinicalert.dao;

import com.clinicalert.model.StockTransaction;
import com.clinicalert.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class TransactionDAO {
    public List<StockTransaction> getAllTransactions() {
        List<StockTransaction> transactions = new ArrayList<>();

        String sql
                = "SELECT "
                + "si.stock_in_id AS transaction_id, "
                + "CONCAT('STK-IN-', si.stock_in_id) AS transaction_ref, "
                + "'IN' AS transaction_type, "
                + "si.item_id, "
                + "m.medicine_name, "
                + "si.batch_no, "
                + "si.quantity AS quantity, "
                + "m.unit, "
                + "si.received_date AS transaction_date, "
                + "si.expiry_date, "
                + "si.supplier AS supplier_or_recipient, "
                + "NULL AS reason_or_remarks, "
                + "u.full_name AS recorded_by "
                + "FROM stock_in si "
                + "INNER JOIN medicines m "
                + "ON si.item_id = m.item_id "
                + "LEFT JOIN users u "
                + "ON si.received_by = u.user_id "
                + "UNION ALL "
                + "SELECT "
                + "so.stock_out_id AS transaction_id, "
                + "CONCAT('STK-OUT-', so.stock_out_id) AS transaction_ref, "
                + "'OUT' AS transaction_type, "
                + "m.item_id, "
                + "m.medicine_name, "
                + "so.batch_no, "
                + "COALESCE(so.quantity_out, so.quantity, 0) AS quantity, "
                + "m.unit, "
                + "COALESCE(so.stock_out_date, so.issued_date) AS transaction_date, "
                + "NULL AS expiry_date, "
                + "so.reason AS supplier_or_recipient, "
                + "so.remarks AS reason_or_remarks, "
                + "COALESCE(u.full_name, so.issued_to, 'Staff') AS recorded_by "
                + "FROM stock_out so "
                + "INNER JOIN medicines m "
                + "ON so.medicine_id = m.medicine_id OR so.item_id = m.item_id "
                + "LEFT JOIN users u "
                + "ON so.issued_by = u.user_id "
                + "ORDER BY transaction_date DESC, transaction_id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                transactions.add(
                        createTransactionFromResultSet(rs)
                );
            }
        } catch (SQLException e) {
            System.err.println(
                    "[TransactionDAO] Error getting all transactions:"
            );

            e.printStackTrace();
        }

        return transactions;
    }

    public List<StockTransaction> getTransactionsByType(String type) {
        List<StockTransaction> transactions = new ArrayList<>();

        if (type == null || type.trim().isEmpty()) {
            return transactions;
        }

        if ("IN".equalsIgnoreCase(type)) {
            String sql
                    = "SELECT "
                    + "si.stock_in_id AS transaction_id, "
                    + "CONCAT('STK-IN-', si.stock_in_id) AS transaction_ref, "
                    + "'IN' AS transaction_type, "
                    + "si.item_id, "
                    + "m.medicine_name, "
                    + "si.batch_no, "
                    + "si.quantity AS quantity, "
                    + "m.unit, "
                    + "si.received_date AS transaction_date, "
                    + "si.expiry_date, "
                    + "si.supplier AS supplier_or_recipient, "
                    + "NULL AS reason_or_remarks, "
                    + "u.full_name AS recorded_by "
                    + "FROM stock_in si "
                    + "INNER JOIN medicines m "
                    + "ON si.item_id = m.item_id "
                    + "LEFT JOIN users u "
                    + "ON si.received_by = u.user_id "
                    + "ORDER BY si.received_date DESC, "
                    + "si.stock_in_id DESC";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(
                            createTransactionFromResultSet(rs)
                    );
                }
            } catch (SQLException e) {
                System.err.println(
                        "[TransactionDAO] Error getting Stock In transactions:"
                );

                e.printStackTrace();
            }
        }else if ("OUT".equalsIgnoreCase(type)) {
            String sql
                    = "SELECT "
                    + "so.stock_out_id AS transaction_id, "
                    + "CONCAT('STK-OUT-', so.stock_out_id) AS transaction_ref, "
                    + "'OUT' AS transaction_type, "
                    + "m.item_id, "
                    + "m.medicine_name, "
                    + "so.batch_no, "
                    + "COALESCE(so.quantity_out, so.quantity, 0) AS quantity, "
                    + "m.unit, "
                    + "COALESCE(so.stock_out_date, so.issued_date) AS transaction_date, "
                    + "NULL AS expiry_date, "
                    + "so.reason AS supplier_or_recipient, "
                    + "so.remarks AS reason_or_remarks, "
                    + "COALESCE(u.full_name, so.issued_to, 'Staff') AS recorded_by "
                    + "FROM stock_out so "
                    + "INNER JOIN medicines m "
                    + "ON so.medicine_id = m.medicine_id OR so.item_id = m.item_id "
                    + "LEFT JOIN users u "
                    + "ON so.issued_by = u.user_id "
                    + "ORDER BY transaction_date DESC, transaction_id DESC";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(
                            createTransactionFromResultSet(rs)
                    );
                }
            } catch (SQLException e) {
                System.err.println(
                        "[TransactionDAO] Error getting Stock Out transactions:"
                );

                e.printStackTrace();
            }
        }

        return transactions;
    }

    public boolean addTransaction(StockTransaction txn) {
        if (txn == null) {
            return false;
        }

        if ("IN".equalsIgnoreCase(txn.getType())) {
            String sql
                    = "INSERT INTO stock_in "
                    + "(item_id, quantity, batch_no, expiry_date, "
                    + "supplier, received_date, received_by) "
                    + "VALUES (?, ?, ?, ?, ?, ?, "
                    + "(SELECT user_id FROM users "
                    + "WHERE staff_id = ? "
                    + "OR CAST(user_id AS CHAR) = ? "
                    + "LIMIT 1))";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(
                        1,
                        txn.getMedicineId()
                );

                ps.setInt(
                        2,
                        txn.getQuantity()
                );

                ps.setString(
                        3,
                        txn.getBatchNo()
                );

                ps.setString(
                        4,
                        txn.getExpiryDate()
                );

                ps.setString(
                        5,
                        txn.getSupplierOrRecipient()
                );

                ps.setString(
                        6,
                        txn.getDate()
                );

                ps.setString(
                        7,
                        txn.getRecordedBy()
                );

                ps.setString(
                        8,
                        txn.getRecordedBy()
                );

                int rows = ps.executeUpdate();

                return rows > 0;
            } catch (SQLException e) {
                System.err.println(
                        "[TransactionDAO] Error adding Stock In:"
                );

                e.printStackTrace();
            }

            return false;
        }

        if ("OUT".equalsIgnoreCase(txn.getType())) {
            String sql
                    = "INSERT INTO stock_out "
                    + "(medicine_id, item_id, batch_no, quantity, quantity_out, reason, "
                    + "stock_out_date, issued_date, remarks, issued_by, issued_to) "
                    + "VALUES ("
                    + "(SELECT medicine_id FROM medicines WHERE item_id = ? OR CAST(medicine_id AS CHAR) = ? LIMIT 1), "
                    + "(SELECT item_id FROM medicines WHERE item_id = ? OR CAST(medicine_id AS CHAR) = ? LIMIT 1), "
                    + "?, ?, ?, ?, ?, ?, ?, "
                    + "(SELECT user_id FROM users WHERE staff_id = ? OR CAST(user_id AS CHAR) = ? OR full_name = ? LIMIT 1), "
                    + "?"
                    + ")";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, txn.getMedicineId());
                ps.setString(2, txn.getMedicineId());

                ps.setString(3, txn.getMedicineId());
                ps.setString(4, txn.getMedicineId());

                ps.setString(5, txn.getBatchNo());

                ps.setInt(6, txn.getQuantity());
                ps.setInt(7, txn.getQuantity());

                ps.setString(8, txn.getSupplierOrRecipient());

                ps.setString(9, txn.getDate());
                ps.setString(10, txn.getDate());

                ps.setString(11, txn.getReasonOrRemarks());

                ps.setString(12, txn.getRecordedBy());
                ps.setString(13, txn.getRecordedBy());
                ps.setString(14, txn.getRecordedBy());

                ps.setString(15, txn.getRecordedBy());

                int rows = ps.executeUpdate();

                return rows > 0;
            } catch (SQLException e) {
                System.err.println(
                        "[TransactionDAO] Error adding Stock Out:"
                );

                e.printStackTrace();
            }

            return false;
        }

        return false;
    }

    public List<StockTransaction> getTodayTransactions() {
        List<StockTransaction> transactions = new ArrayList<>();

        String sql
                = "SELECT "
                + "si.stock_in_id AS transaction_id, "
                + "CONCAT('STK-IN-', si.stock_in_id) AS transaction_ref, "
                + "'IN' AS transaction_type, "
                + "si.item_id, "
                + "m.medicine_name, "
                + "si.batch_no, "
                + "si.quantity AS quantity, "
                + "m.unit, "
                + "si.received_date AS transaction_date, "
                + "si.expiry_date, "
                + "si.supplier AS supplier_or_recipient, "
                + "NULL AS reason_or_remarks, "
                + "u.full_name AS recorded_by "
                + "FROM stock_in si "
                + "INNER JOIN medicines m "
                + "ON si.item_id = m.item_id "
                + "LEFT JOIN users u "
                + "ON si.received_by = u.user_id "
                + "WHERE si.received_date = CURDATE() "
                + "UNION ALL "
                + "SELECT "
                + "so.stock_out_id AS transaction_id, "
                + "CONCAT('STK-OUT-', so.stock_out_id) AS transaction_ref, "
                + "'OUT' AS transaction_type, "
                + "m.item_id, "
                + "m.medicine_name, "
                + "so.batch_no, "
                + "so.quantity_out AS quantity, "
                + "m.unit, "
                + "so.stock_out_date AS transaction_date, "
                + "NULL AS expiry_date, "
                + "so.reason AS supplier_or_recipient, "
                + "so.remarks AS reason_or_remarks, "
                + "u.full_name AS recorded_by "
                + "FROM stock_out so "
                + "INNER JOIN medicines m "
                + "ON so.medicine_id = m.medicine_id "
                + "LEFT JOIN users u "
                + "ON so.issued_by = u.user_id "
                + "WHERE so.stock_out_date = CURDATE() "
                + "ORDER BY transaction_date DESC, "
                + "transaction_id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                transactions.add(
                        createTransactionFromResultSet(rs)
                );
            }
        } catch (SQLException e) {
            System.err.println(
                    "[TransactionDAO] Error getting today's transactions:"
            );

            e.printStackTrace();
        }

        return transactions;
    }

    public int getTodayTransactionCount() {
        String sql
                = "SELECT "
                + "(SELECT COUNT(*) "
                + "FROM stock_in "
                + "WHERE received_date = CURDATE()) "
                + "+ "
                + "(SELECT COUNT(*) "
                + "FROM stock_out "
                + "WHERE stock_out_date = CURDATE()) "
                + "AS total_count";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total_count");
            }
        } catch (SQLException e) {
            System.err.println(
                    "[TransactionDAO] Error getting today's transaction count:"
            );

            e.printStackTrace();
        }

        return 0;
    }

    public int getTodayStockInCount() {
        String sql
                = "SELECT COUNT(*) AS total_count "
                + "FROM stock_in "
                + "WHERE received_date = CURDATE()";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total_count");
            }
        } catch (SQLException e) {
            System.err.println(
                    "[TransactionDAO] Error getting today's Stock In count:"
            );

            e.printStackTrace();
        }

        return 0;
    }

    public int getTodayStockOutCount() {
        String sql
                = "SELECT COUNT(*) AS total_count "
                + "FROM stock_out "
                + "WHERE stock_out_date = CURDATE()";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total_count");
            }
        } catch (SQLException e) {
            System.err.println(
                    "[TransactionDAO] Error getting today's Stock Out count:"
            );

            e.printStackTrace();
        }

        return 0;
    }

    private StockTransaction createTransactionFromResultSet(
            ResultSet rs) throws SQLException {
        StockTransaction transaction
                = new StockTransaction();

        transaction.setId(
                String.valueOf(
                        rs.getInt("transaction_id")
                )
        );

        transaction.setTransactionRef(
                rs.getString("transaction_ref")
        );

        transaction.setType(
                rs.getString("transaction_type")
        );

        transaction.setMedicineId(
                rs.getString("item_id")
        );

        transaction.setMedicineName(
                rs.getString("medicine_name")
        );

        transaction.setBatchNo(
                rs.getString("batch_no")
        );

        transaction.setQuantity(
                rs.getInt("quantity")
        );

        transaction.setUnit(
                rs.getString("unit")
        );

        transaction.setDate(
                rs.getString("transaction_date")
        );

        transaction.setExpiryDate(
                rs.getString("expiry_date")
        );

        transaction.setSupplierOrRecipient(
                rs.getString("supplier_or_recipient")
        );

        transaction.setReasonOrRemarks(
                rs.getString("reason_or_remarks")
        );

        transaction.setRecordedBy(
                rs.getString("recorded_by")
        );

        return transaction;
    }

    public List<StockTransaction> getExpiringBatches(String filter) {
        List<StockTransaction> stockInList = getTransactionsByType("IN");
        List<StockTransaction> stockOutList = getTransactionsByType("OUT");

        Map<String, StockTransaction> batchMap = new LinkedHashMap<>();
        Map<String, Integer> batchStock = new LinkedHashMap<>();

        for (StockTransaction in : stockInList) {
            String batchNo = in.getBatchNo() == null ? "" : in.getBatchNo().trim();
            String expiryDate = in.getExpiryDate() == null ? "" : in.getExpiryDate().trim();

            if (expiryDate.isEmpty()) {
                continue;
            }

            String key = safe(in.getMedicineId()) + "|" + batchNo + "|" + expiryDate;

            if (!batchMap.containsKey(key)) {
                StockTransaction copy = new StockTransaction(
                        in.getId(),
                        in.getTransactionRef(),
                        "IN",
                        in.getMedicineId(),
                        in.getMedicineName(),
                        batchNo,
                        0,
                        in.getUnit(),
                        in.getDate(),
                        expiryDate,
                        in.getSupplierOrRecipient(),
                        in.getReasonOrRemarks(),
                        in.getRecordedBy()
                );

                batchMap.put(key, copy);
                batchStock.put(key, 0);
            }

            int current = batchStock.get(key);
            batchStock.put(key, current + in.getQuantity());
        }

        // Total Stock Out per medicine + batch (one pass, no nested scan)
        Map<String, Integer> outTotals = new LinkedHashMap<>();
        for (StockTransaction out : stockOutList) {
            String outKey = (safe(out.getMedicineId()) + "|" + safe(out.getBatchNo())).toLowerCase();
            outTotals.merge(outKey, out.getQuantity(), Integer::sum);
        }

        // Subtract each total from the first stock-in group of that
        // medicine + batch (same result as subtracting row by row)
        Map<String, Boolean> consumed = new LinkedHashMap<>();
        for (Map.Entry<String, StockTransaction> entry : batchMap.entrySet()) {
            StockTransaction batch = entry.getValue();
            String outKey = (safe(batch.getMedicineId()) + "|" + safe(batch.getBatchNo())).toLowerCase();
            Integer totalOut = outTotals.get(outKey);
            if (totalOut == null || consumed.containsKey(outKey)) {
                continue;
            }
            consumed.put(outKey, Boolean.TRUE);
            String key = entry.getKey();
            batchStock.put(key, Math.max(batchStock.get(key) - totalOut, 0));
        }

        List<StockTransaction> expiryList = new ArrayList<>();
        for (Map.Entry<String, StockTransaction> entry : batchMap.entrySet()) {
            String key = entry.getKey();
            int remaining = batchStock.get(key);
            if (remaining <= 0) {
                continue;
            }
            StockTransaction batch = entry.getValue();
            batch.setQuantity(remaining);
            expiryList.add(batch);
        }

        // Sort nearest expiry first
        expiryList.sort((a, b) -> {
            LocalDate dateA = parseDate(a.getExpiryDate());
            LocalDate dateB = parseDate(b.getExpiryDate());
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateA.compareTo(dateB);
        });

        List<StockTransaction> filtered = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (StockTransaction batch : expiryList) {
            LocalDate expiry = parseDate(batch.getExpiryDate());
            if (expiry == null) {
                continue;
            }

            long daysLeft = ChronoUnit.DAYS.between(today, expiry);
            boolean include;

            if ("30".equals(filter)) {
                include = daysLeft > 0 && daysLeft <= 30;
            } else if ("60".equals(filter)) {
                include = daysLeft > 0 && daysLeft <= 60;
            } else if ("90".equals(filter)) {
                include = daysLeft > 0 && daysLeft <= 90;
            } else if ("expired".equals(filter)) {
                include = daysLeft <= 0;
            } else {
                include = true;
            }

            if (include) {
                filtered.add(batch);
            }
        }

        return filtered;
    }

    public int getExpiringBatchesCount(String filter) {
        return getExpiringBatches(filter).size();
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (Exception e) {
            return null;
        }
    }
}
