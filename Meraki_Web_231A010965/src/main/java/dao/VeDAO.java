package dao;
import java.sql.*;
import java.util.*;
import model.Ve;
import util.DBConnect;

public class VeDAO {
    // ====================================================
    // 1. CÁC HÀM LẤY DỮ LIỆU & LỌC TÌM KIẾM
    // ====================================================
    
    // 🔥 NÂNG CẤP: Hàm Lọc và Tìm Kiếm linh hoạt (Chống lỗi SQL Injection)
    public List<Ve> filterVe(String keyword, String maDM) {
        List<Ve> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT v.*, d.TenDM FROM SanPham_Ve v LEFT JOIN DanhMuc d ON v.MaDM = d.MaDM WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            // Tìm theo Tên Vé hoặc Mã Vé (Ép kiểu an toàn trên SQL Server)
            sql.append("AND (v.TenVe LIKE ? OR CONVERT(VARCHAR, v.MaVe) LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        
        if (maDM != null && !maDM.trim().isEmpty() && !maDM.equals("ALL")) {
            sql.append("AND v.MaDM = ? ");
            params.add(Integer.parseInt(maDM)); // Chỉ ép kiểu khi chắc chắn nó không phải "ALL"
        }
        
        sql.append("ORDER BY v.MaDM ASC, v.MaVe ASC");

        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    stmt.setInt(i + 1, (Integer) params.get(i));
                } else {
                    stmt.setString(i + 1, (String) params.get(i));
                }
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) { list.add(mapVe(rs)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Ve> getVeAvailable() {
        List<Ve> list = new ArrayList<>();
        String sql = "SELECT v.*, d.TenDM FROM SanPham_Ve v LEFT JOIN DanhMuc d ON v.MaDM = d.MaDM WHERE v.SoLuongTon > 0 ORDER BY v.MaDM ASC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) { list.add(mapVe(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Ve> getAllVe() {
        List<Ve> list = new ArrayList<>();
        String sql = "SELECT v.*, d.TenDM FROM SanPham_Ve v LEFT JOIN DanhMuc d ON v.MaDM = d.MaDM ORDER BY v.MaDM ASC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) { list.add(mapVe(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private Ve mapVe(ResultSet rs) throws Exception {
        Ve v = new Ve();
        v.setMaVe(rs.getInt("MaVe")); 
        v.setMaDM(rs.getInt("MaDM"));
        v.setTenVe(rs.getString("TenVe"));
        v.setGiaBan(rs.getDouble("GiaBan"));
        v.setSoLuongTon(rs.getInt("SoLuongTon"));
        
        try { v.setTenDM(rs.getString("TenDM")); } catch (Exception e) { v.setTenDM(""); }
        return v;
    }

    // ====================================================
    // 2. CÁC HÀM CRUD (THÊM, SỬA, XÓA)
    // ====================================================
    public boolean addVe(Ve v) {
        String sql = "INSERT INTO SanPham_Ve(MaDM, TenVe, GiaBan, SoLuongTon) VALUES(?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, v.getMaDM()); stmt.setString(2, v.getTenVe());
            stmt.setDouble(3, v.getGiaBan()); stmt.setInt(4, v.getSoLuongTon());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateVe(Ve v) {
        String sql = "UPDATE SanPham_Ve SET MaDM=?, TenVe=?, GiaBan=?, SoLuongTon=? WHERE MaVe=?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, v.getMaDM()); stmt.setString(2, v.getTenVe());
            stmt.setDouble(3, v.getGiaBan()); stmt.setInt(4, v.getSoLuongTon()); stmt.setInt(5, v.getMaVe());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean deleteVe(int maVe) {
        String sql = "DELETE FROM SanPham_Ve WHERE MaVe=?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, maVe); return stmt.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ====================================================
    // 3. CÁC HÀM THỐNG KÊ DASHBOARD
    // ====================================================
    public int countVeSapHetHang() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM SanPham_Ve WHERE SoLuongTon < 5";
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) count = rs.getInt(1);
        } catch(Exception e) { e.printStackTrace(); }
        return count;
    }
    
 // Tính tổng số lượng vé đã bán ra (Mặc định cho toàn thời gian)
    public int getTongSoVeDaBan() {
        return getTongSoVeDaBan("ALL");
    }

    // 🔥 NÂNG CẤP: Tính tổng số lượng vé theo Bộ Lọc Thời Gian
    public int getTongSoVeDaBan(String filter) {
        int count = 0;
        // Bắt buộc JOIN với HoaDon để lấy NgayTao
        String sql = "SELECT SUM(c.SoLuong) FROM ChiTietHoaDon c JOIN HoaDon h ON c.MaHD = h.MaHD WHERE 1=1 ";
        
        if ("TODAY".equals(filter)) sql += " AND CAST(h.NgayTao AS DATE) = CAST(GETDATE() AS DATE) ";
        else if ("WEEK".equals(filter)) sql += " AND h.NgayTao >= DATEADD(day, -7, CAST(GETDATE() AS DATE)) ";
        else if ("MONTH".equals(filter)) sql += " AND MONTH(h.NgayTao) = MONTH(GETDATE()) AND YEAR(h.NgayTao) = YEAR(GETDATE()) ";
        
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) count = rs.getInt(1);
        } catch(Exception e) { e.printStackTrace(); }
        return count;
    }
}