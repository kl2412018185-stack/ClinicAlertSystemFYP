package com.clinicalert.controller;

import com.clinicalert.dao.UserDAO;
import com.clinicalert.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(
        name = "ChangePasswordServlet",
        urlPatterns = {"/changepassword"}
)
public class ChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("currentUser") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        String message = request.getParameter("msg");

        if ("success".equals(message)) {

            request.setAttribute(
                    "successMessage",
                    "Password changed successfully."
            );
        }

        request.getRequestDispatcher(
                "/changepassword.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("currentUser") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        User user
                = (User) session.getAttribute("currentUser");

        String currentPassword
                = request.getParameter("currentPassword");

        String newPassword
                = request.getParameter("newPassword");

        String confirmPassword
                = request.getParameter("confirmPassword");

        /*
         * Check empty fields
         */
        if (currentPassword == null
                || newPassword == null
                || confirmPassword == null
                || currentPassword.trim().isEmpty()
                || newPassword.trim().isEmpty()
                || confirmPassword.trim().isEmpty()) {

            request.setAttribute(
                    "errorMessage",
                    "All password fields are required."
            );

            request.getRequestDispatcher(
                    "/changepassword.jsp"
            ).forward(request, response);

            return;
        }

        /*
         * Verify CURRENT password using BCrypt.
         */
        boolean currentPasswordCorrect = false;

        try {

            currentPasswordCorrect
                    = BCrypt.checkpw(
                            currentPassword,
                            user.getPassword()
                    );

        } catch (IllegalArgumentException e) {

            currentPasswordCorrect = false;
        }

        if (!currentPasswordCorrect) {

            request.setAttribute(
                    "errorMessage",
                    "Current password is incorrect."
            );

            request.getRequestDispatcher(
                    "/changepassword.jsp"
            ).forward(request, response);

            return;
        }

        /*
         * Check minimum password length.
         */
        if (newPassword.length() < 6) {

            request.setAttribute(
                    "errorMessage",
                    "New password must be at least 6 characters."
            );

            request.getRequestDispatcher(
                    "/changepassword.jsp"
            ).forward(request, response);

            return;
        }

        /*
         * Check whether new password and confirmation match.
         *
         * This is handled separately so the JSP can show:
         * "* Password not match"
         * directly below Confirm New Password.
         */
        if (!newPassword.equals(confirmPassword)) {

            request.setAttribute(
                    "passwordMismatch",
                    true
            );

            request.getRequestDispatcher(
                    "/changepassword.jsp"
            ).forward(request, response);

            return;
        }

        /*
         * Hash NEW password using BCrypt before
         * saving it into the database.
         */
        String hashedPassword
                = BCrypt.hashpw(
                        newPassword,
                        BCrypt.gensalt(12)
                );

        user.setPassword(hashedPassword);

        /*
         * Update user record.
         */
        boolean updated
                = userDAO.updateUser(user);

        if (updated) {

            /*
             * Update current session with the new
             * hashed password.
             */
            session.setAttribute(
                    "currentUser",
                    user
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/changepassword?msg=success"
            );

        } else {

            request.setAttribute(
                    "errorMessage",
                    "Failed to change password."
            );

            request.getRequestDispatcher(
                    "/changepassword.jsp"
            ).forward(request, response);
        }
    }
}
