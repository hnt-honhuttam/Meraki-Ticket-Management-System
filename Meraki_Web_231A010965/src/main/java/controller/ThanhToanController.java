package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import dao.HoaDonDAO;

@WebServlet("/ThanhToanController")
public class ThanhToanController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json"); // Trả về dạng JSON
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("currentUsername");
        
        if (username == null) {
            out.print("{\"status\":\"error\", \"message\":\"Hết phiên làm việc. Vui lòng đăng nhập lại!\"}");
            out.flush(); return;
        }

        try {
            String tongTienStr = request.getParameter("tongTien");
            String payMethod = request.getParameter("payMethod");
            String[] arrMaVe = request.getParameterValues("maVe");
            String[] arrSoLuong = request.getParameterValues("soLuong");
            String[] arrGiaBan = request.getParameterValues("giaBan");

            if (arrMaVe == null || arrMaVe.length == 0) {
                out.print("{\"status\":\"error\", \"message\":\"Giỏ hàng đang trống!\"}");
                out.flush(); return;
            }

            double tongTien = Double.parseDouble(tongTienStr);
            HoaDonDAO dao = new HoaDonDAO();
            
            // Lấy mã HD thật sự từ Database
            String result = dao.thanhToanGiaoDich(username, tongTien, payMethod, arrMaVe, arrSoLuong, arrGiaBan);

            try {
                int maHD = Integer.parseInt(result);
                // Báo thành công và gửi kèm mã HD về cho màn hình POS in ra
                out.print("{\"status\":\"success\", \"maHD\":\"" + maHD + "\"}");
            } catch (NumberFormatException e) {
                out.print("{\"status\":\"error\", \"message\":\"" + result.replace("\"", "'") + "\"}");
            }
        } catch (Exception e) {
            out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
        out.flush();
    }
}