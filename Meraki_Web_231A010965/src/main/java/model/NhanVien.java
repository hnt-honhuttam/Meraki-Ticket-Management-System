package model;

public class NhanVien {
    private String maNV;
    private String tenNV;
    private String tenDangNhap;
    private String matKhau;
    private String quyen;
    private boolean trangThai;

    // Constructor rỗng (Bắt buộc phải có trong chuẩn Java Bean)
    public NhanVien() {}

    // Constructor đầy đủ
    public NhanVien(String maNV, String tenNV, String tenDangNhap, String matKhau, String quyen, boolean trangThai) {
        this.maNV = maNV;
        this.tenNV = tenNV;
        this.tenDangNhap = tenDangNhap;
        this.matKhau = matKhau;
        this.quyen = quyen;
        this.trangThai = trangThai;
    }

    // Các hàm Getters và Setters
    public String getMaNV() { return maNV; }
    public void setMaNV(String maNV) { this.maNV = maNV; }
    public String getTenNV() { return tenNV; }
    public void setTenNV(String tenNV) { this.tenNV = tenNV; }
    public String getTenDangNhap() { return tenDangNhap; }
    public void setTenDangNhap(String tenDangNhap) { this.tenDangNhap = tenDangNhap; }
    public String getMatKhau() { return matKhau; }
    public void setMatKhau(String matKhau) { this.matKhau = matKhau; }
    public String getQuyen() { return quyen; }
    public void setQuyen(String quyen) { this.quyen = quyen; }
    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }
}