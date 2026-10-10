package com.clinicalert.dao;

import com.clinicalert.model.User;
import com.clinicalert.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User authenticate(String staffId, String password) {

        String sql = "SELECT * FROM users "
                + "WHERE staff_id = ? "
                + "LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    String storedPassword = rs.getString("password");
                    String status = rs.getString("status");

                    if (status != null
                            && !status.equalsIgnoreCase("Active")) {
                        return null;
                    }

                    if (storedPassword != null
                            && !storedPassword.trim().isEmpty()
                            && password != null
                            && BCrypt.checkpw(password, storedPassword)) {

                        return createUserFromResultSet(rs);
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("[UserDAO] Authentication error:");
            e.printStackTrace();

        } catch (IllegalArgumentException e) {
            System.err.println("[UserDAO] Invalid BCrypt password format:");
            e.printStackTrace();
        }

        return null;
    }

    public List<User> getAllUsers() {

        List<User> users = new ArrayList<>();

        String sql = "SELECT * FROM users ORDER BY user_id ASC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(createUserFromResultSet(rs));
            }

        } catch (SQLException e) {
            System.err.println("[UserDAO] Error getting users:");
            e.printStackTrace();
        }

        return users;
    }

    public User getUserById(String id) {

        String sql = "SELECT * FROM users "
                + "WHERE staff_id = ? "
                + "OR CAST(user_id AS CHAR) = ? "
                + "LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            ps.setString(2, id);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return createUserFromResultSet(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("[UserDAO] Error getting user:");
            e.printStackTrace();
        }

        return null;
    }

    public boolean addUser(User user) {

        String sql = "INSERT INTO users "
                + "(staff_id, full_name, username, password, role, email, phone, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getStaffId());
            ps.setString(2, user.getName());
            ps.setString(3, user.getStaffId());

            String password = user.getPassword();

            if (password != null
                    && !password.trim().isEmpty()
                    && !isBCryptHash(password)) {

                password = hashPassword(password);
            }

            ps.setString(4, password);
            ps.setString(5, user.getRole());
            ps.setString(6, user.getEmail());
            ps.setString(7, user.getPhone());
            ps.setString(8, user.getStatus());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO] Error adding user:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateUser(User updated) {

        String sql = "UPDATE users SET "
                + "full_name = ?, "
                + "password = ?, "
                + "role = ?, "
                + "email = ?, "
                + "phone = ?, "
                + "status = ? "
                + "WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, updated.getName());

            String password = updated.getPassword();

            if (password != null
                    && !password.trim().isEmpty()
                    && !isBCryptHash(password)) {

                password = hashPassword(password);
            }

            ps.setString(2, password);
            ps.setString(3, updated.getRole());
            ps.setString(4, updated.getEmail());
            ps.setString(5, updated.getPhone());
            ps.setString(6, updated.getStatus());
            ps.setString(7, updated.getStaffId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO] Error updating user:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean toggleStatus(String id) {

        String sql = "UPDATE users "
                + "SET status = CASE "
                + "WHEN LOWER(TRIM(status)) = 'active' "
                + "THEN 'Inactive' "
                + "ELSE 'Active' END "
                + "WHERE staff_id = ? "
                + "OR CAST(user_id AS CHAR) = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            ps.setString(2, id);

            int rowsUpdated = ps.executeUpdate();

            System.out.println(
                    "[UserDAO] Toggle status ID: "
                    + id
                    + ", rows updated: "
                    + rowsUpdated
            );

            return rowsUpdated > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO] Error toggling status:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteUser(String id) {

        String sql = "DELETE FROM users "
                + "WHERE staff_id = ? "
                + "OR CAST(user_id AS CHAR) = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            ps.setString(2, id);

            int rowsDeleted = ps.executeUpdate();

            System.out.println(
                    "[UserDAO] Delete user ID: "
                    + id
                    + ", rows deleted: "
                    + rowsDeleted
            );

            return rowsDeleted > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO] Error deleting user:");
            e.printStackTrace();
        }

        return false;
    }

    private String hashPassword(String password) {

        if (password == null || password.trim().isEmpty()) {
            return password;
        }

        return BCrypt.hashpw(
                password,
                BCrypt.gensalt(12)
        );
    }

    private boolean isBCryptHash(String password) {

        return password != null
                && (password.startsWith("$2a$")
                || password.startsWith("$2b$")
                || password.startsWith("$2y$"));
    }

    private User createUserFromResultSet(ResultSet rs)
            throws SQLException {

        User user = new User();

        user.setId(
                String.valueOf(
                        rs.getInt("user_id")
                )
        );

        user.setStaffId(
                rs.getString("staff_id")
        );

        user.setName(
                rs.getString("full_name")
        );

        user.setRole(
                rs.getString("role")
        );

        user.setEmail(
                rs.getString("email")
        );

        user.setPhone(
                rs.getString("phone")
        );

        user.setStatus(
                rs.getString("status")
        );

        user.setPassword(
                rs.getString("password")
        );

        return user;
    }
}