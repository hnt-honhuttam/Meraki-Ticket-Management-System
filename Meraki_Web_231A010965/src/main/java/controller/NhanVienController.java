package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import dao.NhanVienDAO;
import model.NhanVien;

@WebServlet("/NhanVienController")
public class NhanVienController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String currentRole = (String) session.getAttribute("currentRole");
        String currentUsername = (String) session.getAttribute("currentUsername");
        
        // Chỉ Admin mới được vào trang này
        if (currentUsername == null || !"admin".equalsIgnoreCase(currentRole) && !"quản lý".equalsIgnoreCase(currentRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        NhanVienDAO dao = new NhanVienDAO();
        String action = request.getParameter("action");
        String targetUser = request.getParameter("username");

        // 🔥 XỬ LÝ XÓA & BẢO VỆ CHỐNG TỰ XÓA (ANTI SELF-DELETE)
        if ("delete".equals(action) && targetUser != null) {
            if (targetUser.equalsIgnoreCase(currentUsername)) {
                session.setAttribute("notification", "❌ LỖI: Bạn không thể tự xóa tài khoản đang đăng nhập!");
            } else if (targetUser.equalsIgnoreCase("admin")) {
                session.setAttribute("notification", "❌ LỖI: Không thể xóa tài khoản Admin gốc của hệ thống!");
            } else {
                dao.deleteNhanVien(targetUser);
                session.setAttribute("notification", "✅ Đã xóa nhân sự thành công!");
            }
            response.sendRedirect("NhanVienController");
            return;
        }
        
        // 🔥 XỬ LÝ RESET PASSWORD
        if ("reset".equals(action) && targetUser != null) {
            dao.resetPassword(targetUser);
            session.setAttribute("notification", "🔑 Đã Reset mật khẩu của [" + targetUser + "] về: 123456");
            response.sendRedirect("NhanVienController");
            return;
        }

        // TÌM KIẾM & LỌC
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";
        String roleFilter = request.getParameter("roleFilter");
        if (roleFilter == null) roleFilter = "ALL";

        request.setAttribute("listNV", dao.filterNhanVien(keyword, roleFilter));
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentRoleFilter", roleFilter);

        request.getRequestDispatcher("nhanvien.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        NhanVien nv = new NhanVien();
        nv.setTenDangNhap(request.getParameter("username"));
        nv.setTenNV(request.getParameter("hoten"));
        nv.setQuyen(request.getParameter("role"));
        nv.setTrangThai(Integer.parseInt(request.getParameter("status")) == 1);
        
        NhanVienDAO dao = new NhanVienDAO();
        
        if ("add".equals(action)) {
            if (dao.addNhanVien(nv)) {
                request.getSession().setAttribute("notification", "✅ Đã thêm Nhân sự mới! (Mật khẩu mặc định: 123456)");
            } else {
                request.getSession().setAttribute("notification", "❌ Lỗi: Tài khoản (Username) đã tồn tại!");
            }
        } else if ("update".equals(action)) {
            dao.updateNhanVien(nv);
            request.getSession().setAttribute("notification", "✅ Đã cập nhật hồ sơ nhân sự!");
        }
        
        response.sendRedirect("NhanVienController");
    }
}