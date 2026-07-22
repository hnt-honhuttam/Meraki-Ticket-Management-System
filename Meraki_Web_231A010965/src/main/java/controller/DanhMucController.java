package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import dao.DanhMucDAO;
import model.DanhMuc;

@WebServlet("/DanhMucController")
public class DanhMucController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String currentRole = (String) session.getAttribute("currentRole");
        if (currentRole == null || (!currentRole.equalsIgnoreCase("admin") && !currentRole.equalsIgnoreCase("quản lý"))) {
            response.sendRedirect("login.jsp"); return;
        }

        DanhMucDAO dao = new DanhMucDAO();
        String action = request.getParameter("action");
        
        // 🔥 XỬ LÝ LỆNH XÓA AN TOÀN
        if ("delete".equals(action)) {
            int maDM = Integer.parseInt(request.getParameter("maDM"));
            String result = dao.deleteDanhMucAnToan(maDM);
            
            if ("SUCCESS".equals(result)) {
                session.setAttribute("notification", "✅ Đã xóa Danh mục thành công!");
            } else if (result.startsWith("CONSTRAINT_ERROR_")) {
                int soVe = Integer.parseInt(result.split("_")[2]);
                session.setAttribute("notification", "❌ LỖI: Không thể xóa! Danh mục này đang chứa " + soVe + " vé dịch vụ. Vui lòng chuyển các vé sang danh mục khác trước khi xóa.");
            } else {
                session.setAttribute("notification", "❌ Xóa thất bại. Đã có lỗi xảy ra!");
            }
            response.sendRedirect("DanhMucController");
            return;
        }

        // TÌM KIẾM DANH MỤC
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        request.setAttribute("listDM", dao.filterDanhMuc(keyword));
        request.setAttribute("currentKeyword", keyword);

        request.getRequestDispatcher("danhmuc.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        DanhMuc dm = new DanhMuc();
        dm.setTenDanhMuc(request.getParameter("tenDM"));
        dm.setMoTa(request.getParameter("moTa"));
        
        DanhMucDAO dao = new DanhMucDAO();
        if ("add".equals(action)) {
            dao.addDanhMuc(dm);
            request.getSession().setAttribute("notification", "✅ Đã thêm Danh mục hệ thống mới!");
        } else if ("update".equals(action)) {
            dm.setMaDM(Integer.parseInt(request.getParameter("maDM")));
            dao.updateDanhMuc(dm);
            request.getSession().setAttribute("notification", "✅ Cập nhật Danh mục thành công!");
        }
        response.sendRedirect("DanhMucController");
    }
}