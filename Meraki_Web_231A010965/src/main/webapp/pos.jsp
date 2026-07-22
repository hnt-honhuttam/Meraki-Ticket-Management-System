<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.util.*, model.Ve" %>

<%
    String username = (String) session.getAttribute("currentUsername");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("currentRole");
    String fullName = (String) session.getAttribute("currentFullName");
    if (fullName == null) fullName = username; 
    String clearRoleTitle = "Nhân viên quầy";
    if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
        clearRoleTitle = "Quản lý hệ thống";
    }
    String checkoutMsg = (String) session.getAttribute("checkoutNotification");
    if (checkoutMsg != null) {
%>
    <script>alert("<%= checkoutMsg %>");</script>
<%
        session.removeAttribute("checkoutNotification");
    }

    // TỰ ĐỘNG BÓC TÁCH DANH MỤC TỪ KHO VÉ ĐỂ LÀM TAB LỌC
    List<Ve> listVe = (List<Ve>) request.getAttribute("danhSachVe");
    Set<String> listCategoryTabs = new LinkedHashSet<>();
    if (listVe != null) {
        for (Ve v : listVe) {
            if (v.getTenDM() != null && !v.getTenDM().isEmpty()) {
                listCategoryTabs.add(v.getTenDM());
            }
        }
    }
    request.setAttribute("listCategoryTabs", listCategoryTabs);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hệ Thống POS Bán Vé - Meraki Ticket</title>
    <style>
        /* CSS GIAO DIỆN WEB */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        
        body { display: flex; height: 100vh; background-color: #f4f6f9; overflow: hidden; color: #333; }
        
        /* CỘT TRÁI: DANH SÁCH VÉ CÓ SCROLLBAR ĐỘC LẬP */
        .pos-left { flex: 7; padding: 25px 15px 25px 25px; display: flex; flex-direction: column; overflow: hidden; }
        .header-pos { display: flex; justify-content: space-between; margin-bottom: 15px; align-items: center; background: white; padding: 15px 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); flex-shrink: 0;}
        .welcome-text { font-size: 15px; color: #555; }
        .welcome-text b { color: #aa42fc; font-weight: 700; }
        .pos-title-area h2 { color: #243b55; font-size: 22px; font-weight: 700; margin-bottom: 5px;}
        
        .nav-actions { display: flex; align-items: center; gap: 10px; }
        .btn-back { padding: 10px 18px; background: #34495e; color: white; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 14px; transition: 0.2s; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .btn-back:hover { background: #2c3e50; }
        
        /* 🔥 NÚT CHỐT CA ĐÃ ĐƯỢC DỜI LÊN HEADER */
        .btn-end-shift { padding: 10px 18px; background: #e74c3c; color: white; border: none; border-radius: 6px; font-weight: 600; font-size: 14px; cursor: pointer; transition: 0.2s; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .btn-end-shift:hover { background: #c0392b; transform: translateY(-1px); }
        
        /* GIAO DIỆN TABS LỌC DANH MỤC */
        .category-tabs { display: flex; gap: 10px; margin-bottom: 20px; overflow-x: auto; padding-bottom: 5px; flex-shrink: 0; }
        .category-tabs::-webkit-scrollbar { height: 4px; }
        .category-tabs::-webkit-scrollbar-thumb { background: #dcdde1; border-radius: 10px; }
        .cat-tab { padding: 10px 20px; background: white; border: 1px solid #ddd; border-radius: 20px; font-weight: bold; color: #555; cursor: pointer; white-space: nowrap; transition: 0.2s; box-shadow: 0 2px 5px rgba(0,0,0,0.02);}
        .cat-tab:hover { border-color: #aa42fc; color: #aa42fc; }
        .cat-tab.active { background: linear-gradient(90deg, #aa42fc, #34eba9); color: white; border: none; box-shadow: 0 4px 10px rgba(170, 66, 252, 0.2);}

        .ticket-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; overflow-y: auto; padding-right: 10px; align-content: start; flex: 1;}
        .ticket-grid::-webkit-scrollbar { width: 6px; }
        .ticket-grid::-webkit-scrollbar-thumb { background-color: #bdc3c7; border-radius: 10px; }
        
        .ticket-item { background: white; padding: 15px 15px 40px 15px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.03); cursor: pointer; border: 2px solid transparent; transition: 0.2s; position: relative; }
        .ticket-item:hover { transform: translateY(-3px); border-color: #aa42fc !important; box-shadow: 0 10px 20px rgba(170, 66, 252, 0.12); }
        .ticket-icon { font-size: 26px; margin-bottom: 8px; }
        .ticket-item h4 { color: #2c3e50; font-size: 15px; margin-bottom: 8px; line-height: 1.4; font-weight: 600; height: 42px; overflow: hidden; }
        .ticket-item .price { color: #aa42fc; font-weight: 700; font-size: 18px; margin-bottom: 8px; }
        .ticket-item .stock { color: #7f8c8d; font-size: 13px; border-top: 1px solid #eee; padding-top: 8px; }
        .cat-badge { position: absolute; bottom: 10px; left: 15px; background: #f1f2f6; color: #7f8c8d; font-size: 11px; padding: 3px 8px; border-radius: 4px; font-weight: bold; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: calc(100% - 30px); }

        /* CỘT PHẢI: GIỎ HÀNG CUỘN ĐƯỢC - CHECKOUT ĐÓNG ĐINH DƯỚI ĐÁY */
        .pos-right { flex: 3.5; background: white; border-left: 1px solid #e8ecf0; display: flex; flex-direction: column; box-shadow: -5px 0 15px rgba(0,0,0,0.02); height: 100vh; overflow: hidden; }
        .cart-title { padding: 20px; background: #1a252f; color: white; font-size: 18px; font-weight: 600; display: flex; justify-content: space-between; flex-shrink: 0; }
        
        .cart-items-box { flex: 1; padding: 15px; overflow-y: auto; background: #fdfdfe; }
        .cart-items-box::-webkit-scrollbar { width: 5px; }
        .cart-items-box::-webkit-scrollbar-thumb { background-color: #bdc3c7; border-radius: 10px; }
        
        .cart-item { display: flex; flex-direction: column; padding: 12px; background: white; border: 1px solid #eee; border-radius: 8px; margin-bottom: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
        .cart-item-top { display: flex; justify-content: space-between; margin-bottom: 10px; }
        .cart-item-info h5 { color: #2c3e50; font-size: 14px; margin-bottom: 4px; }
        .cart-item-price { font-weight: bold; color: #e74c3c; font-size: 14px; }
        .cart-item-actions { display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #eee; padding-top: 10px;}
        .qty-controls { display: flex; align-items: center; gap: 5px; }
        .qty-controls button { width: 28px; height: 28px; background: #f1f2f6; border: 1px solid #dcdde1; border-radius: 4px; font-weight: bold; cursor: pointer; }
        .qty-controls input { width: 40px; height: 28px; text-align: center; border: 1px solid #dcdde1; border-radius: 4px; font-weight: bold; }
        
        /* 🔥 ICON THÙNG RÁC CHO TỪNG MÓN (Thay thế nút Đỏ) */
        .btn-delete-item { background: transparent; color: #95a5a6; border: none; padding: 5px; font-size: 16px; cursor: pointer; transition: 0.2s; }
        .btn-delete-item:hover { color: #e74c3c; transform: scale(1.1); }
        
        /* Vùng Checkout đóng đinh */
        .checkout-box { padding: 15px 20px; border-top: 3px solid #e8ecf0; background: white; flex-shrink: 0; box-shadow: 0 -5px 15px rgba(0,0,0,0.03); z-index: 10;}
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 14px; font-weight: 600; color: #555; }
        .summary-row.total { font-size: 22px; color: #243b55; margin-top: 5px; padding-top: 8px; border-top: 2px dashed #ccc; }
        .input-pay { width: 100%; padding: 10px; font-size: 15px; border: 2px solid #3498db; border-radius: 6px; text-align: right; font-weight: 700; color: #2c3e50; margin-bottom: 8px; }
        .quick-cash-container { display: flex; gap: 8px; margin-bottom: 10px; }
        .btn-cash { flex: 1; padding: 6px 0; background: #ecf0f1; border: 1px solid #bdc3c7; border-radius: 4px; font-size: 13px; font-weight: bold; color: #2c3e50; cursor: pointer; transition: 0.2s; }
        .btn-cash:hover { background: #3498db; color: white; border-color: #3498db; }
        
        /* 🔥 MÀU PASTEL CHO NÚT TIỀN NHANH */
        .btn-cash.highlight { background: #d4efdf; color: #2980b9; border-color: #a9cce3; }
        .btn-cash.highlight:hover { background: #a9cce3; color: #154360; }
        
        .action-buttons { display: flex; gap: 10px; margin-top: 10px; }
        
        /* 🔥 NÚT HỦY HOVER ĐỎ THEO YÊU CẦU CỦA SẾP */
        .btn-cancel { flex: 1; padding: 12px; background: #95a5a6; color: white; border: none; font-weight: bold; font-size: 14px; border-radius: 6px; cursor: pointer; transition: 0.2s;}
        .btn-cancel:hover { background: #e74c3c; }
        
        .btn-checkout { flex: 2; padding: 12px; background: #27ae60; color: white; border: none; font-weight: bold; font-size: 14px; border-radius: 6px; cursor: pointer; transition: 0.2s; }
        .btn-checkout:hover { background: #219a52; }
        
        /* 🔥 CẤU TRÚC SEGMENTED TABS CHO THANH TOÁN (Như App Ngân Hàng) */
        .segmented-control { display: flex; background: #f1f2f6; border-radius: 8px; padding: 4px; margin-bottom: 10px; }
        .segmented-control input[type="radio"] { display: none; }
        .segmented-control label { flex: 1; text-align: center; padding: 8px 0; font-weight: bold; font-size: 14px; color: #7f8c8d; cursor: pointer; border-radius: 6px; transition: 0.3s; margin-bottom: 0;}
        .segmented-control input[type="radio"]:checked + label { background: white; color: #2980b9; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        
        .qr-payment-area { display: none; text-align: center; padding: 10px; border: 2px dashed #3498db; border-radius: 8px; margin-bottom: 10px; background: #ebf5fb; }
        .qr-payment-area img { width: 120px; border-radius: 5px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }

        /* CSS IN HÓA ĐƠN K80 */
        #print-invoice { display: none; }
        @media print {
            @page { margin: 0; size: 80mm auto; }
            body { background: white; margin: 0; padding: 0; }
            body * { visibility: hidden; }
            #print-invoice, #print-invoice * { visibility: visible; }
            #print-invoice { display: block; position: absolute; left: 50%; top: 0; transform: translateX(-50%); width: 76mm; padding: 5mm; font-family: 'Courier New', Courier, monospace; color: #000; font-size: 12px; }
            .p-header { text-align: center; margin-bottom: 10px; border-bottom: 1px dashed #000; padding-bottom: 10px; }
            .p-header h2 { font-size: 18px; margin-bottom: 5px; font-weight: bold; }
            .p-header p { font-size: 11px; line-height: 1.3; margin: 0; }
            .p-title { text-align: center; font-size: 15px; font-weight: bold; margin: 10px 0; }
            .p-meta { margin-bottom: 10px; font-size: 11px; }
            .p-meta-row { display: flex; justify-content: space-between; margin-bottom: 3px; }
            .p-table { width: 100%; border-collapse: collapse; margin-bottom: 10px; border-bottom: 1px dashed #000; }
            .p-table th { border-bottom: 1px dashed #000; padding-bottom: 5px; text-align: left; }
            .p-table td { padding: 5px 0; vertical-align: top; }
            .p-table .t-qty { text-align: center; width: 30px; }
            .p-table .t-price { text-align: right; }
            .p-summary { margin-bottom: 15px; border-bottom: 1px dashed #000; padding-bottom: 10px; }
            .p-sum-row { display: flex; justify-content: space-between; margin-bottom: 5px; }
            .p-sum-total { font-size: 16px; font-weight: bold; margin-top: 5px; }
            .p-footer { text-align: center; font-size: 11px; line-height: 1.4; }
            .p-qr-container { margin: 15px 0; text-align: center; }
            .p-qr-container img { width: 120px; height: 120px; margin: 0 auto; display: block; border: 1px solid #ccc; padding: 3px;}
            .qr-payment-area { display: none !important; }
        }
    </style>
</head>
<body>

    <div class="pos-left">
        <div class="header-pos">
            <div class="pos-title-area">
                <h2>🎟️ MÀN HÌNH BÁN VÉ POS</h2>
                <div class="welcome-text">Chào <b><%= clearRoleTitle %></b>: <b><%= fullName %></b>!</div>
            </div>
     
            <div class="nav-actions">
                <button type="button" onclick="processBlindClose()" class="btn-end-shift" title="In Z-Report">🛑 Chốt ca</button>
                
                <% if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) { %>
                    <a href="DashboardController" class="btn-back">📊 Tổng quan</a>
                <% } %>
                
                <a href="LichSuController" class="btn-back" style="background-color: #2980b9;">🧾 Lịch sử giao dịch</a>
            </div>
        </div>
        
        <div class="category-tabs">
            <button class="cat-tab active" onclick="filterTickets('ALL', this)">🌟 Tất cả</button>
            <c:forEach var="cat" items="${listCategoryTabs}">
                <button class="cat-tab" onclick="filterTickets('${cat}', this)">📂 ${cat}</button>
            </c:forEach>
        </div>

        <div class="ticket-grid" id="ticketGrid">
            <c:forEach var="ve" items="${danhSachVe}">
                <c:set var="icon" value="🎟️" />
                <c:set var="borderColor" value="#bdc3c7" />
                <c:if test="${ve.tenVe.toLowerCase().contains('cáp')}">
                    <c:set var="icon" value="🚠" />
                    <c:set var="borderColor" value="#3498db" />
                </c:if>
                <c:if test="${ve.tenVe.toLowerCase().contains('buffet')}">
                    <c:set var="icon" value="🍲" />
                    <c:set var="borderColor" value="#e67e22" />
                </c:if>
                <c:if test="${ve.tenVe.toLowerCase().contains('combo')}">
                    <c:set var="icon" value="🎫" />
                    <c:set var="borderColor" value="#9b59b6" />
                </c:if>
                <c:if test="${ve.tenVe.toLowerCase().contains('vip')}">
                    <c:set var="icon" value="⭐" />
                    <c:set var="borderColor" value="#f1c40f" />
                </c:if>

                <div class="ticket-item" data-category="${ve.tenDM}" style="border-top: 4px solid ${borderColor};" onclick="addToCart('${ve.maVe}', '${ve.tenVe}', ${ve.giaBan}, ${ve.soLuongTon})">
                    <div class="ticket-icon">${icon}</div>
                    <h4>${ve.tenVe}</h4>
                    <p class="price">${String.format('%,.0f', ve.giaBan)} đ</p>
                    <p class="stock">Còn lại: <b>${ve.soLuongTon}</b></p>
                    <span class="cat-badge">${ve.tenDM}</span>
                </div>
            </c:forEach>
        </div>
    </div>

    <div class="pos-right">
        <div class="cart-title">
            <span>🛒 GIỎ HÀNG</span>
            <span id="cartCount" style="background: rgba(255,255,255,0.2); padding: 2px 10px; border-radius: 20px;">0</span>
        </div>
      
        <div class="cart-items-box" id="cartContainer">
            <p style="color: #95a5a6; text-align: center; margin-top: 50px;">Chưa có sản phẩm nào.</p>
        </div>
        
        <form id="checkoutForm" action="ThanhToanController" method="POST" style="display: none;"></form>
        
        <div class="checkout-box">
            <div style="margin-bottom: 10px; padding-bottom: 8px; border-bottom: 1px dashed #dcdde1;">
                <label style="font-size: 13px; color: #555; font-weight: 600; display: block; margin-bottom: 5px;">Đối tượng khách:</label>
                <select id="loaiKhachHang" class="input-pay" onchange="renderCart()" style="text-align: left; cursor: pointer; padding: 6px; font-size: 13px;">
                    <option value="0">🧑 Khách Lẻ (Tiêu chuẩn) - 0%</option>
                    <option value="10">🚌 Khách Đoàn / Đại lý - Giảm 10%</option>
                    <option value="20">⛰️ Người dân Tây Ninh (CCCD) - Giảm 20%</option>
                </select>
            </div>

            <div class="summary-row">
                <span>Tạm tính:</span><span id="subTotal" style="font-weight: bold;">0 đ</span>
            </div>
            <div class="summary-row" style="color: #27ae60;">
                <span>Chiết khấu:</span><span id="discountAmt" style="font-weight: bold;">- 0 đ</span>
            </div>
            <div class="summary-row total">
                <span>THÀNH TIỀN:</span><span id="finalTotal" style="color: #e74c3c;">0 đ</span>
            </div>

            <div class="segmented-control">
                <input type="radio" name="payMethod" id="payCash" value="Tiền mặt" checked onclick="toggleCashInput(true)">
                <label for="payCash">💵 Tiền mặt</label>
                <input type="radio" name="payMethod" id="payQR" value="Chuyển khoản QR" onclick="toggleCashInput(false)">
                <label for="payQR">📱 Mã QR</label>
            </div>
            
            <div id="cashInputArea">
                <div style="margin-top: 5px;">
                    <label style="font-size: 12px; color: #555; font-weight: bold; display: block; margin-bottom: 3px;">Khách đưa (VNĐ):</label>
                    <input type="number" id="txtTienKhachDua" class="input-pay" placeholder="Nhập số tiền..." oninput="calculateChange()">
                </div>
                <div class="quick-cash-container">
                    <button type="button" class="btn-cash" onclick="addCash('exact')">Vừa đủ</button>
                    <button type="button" class="btn-cash" onclick="addCash('000')">+000</button>
                    <button type="button" class="btn-cash highlight" onclick="addCash(100000)">100k</button>
                    <button type="button" class="btn-cash highlight" onclick="addCash(500000)">500k</button>
                </div>
                <div class="summary-row" style="font-size: 15px;">
                    <span>Tiền thối lại:</span><span id="changeAmt" style="font-weight: 900; color: #2980b9;">0 đ</span>
                </div>
            </div>

            <div id="qrPaymentArea" class="qr-payment-area">
                <p style="font-weight: bold; color: #2980b9; margin-bottom: 5px; font-size: 13px;">Vui lòng quét mã VietQR</p>
                <img src="images/qr-thanh-toan.jpg" alt="Mã QR Thanh Toán Ngân Hàng">
            </div>

            <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                <button type="button" id="btnOpenDraft" onclick="openDraftModal()" style="background-color: #f39c12; color: white; border: none; padding: 8px; border-radius: 5px; cursor: pointer; font-weight: bold; width: 48%; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    📂 MỞ ĐƠN (<span id="draftCount">0</span>)
                </button>
                <button type="button" onclick="saveDraft()" style="background-color: #34495e; color: white; border: none; padding: 8px; border-radius: 5px; cursor: pointer; font-weight: bold; width: 48%; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    ⏸ LƯU TẠM
                </button>
            </div>

            <div class="action-buttons">
                <button type="button" class="btn-cancel" onclick="clearCart()">HỦY</button>
                <button type="button" class="btn-checkout" onclick="processCheckout()">THANH TOÁN & IN BILL</button>
            </div>
            
        </div>
    </div>

    <div id="print-invoice">
        <div class="p-header">
            <h2>MERAKI TICKET</h2>
            <p>KHU DU LỊCH NÚI BÀ ĐEN</p>
            <p>ĐC: Thạnh Tân, TP. Tây Ninh, Tây Ninh</p>
            <p>Hotline: 1900 8888 88 | MST: 3901234567</p>
        </div>
        <div class="p-title">HÓA ĐƠN DỊCH VỤ VÀ VÉ</div>
        
        <div class="p-meta">
            <div class="p-meta-row"><span>Mã HĐ:</span><span id="pr-mahd">HD-...</span></div>
            <div class="p-meta-row"><span>Ngày:</span><span id="pr-date"></span></div>
             <div class="p-meta-row"><span>Thu ngân:</span><span><%= fullName %></span></div>
            <div class="p-meta-row"><span>Đối tượng:</span><span id="pr-customer">Khách lẻ</span></div>
        </div>

        <table class="p-table">
            <thead><tr><th>Tên Vé</th><th class="t-qty">SL</th><th class="t-price">T.Tiền</th></tr></thead>
            <tbody id="pr-items"></tbody>
        </table>

        <div class="p-summary">
            <div class="p-sum-row"><span>Tổng tạm tính:</span><span id="pr-subtotal"></span></div>
            <div class="p-sum-row" id="pr-discount-row" style="display: none;">
                <span id="pr-discount-label">Giảm giá:</span>
                <span id="pr-discount-amt" style="font-weight: bold;">0 đ</span>
            </div>
            <div class="p-sum-row p-sum-total"><span>TỔNG THANH TOÁN:</span><span id="pr-total"></span></div>
            <p style="text-align: center; font-size: 10px; margin-top: 5px;">(Giá đã bao gồm thuế GTGT)</p>
            <br>
            <div class="p-sum-row"><span>Hình thức:</span><span id="pr-method"></span></div>
            <div class="p-sum-row" id="pr-row-cash"><span>Khách đưa:</span><span id="pr-cash"></span></div>
            <div class="p-sum-row" id="pr-row-change"><span>Thối lại:</span><span id="pr-change"></span></div>
        </div>

        <div class="p-footer">
            <div class="p-qr-container"><img id="pr-qr-img" src="" alt="QR Soát Vé"></div>
            <p style="font-weight: bold;">Mã tra cứu: QR-<span id="pr-qr-code"></span></p>
            <p style="margin-top: 5px;">Vé có giá trị sử dụng 1 lần trong ngày. Vui lòng bảo quản hóa đơn sạch sẽ để quét tại cửa soát vé tự động.</p>
            <p style="margin-top: 10px; font-weight: bold; border-top: 1px dashed #000; padding-top: 10px;">Meraki Ticket xin cảm ơn & chúc quý khách một chuyến đi vui vẻ!</p>
        </div>
    </div>
    
    <script>
        let cart = [];
        window.currentTotal = 0;
        window.discountAmount = 0;
        window.subTotalAmount = 0;

        function formatMoney(amount) { return new Intl.NumberFormat('vi-VN').format(amount) + ' đ'; }

        function filterTickets(category, btnElement) {
            let tabs = document.querySelectorAll('.cat-tab');
            tabs.forEach(tab => tab.classList.remove('active'));
            btnElement.classList.add('active');

            let items = document.querySelectorAll('.ticket-item');
            items.forEach(item => {
                if (category === 'ALL' || item.getAttribute('data-category') === category) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        function toggleCashInput(isCash) {
            document.getElementById('cashInputArea').style.display = isCash ? 'block' : 'none';
            document.getElementById('qrPaymentArea').style.display = isCash ? 'none' : 'block';
            if (!isCash) {
                document.getElementById('txtTienKhachDua').value = window.currentTotal;
                calculateChange();
            } else {
                document.getElementById('txtTienKhachDua').value = "";
                calculateChange();
            }
        }

        function addToCart(maVe, tenVe, gia, maxStock) {
            let item = cart.find(x => x.maVe === maVe);
            if (item) { 
                if (item.soLuong < maxStock) { item.soLuong++;
                } 
                else { alert("Cảnh báo: Kho chỉ còn " + maxStock + " vé!");
                }
            } else { 
                if (maxStock > 0) { cart.push({ maVe: maVe, tenVe: tenVe, gia: parseFloat(gia), soLuong: 1, maxStock: maxStock });
                } 
                else { alert("Vé này đã hết hàng!");
                }
            }
            renderCart();
        }

        function changeQty(maVe, delta) {
            let item = cart.find(x => x.maVe === maVe);
            if (item) {
                if (delta > 0 && item.soLuong >= item.maxStock) {
                    alert("Cảnh báo: Kho chỉ còn " + item.maxStock + " vé!");
                    return;
                }
                item.soLuong += delta;
                if (item.soLuong <= 0) { cart = cart.filter(x => x.maVe !== maVe);
                }
                renderCart();
            }
        }

        function removeItem(maVe) { cart = cart.filter(x => x.maVe !== maVe);
        renderCart(); }

        function clearCart() {
            if(cart.length > 0 && confirm("Bạn có chắc chắn muốn hủy toàn bộ giỏ hàng này không?")) {
                cart = [];
                document.getElementById("txtTienKhachDua").value = "";
                renderCart();
            }
        }

        function addCash(val) {
            let inputField = document.getElementById("txtTienKhachDua");
            let currentVal = inputField.value;
            if (val === 'exact') { inputField.value = window.currentTotal;
            } 
            else if (val === '000') { if(currentVal !== "") inputField.value = currentVal + "000";
            } 
            else { inputField.value = (currentVal === "" ? 0 : parseInt(currentVal)) + parseInt(val);
            }
            calculateChange();
        }

        function renderCart() {
            let container = document.getElementById("cartContainer");
            let totalItems = 0;
            window.subTotalAmount = 0;
            
            if (cart.length === 0) {
                container.innerHTML = '<p style="color: #999; text-align: center; margin-top: 50px;">Chưa có sản phẩm nào.</p>';
                document.getElementById("subTotal").innerText = "0 đ";
                document.getElementById("discountAmt").innerText = "- 0 đ";
                document.getElementById("finalTotal").innerText = "0 đ";
                document.getElementById("cartCount").innerText = "0";
                window.currentTotal = 0;
                window.discountAmount = 0;
                calculateChange(); return;
            }
            
            let html = "";
            cart.forEach(item => {
                let itemTotal = item.gia * item.soLuong;
                window.subTotalAmount += itemTotal;
                totalItems += item.soLuong;
                
                // 🔥 SỬ DỤNG ICON THÙNG RÁC XÓA ITEM
 
                html += `<div class="cart-item">
                    <div class="cart-item-top">
                        <div class="cart-item-info"><h5>\${item.tenVe}</h5><span style="font-size:12px; color:#7f8c8d;">Đơn giá: \${formatMoney(item.gia)}</span></div>
                        <div class="cart-item-price">\${formatMoney(itemTotal)}</div>
       
                    </div>
                    <div class="cart-item-actions">
                        <div class="qty-controls">
                            <button type="button" onclick="changeQty('\${item.maVe}', -1)">-</button>
          
                             <input type="text" value="\${item.soLuong}" readonly>
                            <button type="button" onclick="changeQty('\${item.maVe}', 1)">+</button>
                        </div>
                        
                        <button type="button" class="btn-delete-item" title="Xóa vé này" onclick="removeItem('\${item.maVe}')">🗑️</button>
                    </div>
                </div>`;
            });
            container.innerHTML = html;
            document.getElementById("cartCount").innerText = totalItems;
            
            let phanTramGiam = parseInt(document.getElementById("loaiKhachHang").value) || 0;
            window.discountAmount = window.subTotalAmount * (phanTramGiam / 100);
            window.currentTotal = window.subTotalAmount - window.discountAmount;
            
            document.getElementById("subTotal").innerText = formatMoney(window.subTotalAmount);
            document.getElementById("discountAmt").innerText = "- " + formatMoney(window.discountAmount);
            document.getElementById("finalTotal").innerText = formatMoney(window.currentTotal);
            if(document.querySelector('input[name="payMethod"]:checked').value !== 'Tiền mặt') {
                document.getElementById('txtTienKhachDua').value = window.currentTotal;
            }
            calculateChange();
        }

        function calculateChange() {
            if (!window.currentTotal) { document.getElementById("changeAmt").innerText = "0 đ";
            return; }
            let isCash = document.querySelector('input[name="payMethod"]:checked').value === 'Tiền mặt';
            let tienKhach = isCash ? document.getElementById("txtTienKhachDua").value : window.currentTotal;
            
            if (tienKhach === "") { document.getElementById("changeAmt").innerText = "0 đ"; return;
            }
            let tienThoi = parseInt(tienKhach) - window.currentTotal;
            if (tienThoi >= 0) {
                document.getElementById("changeAmt").innerText = formatMoney(tienThoi);
                document.getElementById("changeAmt").style.color = "#2980b9";
            } else {
                document.getElementById("changeAmt").innerText = "Chưa đủ tiền";
                document.getElementById("changeAmt").style.color = "#e74c3c";
            }
        }

     // 🔥 THUẬT TOÁN ĐỒNG BỘ IN BILL VÀ DATABASE KHÔNG TẢI LẠI TRANG
        function processCheckout() {
            if (cart.length === 0) { alert("Vui lòng chọn vé trước khi thanh toán!");
            return; }
            let payMethod = document.querySelector('input[name="payMethod"]:checked').value;
            let tienKhach = document.getElementById("txtTienKhachDua").value;
            
            if (payMethod === 'Tiền mặt' && (tienKhach === "" || parseInt(tienKhach) < window.currentTotal)) {
                alert("Khách đưa chưa đủ tiền để thanh toán!");
                return;
            }

            if (confirm("Xác nhận Thanh toán, in Hóa đơn và Trừ tồn kho?")) {
                
                // 1. Gói hàng gửi xuống Database
                let formData = new URLSearchParams();
                formData.append("tongTien", window.currentTotal);
                formData.append("payMethod", payMethod);
                cart.forEach(item => {
                    formData.append("maVe", item.maVe);
                    formData.append("soLuong", item.soLuong);
                    formData.append("giaBan", item.gia);
                });
                // 2. Gửi AJAX siêu tốc
                fetch('ThanhToanController', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
            
                })
                .then(response => response.json())
                .then(data => {
                    if(data.status === 'success') {
                        let realMaHD = data.maHD; // ĐÂY LÀ MÃ THẬT TỪ SQL SERVER (Ví dụ: 6)
                        
                        // 3. Chuẩn bị In Hóa Đơn (Với mã HD thật)
                        let d = new Date();
             
                        document.getElementById("pr-date").innerText = d.toLocaleDateString('vi-VN') + " " + d.toLocaleTimeString('vi-VN');
                        document.getElementById("pr-mahd").innerText = "HD-" + realMaHD;
                        document.getElementById("pr-qr-code").innerText = "HD-" + realMaHD; // Chữ hiển thị dưới mã QR
                   
                        
                        let cmbKhach = document.getElementById("loaiKhachHang");
                        let tenLoaiKhach = cmbKhach.options[cmbKhach.selectedIndex].text.split('-')[0].trim();
                        document.getElementById("pr-customer").innerText = tenLoaiKhach;

                        let prItemsHtml = "";
                        cart.forEach(item => {
                            prItemsHtml += `<tr>
                                <td>\${item.tenVe}<br><span style="font-size: 10px;">ĐG: \${formatMoney(item.gia)}</span></td>
                                <td class="t-qty">\${item.soLuong}</td>
                                <td class="t-price">\${formatMoney(item.gia * item.soLuong)}</td>
                            </tr>`;
                        });
                        document.getElementById("pr-items").innerHTML = prItemsHtml;
                        
                        document.getElementById("pr-subtotal").innerText = formatMoney(window.subTotalAmount);
                        if (window.discountAmount > 0) {
                            document.getElementById("pr-discount-row").style.display = "flex";
                            document.getElementById("pr-discount-label").innerText = "Giảm giá (" + cmbKhach.value + "%):";
                            document.getElementById("pr-discount-amt").innerText = "- " + formatMoney(window.discountAmount);
                        } else {
                            document.getElementById("pr-discount-row").style.display = "none";
                        }
                        
                        document.getElementById("pr-total").innerText = formatMoney(window.currentTotal);
                        document.getElementById("pr-method").innerText = payMethod;

                        if (payMethod === 'Tiền mặt') {
                            document.getElementById("pr-row-cash").style.display = "flex";
                            document.getElementById("pr-row-change").style.display = "flex";
                            document.getElementById("pr-cash").innerText = formatMoney(parseInt(tienKhach));
                            document.getElementById("pr-change").innerText = formatMoney(parseInt(tienKhach) - window.currentTotal);
                        } else {
                            document.getElementById("pr-row-cash").style.display = "none";
                            document.getElementById("pr-row-change").style.display = "none";
                        }

                        // 4. Sinh mã QR từ mã thật và Kích hoạt máy in
                        let qrImg = document.getElementById("pr-qr-img");
                        let printAndReset = function() {
                            window.print();
                            // Mở bảng in
                            cart = [];
                            // Reset Giỏ hàng 
                            document.getElementById("txtTienKhachDua").value = "";
                            renderCart();
                        };

                        qrImg.onload = printAndReset;
                        qrImg.onerror = printAndReset;
                        qrImg.src = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=HD-" + realMaHD;
                    } else {
                        alert("❌ Lỗi thanh toán: " + data.message);
                    }
                })
                .catch(error => {
                    alert("❌ Lỗi kết nối đến máy chủ!");
                    console.error(error);
                });
            }
        }

        // THUẬT TOÁN BẬT POP-UP ĐẾM TIỀN CHỐT CA MÙ
        function processBlindClose() {
            let tienThucDem = prompt("🛑 CHỐT CA MÙ (Z-REPORT)\n\nVui lòng mở két, đếm TỔNG SỐ TIỀN MẶT hiện có và nhập vào bên dưới (VNĐ):");
            if (tienThucDem !== null) {
                tienThucDem = tienThucDem.replace(/\D/g,'');
                if (tienThucDem === "") {
                    alert("Vui lòng nhập số tiền hợp lệ!");
                    return;
                }
                let ghiChu = prompt("Nhập ghi chú chốt ca (Ví dụ: 'Thiếu 5k do khách bo' hoặc 'Chênh lệch thẻ'):", "");
                if (ghiChu === null) ghiChu = ""; 
                window.location.href = "ChotCaController?tienThucDem=" + tienThucDem + "&ghiChu=" + encodeURIComponent(ghiChu);
            }
        }

        let draftOrders = JSON.parse(localStorage.getItem('meraki_drafts')) || [];
        updateDraftCount();

        function saveDraft() {
            if (cart.length === 0) {
                alert("Giỏ hàng đang trống, không có gì để lưu tạm!");
                return;
            }
            const draft = { id: "DRAFT_" + new Date().getTime(), time: new Date().toLocaleTimeString('vi-VN'), items: [...cart] };
            draftOrders.push(draft);
            localStorage.setItem('meraki_drafts', JSON.stringify(draftOrders));
            cart = []; document.getElementById("txtTienKhachDua").value = "";
            renderCart(); updateDraftCount();
            alert("⏸ Đã LƯU TẠM đơn hàng thành công!");
        }

        function updateDraftCount() {
            const countElement = document.getElementById('draftCount');
            if(countElement) {
                countElement.innerText = draftOrders.length;
                countElement.style.color = draftOrders.length > 0 ? "#e74c3c" : "white";
            }
        }

        function openDraftModal() {
            if (draftOrders.length === 0) { alert("Hiện không có đơn hàng nào đang lưu tạm!");
            return; }
            if (cart.length > 0) {
                if (!confirm("CẢNH BÁO: Giỏ hàng hiện tại đang có sản phẩm. Mở đơn tạm sẽ GHI ĐÈ và làm mất giỏ hàng này. Bạn có chắc chắn? (Khuyên dùng: Bấm Hủy và Lưu tạm đơn hiện tại trước)")) { return;
                }
            }
            let msg = "DANH SÁCH ĐƠN LƯU TẠM:\n\n";
            draftOrders.forEach((draft, index) => { msg += `[${index + 1}] Lưu lúc ${draft.time} - Gồm ${draft.items.length} loại vé\n`; });
            msg += "\nNhập số thứ tự của đơn muốn mở lại (Ví dụ: 1) hoặc bấm Hủy để đóng:";
            let choice = prompt(msg);
            if (choice !== null && choice.trim() !== "") {
                let index = parseInt(choice) - 1;
                if (index >= 0 && index < draftOrders.length) {
                    cart = draftOrders[index].items;
                    draftOrders.splice(index, 1);
                    localStorage.setItem('meraki_drafts', JSON.stringify(draftOrders));
                    document.getElementById("txtTienKhachDua").value = "";
                    renderCart(); updateDraftCount();
                    alert("📂 Đã PHỤC HỒI đơn hàng thành công! Bạn có thể tiếp tục thanh toán.");
                } else { alert("❌ Số thứ tự không hợp lệ!");
                }
            }
        }
    </script>
</body>
</html>