-- =========================================================
-- SCRIPT DATABASE MERAKI TICKET - NỘP ĐỒ ÁN 
-- =========================================================

USE master;
GO

-- 1. XÓA DATABASE CŨ (NẾU CÓ) ĐỂ TẠO MỚI SẠCH SẼ 100%
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Meraki_DB')
BEGIN
    ALTER DATABASE Meraki_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Meraki_DB;
END
GO

CREATE DATABASE Meraki_DB;
GO

USE Meraki_DB;
GO

-- =========================================================
-- 2. KHỞI TẠO CẤU TRÚC 7 BẢNG (CHUẨN RÀNG BUỘC KHÓA NGOẠI)
-- =========================================================

-- Bảng 1: TaiKhoan (Phải tạo đầu tiên)
CREATE TABLE TaiKhoan (
    Username VARCHAR(50) PRIMARY KEY,
    Password VARCHAR(50) NOT NULL,
    Role NVARCHAR(20) NOT NULL
);

-- Bảng 2: NhanVien (Tham chiếu đến TaiKhoan)
CREATE TABLE NhanVien (
    MaNV VARCHAR(50) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    TenDangNhap VARCHAR(50) UNIQUE NOT NULL FOREIGN KEY REFERENCES TaiKhoan(Username) ON DELETE CASCADE,
    MatKhau VARCHAR(255) NOT NULL,
    Quyen VARCHAR(20) NOT NULL,
    TrangThai BIT DEFAULT 1
);

-- Bảng 3: DanhMuc
CREATE TABLE DanhMuc (
    MaDM INT IDENTITY(1,1) PRIMARY KEY,
    TenDM NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(255)
);

-- Bảng 4: SanPham_Ve
CREATE TABLE SanPham_Ve (
    MaVe INT IDENTITY(1,1) PRIMARY KEY,
    MaDM INT FOREIGN KEY REFERENCES DanhMuc(MaDM),
    TenVe NVARCHAR(100) NOT NULL,
    GiaBan FLOAT NOT NULL,
    SoLuongTon INT NOT NULL
);

-- Bảng 5: HoaDon (ĐÃ NÂNG CẤP THÊM CỘT 'HÌNH THỨC THANH TOÁN')
CREATE TABLE HoaDon (
    MaHD INT IDENTITY(1,1) PRIMARY KEY,
    NgayTao DATETIME DEFAULT GETDATE(),
    NguoiTao VARCHAR(50) FOREIGN KEY REFERENCES TaiKhoan(Username),
    TongTien FLOAT DEFAULT 0,
    HinhThucThanhToan NVARCHAR(50) DEFAULT N'Tiền mặt', -- Mới thêm để bóc tách Z-Report
    TrangThaiSoatVe INT DEFAULT 0
);

-- Bảng 6: ChiTietHoaDon
CREATE TABLE ChiTietHoaDon (
    MaHD INT FOREIGN KEY REFERENCES HoaDon(MaHD) ON DELETE CASCADE,
    MaVe INT FOREIGN KEY REFERENCES SanPham_Ve(MaVe),
    SoLuong INT NOT NULL,
    ThanhTien FLOAT NOT NULL,
    PRIMARY KEY (MaHD, MaVe)
);

-- Bảng 7: ChotCaLamViec (PHIÊN BẢN A+ CHUYÊN SÂU DÀNH CHO KẾ TOÁN)
CREATE TABLE ChotCaLamViec (
    MaChotCa VARCHAR(20) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES TaiKhoan(Username),
    MaQuayPOS VARCHAR(20) NOT NULL,
    ThoiGianMoCa DATETIME DEFAULT GETDATE(),
    ThoiGianDongCa DATETIME NULL,
    
    TongSoHoaDon INT DEFAULT 0,
    TongDoanhThu FLOAT DEFAULT 0,
    TongChietKhau FLOAT DEFAULT 0,
    
    TienMatDauCa FLOAT DEFAULT 0,
    DT_TienMat FLOAT DEFAULT 0,
    DT_ChuyenKhoan FLOAT DEFAULT 0,
    
    TienMatThucDem FLOAT DEFAULT 0,
    TienChenhLech FLOAT DEFAULT 0,
    
    GhiChu NVARCHAR(255) NULL,
    TrangThai VARCHAR(20) DEFAULT 'DANG_MO' -- 'DANG_MO' hoặc 'DA_CHOT'
);

