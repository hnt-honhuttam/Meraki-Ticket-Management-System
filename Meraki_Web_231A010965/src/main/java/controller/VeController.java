package controller;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.VeDAO;
import dao.DanhMucDAO;
import model.Ve;

@WebServlet("/VeController")
public class VeController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("currentUsername") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("currentRole"))) {
            response.sendRedirect("login.jsp"); return;
        }

        VeDAO veDao = new VeDAO();
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            veDao.deleteVe(Integer.parseInt(request.getParameter("maVe")));
            session.setAttribute("notification", "✅ Đã xóa Vé thành công!");
            response.sendRedirect("VeController");
            return;
        }

        // 🔥 FIX LỖI: Bắt tham số an toàn, chống rỗng
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = ""; // Mặc định rỗng
        
        String filterDM = request.getParameter("filterDM");
        if (filterDM == null || filterDM.trim().isEmpty()) filterDM = "ALL"; // Mặc định là Tất cả

        DanhMucDAO dmDao = new DanhMucDAO();
        request.setAttribute("listDM", dmDao.getAllDanhMuc());
        
        // Truyền xuống DAO để lọc an toàn
        request.setAttribute("listVe", veDao.filterVe(keyword, filterDM)); 
        
        // Trả lại từ khóa lên JSP
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentFilterDM", filterDM);

        request.getRequestDispatcher("ve.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        Ve v = new Ve();
        v.setMaDM(Integer.parseInt(request.getParameter("maDM")));
        v.setTenVe(request.getParameter("tenVe"));
        v.setGiaBan(Double.parseDouble(request.getParameter("giaBan")));
        v.setSoLuongTon(Integer.parseInt(request.getParameter("soLuongTon")));
        
        VeDAO dao = new VeDAO();
        if ("add".equals(action)) {
            dao.addVe(v);
            request.getSession().setAttribute("notification", "✅ Đã thêm Vé mới!");
        } else if ("update".equals(action)) {
            v.setMaVe(Integer.parseInt(request.getParameter("maVe")));
            dao.updateVe(v);
            request.getSession().setAttribute("notification", "✅ Đã cập nhật Vé!");
        }
        response.sendRedirect("VeController");
    }
}