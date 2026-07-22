package model;

public class ChiTietHoaDon {
    private int maHD;
    private String maVe;
    private String tenVe; // Lấy từ phép JOIN với bảng Ve_SanPham
    private int soLuong;
    private double thanhTien;

    public ChiTietHoaDon() {}

    public int getMaHD() { return maHD; }
    public void setMaHD(int maHD) { this.maHD = maHD; }
    public String getMaVe() { return maVe; }
    public void setMaVe(String maVe) { this.maVe = maVe; }
    public String getTenVe() { return tenVe; }
    public void setTenVe(String tenVe) { this.tenVe = tenVe; }
    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }
    public double getThanhTien() { return thanhTien; }
    public void setThanhTien(double thanhTien) { this.thanhTien = thanhTien; }
}