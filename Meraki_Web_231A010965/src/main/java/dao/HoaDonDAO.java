package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import util.DBConnect;

public class HoaDonDAO {
 
    // 1. CHỨC NĂNG THANH TOÁN (TRẢ VỀ MÃ HÓA ĐƠN THẬT)
    // ====================================================
    public String thanhToanGiaoDich(String tenDangNhap, double tongTien, String hinhThucThanhToan, String[] arrMaVe, String[] arrSoLuong, String[] arrGiaBan) {
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false); 

            String sqlHD = "INSERT INTO HoaDon(NguoiTao, NgayTao, TongTien, HinhThucThanhToan) VALUES(?, GETDATE(), ?, ?)";
            PreparedStatement psHD = conn.prepareStatement(sqlHD, Statement.RETURN_GENERATED_KEYS);
            psHD.setString(1, tenDangNhap); 
            psHD.setDouble(2, tongTien);
            psHD.setString(3, hinhThucThanhToan); 
            psHD.executeUpdate();

            ResultSet rsKeys = psHD.getGeneratedKeys();
            int maHD = 0;
            if (rsKeys.next()) { maHD = rsKeys.getInt(1); }

            String sqlCT = "INSERT INTO ChiTietHoaDon(MaHD, MaVe, SoLuong, ThanhTien) VALUES(?, ?, ?, ?)";
            String sqlUpdateKho = "UPDATE SanPham_Ve SET SoLuongTon = SoLuongTon - ? WHERE MaVe = ? AND SoLuongTon >= ?";
            PreparedStatement psCT = conn.prepareStatement(sqlCT);
            PreparedStatement psKho = conn.prepareStatement(sqlUpdateKho);

            for (int i = 0; i < arrMaVe.length; i++) {
                int maVe = Integer.parseInt(arrMaVe[i]);
                int soLuong = Integer.parseInt(arrSoLuong[i]);
                double giaBan = Double.parseDouble(arrGiaBan[i]);
                double thanhTien = soLuong * giaBan;

                psCT.setInt(1, maHD); psCT.setInt(2, maVe); psCT.setInt(3, soLuong); psCT.setDouble(4, thanhTien);
                psCT.executeUpdate();

                psKho.setInt(1, soLuong); psKho.setInt(2, maVe); psKho.setInt(3, soLuong);
                if (psKho.executeUpdate() == 0) throw new Exception("Kho không đủ cho Mã vé ID: " + maVe);
            }

