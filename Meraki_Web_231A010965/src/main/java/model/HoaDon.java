package model;

import java.text.SimpleDateFormat;
import java.util.Date;

public class HoaDon {
    private int maHD;
    private Date ngayTao;
    private String nguoiTao;
    private double tongTien;

    public HoaDon() {}

    // Hàm hỗ trợ format ngày tháng siêu đẹp (VD: 22/06/2026 14:30)
    public String getNgayTaoStr() {
        if (ngayTao == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        return sdf.format(ngayTao);
    }

    public int getMaHD() { return maHD; }
    public void setMaHD(int maHD) { this.maHD = maHD; }
    public Date getNgayTao() { return ngayTao; }
    public void setNgayTao(Date ngayTao) { this.ngayTao = ngayTao; }
    public String getNguoiTao() { return nguoiTao; }
    public void setNguoiTao(String nguoiTao) { this.nguoiTao = nguoiTao; }
    public double getTongTien() { return tongTien; }
    public void setTongTien(double tongTien) { this.tongTien = tongTien; }
}