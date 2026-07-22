package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.HoaDonDAO;

@WebServlet("/ChotCaController")
public class ChotCaController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Fix lỗi UTF-8 nếu thu ngân gõ Tiếng Việt trong ô Ghi chú
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("currentUsername");
        
        // 🔥 NÂNG CẤP: Lấy tên đầy đủ của nhân viên từ Session
        String fullName = (String) session.getAttribute("currentFullName");
        
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Đón dữ liệu Tự đếm (Blind Close) từ giao diện POS gửi sang
        double tienThucDem = 0;
        try {
            String t = request.getParameter("tienThucDem");
            if (t != null && !t.isEmpty()) {
                tienThucDem = Double.parseDouble(t);
            }
        } catch (Exception e) {}
        
        String ghiChu = request.getParameter("ghiChu");
        if (ghiChu == null) ghiChu = "";

        HoaDonDAO dao = new HoaDonDAO();
        
        // 1. Lấy mảng dữ liệu: [0]: Tổng Doanh Thu, [1]: Số Bill, [2]: Tiền mặt, [3]: QR/CK
        double[] thongKe = dao.thongKeDoanhThuCa(username);
        
        // 2. Thực hiện đóng ca (Xử lý thuật toán đối soát ngầm dưới CSDL)
        boolean isClosed = dao.dongCaLamViec(username, tienThucDem, ghiChu);
        
        if (isClosed) {
            // Bắt buộc đăng nhập lại vào ca mới
            session.invalidate(); 
            
            // Gửi dữ liệu qua trang Phieuchotca.jsp để in Z-Report
            request.setAttribute("tongTien", thongKe[0]);
            request.setAttribute("soHoaDon", (int)thongKe[1]);
            request.setAttribute("dtTienMat", thongKe[2]);
            request.setAttribute("dtChuyenKhoan", thongKe[3]);
            request.setAttribute("tienThucDem", tienThucDem);
            
            // Gửi cả Username (để lưu Log) và FullName (để in báo cáo đẹp)
            request.setAttribute("nguoiChot", username);
            request.setAttribute("tenNhanVien", fullName != null ? fullName : username); 
            
            request.getRequestDispatcher("phieuchotca.jsp").forward(request, response);
        } else {
            response.sendRedirect("DashboardController");
        }
    }
}