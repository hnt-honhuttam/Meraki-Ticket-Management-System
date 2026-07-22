package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LogoutController")
public class LogoutController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Lấy Session hiện tại ra
        HttpSession session = request.getSession(false);
        
        // 2. Nếu Session đang tồn tại thì Hủy nó đi (Xóa sạch mọi thông tin đăng nhập)
        if (session != null) {
            session.invalidate();
        }
        
        // 3. Đá về trang đăng nhập
        response.sendRedirect("login.jsp");
    }
}