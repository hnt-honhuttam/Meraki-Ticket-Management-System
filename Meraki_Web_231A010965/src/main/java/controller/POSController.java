package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import dao.VeDAO;
import model.Ve;

@WebServlet("/POSController")
public class POSController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // 1. Kiểm tra đăng nhập
        if (session.getAttribute("currentUsername") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Lấy dữ liệu từ SQL thông qua VeDAO
        VeDAO veDao = new VeDAO();
        List<Ve> listVe = veDao.getVeAvailable(); // Hàm này lấy vé còn tồn kho
        
        // 3. ĐẨY DỮ LIỆU SANG JSP (Lưu ý: Tên phải là 'danhSachVe' để khớp với pos.jsp)
        request.setAttribute("danhSachVe", listVe);
        
        // 4. Chuyển hướng
        request.getRequestDispatcher("pos.jsp").forward(request, response);
    }
}