package com.clinicalert.model;

import java.io.Serializable;

public class StockTransaction implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String transactionRef;
    private String type; // "IN" or "OUT"

    private String medicineId;
    private String medicineName;
    private String batchNo;

    private int quantity;
    private String unit;

    private String date;
    private String expiryDate;

    private String supplierOrRecipient;
    private String reasonOrRemarks;
    private String recordedBy;

    public StockTransaction() {
    }

    public StockTransaction(
            String id,
            String transactionRef,
            String type,
            String medicineId,
            String medicineName,
            String batchNo,
            int quantity,
            String unit,
            String date,
            String expiryDate,
            String supplierOrRecipient,
            String reasonOrRemarks,
            String recordedBy) {
        this.id = id;
        this.transactionRef = transactionRef;
        this.type = type;
        this.medicineId = medicineId;
        this.medicineName = medicineName;
        this.batchNo = batchNo;
        this.quantity = quantity;
        this.unit = unit;
        this.date = date;
        this.expiryDate = expiryDate;
        this.supplierOrRecipient = supplierOrRecipient;
        this.reasonOrRemarks = reasonOrRemarks;
        this.recordedBy = recordedBy;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTransactionRef() {
        return transactionRef;
    }

    public void setTransactionRef(String transactionRef) {
        this.transactionRef = transactionRef;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getMedicineId() {
        return medicineId;
    }

    public void setMedicineId(String medicineId) {
        this.medicineId = medicineId;
    }

    public String getMedicineName() {
        return medicineName;
    }

    public void setMedicineName(String medicineName) {
        this.medicineName = medicineName;
    }

    public String getBatchNo() {
        return batchNo;
    }

    public void setBatchNo(String batchNo) {
        this.batchNo = batchNo;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(String expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getSupplierOrRecipient() {
        return supplierOrRecipient;
    }

    public void setSupplierOrRecipient(String supplierOrRecipient) {
        this.supplierOrRecipient = supplierOrRecipient;
    }

    public String getReasonOrRemarks() {
        return reasonOrRemarks;
    }

    public void setReasonOrRemarks(String reasonOrRemarks) {
        this.reasonOrRemarks = reasonOrRemarks;
    }

    public String getRecordedBy() {
        return recordedBy;
    }

    public void setRecordedBy(String recordedBy) {
        this.recordedBy = recordedBy;
    }

    public long getDaysLeft() {
        if (expiryDate == null || expiryDate.trim().isEmpty()) {
            return 999;
        }
        try {
            java.time.LocalDate exp = java.time.LocalDate.parse(expiryDate.trim());
            java.time.LocalDate now = java.time.LocalDate.now();
            return java.time.temporal.ChronoUnit.DAYS.between(now, exp);
        } catch (Exception e) {
            return 999;
        }
    }

    public int getCurrentStock() {
        return quantity;
    }

    public String getStatus() {
        long days = getDaysLeft();
        if (days <= 0) {
            return "Expired";
        }
        if (days <= 30) {
            return "Expiring Soon";
        }
        return "In Stock";
    }
}