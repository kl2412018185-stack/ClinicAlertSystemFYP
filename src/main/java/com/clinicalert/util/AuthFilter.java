package com.clinicalert.util;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Requires a logged-in user for every page and API except the login
 * flow and static assets. API calls get a 401 instead of a redirect.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {
    // init/destroy are not default methods before Servlet 4.0, and
    // XAMPP's Tomcat 8.5 only provides Servlet 3.1.
    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void destroy() {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();

        if (isPublic(path)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            chain.doFilter(req, res);
            return;
        }

        if (path.startsWith("/api/")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().print("{\"error\":\"Login required.\"}");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    private boolean isPublic(String path) {
        return path.equals("/login")
                || path.equals("/auth")
                || path.equals("/logout")
                || path.equals("/login.jsp")
                || path.equals("/logout.jsp")
                || path.equals("/index.jsp")
                || path.isEmpty()
                || path.equals("/")
                || path.startsWith("/css/")
                || path.startsWith("/js/");
    }
}
