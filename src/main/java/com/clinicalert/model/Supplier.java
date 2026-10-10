package com.clinicalert.model;

import java.io.Serializable;

public class Supplier implements Serializable {

    private static final long serialVersionUID = 1L;
    private int supplierId;
    private String supplierName, contactPerson, phone, email, address, status;

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

    public String getContactPerson() {
        return contactPerson;
    }

    public void setContactPerson(String v) {
        contactPerson = v;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String v) {
        phone = v;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String v) {
        email = v;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String v) {
        address = v;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String v) {
        status = v;
    }
}
