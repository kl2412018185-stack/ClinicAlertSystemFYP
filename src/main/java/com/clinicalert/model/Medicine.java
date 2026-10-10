package com.clinicalert.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Medicine implements Serializable {
    private static final long serialVersionUID = 1L;

    private String medicineId;
    private String name;
    private String category;
    private String batchNo;
    private String unit;
    private int currentStock;
    private int minStock;
    private String supplier;
    private String expiryDate; // YYYY-MM-DD
    private String description;
    private double unitPrice;
    private String location;

    public Medicine() {}

    public Medicine(String medicineId, String name, String category, String batchNo, 
                    String unit, int currentStock, int minStock, String supplier, 
                    String expiryDate, String description, double unitPrice, String location) {
        this.medicineId = medicineId;
        this.name = name;
        this.category = category;
        this.batchNo = batchNo;
        this.unit = unit;
        this.currentStock = currentStock;
        this.minStock = minStock;
        this.supplier = supplier;
        this.expiryDate = expiryDate;
        this.description = description;
        this.unitPrice = unitPrice;
        this.location = location;
    }

    public String getMedicineId() { return medicineId; }
    public void setMedicineId(String medicineId) { this.medicineId = medicineId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getBatchNo() { return batchNo; }
    public void setBatchNo(String batchNo) { this.batchNo = batchNo; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public int getCurrentStock() { return currentStock; }
    public void setCurrentStock(int currentStock) { this.currentStock = currentStock; }

    public int getMinStock() { return minStock; }
    public void setMinStock(int minStock) { this.minStock = minStock; }

    public String getSupplier() { return supplier; }
    public void setSupplier(String supplier) { this.supplier = supplier; }

    public String getExpiryDate() { return expiryDate; }
    public void setExpiryDate(String expiryDate) { this.expiryDate = expiryDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public long getDaysLeft() {
        if (expiryDate == null || expiryDate.isEmpty()) return 999;
        try {
            LocalDate exp = LocalDate.parse(expiryDate);
            LocalDate now = LocalDate.now();
            return ChronoUnit.DAYS.between(now, exp);
        } catch (Exception e) {
            return 999;
        }
    }

    public String getStatus() {
        long days = getDaysLeft();
        if (days <= 0) return "Expired";
        if (currentStock <= minStock * 0.3) return "Critical Low";
        if (currentStock <= minStock) return "Low Stock";
        if (days <= 30) return "Expiring Soon";
        return "In Stock";
    }
}