            conn.commit();
            // 🔥 THAY ĐỔI: TRẢ VÉ MÃ HÓA ĐƠN THẬT (Ví dụ: "6")
            return String.valueOf(maHD); 
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) { re.printStackTrace(); }
            e.printStackTrace();
            return e.getMessage(); 
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) { ce.printStackTrace(); }
        }
    }

    public List<model.HoaDon> getAllHoaDon() {
        List<model.HoaDon> list = new ArrayList<>();
        String sql = "SELECT * FROM HoaDon ORDER BY NgayTao DESC";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                model.HoaDon hd = new model.HoaDon();
                hd.setMaHD(rs.getInt("MaHD")); hd.setNgayTao(rs.getTimestamp("NgayTao"));
                hd.setNguoiTao(rs.getString("NguoiTao")); hd.setTongTien(rs.getDouble("TongTien"));
                list.add(hd);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<model.HoaDon> getHoaDonByDateFilter(String tuNgay, String denNgay, String filter) {
        List<model.HoaDon> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM HoaDon WHERE 1=1 ");

        if (filter != null && !filter.isEmpty() && !filter.equals("ALL")) {
            switch (filter) {
                case "today":
                    sql.append("AND CAST(NgayTao AS DATE) = CAST(GETDATE() AS DATE) ");
                    break;
                case "week":
                    sql.append("AND NgayTao >= DATEADD(wk, DATEDIFF(wk, 0, GETDATE()), 0) ");
                    break;
                case "month":
                    sql.append("AND MONTH(NgayTao) = MONTH(GETDATE()) AND YEAR(NgayTao) = YEAR(GETDATE()) ");
                    break;
            }
        } else if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
            sql.append("AND CAST(NgayTao AS DATE) >= ? AND CAST(NgayTao AS DATE) <= ? ");
        }

        sql.append("ORDER BY NgayTao DESC");

        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            if ((filter == null || filter.equals("ALL") || filter.isEmpty()) && tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
                stmt.setString(1, tuNgay);
                stmt.setString(2, denNgay);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    model.HoaDon hd = new model.HoaDon();
                    hd.setMaHD(rs.getInt("MaHD"));
                    hd.setNgayTao(rs.getTimestamp("NgayTao"));
                    hd.setNguoiTao(rs.getString("NguoiTao"));
                    hd.setTongTien(rs.getDouble("TongTien"));
                    list.add(hd);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<model.ChiTietHoaDon> getChiTietByMaHD(int maHD) {
        List<model.ChiTietHoaDon> list = new ArrayList<>();
        String sql = "SELECT c.*, v.TenVe FROM ChiTietHoaDon c JOIN SanPham_Ve v ON c.MaVe = v.MaVe WHERE c.MaHD = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, maHD);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    model.ChiTietHoaDon ct = new model.ChiTietHoaDon();
                    ct.setMaHD(rs.getInt("MaHD")); ct.setMaVe(rs.getString("MaVe"));
                    ct.setSoLuong(rs.getInt("SoLuong")); ct.setThanhTien(rs.getDouble("ThanhTien")); ct.setTenVe(rs.getString("TenVe"));
                    list.add(ct);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public String xoaHoaDon(int maHD) {
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false); 

            String sqlGetCT = "SELECT MaVe, SoLuong FROM ChiTietHoaDon WHERE MaHD = ?";
            PreparedStatement psGetCT = conn.prepareStatement(sqlGetCT); psGetCT.setInt(1, maHD);
            ResultSet rs = psGetCT.executeQuery();

            String sqlUpdateKho = "UPDATE SanPham_Ve SET SoLuongTon = SoLuongTon + ? WHERE MaVe = ?";
            PreparedStatement psKho = conn.prepareStatement(sqlUpdateKho);
            while (rs.next()) {
                psKho.setInt(1, rs.getInt("SoLuong")); psKho.setString(2, rs.getString("MaVe")); psKho.executeUpdate();
            }

            String sqlDelCT = "DELETE FROM ChiTietHoaDon WHERE MaHD = ?";
            PreparedStatement psDelCT = conn.prepareStatement(sqlDelCT); psDelCT.setInt(1, maHD); psDelCT.executeUpdate();

            String sqlDelHD = "DELETE FROM HoaDon WHERE MaHD = ?";
            PreparedStatement psDelHD = conn.prepareStatement(sqlDelHD); psDelHD.setInt(1, maHD); psDelHD.executeUpdate();

            conn.commit(); 
            return "SUCCESS";
        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception re) {}
            return e.getMessage();
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (Exception ce) {}
        }
    }

    // ====================================================
    // 2. CÁC HÀM THỐNG KÊ DASHBOARD
    // ====================================================
    public double getTongDoanhThu() {
        double total = 0;
        String sql = "SELECT SUM(TongTien) FROM HoaDon";
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) total = rs.getDouble(1);
        } catch(Exception e) { e.printStackTrace(); }
        return total;
    }
    
    public double getDoanhThuHomNay() {
        double total = 0;
        String sql = "SELECT SUM(TongTien) FROM HoaDon WHERE CAST(NgayTao AS DATE) = CAST(GETDATE() AS DATE)";
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) total = rs.getDouble(1);
        } catch(Exception e) { e.printStackTrace(); }
        return total;
    }

    public double getDoanhThuHomQua() {
        double total = 0;
        String sql = "SELECT SUM(TongTien) FROM HoaDon WHERE CAST(NgayTao AS DATE) = CAST(DATEADD(day, -1, GETDATE()) AS DATE)";
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) total = rs.getDouble(1);
        } catch(Exception e) { e.printStackTrace(); }
        return total;
    }

    public int getTongSoHoaDon() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM HoaDon";
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if(rs.next()) count = rs.getInt(1);
        } catch(Exception e) { e.printStackTrace(); }
        return count;
    }

    public String[] getDoanhThu7Ngay() {
        String[] result = new String[2]; 
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        
        java.time.LocalDate today = java.time.LocalDate.now();
        java.util.Map<String, Double> map7Ngay = new java.util.LinkedHashMap<>();
        for(int i = 6; i >= 0; i--) {
            map7Ngay.put(today.minusDays(i).format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")), 0.0);
        }
        
        String sql = "SELECT CONVERT(varchar, NgayTao, 103) as Ngay, SUM(TongTien) as DoanhThu " +
                     "FROM HoaDon WHERE NgayTao >= DATEADD(day, -7, GETDATE()) " +
                     "GROUP BY CONVERT(varchar, NgayTao, 103)";
        
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while(rs.next()) {
                String ngay = rs.getString("Ngay");
                if (map7Ngay.containsKey(ngay)) {
                    map7Ngay.put(ngay, rs.getDouble("DoanhThu"));
                }
            }
        } catch(Exception e) { e.printStackTrace(); }
        
        boolean first = true;
        for(java.util.Map.Entry<String, Double> entry : map7Ngay.entrySet()) {
            if(!first) { labels.append(","); data.append(","); }
            labels.append("'").append(entry.getKey().substring(0, 5)).append("'"); 
            data.append(entry.getValue());
            first = false;
        }
        
        labels.append("]"); data.append("]");
        result[0] = labels.toString(); 
        result[1] = data.toString();   
        return result;
    }

    public String[] getTyTrongDoanhThu() {
        String[] result = new String[2]; 
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        
        String sql = "SELECT v.TenVe, SUM(c.ThanhTien) as TongTien " +
                     "FROM ChiTietHoaDon c JOIN SanPham_Ve v ON c.MaVe = v.MaVe " +
                     "GROUP BY v.TenVe ORDER BY TongTien DESC";
        
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while(rs.next()) {
                if(!first) { labels.append(","); data.append(","); }
                labels.append("'").append(rs.getString("TenVe")).append("'");
                data.append(rs.getDouble("TongTien"));
                first = false;
            }
        } catch(Exception e) { e.printStackTrace(); }
        
        labels.append("]"); data.append("]");
        result[0] = labels.toString(); 
        result[1] = data.toString();   
        return result;
    }

    // ====================================================
    // 3. CHỨC NĂNG CỔNG SOÁT VÉ ĐIỆN TỬ
    // ====================================================
    public String kiemTraVaSoatVe(String maHDInput) {
        int maHD = 0;
        try {
            maHD = Integer.parseInt(maHDInput.toUpperCase().replace("HD-", "").trim());
        } catch(Exception e) { return "INVALID_FORMAT"; }
        
        String result = "NOT_FOUND";
        String sqlCheck = "SELECT TrangThaiSoatVe FROM HoaDon WHERE MaHD = ?";
        
        try(Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
            ps.setInt(1, maHD);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next()) {
                int status = rs.getInt("TrangThaiSoatVe");
                if(status == 1) {
                    result = "ALREADY_USED";
                } else {
                    String sqlUpdate = "UPDATE HoaDon SET TrangThaiSoatVe = 1 WHERE MaHD = ?";
                    PreparedStatement psUp = conn.prepareStatement(sqlUpdate);
                    psUp.setInt(1, maHD);
                    psUp.executeUpdate();
                    result = "SUCCESS";
                }
            }
        } catch(Exception e) { e.printStackTrace(); return "ERROR"; }
        return result;
    }

    // ====================================================
    // 4. CHỨC NĂNG ĐỐI SOÁT & CHỐT CA
    // ====================================================
    public double[] thongKeDoanhThuCa(String username) {
        double[] stats = new double[4]; 
        String sqlTime = "SELECT ThoiGianMoCa FROM ChotCaLamViec WHERE Username = ? AND TrangThai = 'DANG_MO'";
        String sqlSum = "SELECT HinhThucThanhToan, SUM(TongTien) as Total, COUNT(*) as Code " +
                        "FROM HoaDon WHERE NguoiTao = ? AND NgayTao >= ? GROUP BY HinhThucThanhToan";
        
        try (Connection conn = DBConnect.getConnection()) {
            java.sql.Timestamp openTime = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlTime)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) openTime = rs.getTimestamp("ThoiGianMoCa");
                }
            }
            
            if (openTime != null) {
                try (PreparedStatement ps = conn.prepareStatement(sqlSum)) {
                    ps.setString(1, username);
                    ps.setTimestamp(2, openTime);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String method = rs.getString("HinhThucThanhToan");
                            double total = rs.getDouble("Total");
                            int count = rs.getInt("Code");
                            
                            stats[0] += total;
                            stats[1] += count;
                            if (method != null && method.equalsIgnoreCase("Chuyển khoản QR")) {
                                stats[3] += total;
                            } else {
                                stats[2] += total;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return stats;
    }

    public boolean dongCaLamViec(String username, double tienThucDem, String ghiChu) {
        double[] stats = thongKeDoanhThuCa(username); 
        double tienMatDauCa = 2000000; 
        double tienHeThongGhiNhan = tienMatDauCa + stats[2]; 
        double tienChenhLech = tienThucDem - tienHeThongGhiNhan; 
        
        String sql = "UPDATE ChotCaLamViec SET " +
                     "ThoiGianDongCa = GETDATE(), " +
                     "TongSoHoaDon = ?, " +
                     "TongDoanhThu = ?, " +
                     "TienMatDauCa = ?, " +
                     "DT_TienMat = ?, " +
                     "DT_ChuyenKhoan = ?, " +
                     "TienMatThucDem = ?, " +
                     "TienChenhLech = ?, " +
                     "GhiChu = ?, " +
                     "TrangThai = 'DA_CHOT' " +
                     "WHERE Username = ? AND TrangThai = 'DANG_MO'";
                     
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (int)stats[1]);
            ps.setDouble(2, stats[0]);
            ps.setDouble(3, tienMatDauCa);
            ps.setDouble(4, stats[2]);
            ps.setDouble(5, stats[3]);
            ps.setDouble(6, tienThucDem);
            ps.setDouble(7, tienChenhLech);
            ps.setString(8, ghiChu);
            ps.setString(9, username);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ====================================================
    // 5. HÀM MỚI: LẤY PHƯƠNG THỨC THANH TOÁN CHO VIEW CHI TIẾT
    // ====================================================
    public String getHinhThucThanhToan(int maHD) {
        String pt = "Tiền mặt"; 
        String sql = "SELECT HinhThucThanhToan FROM HoaDon WHERE MaHD = ?";
        try (Connection conn = DBConnect.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maHD);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getString(1) != null) {
                    pt = rs.getString(1);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return pt;
    }
}