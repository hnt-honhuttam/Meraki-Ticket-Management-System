package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.HoaDonDAO;
import dao.VeDAO;

@WebServlet("/DashboardController")
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("currentUsername") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        HoaDonDAO hdDao = new HoaDonDAO();
        VeDAO veDao = new VeDAO();

        request.setAttribute("tongDoanhThu", hdDao.getTongDoanhThu());
        request.setAttribute("tongHoaDon", hdDao.getTongSoHoaDon());
        request.setAttribute("tongVeBan", veDao.getTongSoVeDaBan());
        request.setAttribute("veSapHet", veDao.countVeSapHetHang());
        
        // 🔥 TÍNH TOÁN TREND TĂNG TRƯỞNG (+/- %)
        double dtNay = hdDao.getDoanhThuHomNay();
        double dtQua = hdDao.getDoanhThuHomQua();
        double trend = 0.0;
        if (dtQua > 0) {
            trend = ((dtNay - dtQua) / dtQua) * 100;
        } else if (dtNay > 0) {
            trend = 100.0;
        }
        request.setAttribute("doanhThuTrend", trend);

        String[] chart7Ngay = hdDao.getDoanhThu7Ngay();
        request.setAttribute("labels7Ngay", chart7Ngay[0]);
        request.setAttribute("data7Ngay", chart7Ngay[1]);

        String[] chartTyTrong = hdDao.getTyTrongDoanhThu();
        request.setAttribute("labelsTyTrong", chartTyTrong[0]);
        request.setAttribute("dataTyTrong", chartTyTrong[1]);

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}