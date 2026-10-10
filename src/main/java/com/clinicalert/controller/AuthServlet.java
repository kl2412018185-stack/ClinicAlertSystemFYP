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

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth", "/login", "/logout"})
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp?msg=logged_out");
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String staffId = request.getParameter("staffId");
        String password = request.getParameter("password");

        User user = userDAO.authenticate(staffId, password);
        if (user != null && "Active".equalsIgnoreCase(user.getStatus())) {
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("staffName", user.getName());
            session.setAttribute("staffId", user.getStaffId());
            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            request.setAttribute("errorMessage", "Invalid Staff ID or Password. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
