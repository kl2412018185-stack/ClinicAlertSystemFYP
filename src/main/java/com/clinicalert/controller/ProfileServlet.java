package com.clinicalert.controller;

import com.clinicalert.dao.UserDAO;
import com.clinicalert.model.User;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
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

        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        User user = (User) session.getAttribute("currentUser");

        request.setAttribute("user", user);

        String message = request.getParameter("msg");

        if ("updated".equals(message)) {
            request.setAttribute(
                    "successMessage",
                    "Profile updated successfully."
            );
        }

        request.getRequestDispatcher("/profile.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        User user = (User) session.getAttribute("currentUser");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        if (name == null || name.trim().isEmpty()) {
            request.setAttribute(
                    "errorMessage",
                    "Full name cannot be empty."
            );

            request.setAttribute("user", user);

            request.getRequestDispatcher("/profile.jsp")
                    .forward(request, response);

            return;
        }

        user.setName(name.trim());

        user.setEmail(
                email != null ? email.trim() : ""
        );

        user.setPhone(
                phone != null ? phone.trim() : ""
        );

        boolean updated = userDAO.updateUser(user);

        if (updated) {
            session.setAttribute("currentUser", user);

            session.setAttribute(
                    "staffName",
                    user.getName()
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/profile?msg=updated"
            );
        } else {
            request.setAttribute(
                    "errorMessage",
                    "Failed to update profile."
            );

            request.setAttribute("user", user);

            request.getRequestDispatcher("/profile.jsp")
                    .forward(request, response);
        }
    }
}