<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("currentUsername");
    if (username == null) { response.sendRedirect("login.jsp"); return; }
    
    String role = (String) session.getAttribute("currentRole");
    String fullName = (String) session.getAttribute("currentFullName");
    String chucDanh = (role != null && (role.equalsIgnoreCase("admin") || role.equalsIgnoreCase("quản lý"))) ? "Quản lý" : "Nhân viên";
    
    String msg = (String) session.getAttribute("notification");
    if (msg != null) { %><script>alert("<%= msg %>");</script><% session.removeAttribute("notification"); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đổi Mật Khẩu - Meraki Ticket</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        body { display: flex; height: 100vh; background-color: #f4f7f6; }
        
        .sidebar { width: 250px; background: linear-gradient(180deg, #243b55, #141e30); color: white; display: flex; flex-direction: column; padding-top: 20px; position: relative;}
        .sidebar img { width: 60px; margin: 0 auto; display: block;}
        .sidebar h3 { text-align: center; color: #34eb71; margin: 10px 0 20px; font-weight: bold;}
        .sidebar a { padding: 15px 25px; text-decoration: none; color: #cdcdcd; display: block; transition: 0.3s; border-left: 4px solid transparent;}
        .sidebar a:hover { background: rgba(255,255,255,0.05); color: white; border-left-color: #34eb71; }
        .sidebar-bottom { position: absolute; bottom: 20px; width: 100%; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 10px;}
        
        .main-content { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        
        .security-box { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); width: 450px; border-top: 5px solid #f39c12;}
        .security-box h2 { text-align: center; color: #2c3e50; margin-bottom: 5px;}
        .security-box p { text-align: center; color: #7f8c8d; font-size: 14px; margin-bottom: 25px;}
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; color: #34495e; font-size: 14px; margin-bottom: 8px;}
        .form-group input { width: 100%; padding: 12px; border: 1px solid #dcdde1; border-radius: 6px; font-size: 15px; outline: none; transition: 0.2s;}
        .form-group input:focus { border-color: #f39c12; }
        
        .btn-submit { width: 100%; padding: 14px; background: #f39c12; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.2s; margin-top: 10px;}
        .btn-submit:hover { background: #d35400; }
        
        .profile-badge { display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 30px; background: #f8f9fa; padding: 15px; border-radius: 8px;}
        .profile-badge img { width: 50px; height: 50px; border-radius: 50%; }
        .profile-badge div { display: flex; flex-direction: column; }
    </style>
</head>
<body>
    <div class="sidebar">
        <img src="images/logo.png">
        <h3>MERAKI TICKET</h3>
        <a href="DashboardController" onclick="history.back(); return false;">⬅ Quay lại màn hình trước</a>
        
        <div class="sidebar-bottom">
            <a href="DoiMatKhauController" style="color: #f1c40f; border-left-color: #f1c40f; background: rgba(241, 196, 15, 0.1);">🔑 Đổi mật khẩu cá nhân</a>
            <a href="LogoutController" style="color: #bdc3c7;" onmouseover="this.style.color='#e74c3c'" onmouseout="this.style.color='#bdc3c7'">🚪 Đăng xuất hệ thống</a>
        </div>
    </div>

    <div class="main-content">
        <div class="security-box">
            <h2>THIẾT LẬP BẢO MẬT</h2>
            <p>Vui lòng tạo mật khẩu mới để bảo vệ tài khoản</p>
            
            <div class="profile-badge">
                <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=aa42fc&color=fff">
                <div>
                    <strong style="color: #2c3e50;"><%= fullName %></strong>
                    <span style="font-size: 12px; color: #7f8c8d;">Tài khoản: <%= username %> | <%= chucDanh %></span>
                </div>
            </div>

            <form action="DoiMatKhauController" method="POST">
                <div class="form-group">
                    <label>Mật khẩu hiện tại:</label>
                    <input type="password" name="matKhauCu" required placeholder="Nhập mật khẩu đang sử dụng">
                </div>
                <div class="form-group">
                    <label>Mật khẩu mới:</label>
                    <input type="password" name="matKhauMoi" required placeholder="Nhập mật khẩu mới">
                </div>
                <div class="form-group">
                    <label>Xác nhận mật khẩu mới:</label>
                    <input type="password" name="xacNhanMatKhau" required placeholder="Gõ lại mật khẩu mới">
                </div>
                <button type="submit" class="btn-submit">🔒 CẬP NHẬT MẬT KHẨU</button>
            </form>
        </div>
    </div>
</body>
</html>