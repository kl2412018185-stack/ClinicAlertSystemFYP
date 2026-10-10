package com.clinicalert.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class RestockOrder implements Serializable {

    private static final long serialVersionUID = 1L;
    private int orderId, supplierId, requestedBy;
    private String orderNo, supplierName, requesterName, status, approverName, approvalRemarks;
    private Date orderDate, expectedDeliveryDate;
    private Integer approvedBy;
    private Timestamp approvedAt, createdAt;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private List<RestockOrderItem> items = new ArrayList<>();

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int v) {
        orderId = v;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String v) {
        orderNo = v;
    }

    public int getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(int v) {
        supplierId = v;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String v) {
        supplierName = v;
    }

    public int getRequestedBy() {
        return requestedBy;
    }

    public void setRequestedBy(int v) {
        requestedBy = v;
    }

    public String getRequesterName() {
        return requesterName;
    }

    public void setRequesterName(String v) {
        requesterName = v;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date v) {
        orderDate = v;
    }

    public Date getExpectedDeliveryDate() {
        return expectedDeliveryDate;
    }

    public void setExpectedDeliveryDate(Date v) {
        expectedDeliveryDate = v;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String v) {
        status = v;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer v) {
        approvedBy = v;
    }

    public String getApproverName() {
        return approverName;
    }

    public void setApproverName(String v) {
        approverName = v;
    }

    public Timestamp getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Timestamp v) {
        approvedAt = v;
    }

    public String getApprovalRemarks() {
        return approvalRemarks;
    }

    public void setApprovalRemarks(String v) {
        approvalRemarks = v;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal v) {
        totalAmount = v;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp v) {
        createdAt = v;
    }

    public List<RestockOrderItem> getItems() {
        return items;
    }

    public void setItems(List<RestockOrderItem> v) {
        items = v;
    }
}
