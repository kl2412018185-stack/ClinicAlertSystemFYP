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

@WebServlet(
        name = "UserServlet",
        urlPatterns = {
            "/usermanagement",
            "/users/add",
            "/users/edit",
            "/users/toggle",
            "/users/delete"
        }
)
public class UserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }


    private boolean isAdmin(HttpServletRequest request) {

        HttpSession session = request.getSession(false);

        if (session == null) {
            return false;
        }

        User currentUser =
                (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            return false;
        }

        return currentUser.isAdministrative();
    }


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        User currentUser =
                session != null
                ? (User) session.getAttribute("currentUser")
                : null;

 
        if (currentUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return;
        }


        if (!isAdmin(request)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/dashboard?error=access_denied"
            );

            return;
        }

        String action =
                request.getServletPath();

        String id =
                request.getParameter("id");


        if ("/users/toggle".equals(action)
                && id != null
                && !id.trim().isEmpty()) {

            userDAO.toggleStatus(id);

            response.sendRedirect(
                    request.getContextPath()
                    + "/usermanagement?msg=toggled"
            );

            return;
        }


        if ("/users/delete".equals(action)
                && id != null
                && !id.trim().isEmpty()) {

            boolean deleted =
                    userDAO.deleteUser(id);

            if (deleted) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/usermanagement?msg=deleted"
                );

            } else {

                response.sendRedirect(
                        request.getContextPath()
                        + "/usermanagement?msg=delete_failed"
                );
            }

            return;
        }

        request.setAttribute(
                "userList",
                userDAO.getAllUsers()
        );

        request.getRequestDispatcher(
                "/usermanagement.jsp"
        ).forward(request, response);
    }


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        User currentUser =
                session != null
                ? (User) session.getAttribute("currentUser")
                : null;


        if (currentUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp"
            );

            return;
        }


        if (!isAdmin(request)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/dashboard?error=access_denied"
            );

            return;
        }


        String id =
                request.getParameter("id");

        String staffId =
                request.getParameter("staffId");

        String name =
                request.getParameter("name");

        String role =
                request.getParameter("role");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String status =
                request.getParameter("status");

        String password =
                request.getParameter("password");

        String department =
                request.getParameter("department");

        String branch =
                request.getParameter("branch");

        if (status == null
                || status.trim().isEmpty()) {

            status = "Active";
        }


        if (password == null
                || password.trim().isEmpty()) {

            password = "password123";
        }

        User user = new User(
                id,
                staffId,
                name,
                role,
                email,
                phone,
                status,
                password,
                department,
                branch
        );

        if (id != null
                && !id.trim().isEmpty()
                && userDAO.getUserById(id) != null) {

            userDAO.updateUser(user);

        } else {

            userDAO.addUser(user);
        }

        response.sendRedirect(
                request.getContextPath()
                + "/usermanagement?msg=saved"
        );
    }
}