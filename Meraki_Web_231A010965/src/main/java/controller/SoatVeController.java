package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import dao.HoaDonDAO;
import model.ChiTietHoaDon;

@WebServlet("/SoatVeController")
public class SoatVeController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (request.getSession().getAttribute("currentUsername") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        // Gọi giao diện Kiosk
        request.getRequestDispatcher("soatve.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String maHDInput = request.getParameter("maHD");
        if (maHDInput == null || maHDInput.trim().isEmpty()) {
            out.print("{\"status\":\"INVALID_FORMAT\", \"message\":\"Vui lòng nhập mã hóa đơn\"}");
            out.flush(); return;
        }

        HoaDonDAO dao = new HoaDonDAO();
        // 1. Kiểm tra trạng thái mã vé
        String result = dao.kiemTraVaSoatVe(maHDInput);
        
        // 2. Lấy thông tin số lượng người (chi tiết vé) để gửi ra màn hình
        String detailsHtml = "";
        if (result.equals("SUCCESS") || result.equals("ALREADY_USED")) {
            try {
                int maHD = Integer.parseInt(maHDInput.toUpperCase().replace("HD-", "").trim());
                List<ChiTietHoaDon> listCT = dao.getChiTietByMaHD(maHD);
                StringBuilder sb = new StringBuilder();
                for (ChiTietHoaDon ct : listCT) {
                    // Định dạng: 3x Khứ hồi Vân Sơn (Người lớn)
                    sb.append("<div style='margin-bottom: 8px; font-size: 18px;'>")
                      .append("<b style='color: #f1c40f;'>").append(ct.getSoLuong()).append("x</b> ")
                      .append(ct.getTenVe())
                      .append("</div>");
                }
                detailsHtml = sb.toString().replace("\"", "\\\""); // Chống lỗi nháy kép trong JSON
            } catch (Exception e) {}
        }

        // Trả kết quả về dạng JSON cho súng quét
        String json = "{\"status\":\"" + result + "\", \"details\":\"" + detailsHtml + "\"}";
        out.print(json);
        out.flush();
    }
}