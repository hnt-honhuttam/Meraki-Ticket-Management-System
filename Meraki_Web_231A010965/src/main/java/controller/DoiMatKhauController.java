package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import dao.NhanVienDAO;

@WebServlet("/DoiMatKhauController")
public class DoiMatKhauController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (request.getSession().getAttribute("currentUsername") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        request.getRequestDispatcher("doimatkhau.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("currentUsername");
        
        if (username == null) { response.sendRedirect("login.jsp"); return; }

        String mkCu = request.getParameter("matKhauCu");
        String mkMoi = request.getParameter("matKhauMoi");
        String xacNhan = request.getParameter("xacNhanMatKhau");

        if (!mkMoi.equals(xacNhan)) {
            session.setAttribute("notification", "❌ Lỗi: Mật khẩu xác nhận không khớp!");
            response.sendRedirect("DoiMatKhauController");
            return;
        }

        NhanVienDAO dao = new NhanVienDAO();
        boolean success = dao.doiMatKhau(username, mkCu, mkMoi);

        if (success) {
            // 🔥 THUẬT TOÁN MỚI: GIỮ LẠI THÔNG BÁO KHI ĐĂNG XUẤT
            
            // 1. Tiêu hủy phiên làm việc hiện tại (Bản chất là Đăng xuất)
            session.invalidate(); 
            
            // 2. Tạo một phiên làm việc MỚI TINH và nhét câu thông báo vào
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("notification", "✅ Đổi mật khẩu thành công! Hệ thống đã tự động đăng xuất, vui lòng đăng nhập lại.");
            
            // 3. Đẩy thẳng về trang Đăng nhập
            response.sendRedirect("login.jsp"); 
        } else {
            session.setAttribute("notification", "❌ Lỗi: Mật khẩu hiện tại không chính xác!");
            response.sendRedirect("DoiMatKhauController");
        }
    }
}