-- =========================================================
-- 3. NẠP DỮ LIỆU MẪU (BẢO TOÀN DỮ LIỆU GỐC CỦA SẾP)
-- =========================================================

-- Nạp tài khoản
INSERT INTO TaiKhoan (Username, Password, Role) VALUES 
('admin', '123456', 'Admin'),
('nv01', '123456', 'Staff'),
('nv02', '123456', 'Staff');

-- Nạp nhân viên
INSERT INTO NhanVien (MaNV, HoTen, TenDangNhap, MatKhau, Quyen, TrangThai) VALUES
('admin', N'Quản Lý Cấp Cao', 'admin', '123456', 'Admin', 1),
('nv01', N'Hồ Nhựt Tâm', 'nv01', '123456', 'Staff', 1),
('nv02', N'Nguyễn Văn Tuấn', 'nv02', '123456', 'Staff', 1);

-- Nạp danh mục
INSERT INTO DanhMuc (TenDM, MoTa) VALUES
(N'Tuyến Cáp Vân Sơn', N'Hệ thống cáp treo di chuyển thẳng lên Đỉnh núi Bà Đen'),
(N'Tuyến Cáp Chùa Hang', N'Hệ thống cáp treo di chuyển quần thể Chùa Bà'),
(N'Tuyến Cáp Tâm An', N'Tuyến cáp kết nối Chùa Bà lên Đỉnh núi'),
(N'Dịch Vụ Ẩm Thực', N'Nhà hàng Buffet trên đỉnh núi phục vụ hơn 80 món Á - Âu'),
(N'Combo Trọn Gói', N'Vé kết hợp nhiều dịch vụ giúp khách hàng tối ưu chi phí'),
(N'Đặc Quyền VIP', N'Lối đi ưu tiên (Fast Track), không cần xếp hàng');

-- Nạp 11 Loại Vé
INSERT INTO SanPham_Ve (MaDM, TenVe, GiaBan, SoLuongTon) VALUES
(1, N'Khứ hồi Đỉnh Vân Sơn (Người lớn >1.4m)', 400000, 5000),
(1, N'Khứ hồi Đỉnh Vân Sơn (Trẻ em 1m-1.4m)', 300000, 4997),
(2, N'Khứ hồi Chùa Hang (Người lớn >1.4m)', 250000, 2998),
(2, N'Khứ hồi Chùa Hang (Trẻ em 1m-1.4m)', 150000, 2997),
(3, N'Một chiều Tâm An (Chùa lên Đỉnh)', 350000, 2000),
(4, N'Buffet trưa nhà hàng Vân Sơn (Người lớn)', 300000, 4),
(4, N'Buffet trưa nhà hàng Vân Sơn (Trẻ em)', 150000, 800),
(5, N'Combo: Cáp Đỉnh + Buffet (Người lớn)', 650000, 1000),
(5, N'Combo: Cáp Đỉnh + Buffet (Trẻ em)', 400000, 1000),
(5, N'Combo: All-in-One (Đỉnh + Chùa + Buffet)', 900000, 0),
(6, N'Khứ hồi Đỉnh VIP Fast Track (Mọi độ tuổi)', 750000, 200);

-- Nạp lịch sử mẫu (Để dashboard có biểu đồ ngay) - Phân loại rõ Tiền mặt và QR
INSERT INTO HoaDon (NgayTao, NguoiTao, TongTien, HinhThucThanhToan) VALUES
(DATEADD(day, -2, GETDATE()), 'admin', 2200000, N'Tiền mặt'),
(DATEADD(day, -1, GETDATE()), 'nv01', 1800000, N'Chuyển khoản QR'),
(GETDATE(), 'nv02', 1750000, N'Tiền mặt');

INSERT INTO ChiTietHoaDon (MaHD, MaVe, SoLuong, ThanhTien) VALUES
(1, 1, 2, 800000), (1, 6, 2, 600000), (1, 3, 2, 500000), (1, 4, 2, 300000),
(2, 10, 2, 1800000),
(3, 8, 1, 650000), (3, 5, 2, 700000), (3, 1, 1, 400000);
GO