package com.clinicalert.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class RestockOrderItem implements Serializable {
    private static final long serialVersionUID = 1L;
    private int itemId, orderId, quantity;
    private String medicineId; // medicines.item_id, e.g. "MD001"
    private String medicineName, unit;
    private BigDecimal unitPrice = BigDecimal.ZERO, subtotal = BigDecimal.ZERO;

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int v) {
        itemId = v;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int v) {
        orderId = v;
    }

    public String getMedicineId() {
        return medicineId;
    }

    public void setMedicineId(String v) {
        medicineId = v;
    }

    public String getMedicineName() {
        return medicineName;
    }

    public void setMedicineName(String v) {
        medicineName = v;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String v) {
        unit = v;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int v) {
        quantity = v;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal v) {
        unitPrice = v;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal v) {
        subtotal = v;
    }
}
