<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meraki Ticket - Đăng nhập</title>
    <style>
        /* CSS reset cơ bản */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        /* Cài đặt ảnh nền tràn viền */
        body {
           background-image: url('images/background.jpg?v=2');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: #1a1a2e; /* Màu nền dự phòng */
        }

        /* Hộp form đăng nhập hiệu ứng kính mờ (Glassmorphism) */
        .login-container {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            width: 400px;
            text-align: center;
        }

        /* Logo và Tiêu đề */
        .logo-box img { width: 80px; margin-bottom: 10px; }
        .login-container h2 {
            /* Hiệu ứng màu chữ Gradient Tím - Xanh Ngọc theo đúng màu logo bạn chọn */
            background: linear-gradient(90deg, #aa42fc, #34eba9);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 28px;
            margin-bottom: 5px;
        }
        .login-container p { color: #666; margin-bottom: 25px; font-style: italic; }

        /* Khung nhập liệu */
        .input-group { margin-bottom: 20px; text-align: left; }
        .input-group label { display: block; font-weight: bold; color: #333; margin-bottom: 8px; }
        .input-group input {
            width: 100%;
            padding: 12px; border: 1px solid #ccc;
            border-radius: 8px; font-size: 14px;
            transition: 0.3s;
        }
        .input-group input:focus { border-color: #aa42fc; outline: none; box-shadow: 0 0 5px rgba(170, 66, 252, 0.5); }

        /* Nút đăng nhập Gradient cực ngầu */
        .btn-login {
            width: 100%;
            padding: 12px;
            background: linear-gradient(90deg, #aa42fc, #34eba9);
            border: none; border-radius: 8px;
            color: white; font-weight: bold; font-size: 16px;
            cursor: pointer; transition: 0.3s;
            margin-top: 10px;
        }
        .btn-login:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(52, 235, 169, 0.4); }

        /* Hiển thị lỗi nếu sai tài khoản */
        .error-msg { color: red; font-size: 13px; margin-bottom: 15px; display: block; }

        /* --- PHẦN BỔ SUNG: CSS CHO KHỐI GỢI Ý TEST --- */
        .test-hint-box {
            margin-top: 25px;
            padding: 12px;
            background-color: rgba(248, 249, 250, 0.8); /* Màu nền xám nhạt hơi trong suốt */
            border: 1px dashed #adb5bd; /* Viền đứt nét */
            border-radius: 8px;
            text-align: center;
            font-size: 13px;
            color: #495057;
        }

        .test-hint-box .hint-title {
            font-weight: bold;
            color: #6f42c1; /* Màu tím tone-sur-tone với nút đăng nhập */
            margin-bottom: 8px;
            margin-top: 0;
        }

        .test-hint-box p {
            margin: 4px 0;
        }

        /* Định dạng cho chữ tài khoản / mật khẩu nổi bật lên */
        .test-hint-box code {
            background-color: #e9ecef;
            padding: 3px 6px;
            border-radius: 4px;
            font-family: monospace;
            font-weight: bold;
            color: #d63384; /* Màu hồng đỏ nổi bật */
        }
    </style>
</head>
<body>

    <%
        // 🔥 BỘ BẮT THÔNG BÁO TOÀN CỤC CHO TRANG LOGIN
        String msg = (String) session.getAttribute("notification");
        if (msg != null) { 
    %>
        <script>alert("<%= msg %>");</script>
    <% 
            session.removeAttribute("notification"); // Hiển thị xong thì xóa đi để không bị lặp lại
        } 
    %>

    <div class="login-container">
        <div class="logo-box">
            <img src="images/logo.png" alt="Meraki Logo">
        </div>
        <h2>MERAKI TICKET</h2>
        <p>Khởi nguồn trải nghiệm</p>
        
       <form action="LoginController" method="POST">
            
            <% 
                String error = (String) request.getAttribute("errorMessage");
                if (error != null) { 
            %>
                <span class="error-msg"><%= error %></span>
            <% } %>

            <div class="input-group">
                <label>Tên đăng nhập:</label>
                <input type="text" name="username" placeholder="Nhập tài khoản..." required>
            </div>
            
            <div class="input-group">
                <label>Mật khẩu:</label>
                <input type="password" name="password" placeholder="Nhập mật khẩu..." required>
            </div>
            
            <button type="submit" class="btn-login">ĐĂNG NHẬP</button>

            <!-- KHỐI GỢI Ý TEST ĐƯỢC CHÈN VÀO ĐÂY -->
            <div class="test-hint-box">
                <p class="hint-title">📌 Dành cho Giảng viên Test:</p>
                <p>👑 Quản lý: <code>admin</code> | Pass: <code>123456</code></p>
                <p>👤 Thu ngân: <code>nv01</code> | Pass: <code>123456</code></p>
            </div>

        </form>
    </div>

</body>
</html>