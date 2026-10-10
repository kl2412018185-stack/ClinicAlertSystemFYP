package com.clinicalert.dao;

import com.clinicalert.model.Medicine;
import com.clinicalert.model.StockTransaction;
import com.clinicalert.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MedicineDAO {
    public static class StockBatch {
        private String batchNo;
        private int quantity;
        private String expiryDate;

        public StockBatch(
                String batchNo,
                int quantity,
                String expiryDate) {
            this.batchNo = batchNo;
            this.quantity = quantity;
            this.expiryDate = expiryDate;
        }

        public String getBatchNo() {
            return batchNo;
        }

        public int getQuantity() {
            return quantity;
        }

        public String getExpiryDate() {
            return expiryDate;
        }
    }

    public List<Medicine> getAllMedicines() {
        List<Medicine> medicines = new ArrayList<>();

        String sql
                = "SELECT medicine_id, item_id, medicine_name, category, "
                + "batch_no, unit, current_stock, minimum_stock, supplier, "
                + "expiry_date, description, unit_price, location, status "
                + "FROM medicines "
                + "WHERE status = 'Active' "
                + "ORDER BY medicine_id ASC";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                medicines.add(createMedicineFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error getting medicines:"
            );
            e.printStackTrace();
        }

        return medicines;
    }

    public Medicine getMedicineById(String id) {
        if (id == null || id.trim().isEmpty()) {
            return null;
        }

        String sql
                = "SELECT medicine_id, item_id, medicine_name, category, "
                + "batch_no, unit, current_stock, minimum_stock, supplier, "
                + "expiry_date, description, unit_price, location, status "
                + "FROM medicines "
                + "WHERE item_id = ? "
                + "OR CAST(medicine_id AS CHAR) = ? "
                + "LIMIT 1";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return createMedicineFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error getting medicine:"
            );
            e.printStackTrace();
        }

        return null;
    }

    public static class BatchSummary {
        private final String itemId;
        private final String medicineName;
        private final String batchNo;
        private final String expiryDate;
        private final int received;
        private final int issued;

        public BatchSummary(String itemId, String medicineName, String batchNo,
                String expiryDate, int received, int issued) {
            this.itemId = itemId;
            this.medicineName = medicineName;
            this.batchNo = batchNo;
            this.expiryDate = expiryDate;
            this.received = received;
            this.issued = issued;
        }

        public String getItemId() {
            return itemId;
        }

        public String getMedicineName() {
            return medicineName;
        }

        public String getBatchNo() {
            return batchNo;
        }

        public String getExpiryDate() {
            return expiryDate;
        }

        public int getReceived() {
            return received;
        }

        public int getIssued() {
            return issued;
        }

        public int getRemaining() {
            return Math.max(0, received - issued);
        }
    }

    public List<BatchSummary> getBatchSummaries() {
        List<BatchSummary> batches = new ArrayList<>();

        String sql
                = "SELECT si.item_id, m.medicine_name, si.batch_no, "
                + "MAX(si.expiry_date) AS expiry_date, "
                + "SUM(si.quantity) AS received, "
                + "COALESCE((SELECT SUM(COALESCE(so.quantity_out, so.quantity, 0)) "
                + "          FROM stock_out so "
                + "          WHERE so.item_id = si.item_id "
                + "          AND so.batch_no = si.batch_no), 0) AS issued "
                + "FROM stock_in si "
                + "INNER JOIN medicines m ON m.item_id = si.item_id "
                + "WHERE si.batch_no IS NOT NULL AND TRIM(si.batch_no) <> '' "
                + "GROUP BY si.item_id, m.medicine_name, si.batch_no "
                + "ORDER BY MAX(si.received_date) DESC, si.item_id, si.batch_no";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String expiry = rs.getString("expiry_date");
                batches.add(new BatchSummary(
                        rs.getString("item_id"),
                        rs.getString("medicine_name"),
                        rs.getString("batch_no"),
                        expiry == null ? "" : expiry,
                        rs.getInt("received"),
                        rs.getInt("issued")));
            }
        } catch (SQLException e) {
            System.err.println("[MedicineDAO] Error getting batch summaries:");
            e.printStackTrace();
        }

        return batches;
    }

    // Removes every stock_in and stock_out row of the batch and
    // takes the batch's remaining quantity off current_stock,
    // all in one transaction.
    public boolean deleteBatch(String itemId, String batchNo) {
        if (itemId == null || itemId.trim().isEmpty()
                || batchNo == null || batchNo.trim().isEmpty()) {
            return false;
        }

        String remainingSql
                = "SELECT "
                + "COALESCE((SELECT SUM(quantity) FROM stock_in "
                + "          WHERE item_id = ? AND batch_no = ?), 0) "
                + "- COALESCE((SELECT SUM(COALESCE(quantity_out, quantity, 0)) FROM stock_out "
                + "          WHERE item_id = ? AND batch_no = ?), 0) AS remaining";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int remaining;

                try (PreparedStatement ps = conn.prepareStatement(remainingSql)) {
                    ps.setString(1, itemId);
                    ps.setString(2, batchNo);
                    ps.setString(3, itemId);
                    ps.setString(4, batchNo);
                    try (ResultSet rs = ps.executeQuery()) {
                        remaining = rs.next() ? Math.max(0, rs.getInt("remaining")) : 0;
                    }
                }

                int deletedIn;
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM stock_in WHERE item_id = ? AND batch_no = ?")) {
                    ps.setString(1, itemId);
                    ps.setString(2, batchNo);
                    deletedIn = ps.executeUpdate();
                }

                if (deletedIn == 0) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM stock_out WHERE item_id = ? AND batch_no = ?")) {
                    ps.setString(1, itemId);
                    ps.setString(2, batchNo);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE medicines SET current_stock = GREATEST(0, current_stock - ?) "
                        + "WHERE item_id = ?")) {
                    ps.setInt(1, remaining);
                    ps.setString(2, itemId);
                    ps.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[MedicineDAO] Error deleting batch:");
            e.printStackTrace();
        }

        return false;
    }

    public List<StockBatch> getStockBatches(String medicineId) {
        List<StockBatch> batches = new ArrayList<>();

        if (medicineId == null
                || medicineId.trim().isEmpty()) {
            return batches;
        }

        String sql
                = "SELECT "
                + "batch_no, "
                + "SUM(quantity) AS total_quantity, "
                + "MAX(expiry_date) AS expiry_date "
                + "FROM stock_in "
                + "WHERE item_id = ? "
                + "GROUP BY batch_no "
                + "ORDER BY expiry_date ASC, batch_no ASC";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, medicineId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String batchNo
                            = rs.getString("batch_no");

                    int quantity
                            = rs.getInt("total_quantity");

                    String expiryDate
                            = rs.getString("expiry_date");

                    if (batchNo == null
                            || batchNo.trim().isEmpty()) {
                        continue;
                    }

                    if (expiryDate == null) {
                        expiryDate = "";
                    }

                    batches.add(
                            new StockBatch(
                                    batchNo,
                                    quantity,
                                    expiryDate
                            )
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error getting stock batches:"
            );
            e.printStackTrace();
        }

        return batches;
    }

    public Map<String, List<StockBatch>> getAllStockBatches() {
        Map<String, List<StockBatch>> batchesByMedicine
                = new HashMap<>();

        String sql
                = "SELECT "
                + "si.item_id, "
                + "si.batch_no, "
                + "MAX(si.expiry_date) AS expiry_date, "
                + "GREATEST(0, COALESCE(SUM(si.quantity), 0) - COALESCE(( "
                + "    SELECT SUM(COALESCE(so.quantity_out, so.quantity, 0)) "
                + "    FROM stock_out so "
                + "    INNER JOIN medicines m ON so.medicine_id = m.medicine_id OR so.item_id = m.item_id "
                + "    WHERE (m.item_id = si.item_id OR CAST(m.medicine_id AS CHAR) = si.item_id) "
                + "      AND so.batch_no = si.batch_no "
                + "), 0)) AS available_quantity "
                + "FROM stock_in si "
                + "WHERE si.batch_no IS NOT NULL "
                + "AND TRIM(si.batch_no) <> '' "
                + "GROUP BY si.item_id, si.batch_no "
                + "ORDER BY si.item_id ASC, "
                + "MAX(si.received_date) ASC, "
                + "si.batch_no ASC";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String medicineId
                        = rs.getString("item_id");

                String batchNo
                        = rs.getString("batch_no");

                String expiryDate
                        = rs.getString("expiry_date");

                int availableQuantity
                        = rs.getInt("available_quantity");

                if (medicineId == null
                        || medicineId.trim().isEmpty()) {
                    continue;
                }

                if (batchNo == null
                        || batchNo.trim().isEmpty()) {
                    continue;
                }

                if (expiryDate == null) {
                    expiryDate = "";
                }

                batchesByMedicine
                        .computeIfAbsent(
                                medicineId,
                                k -> new ArrayList<>()
                        )
                        .add(
                                new StockBatch(
                                        batchNo,
                                        availableQuantity,
                                        expiryDate
                                )
                        );
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error getting all stock-in batches:"
            );

            e.printStackTrace();
        }

        return batchesByMedicine;
    }

    public int getBatchStock(
            String medicineId,
            String batchNo) {
        if (medicineId == null
                || medicineId.trim().isEmpty()
                || batchNo == null
                || batchNo.trim().isEmpty()) {
            return 0;
        }

        String sql
                = "SELECT "
                + "GREATEST(0, COALESCE(( "
                + "    SELECT SUM(si.quantity) "
                + "    FROM stock_in si "
                + "    INNER JOIN medicines m ON si.item_id = m.item_id "
                + "    WHERE (m.item_id = ? OR CAST(m.medicine_id AS CHAR) = ?) "
                + "    AND si.batch_no = ? "
                + "), 0) "
                + "- "
                + "COALESCE(( "
                + "    SELECT SUM(COALESCE(so.quantity_out, so.quantity, 0)) "
                + "    FROM stock_out so "
                + "    INNER JOIN medicines m "
                + "        ON so.medicine_id = m.medicine_id OR so.item_id = m.item_id "
                + "    WHERE (m.item_id = ? OR CAST(m.medicine_id AS CHAR) = ?) "
                + "    AND so.batch_no = ? "
                + "), 0)) "
                + "AS available_stock";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, medicineId);
            ps.setString(2, medicineId);
            ps.setString(3, batchNo);
            ps.setString(4, medicineId);
            ps.setString(5, medicineId);
            ps.setString(6, batchNo);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Math.max(
                            0,
                            rs.getInt("available_stock")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error checking batch stock:"
            );

            e.printStackTrace();
        }

        return 0;
    }

    public boolean addMedicine(Medicine med) {
        String sql
                = "INSERT INTO medicines "
                + "(item_id, medicine_name, category, batch_no, unit, "
                + "current_stock, minimum_stock, supplier, expiry_date, "
                + "description, unit_price, location, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, med.getMedicineId());
            ps.setString(2, med.getName());
            ps.setString(3, med.getCategory() == null ? "" : med.getCategory().trim());
            ps.setString(4, med.getBatchNo() == null ? "" : med.getBatchNo().trim());
            ps.setString(5, med.getUnit() == null ? "" : med.getUnit().trim());
            ps.setInt(6, med.getCurrentStock());
            ps.setInt(7, med.getMinStock());
            ps.setString(8, med.getSupplier() == null ? "" : med.getSupplier().trim());
            if (med.getExpiryDate() != null && !med.getExpiryDate().trim().isEmpty()) {
                ps.setString(9, med.getExpiryDate().trim());
            } else {
                ps.setNull(9, java.sql.Types.DATE);
            }
            ps.setString(10, med.getDescription() == null ? "" : med.getDescription().trim());
            ps.setDouble(11, med.getUnitPrice());
            ps.setString(12, med.getLocation() == null || med.getLocation().trim().isEmpty() ? "Main Pharmacy" : med.getLocation().trim());
            ps.setString(13, "Active");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error adding medicine: " + e.getMessage()
            );

            e.printStackTrace();
        }

        return false;
    }

    public boolean updateMedicine(Medicine updated) {
        String sql
                = "UPDATE medicines SET "
                + "medicine_name = ?, "
                + "category = ?, "
                + "batch_no = ?, "
                + "unit = ?, "
                + "current_stock = ?, "
                + "minimum_stock = ?, "
                + "supplier = ?, "
                + "expiry_date = ?, "
                + "description = ?, "
                + "unit_price = ?, "
                + "location = ? "
                + "WHERE item_id = ? "
                + "OR CAST(medicine_id AS CHAR) = ?";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, updated.getName());
            ps.setString(2, updated.getCategory() == null ? "" : updated.getCategory().trim());
            ps.setString(3, updated.getBatchNo() == null ? "" : updated.getBatchNo().trim());
            ps.setString(4, updated.getUnit() == null ? "" : updated.getUnit().trim());
            ps.setInt(5, updated.getCurrentStock());
            ps.setInt(6, updated.getMinStock());
            ps.setString(7, updated.getSupplier() == null ? "" : updated.getSupplier().trim());
            if (updated.getExpiryDate() != null && !updated.getExpiryDate().trim().isEmpty()) {
                ps.setString(8, updated.getExpiryDate().trim());
            } else {
                ps.setNull(8, java.sql.Types.DATE);
            }
            ps.setString(9, updated.getDescription() == null ? "" : updated.getDescription().trim());
            ps.setDouble(10, updated.getUnitPrice());
            ps.setString(11, updated.getLocation() == null || updated.getLocation().trim().isEmpty() ? "Main Pharmacy" : updated.getLocation().trim());
            ps.setString(12, updated.getMedicineId());
            ps.setString(13, updated.getMedicineId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error updating medicine: " + e.getMessage()
            );

            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteMedicine(String id) {
        String itemId = id;
        Medicine med = getMedicineById(id);
        if (med != null && med.getMedicineId() != null) {
            itemId = med.getMedicineId();
        }

        String sqlDeleteMed = "DELETE FROM medicines WHERE item_id = ? OR CAST(medicine_id AS CHAR) = ?";
        String sqlDeleteIn = "DELETE FROM stock_in WHERE item_id = ?";
        String sqlDeleteOut = "DELETE FROM stock_out WHERE item_id = ?";
        String sqlDeleteRestock = "DELETE FROM restock_order_items WHERE item_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement psRestock = conn.prepareStatement(sqlDeleteRestock)) {
                    psRestock.setString(1, itemId);
                    psRestock.executeUpdate();
                }
                try (PreparedStatement psOut = conn.prepareStatement(sqlDeleteOut)) {
                    psOut.setString(1, itemId);
                    psOut.executeUpdate();
                }
                try (PreparedStatement psIn = conn.prepareStatement(sqlDeleteIn)) {
                    psIn.setString(1, itemId);
                    psIn.executeUpdate();
                }
                int deleted;
                try (PreparedStatement psMed = conn.prepareStatement(sqlDeleteMed)) {
                    psMed.setString(1, itemId);
                    psMed.setString(2, id);
                    deleted = psMed.executeUpdate();
                }
                conn.commit();
                return deleted > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[MedicineDAO] Error deleting medicine: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public List<Medicine> getLowStockMedicines() {
        List<Medicine> medicines = new ArrayList<>();

        String sql
                = "SELECT medicine_id, item_id, medicine_name, category, "
                + "batch_no, unit, current_stock, minimum_stock, supplier, "
                + "expiry_date, description, unit_price, location, status "
                + "FROM medicines "
                + "WHERE current_stock > 0 "
                + "AND current_stock <= minimum_stock "
                + "AND status = 'Active' "
                + "ORDER BY current_stock ASC";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                medicines.add(
                        createMedicineFromResultSet(rs)
                );
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error getting low stock medicines:"
            );

            e.printStackTrace();
        }

        return medicines;
    }

    public List<Medicine> getExpiringSoonMedicines(
            int daysThreshold) {
        List<StockTransaction> batches =
                new TransactionDAO().getExpiringBatches(String.valueOf(daysThreshold));

        List<Medicine> medicines = new ArrayList<>();
        for (StockTransaction batch : batches) {
            Medicine m = new Medicine();
            m.setMedicineId(batch.getMedicineId());
            m.setName(batch.getMedicineName());
            m.setBatchNo(batch.getBatchNo());
            m.setUnit(batch.getUnit());
            m.setCurrentStock(batch.getQuantity());
            m.setExpiryDate(batch.getExpiryDate());
            medicines.add(m);
        }

        return medicines;
    }

    public boolean adjustStock(
            String medicineId,
            int quantityChange) {
        String sql
                = "UPDATE medicines "
                + "SET current_stock = current_stock + ? "
                + "WHERE item_id = ? "
                + "OR CAST(medicine_id AS CHAR) = ?";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantityChange);
            ps.setString(2, medicineId);
            ps.setString(3, medicineId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error adjusting stock:"
            );

            e.printStackTrace();
        }

        return false;
    }

    public String generateNextItemId() {
        String sql = "SELECT MAX(CAST(SUBSTRING(item_id, 3) AS UNSIGNED)) AS max_num "
                   + "FROM medicines WHERE item_id LIKE 'MD%'";

        try (
                Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int maxNum = rs.getInt("max_num");
                int nextNum = maxNum > 0 ? maxNum + 1 : 1;
                return String.format("MD%03d", nextNum);
            }
        } catch (SQLException e) {
            System.err.println(
                    "[MedicineDAO] Error generating item ID: " + e.getMessage()
            );

            e.printStackTrace();
        }

        return "MD001";
    }

    private Medicine createMedicineFromResultSet(
            ResultSet rs) throws SQLException {
        Medicine medicine = new Medicine();

        medicine.setMedicineId(
                rs.getString("item_id")
        );

        medicine.setName(
                rs.getString("medicine_name")
        );

        medicine.setCategory(
                rs.getString("category") == null
                ? ""
                : rs.getString("category")
        );

        medicine.setSupplier(
                rs.getString("supplier") == null
                ? ""
                : rs.getString("supplier")
        );

        medicine.setUnit(
                rs.getString("unit") == null
                ? ""
                : rs.getString("unit")
        );

        medicine.setCurrentStock(
                rs.getInt("current_stock")
        );

        medicine.setMinStock(
                rs.getInt("minimum_stock")
        );

        medicine.setBatchNo(
                rs.getString("batch_no") == null
                ? ""
                : rs.getString("batch_no")
        );

        medicine.setExpiryDate(
                rs.getString("expiry_date") == null
                ? ""
                : rs.getString("expiry_date")
        );

        medicine.setDescription(
                rs.getString("description") == null
                ? ""
                : rs.getString("description")
        );

        medicine.setUnitPrice(
                rs.getDouble("unit_price")
        );

        medicine.setLocation(
                rs.getString("location") == null
                ? ""
                : rs.getString("location")
        );

        return medicine;
    }
}
