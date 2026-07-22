package model;

public class DanhMuc {
    private int maDM;
    private String tenDanhMuc;
    private String moTa;

    public DanhMuc() {}

    public DanhMuc(int maDM, String tenDanhMuc, String moTa) {
        this.maDM = maDM;
        this.tenDanhMuc = tenDanhMuc;
        this.moTa = moTa;
    }

    // Getters và Setters
    public int getMaDM() { return maDM; }
    public void setMaDM(int maDM) { this.maDM = maDM; }
    public String getTenDanhMuc() { return tenDanhMuc; }
    public void setTenDanhMuc(String tenDanhMuc) { this.tenDanhMuc = tenDanhMuc; }
    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }
}