package com.clinicalert.dao;

import com.clinicalert.model.*;
import com.clinicalert.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestockDAO {

    public List<Supplier> getActiveSuppliers() {
        List<Supplier> l = new ArrayList<>();
        String q = "SELECT supplier_id,supplier_name,contact_person,phone,email,address,status FROM suppliers WHERE status='Active' ORDER BY supplier_name";
        try (Connection c = DBConnection.getConnection(); PreparedStatement p = c.prepareStatement(q); ResultSet r = p.executeQuery()) {
            while (r.next()) {
                Supplier s = new Supplier();
                s.setSupplierId(r.getInt("supplier_id"));
                s.setSupplierName(r.getString("supplier_name"));
                s.setContactPerson(r.getString("contact_person"));
                s.setPhone(r.getString("phone"));
                s.setEmail(r.getString("email"));
                s.setAddress(r.getString("address"));
                s.setStatus(r.getString("status"));
                l.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return l;
    }

    public List<RestockOrder> getAllOrders() {
        List<RestockOrder> l = new ArrayList<>();
        String q = "SELECT ro.*,s.supplier_name,u.full_name requester_name,au.full_name approver_name FROM restock_orders ro JOIN suppliers s ON s.supplier_id=ro.supplier_id JOIN users u ON u.user_id=ro.requested_by LEFT JOIN users au ON au.user_id=ro.approved_by ORDER BY ro.order_id DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement p = c.prepareStatement(q); ResultSet r = p.executeQuery()) {
            while (r.next()) {
                l.add(map(r));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return l;
    }

    public RestockOrder getOrderById(int id) {
        String q = "SELECT ro.*,s.supplier_name,u.full_name requester_name,au.full_name approver_name FROM restock_orders ro JOIN suppliers s ON s.supplier_id=ro.supplier_id JOIN users u ON u.user_id=ro.requested_by LEFT JOIN users au ON au.user_id=ro.approved_by WHERE ro.order_id=?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement p = c.prepareStatement(q)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    RestockOrder o = map(r);
                    o.setItems(getItems(c, id));
                    return o;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private List<RestockOrderItem> getItems(Connection c, int id) throws SQLException {
        List<RestockOrderItem> l = new ArrayList<>();
        String q = "SELECT i.order_item_id,i.order_id,i.item_id,i.quantity,i.unit_price,i.quantity*i.unit_price AS subtotal,m.medicine_name,m.unit FROM restock_order_items i JOIN medicines m ON m.item_id=i.item_id WHERE i.order_id=? ORDER BY i.order_item_id";
        try (PreparedStatement p = c.prepareStatement(q)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    RestockOrderItem i = new RestockOrderItem();
                    i.setItemId(r.getInt("order_item_id"));
                    i.setOrderId(r.getInt("order_id"));
                    i.setMedicineId(r.getString("item_id"));
                    i.setMedicineName(r.getString("medicine_name"));
                    i.setUnit(r.getString("unit"));
                    i.setQuantity(r.getInt("quantity"));
                    i.setUnitPrice(r.getBigDecimal("unit_price"));
                    i.setSubtotal(r.getBigDecimal("subtotal"));
                    l.add(i);
                }
            }
        }
        return l;
    }

    private RestockOrder map(ResultSet r) throws SQLException {
        RestockOrder o = new RestockOrder();
        o.setOrderId(r.getInt("order_id"));
        o.setOrderNo(r.getString("order_no"));
        o.setSupplierId(r.getInt("supplier_id"));
        o.setSupplierName(r.getString("supplier_name"));
        o.setRequestedBy(r.getInt("requested_by"));
        o.setRequesterName(r.getString("requester_name"));
        o.setOrderDate(r.getDate("order_date"));
        o.setExpectedDeliveryDate(r.getDate("expected_delivery_date"));
        o.setStatus(r.getString("status"));
        int a = r.getInt("approved_by");
        o.setApprovedBy(r.wasNull() ? null : a);
        o.setApproverName(r.getString("approver_name"));
        o.setApprovedAt(r.getTimestamp("approved_at"));
        o.setApprovalRemarks(r.getString("approval_remarks"));
        o.setTotalAmount(r.getBigDecimal("total_amount"));
        o.setCreatedAt(r.getTimestamp("created_at"));
        return o;
    }

    public int createOrder(int supplierId, int requestedBy, Date orderDate, Date expected, List<RestockOrderItem> items) throws SQLException {
        if (items == null || items.isEmpty()) {
            throw new SQLException("At least one medicine item is required.");
        }
        String no = "PO-" + new java.text.SimpleDateFormat("yyyyMMdd-HHmmss").format(new java.util.Date());
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                int id;
                String q = "INSERT INTO restock_orders(order_no,supplier_id,requested_by,order_date,expected_delivery_date,status,total_amount) VALUES(?,?,?,?,?,'Pending Approval',0)";
                try (PreparedStatement p = c.prepareStatement(q, Statement.RETURN_GENERATED_KEYS)) {
                    p.setString(1, no);
                    p.setInt(2, supplierId);
                    p.setInt(3, requestedBy);
                    p.setDate(4, orderDate);
                    if (expected == null) {
                        p.setNull(5, Types.DATE);
                    } else {
                        p.setDate(5, expected);
                    }
                    p.executeUpdate();
                    try (ResultSet k = p.getGeneratedKeys()) {
                        if (!k.next()) {
                            throw new SQLException("Unable to create restock order.");
                        }
                        id = k.getInt(1);
                    }
                }
                BigDecimal total = BigDecimal.ZERO;
                q = "INSERT INTO restock_order_items(order_id,item_id,medicine_id,quantity,unit_price,subtotal) VALUES(?,?,(SELECT medicine_id FROM medicines WHERE item_id=? LIMIT 1),?,?,?)";
                try (PreparedStatement p = c.prepareStatement(q)) {
                    for (RestockOrderItem i : items) {
                        if (i.getQuantity() <= 0) {
                            throw new SQLException("Quantity must be greater than 0.");
                        }
                        BigDecimal price = i.getUnitPrice() == null ? BigDecimal.ZERO : i.getUnitPrice();
                        BigDecimal sub = price.multiply(BigDecimal.valueOf(i.getQuantity()));
                        p.setInt(1, id);
                        p.setString(2, i.getMedicineId());
                        p.setString(3, i.getMedicineId());
                        p.setInt(4, i.getQuantity());
                        p.setBigDecimal(5, price);
                        p.setBigDecimal(6, sub);
                        p.addBatch();
                        total = total.add(sub);
                    }
                    p.executeBatch();
                }
                q = "UPDATE restock_orders SET total_amount=? WHERE order_id=?";
                try (PreparedStatement p = c.prepareStatement(q)) {
                    p.setBigDecimal(1, total);
                    p.setInt(2, id);
                    p.executeUpdate();
                }
                c.commit();
                return id;
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public boolean updateApproval(int orderId, int doctorId, boolean approve, String remarks) throws SQLException {
        String q = "UPDATE restock_orders SET status=?,approved_by=?,approved_at=NOW(),approval_remarks=? WHERE order_id=? AND status='Pending Approval'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement p = c.prepareStatement(q)) {
            p.setString(1, approve ? "Approved" : "Rejected");
            p.setInt(2, doctorId);
            p.setString(3, remarks == null ? "" : remarks.trim());
            p.setInt(4, orderId);
            return p.executeUpdate() > 0;
        }
    }

    public boolean markOrdered(int orderId) throws SQLException {
        String q = "UPDATE restock_orders SET status='Ordered' WHERE order_id=? AND status='Approved'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement p = c.prepareStatement(q)) {
            p.setInt(1, orderId);
            return p.executeUpdate() > 0;
        }
    }
}
