package com.clinicalert.model;

import java.io.Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String staffId;
    private String name;
    private String role; // "Clinic Owner", "Doctor", "Senior Clinic Assistant", "Clinic Assistant"
    private String email;
    private String phone;
    private String status; // "Active", "Inactive"
    private String password;
    private String department;
    private String branch;
    private String lastLogin;

    public User() {}

    public User(String id, String staffId, String name, String role, String email, 
                String phone, String status, String password, String department, String branch) {
        this.id = id;
        this.staffId = staffId;
        this.name = name;
        this.role = role;
        this.email = email;
        this.phone = phone;
        this.status = status;
        this.password = password;
        this.department = department;
        this.branch = branch;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getStaffId() { return staffId; }
    public void setStaffId(String staffId) { this.staffId = staffId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getBranch() { return branch; }
    public void setBranch(String branch) { this.branch = branch; }

    public String getLastLogin() { return lastLogin; }
    public void setLastLogin(String lastLogin) { this.lastLogin = lastLogin; }

    /**
     * Admin-level access (user management, admin menus). Plain assistants
     * are not administrative. Accepts both role vocabularies: the database
     * seed ("Admin", "Senior Assistant", "Assistant") and the original
     * design ("Clinic Owner", "Senior Clinic Assistant", "Clinic Assistant").
     */
    public boolean isAdministrative() {
        return isAdminRole();
    }

    public boolean isAdminRole() {
        if (role == null) {
            return false;
        }
        String r = role.trim();
        return r.equalsIgnoreCase("Admin")
                || r.equalsIgnoreCase("Administrator")
                || r.equalsIgnoreCase("Clinic Owner")
                || r.equalsIgnoreCase("Doctor")
                || r.equalsIgnoreCase("Senior Assistant")
                || r.equalsIgnoreCase("Senior Clinic Assistant");
    }
}
