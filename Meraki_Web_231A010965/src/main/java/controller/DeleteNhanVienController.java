package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import dao.NhanVienDAO;

@WebServlet("/DeleteNhanVienController")
public class DeleteNhanVienController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Lấy mã nhân viên cần xóa từ thanh URL
        String maNV = request.getParameter("maNV");
        
        if (maNV != null && !maNV.isEmpty()) {
            NhanVienDAO dao = new NhanVienDAO();
            dao.deleteNhanVien(maNV);
        }
        
        // Xóa xong thì tải lại trang danh sách
        response.sendRedirect("NhanVienController");
    }
}