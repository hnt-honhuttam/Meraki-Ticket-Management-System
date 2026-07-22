package model;

public class Ve {
    private int maVe;
    private int maDM;
    private String tenVe;
    private double giaBan;
    private int soLuongTon;
    
    // 🔥 MỚI BỔ SUNG: Dùng để hiển thị Tên Danh Mục ra bảng thay vì chỉ hiện Mã
    private String tenDM; 

    public Ve() {}

    public Ve(int maVe, int maDM, String tenVe, double giaBan, int soLuongTon, String tenDM) {
        this.maVe = maVe;
        this.maDM = maDM;
        this.tenVe = tenVe;
        this.giaBan = giaBan;
        this.soLuongTon = soLuongTon;
        this.tenDM = tenDM;
    }

    // Getters và Setters
    public int getMaVe() { return maVe; }
    public void setMaVe(int maVe) { this.maVe = maVe; }
    public int getMaDM() { return maDM; }
    public void setMaDM(int maDM) { this.maDM = maDM; }
    public String getTenVe() { return tenVe; }
    public void setTenVe(String tenVe) { this.tenVe = tenVe; }
    public double getGiaBan() { return giaBan; }
    public void setGiaBan(double giaBan) { this.giaBan = giaBan; }
    public int getSoLuongTon() { return soLuongTon; }
    public void setSoLuongTon(int soLuongTon) { this.soLuongTon = soLuongTon; }
    
    // Getter/Setter cho tenDM
    public String getTenDM() { return tenDM; }
    public void setTenDM(String tenDM) { this.tenDM = tenDM; }
}