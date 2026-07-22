<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    String role = (String) session.getAttribute("currentRole");
    if (role == null) { 
        response.sendRedirect("login.jsp"); return;
    }
    String fullName = (String) session.getAttribute("currentFullName");
    if (fullName == null) fullName = (String) session.getAttribute("currentUsername");
    boolean isAdmin = role.equalsIgnoreCase("admin") || role.equalsIgnoreCase("quản lý");
    String chucDanh = isAdmin ? "Quản lý" : "Nhân viên";
    String msg = (String) session.getAttribute("notification");
    if (msg != null) { 
%>
    <script>alert("<%= msg %>");</script>
<% 
        session.removeAttribute("notification");
    } 
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lịch Sử Doanh Thu - Meraki Ticket</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        body { display: flex; height: 100vh; background-color: #f4f7f6; overflow: hidden;}
        
        .sidebar { width: 250px; background: linear-gradient(180deg, #243b55, #141e30); color: white; display: flex; flex-direction: column; padding-top: 20px; flex-shrink: 0; position: relative;}
        .sidebar .logo-area { text-align: center; margin-bottom: 30px; }
        .sidebar .logo-area h3 { color: #34eb71; font-weight: bold; font-size: 20px;}
        .sidebar a { padding: 15px 25px; text-decoration: none; color: #cdcdcd; display: block; font-size: 15px; transition: 0.2s; border-left: 4px solid transparent; }
        .sidebar a:hover { background: rgba(255,255,255,0.05); color: white; border-left-color: #34eb71; }
        .sidebar a.active { background: rgba(255,255,255,0.1); color: #34eb71; border-left-color: #34eb71; font-weight: bold; }
        
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .header { height: 70px; background: white; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); flex-shrink: 0;}
        .header .breadcrumb { font-size: 20px; font-weight: bold; color: #2c3e50; text-transform: uppercase;}
        
        .content-body { padding: 20px; flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 20px; }
        
        .kpi-container { display: flex; gap: 20px; }
        .kpi-card { flex: 1; background: white; border-radius: 8px; padding: 20px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); border-left: 5px solid #3498db; display: flex; justify-content: space-between; align-items: center;}
        .kpi-card.green { border-left-color: #2ecc71; }
        .kpi-card.purple { border-left-color: #aa42fc; }
        .kpi-info h4 { color: #7f8c8d; font-size: 14px; margin-bottom: 5px; text-transform: uppercase;}
        .kpi-info h2 { color: #2c3e50; font-size: 24px;}
        
        .toolbar { background: white; padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center; }
        .filter-group { display: flex; gap: 10px; align-items: center; }
        .filter-group input[type="date"] { padding: 8px; border: 1px solid #ddd; border-radius: 4px; outline: none; }
        .filter-btn { padding: 8px 15px; background: #f8f9fa; border: 1px solid #ddd; border-radius: 4px; cursor: pointer; color: #2c3e50; transition: 0.2s;}
        .filter-btn:hover, .filter-btn.active { background: #3498db; color: white; border-color: #3498db;}
        
        .main-panels { display: flex; gap: 20px; flex: 1; min-height: 0; }
        .left-panel { flex: 1.5; background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); overflow: hidden; display: flex; flex-direction: column;}
        .right-panel { flex: 1; background: white; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); overflow: hidden; border: 2px solid #aa42fc; display: flex; flex-direction: column;}
        
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #f0f0f0; font-size: 14px; }
        th { background-color: #f8f9fa; color: #2c3e50; font-weight: bold; position: sticky; top: 0;}
        tr:hover { background-color: #f1f8ff; }
        
        .btn { padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; color: white; font-size: 13px; text-decoration: none; display: inline-block;}
        .btn-view { background: #3498db; }
        .btn-void { background: #e67e22; margin-left: 5px; }
        .active-row { background-color: #e8f6f3 !important; border-left: 4px solid #1abc9c;}
        
        .btn-export { background: #2ecc71; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 14px; border: none; cursor: pointer; transition: 0.3s; box-shadow: 0 2px 5px rgba(0,0,0,0.2);}
        .btn-export:hover { background: #27ae60; transform: translateY(-1px); }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="logo-area">
            <h3>MERAKI STAFF</h3>
        </div>
        <br><br>
        
        <% if (isAdmin) { %>
            <a href="DashboardController">📊 Tổng quan</a>
            <a href="NhanVienController">👥 Quản lý Nhân sự</a>
            <a href="DanhMucController">📁 Quản lý Danh mục</a>
            <a href="VeController">🎫 Quản lý Dịch vụ (Vé)</a>
        <% } %>
        
        <a href="POSController">🎟️ Bán vé tại quầy (POS)</a>
        <a href="LichSuController" class="active">🧾 Lịch sử giao dịch</a>
        <a href="SoatVeController">⛩️ Cổng soát vé điện tử</a>
        
        <div class="sidebar-bottom" style="position: absolute; bottom: 20px; width: 100%;">
            <a href="DoiMatKhauController" style="color: #f1c40f; text-decoration: none; padding: 15px 25px; display: block; transition: 0.3s;" onmouseover="this.style.background='rgba(241, 196, 15, 0.1)'" onmouseout="this.style.background='transparent'">🔑 Đổi mật khẩu cá nhân</a>
            <a href="LogoutController" style="color: #bdc3c7;" onmouseover="this.style.color='#e74c3c'" onmouseout="this.style.color='#bdc3c7'" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?');">🚪 Đăng xuất hệ thống</a>
        </div>
    </div>

    <div class="main-content">
        <div class="header">
            <div class="breadcrumb">LỊCH SỬ GIAO DỊCH & BÁO CÁO DOANH THU</div>
            <div style="font-weight: bold; color: #2c3e50;">
                👤 <%= chucDanh %>: <span style="color: #aa42fc;"><%= fullName %></span>
            </div>
        </div>
        
        <div class="content-body">
            
            <div class="kpi-container">
                <%-- 🔥 CHỈ ADMIN MỚI THẤY TỔNG DOANH THU ĐỂ ĐẢM BẢO NHÂN VIÊN PHẢI CHỐT CA MÙ --%>
                <% if (isAdmin) { %>
                <div class="kpi-card green">
                    <div class="kpi-info">
                        <h4>Tổng Doanh Thu Lọc Được</h4>
                        <h2><fmt:formatNumber value="${tongDoanhThu}" type="number" pattern="#,###"/> đ</h2>
                    </div>
                    <div style="font-size: 40px;">💰</div>
                </div>
                <% } %>
                
                <div class="kpi-card purple">
                    <div class="kpi-info">
                        <h4>Tổng Hóa Đơn Lọc Được</h4>
                        <h2>${listHD.size()} đơn</h2>
                    </div>
                    <div style="font-size: 40px;">🧾</div>
                </div>
            </div>

            <div class="toolbar">
                <form action="LichSuController" method="get" class="filter-group">
                    <button type="submit" name="filter" value="today" class="filter-btn ${param.filter == 'today' ? 'active' : ''}">Hôm nay</button>
                    <button type="submit" name="filter" value="week" class="filter-btn ${param.filter == 'week' ? 'active' : ''}">Tuần này</button>
                    <button type="submit" name="filter" value="month" class="filter-btn ${param.filter == 'month' ? 'active' : ''}">Tháng này</button>
                    <span style="color: #bdc3c7; margin: 0 10px;">|</span>
                    <input type="date" name="tuNgay" value="${param.tuNgay}">
                    <span>Đến</span>
                    <input type="date" name="denNgay" value="${param.denNgay}">
                    <button type="submit" class="filter-btn active" style="background: #2c3e50; color: white;">Lọc Dữ Liệu</button>
                </form>
                
                <%-- 🔥 CHỈ ADMIN MỚI THẤY NÚT XUẤT EXCEL --%>
                <% if (isAdmin) { %>
                    <a href="LichSuController?action=exportExcel&tuNgay=${param.tuNgay}&denNgay=${param.denNgay}&filter=${param.filter}" class="btn-export">📊 Xuất file Excel (.xlsx)</a>
                <% } %>
            </div>

            <div class="main-panels">
                <div class="left-panel">
                    <div style="background-color: #2c3e50; color: white; padding: 15px 20px;">
                        <h3 style="font-size: 16px;">SỔ LƯU BÁN HÀNG</h3>
                    </div>
                    <div style="flex: 1; overflow-y: auto;">
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã HĐ</th>
                                    <th>Thời gian lập</th>
                                    <th>Thu Ngân</th>
                                    <th>Tổng Tiền</th>
                                    <th style="text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${listHD}" var="hd">
                                    <tr class="${hd.maHD == activeHD ? 'active-row' : ''}">
                                        <td style="font-weight: bold; color: #16a085;">HD-${hd.maHD}</td>
                                        <td><fmt:formatDate value="${hd.ngayTao}" pattern="dd/MM/yyyy HH:mm" /></td>
                                        <td>${hd.nguoiTao}</td>
                                        <td style="color: #27ae60; font-weight: bold;">
                                            <fmt:formatNumber value="${hd.tongTien}" type="number" pattern="#,###"/> đ
                                        </td>
                                        <td style="text-align: center;">
                                            <a href="LichSuController?action=view&maHD=${hd.maHD}&tuNgay=${param.tuNgay}&denNgay=${param.denNgay}&filter=${param.filter}" class="btn btn-view">Chi tiết</a>
                                            <% if (isAdmin) { %>
                                                <a href="LichSuController?action=delete&maHD=${hd.maHD}&tuNgay=${param.tuNgay}&denNgay=${param.denNgay}&filter=${param.filter}" class="btn btn-void" onclick="return confirm('CẢNH BÁO: Hủy hóa đơn HD-${hd.maHD} sẽ hoàn trả lại số lượng vé vào kho. Tiếp tục?');">Hủy</a>
                                            <% } %>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="right-panel">
                    <c:choose>
                        <c:when test="${not empty listCT}">
                            
                            <div style="background-color: #f8f9fa; padding: 15px 20px; border-bottom: 2px solid #aa42fc; display: flex; justify-content: space-between; align-items: center;">
                                <h3 style="color: #aa42fc; font-size: 18px; margin: 0;">CHI TIẾT: HD-${activeHD}</h3>
                                <span style="background-color: #e8f8f5; color: #16a085; padding: 5px 15px; border-radius: 20px; font-size: 13px; font-weight: bold; border: 1px solid #1abc9c;">
                                    ${phuongThuc != null && phuongThuc.contains('QR') ? '📱' : '💵'} ${phuongThuc}
                                </span>
                            </div>

                            <div style="flex: 1; overflow-y: auto;">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Tên Dịch Vụ / Vé</th>
                                            <th style="text-align: center;">SL</th>
                                            <th style="text-align: right;">Thành Tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${listCT}" var="ct">
                                            <tr>
                                                <td style="color: #2c3e50; font-weight: 500;">${ct.tenVe}</td>
                                                <td style="text-align: center;"><b>${ct.soLuong}</b></td>
                                                <td style="text-align: right; font-weight: bold;">
                                                    <fmt:formatNumber value="${ct.thanhTien}" type="number" pattern="#,###"/> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-detail" style="text-align: center; margin-top: 100px; color: #7f8c8d;">
                                <h2 style="font-size: 40px; margin-bottom: 10px;">🧾</h2>
                                <h3>CHƯA CHỌN HÓA ĐƠN</h3>
                                <p>Vui lòng bấm nút "Chi tiết" ở bảng bên trái để xem nội dung.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</body>
</html>