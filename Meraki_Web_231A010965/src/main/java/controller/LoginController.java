package controller;

import java.io.IOException;
// Bổ sung các import này để chạy được lệnh SQL
import java.sql.Connection;
import java.sql.PreparedStatement;

import dao.NhanVienDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.NhanVien;
import util.DBConnect;

@WebServlet("/LoginController")
public class LoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        
        NhanVienDAO dao = new NhanVienDAO();
        NhanVien nv = dao.checkLogin(user, pass);
        
        if (nv != null) {
            // ĐĂNG NHẬP THÀNH CÔNG
            HttpSession session = request.getSession();
            session.setAttribute("currentUsername", nv.getTenDangNhap());
            session.setAttribute("currentRole", nv.getQuyen());
            session.setAttribute("currentFullName", nv.getTenNV());
            
            // 🔥 NÂNG CẤP: Logic tạo ca làm việc mới theo chuẩn Z-Report (GIỮ NGUYÊN)
            try (Connection conn = DBConnect.getConnection()) {
                String maChotCa = "CC-" + System.currentTimeMillis() / 1000; // Sinh mã ca độc nhất
                String sql = "INSERT INTO ChotCaLamViec(MaChotCa, Username, MaQuayPOS, ThoiGianMoCa, TienMatDauCa, TrangThai) VALUES(?, ?, 'POS-01', GETDATE(), 2000000, 'DANG_MO')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, maChotCa);
                    ps.setString(2, nv.getTenDangNhap());
                    ps.executeUpdate();
                }
            } catch (Exception e) { 
                System.out.println("❌ Lỗi khi mở ca làm việc:");
                e.printStackTrace(); 
            }

            // XỬ LÝ DANH XƯNG CHO THÔNG BÁO POP-UP
            String roleName = "Nhân viên";
            if (nv.getQuyen() != null && (nv.getQuyen().equalsIgnoreCase("admin") || nv.getQuyen().equalsIgnoreCase("quản lý"))) {
                roleName = "Quản lý";
            }
            
            String alertMessage = "Đăng nhập thành công! Chào mừng " + roleName + " " + nv.getTenNV() + " quay trở lại hệ thống.";
            session.setAttribute("loginNotification", alertMessage);
            
            // 🔥 ĐÃ SỬA LỖI ĐỊNH TUYẾN Ở ĐÂY
            if (roleName.equals("Quản lý")) {
                response.sendRedirect("DashboardController"); // Quản lý thì được vào Bảng điều khiển
            } else {
                response.sendRedirect("POSController"); // Nhân viên ra máy POS bán vé
            }
            return; 
            
        } else {
            // ĐĂNG NHẬP THẤT BẠI
            request.setAttribute("errorMessage", "Sai tài khoản, mật khẩu hoặc tài khoản bị khóa!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return; 
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}