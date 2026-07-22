<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    String username = (String) session.getAttribute("currentUsername");
    if (username == null) { response.sendRedirect("login.jsp"); return; }
    
    if (request.getAttribute("tongDoanhThu") == null) {
        response.sendRedirect("DashboardController");
        return;
    }

    String role = (String) session.getAttribute("currentRole");
    String fullName = (String) session.getAttribute("currentFullName");
    if (fullName == null) fullName = username; 
    String chucDanh = (role != null && (role.equalsIgnoreCase("admin") || role.equalsIgnoreCase("quản lý"))) ? "Quản lý" : "Nhân viên";
    
    Double trend = (Double) request.getAttribute("doanhThuTrend");
    if(trend == null) trend = 0.0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meraki Ticket - Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        body { display: flex; height: 100vh; background-color: #f4f7f6; }
        
        .sidebar { width: 250px; background: linear-gradient(180deg, #243b55, #141e30); color: white; display: flex; flex-direction: column; padding-top: 20px; position: relative;}
        .sidebar .logo-area { text-align: center; margin-bottom: 30px; }
        .sidebar .logo-area h3 { color: #34eb71; font-weight: bold; font-size: 20px;}
        .sidebar a { padding: 15px 25px; text-decoration: none; color: #cdcdcd; display: block; font-size: 15px; transition: 0.3s; border-left: 4px solid transparent; }
        .sidebar a:hover { background: rgba(255,255,255,0.05); color: white; border-left-color: #34eb71; }
        .sidebar a.active { background: rgba(255,255,255,0.1); color: #34eb71; border-left-color: #34eb71; font-weight: bold; }
        
        /* Chỉnh lại nút đăng xuất thanh lịch */
        .sidebar-bottom { position: absolute; bottom: 20px; width: 100%; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 10px;}
        .sidebar-bottom a { color: #bdc3c7; }
        .sidebar-bottom a:hover { color: #e74c3c; border-left-color: #e74c3c; background: rgba(231, 76, 60, 0.1); }
        
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        
        /* Header Profile xịn xò */
        .header { height: 70px; background: white; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); z-index: 10;}
        .header-title { font-size: 20px; font-weight: 800; color: #2c3e50; letter-spacing: 1px;}
        .profile-area { display: flex; align-items: center; gap: 12px; }
        .profile-area img { width: 40px; height: 40px; border-radius: 50%; border: 2px solid #aa42fc; padding: 2px;}
        .profile-info { display: flex; flex-direction: column; text-align: right;}
        .profile-name { font-weight: bold; font-size: 14px; color: #2c3e50;}
        .profile-role { font-size: 12px; color: #7f8c8d;}
        
        .content-body { padding: 30px; }
        
        .cards-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 20px 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); border-left: 5px solid #00acc1; transition: 0.3s; position: relative; overflow: hidden; cursor: default;}
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.08); }
        .stat-card.green { border-color: #2ecc71; }
        .stat-card.purple { border-color: #9b59b6; }
        .stat-card.red { border-color: #e74c3c; }
        
        .stat-card h3 { margin: 0; color: #7f8c8d; font-size: 13px; text-transform: uppercase; font-weight: 600;}
        .stat-card .value { font-size: 26px; font-weight: 800; color: #2c3e50; margin-top: 5px; }
        
        /* Icon chìm (Watermark) */
        .watermark-icon { position: absolute; right: -15px; bottom: -25px; font-size: 80px; opacity: 0.05; transform: rotate(-15deg); }
        
        /* Trend Indicator */
        .trend { font-size: 12px; font-weight: bold; margin-top: 8px; display: inline-block; padding: 3px 8px; border-radius: 20px;}
        .trend.up { background: rgba(46, 204, 113, 0.15); color: #27ae60; }
        .trend.down { background: rgba(231, 76, 60, 0.15); color: #c0392b; }
        
        .charts-container { display: flex; gap: 20px; margin-bottom: 30px; align-items: stretch;}
        .chart-wrapper { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); transition: 0.3s;}
        .chart-wrapper:hover { box-shadow: 0 10px 20px rgba(0,0,0,0.08); }
        .chart-left { flex: 2; }
        .chart-right { flex: 1.2; }
        .chart-title { text-align: left; color: #243b55; font-size: 15px; font-weight: 800; margin-bottom: 20px; text-transform: uppercase; border-bottom: 2px solid #f1f2f6; padding-bottom: 10px;}
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="logo-area"><h3>MERAKI STAFF</h3></div><br>
        <a href="DashboardController" class="active">📊 Tổng quan</a>
        <% if ("admin".equalsIgnoreCase(role) || "quản lý".equalsIgnoreCase(role)) { %>
            <a href="NhanVienController">👥 Quản lý Nhân sự</a>
            <a href="DanhMucController">📁 Quản lý Danh mục</a>
            <a href="VeController">🎫 Quản lý Dịch vụ (Vé)</a>
        <% } %>
        <a href="POSController">🎟️ Bán vé tại quầy (POS)</a>
        <a href="LichSuController">🧾 Lịch sử giao dịch</a>
        <a href="SoatVeController">⛩️ Cổng soát vé điện tử</a>
       
        <div class="sidebar-bottom">
         <a href="DoiMatKhauController" style="color: #f1c40f; text-decoration: none; padding: 15px 25px; display: block; transition: 0.3s;" onmouseover="this.style.background='rgba(241, 196, 15, 0.1)'" onmouseout="this.style.background='transparent'">🔑 Đổi mật khẩu cá nhân</a>
            <a href="LogoutController" 
  		 style="color: #bdc3c7;" 
   		onmouseover="this.style.color='#e74c3c'" 
   		onmouseout="this.style.color='#bdc3c7'" 
  		onclick="return confirm('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?');">
  		 🚪 Đăng xuất hệ thống
</a>
        </div>
    </div>

    <div class="main-content">
        <div class="header">
            <div class="header-title">BẢNG ĐIỀU KHIỂN (DASHBOARD)</div>
            <div class="profile-area">
                <div class="profile-info">
                    <span class="profile-name"><%= fullName %></span>
                    <span class="profile-role"><%= chucDanh %></span>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=aa42fc&color=fff" alt="Avatar">
            </div>
        </div>
        
        <div class="content-body">
            
            <div class="cards-grid">
                <div class="stat-card green">
                    <div class="watermark-icon">💰</div>
                    <h3>Tổng Doanh Thu (VNĐ)</h3>
                    <div class="value"><fmt:formatNumber value="${tongDoanhThu != null ? tongDoanhThu : 0}" type="number" pattern="#,###"/></div>
                    <% if (trend >= 0) { %>
                        <div class="trend up">▲ +<%= String.format("%.1f", trend) %>% so với hôm qua</div>
                    <% } else { %>
                        <div class="trend down">▼ <%= String.format("%.1f", trend) %>% so với hôm qua</div>
                    <% } %>
                </div>
                <div class="stat-card">
                    <div class="watermark-icon">🧾</div>
                    <h3>Hóa Đơn Đã Xuất</h3>
                    <div class="value">${tongHoaDon != null ? tongHoaDon : 0}</div>
                    <div class="trend" style="background: rgba(52, 152, 219, 0.15); color: #2980b9;">Đang hoạt động</div>
                </div>
                <div class="stat-card purple">
                    <div class="watermark-icon">🎟️</div>
                    <h3>Số Vé Phục Vụ</h3>
                    <div class="value">${tongVeBan != null ? tongVeBan : 0}</div>
                    <div class="trend" style="background: rgba(155, 89, 182, 0.15); color: #8e44ad;">Khách đã mua</div>
                </div>
                <div class="stat-card red">
                    <div class="watermark-icon">⚠️</div>
                    <h3>Dịch Vụ Sắp Hết Kho (< 5)</h3>
                    <div class="value" style="color: #e74c3c;">${veSapHet != null ? veSapHet : 0}</div>
                    <div class="trend down">Cần bổ sung ngay</div>
                </div>
            </div>

            <div class="charts-container">
                <div class="chart-wrapper chart-left">
                    <div class="chart-title">📈 BIỂU ĐỒ DOANH THU 7 NGÀY GẦN NHẤT</div>
                    <div style="height: 300px; width: 100%;"><canvas id="barChart"></canvas></div>
                </div>
                <div class="chart-wrapper chart-right">
                    <div class="chart-title">🍩 TỶ TRỌNG DỊCH VỤ</div>
                    <div style="height: 300px; width: 100%; display: flex; justify-content: center;"><canvas id="doughnutChart"></canvas></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Cấu hình Biểu đồ Cột (Thêm màu hover)
        const lbl7Ngay = ${labels7Ngay != null ? labels7Ngay : "[]"};
        const data7Ngay = ${data7Ngay != null ? data7Ngay : "[]"};

        if (lbl7Ngay.length > 0) {
            new Chart(document.getElementById('barChart').getContext('2d'), {
                type: 'bar', 
                data: {
                    labels: lbl7Ngay,
                    datasets: [{
                        label: 'Doanh thu (VNĐ)',
                        data: data7Ngay,
                        backgroundColor: 'rgba(52, 152, 219, 0.8)',
                        hoverBackgroundColor: 'rgba(41, 128, 185, 1)', // Hover đậm màu lên
                        borderColor: '#2980b9',
                        borderWidth: 1,
                        borderRadius: 4
                    }]
                },
                options: { 
                    responsive: true, maintainAspectRatio: false, 
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                }
            });
        }

        // Cấu hình Biểu đồ Tròn (Chuyển Legend sang Phải)
        const lblTyTrong = ${labelsTyTrong != null ? labelsTyTrong : "[]"};
        const dataTyTrong = ${dataTyTrong != null ? dataTyTrong : "[]"};
        
        if (lblTyTrong.length > 0) {
            new Chart(document.getElementById('doughnutChart').getContext('2d'), {
                type: 'doughnut', 
                data: {
                    labels: lblTyTrong,
                    datasets: [{
                        data: dataTyTrong,
                        backgroundColor: ['#1abc9c', '#9b59b6', '#f1c40f', '#e74c3c', '#34495e', '#e67e22'],
                        hoverOffset: 10 // Phóng to viền khi hover
                    }]
                },
                options: { 
                    responsive: true, 
                    maintainAspectRatio: false,
                    plugins: { 
                        legend: { 
                            position: 'right', // Chuyển chú thích sang phải
                            labels: { boxWidth: 15, font: {size: 12} } 
                        } 
                    } 
                }
            });
        }
    </script>
</body>
</html>