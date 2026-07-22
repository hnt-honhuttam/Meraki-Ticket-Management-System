package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.NhanVien;
import util.DBConnect;

public class NhanVienDAO {

    public NhanVien checkLogin(String username, String password) {
        String sql = "SELECT * FROM NhanVien WHERE TenDangNhap = ? AND MatKhau = ? AND TrangThai = 1";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                NhanVien nv = new NhanVien();
                nv.setMaNV(rs.getString("MaNV"));
                nv.setTenNV(rs.getString("HoTen"));
                nv.setTenDangNhap(rs.getString("TenDangNhap"));
                nv.setQuyen(rs.getString("Quyen"));
                return nv;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // 🔥 HÀM MỚI: Lấy danh sách kết hợp Bộ Lọc
    public List<NhanVien> filterNhanVien(String keyword, String role) {
        List<NhanVien> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM NhanVien WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (HoTen LIKE ? OR TenDangNhap LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        
        if (role != null && !role.trim().isEmpty() && !role.equals("ALL")) {
            sql.append("AND Quyen = ? ");
            params.add(role);
        }
        
        sql.append("ORDER BY Quyen ASC, TenDangNhap ASC");

        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, (String) params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                NhanVien nv = new NhanVien();
                nv.setMaNV(rs.getString("MaNV"));
                nv.setTenNV(rs.getString("HoTen"));
                nv.setTenDangNhap(rs.getString("TenDangNhap"));
                nv.setQuyen(rs.getString("Quyen"));
                nv.setTrangThai(rs.getBoolean("TrangThai"));
                list.add(nv);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 🔥 HÀM MỚI: Thêm Nhân Viên (Đồng thời tạo Tài Khoản)
    public boolean addNhanVien(NhanVien nv) {
        String sqlTK = "INSERT INTO TaiKhoan(Username, Password, Role) VALUES(?, ?, ?)";
        String sqlNV = "INSERT INTO NhanVien(MaNV, HoTen, TenDangNhap, MatKhau, Quyen, TrangThai) VALUES(?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false); // Transaction

            PreparedStatement psTK = conn.prepareStatement(sqlTK);
            psTK.setString(1, nv.getTenDangNhap());
            psTK.setString(2, "123456"); // Mặc định pass mới
            psTK.setString(3, nv.getQuyen());
            psTK.executeUpdate();

            PreparedStatement psNV = conn.prepareStatement(sqlNV);
            psNV.setString(1, nv.getTenDangNhap()); // Dùng username làm MaNV cho gọn
            psNV.setString(2, nv.getTenNV());
            psNV.setString(3, nv.getTenDangNhap());
            psNV.setString(4, "123456");
            psNV.setString(5, nv.getQuyen());
            psNV.setBoolean(6, nv.isTrangThai());
            psNV.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) {}
            e.printStackTrace(); return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) {}
        }
    }

    public boolean updateNhanVien(NhanVien nv) {
        String sqlTK = "UPDATE TaiKhoan SET Role = ? WHERE Username = ?";
        String sqlNV = "UPDATE NhanVien SET HoTen = ?, Quyen = ?, TrangThai = ? WHERE TenDangNhap = ?";
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            PreparedStatement psTK = conn.prepareStatement(sqlTK);
            psTK.setString(1, nv.getQuyen());
            psTK.setString(2, nv.getTenDangNhap());
            psTK.executeUpdate();

            PreparedStatement psNV = conn.prepareStatement(sqlNV);
            psNV.setString(1, nv.getTenNV());
            psNV.setString(2, nv.getQuyen());
            psNV.setBoolean(3, nv.isTrangThai());
            psNV.setString(4, nv.getTenDangNhap());
            psNV.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) {}
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) {}
        }
    }

    public boolean deleteNhanVien(String username) {
        String sqlNV = "DELETE FROM NhanVien WHERE TenDangNhap = ?";
        String sqlTK = "DELETE FROM TaiKhoan WHERE Username = ?";
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            
            PreparedStatement psNV = conn.prepareStatement(sqlNV);
            psNV.setString(1, username);
            psNV.executeUpdate();

            PreparedStatement psTK = conn.prepareStatement(sqlTK);
            psTK.setString(1, username);
            psTK.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) {}
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) {}
        }
    }

    // 🔥 HÀM MỚI: Reset Password về 123456
    public boolean resetPassword(String username) {
        String sqlTK = "UPDATE TaiKhoan SET Password = '123456' WHERE Username = ?";
        String sqlNV = "UPDATE NhanVien SET MatKhau = '123456' WHERE TenDangNhap = ?";
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            
            PreparedStatement psTK = conn.prepareStatement(sqlTK);
            psTK.setString(1, username); psTK.executeUpdate();

            PreparedStatement psNV = conn.prepareStatement(sqlNV);
            psNV.setString(1, username); psNV.executeUpdate();

            conn.commit(); return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) {}
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) {}
        }
    }
 // 🔥 HÀM MỚI: Người dùng tự đổi mật khẩu
    public boolean doiMatKhau(String username, String matKhauCu, String matKhauMoi) {
        String sqlCheck = "SELECT * FROM TaiKhoan WHERE Username = ? AND Password = ?";
        String sqlUpdateTK = "UPDATE TaiKhoan SET Password = ? WHERE Username = ?";
        String sqlUpdateNV = "UPDATE NhanVien SET MatKhau = ? WHERE TenDangNhap = ?";
        Connection conn = null;
        try {
            conn = util.DBConnect.getConnection();
            
            // 1. Kiểm tra xem mật khẩu cũ có gõ đúng không
            PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
            psCheck.setString(1, username);
            psCheck.setString(2, matKhauCu);
            ResultSet rs = psCheck.executeQuery();
            if (!rs.next()) return false; // Sai mật khẩu cũ -> Từ chối

            // 2. Đúng thì tiến hành cập nhật (Dùng Transaction cho 2 bảng)
            conn.setAutoCommit(false);
            
            PreparedStatement psTK = conn.prepareStatement(sqlUpdateTK);
            psTK.setString(1, matKhauMoi); psTK.setString(2, username);
            psTK.executeUpdate();

            PreparedStatement psNV = conn.prepareStatement(sqlUpdateNV);
            psNV.setString(1, matKhauMoi); psNV.setString(2, username);
            psNV.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) {}
            e.printStackTrace(); return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) {}
        }
    }
}