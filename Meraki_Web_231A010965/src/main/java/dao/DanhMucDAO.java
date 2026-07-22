package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.DanhMuc;
import util.DBConnect;

public class DanhMucDAO {

    // 1. Lấy tất cả danh mục (Hàm cơ bản)
    public List<DanhMuc> getAllDanhMuc() {
        List<DanhMuc> list = new ArrayList<>();
        String sql = "SELECT * FROM DanhMuc ORDER BY MaDM ASC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DanhMuc dm = new DanhMuc();
                dm.setMaDM(rs.getInt("MaDM"));
                dm.setTenDanhMuc(rs.getString("TenDM"));
                // Giả sử bảng DanhMuc có thêm cột MoTa, nếu không có thì sếp có thể tạo thêm trên DB hoặc bỏ dòng dưới
                try { dm.setMoTa(rs.getString("MoTa")); } catch(Exception e) { dm.setMoTa(""); }
                list.add(dm);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 🔥 2. HÀM MỚI: Tìm kiếm Danh mục
    public List<DanhMuc> filterDanhMuc(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return getAllDanhMuc();
        
        List<DanhMuc> list = new ArrayList<>();
        String sql = "SELECT * FROM DanhMuc WHERE TenDM LIKE ? OR MoTa LIKE ? ORDER BY MaDM ASC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword.trim() + "%");
            ps.setString(2, "%" + keyword.trim() + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                DanhMuc dm = new DanhMuc();
                dm.setMaDM(rs.getInt("MaDM"));
                dm.setTenDanhMuc(rs.getString("TenDM"));
                try { dm.setMoTa(rs.getString("MoTa")); } catch(Exception e) { dm.setMoTa(""); }
                list.add(dm);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean addDanhMuc(DanhMuc dm) {
        String sql = "INSERT INTO DanhMuc(TenDM, MoTa) VALUES(?, ?)";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dm.getTenDanhMuc());
            ps.setString(2, dm.getMoTa());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateDanhMuc(DanhMuc dm) {
        String sql = "UPDATE DanhMuc SET TenDM = ?, MoTa = ? WHERE MaDM = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dm.getTenDanhMuc());
            ps.setString(2, dm.getMoTa());
            ps.setInt(3, dm.getMaDM());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // 🔥 3. HÀM MỚI: Xóa An Toàn (Kiểm tra khóa ngoại với bảng Vé)
    public String deleteDanhMucAnToan(int maDM) {
        // Bước 1: Kiểm tra xem có Vé nào đang dùng Danh mục này không
        String sqlCheck = "SELECT COUNT(*) FROM SanPham_Ve WHERE MaDM = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
            psCheck.setInt(1, maDM);
            ResultSet rs = psCheck.executeQuery();
            if (rs.next()) {
                int countVe = rs.getInt(1);
                if (countVe > 0) {
                    return "CONSTRAINT_ERROR_" + countVe; // Báo lỗi đang có vé
                }
            }
            
            // Bước 2: Không vướng Khóa ngoại -> Xóa an toàn
            String sqlDelete = "DELETE FROM DanhMuc WHERE MaDM = ?";
            PreparedStatement psDel = conn.prepareStatement(sqlDelete);
            psDel.setInt(1, maDM);
            if (psDel.executeUpdate() > 0) return "SUCCESS";
            
        } catch (Exception e) { e.printStackTrace(); }
        return "ERROR";
    }
}