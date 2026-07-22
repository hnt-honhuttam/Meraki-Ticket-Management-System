<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    // 1. Nhận dữ liệu từ ChotCaController truyền sang
    Double tongTien = (Double) request.getAttribute("tongTien");
    Integer soHoaDon = (Integer) request.getAttribute("soHoaDon");
    Double dtTienMat = (Double) request.getAttribute("dtTienMat");
    Double dtChuyenKhoan = (Double) request.getAttribute("dtChuyenKhoan");
    Double tienThucDem = (Double) request.getAttribute("tienThucDem");
    
    String nguoiChot = (String) request.getAttribute("nguoiChot");
    // 🔥 Lấy biến Tên Nhân Viên đầy đủ
    String tenNhanVien = (String) request.getAttribute("tenNhanVien");
    
    // Nếu không có dữ liệu (ai đó gõ thẳng link trên trình duyệt), đẩy về trang đăng nhập
    if (nguoiChot == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fallback an toàn nếu lỡ tên bị rỗng
    if (tenNhanVien == null || tenNhanVien.trim().isEmpty()) {
        tenNhanVien = nguoiChot;
    }

    // 2. Xử lý logic an toàn & Tính toán độ lệch két
    if (tongTien == null) tongTien = 0.0;
    if (dtTienMat == null) dtTienMat = 0.0;
    if (dtChuyenKhoan == null) dtChuyenKhoan = 0.0;
    if (tienThucDem == null) tienThucDem = 0.0;

    double tienMatDauCa = 2000000.0; // Tiền lẻ công ty giao mặc định đầu ca
    double tienHeThong = tienMatDauCa + dtTienMat; // Số tiền mặt MONG ĐỢI CÓ TRONG KÉT
    double chenhLech = tienThucDem - tienHeThong; // Tính độ lệch
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Phiếu Chốt Ca (Z-Report) - Meraki Ticket</title>
    <style>
        body { 
            background-color: #f4f6f9; display: flex; flex-direction: column; 
            align-items: center; justify-content: center; min-height: 100vh; margin: 0; font-family: 'Courier New', Courier, monospace; 
        }
        
        .receipt-container { 
            background: white; width: 400px; padding: 30px; 
            border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); 
            position: relative; color: #000;
        }
        
        /* Hiệu ứng viền răng cưa cho đẹp mắt trên màn hình */
        .receipt-container::after {
            content: ""; position: absolute; bottom: -10px; left: 0; right: 0; height: 10px;
            background-size: 20px 20px;
            background-image: radial-gradient(circle at 10px 0, transparent 10px, white 11px);
        }

        .text-center { text-align: center; }
        .bold { font-weight: bold; }
        .title { font-size: 22px; font-weight: bold; margin-bottom: 5px; }
        .divider { border-top: 2px dashed #000; margin: 15px 0; }
        
        .row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px;}
        .section-title { font-weight: bold; margin-top: 15px; margin-bottom: 10px; font-size: 15px; text-decoration: underline; text-transform: uppercase;}
        .highlight { font-size: 18px; font-weight: bold; margin-top: 10px; padding-top: 10px; border-top: 1px dotted #000;}
        
        .signature-area { display: flex; justify-content: space-between; margin-top: 30px; text-align: center; font-size: 14px; }
        .signature-box { width: 45%; }
        
        .action-btns { margin-top: 30px; display: flex; gap: 10px; width: 400px;}
        .btn { flex: 1; padding: 15px; border: none; border-radius: 5px; font-weight: bold; font-family: 'Segoe UI', sans-serif; cursor: pointer; text-align: center; text-decoration: none; transition: 0.2s; font-size: 15px;}
        .btn-print { background: #3498db; color: white; }
        .btn-print:hover { background: #2980b9; }
        .btn-exit { background: #e74c3c; color: white; }
        .btn-exit:hover { background: #c0392b; }

        /* CSS CHUẨN CHO MÁY IN NHIỆT K80 (80mm) */
        @media print {
            @page { margin: 0; size: 80mm auto; }
            body { background: white; align-items: flex-start; padding: 0; margin: 0;}
            .receipt-container { 
                box-shadow: none; border-radius: 0; width: 76mm; padding: 5mm; 
                margin: 0 auto;
            }
            .receipt-container::after { display: none; }
            .action-btns { display: none; } /* Ẩn nút in và nút thoát khi in */
        }
    </style>
</head>
<body>

    <div class="receipt-container">
        <div class="text-center">
            <div class="title">MERAKI TICKET</div>
            <div>Hệ Thống Bán Vé & Kiểm Soát</div>
            <div class="divider"></div>
            <div class="title" style="font-size: 18px;">PHIẾU BÀN GIAO CA</div>
            <div>(Z-REPORT)</div>
        </div>

        <div class="divider"></div>

        <!-- Thông tin ca -->
        <div class="row"><span>Thời gian in:</span> <span><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span></div>
        <div class="row"><span>Nhân viên trực:</span> <span class="bold"><%= tenNhanVien %></span></div> <!-- 🔥 ĐÃ SỬA THÀNH TÊN ĐẦY ĐỦ -->
        <div class="row"><span>Quầy POS:</span> <span class="bold">POS-01</span></div>

        <!-- Thống kê tổng quan -->
        <div class="section-title">THỐNG KÊ DOANH THU</div>
        <div class="row"><span>Tổng số hóa đơn:</span> <span class="bold"><%= soHoaDon != null ? soHoaDon : 0 %> bill</span></div>
        <div class="row"><span>Thu Tiền Mặt:</span> <span><fmt:formatNumber value="<%= dtTienMat %>" type="number" pattern="#,###"/> đ</span></div>
        <div class="row"><span>Thu QR/CK:</span> <span><fmt:formatNumber value="<%= dtChuyenKhoan %>" type="number" pattern="#,###"/> đ</span></div>
        <div class="row highlight">
            <span>TỔNG DOANH THU:</span> <span><fmt:formatNumber value="<%= tongTien %>" type="number" pattern="#,###"/> đ</span>
        </div>

        <div class="divider"></div>

        <!-- Đối soát Két tiền mặt (Dành cho kế toán) -->
        <div class="section-title">ĐỐI SOÁT KÉT TIỀN MẶT</div>
        <div class="row"><span>Tiền đầu ca (Mở két):</span> <span><fmt:formatNumber value="<%= tienMatDauCa %>" type="number" pattern="#,###"/> đ</span></div>
        <div class="row"><span>Doanh thu Tiền mặt:</span> <span><fmt:formatNumber value="<%= dtTienMat %>" type="number" pattern="#,###"/> đ</span></div>
        
        <div class="row highlight" style="font-size: 16px;">
            <span>HỆ THỐNG GHI NHẬN:</span> <span><fmt:formatNumber value="<%= tienHeThong %>" type="number" pattern="#,###"/> đ</span>
        </div>
        <div class="row" style="font-size: 16px; margin-top: 10px;">
            <span>THỰC TẾ TRONG KÉT:</span> <span class="bold"><fmt:formatNumber value="<%= tienThucDem %>" type="number" pattern="#,###"/> đ</span>
        </div>
        
        <div class="row" style="font-size: 16px; margin-top: 10px;">
            <span>CHÊNH LỆCH:</span> 
            <span class="bold">
                <% if (chenhLech == 0) { %>
                    <span style="color: #27ae60;">0 đ (Khớp)</span>
                <% } else if (chenhLech > 0) { %>
                    <span style="color: #f39c12;">+<fmt:formatNumber value="<%= chenhLech %>" type="number" pattern="#,###"/> đ (Dư)</span>
                <% } else { %>
                    <span style="color: #c0392b;"><fmt:formatNumber value="<%= chenhLech %>" type="number" pattern="#,###"/> đ (Thiếu)</span>
                <% } %>
            </span>
        </div>

        <div class="divider"></div>

        <!-- Chữ ký bàn giao -->
        <div class="signature-area">
            <div class="signature-box">
                <div class="bold">Người giao</div>
                <div style="font-size: 11px; font-weight: normal; margin-top: 5px;">(Ký, ghi rõ họ tên)</div>
                <br><br><br><br>
                <div class="bold"><%= tenNhanVien %></div> <!-- 🔥 ĐÃ SỬA THÀNH TÊN ĐẦY ĐỦ -->
            </div>
            <div class="signature-box">
                <div class="bold">Quản lý nhận</div>
                <div style="font-size: 11px; font-weight: normal; margin-top: 5px;">(Ký, ghi rõ họ tên)</div>
                <br><br><br><br>
                <div>...................</div>
            </div>
        </div>
        
        <div class="text-center" style="margin-top: 20px; font-size: 12px; font-style: italic;">
            Vui lòng bàn giao chính xác số tiền mặt<br>được ghi nhận trên phiếu (Thực tế trong két).
        </div>
    </div>
    
    <!-- Các nút thao tác (Sẽ bị ẩn đi khi bấm In) -->
    <div class="action-btns">
        <button onclick="window.print()" class="btn btn-print">🖨️ IN PHIẾU (Z-REPORT)</button>
        <a href="login.jsp" class="btn btn-exit">🚪 KẾT THÚC & VỀ TRANG ĐĂNG NHẬP</a>
    </div>

</body>
</html>