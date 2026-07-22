<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String role = (String) session.getAttribute("currentRole");
    if (role == null || (!role.equalsIgnoreCase("admin") && !role.equalsIgnoreCase("quản lý"))) { 
        response.sendRedirect("login.jsp"); return; 
    }
    String fullName = (String) session.getAttribute("currentFullName");
    String currentUsername = (String) session.getAttribute("currentUsername");
    
    String msg = (String) session.getAttribute("notification");
    if (msg != null) { %><script>alert("<%= msg %>");</script><% session.removeAttribute("notification"); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Nhân Sự - Meraki Ticket</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        body { display: flex; height: 100vh; background-color: #f4f7f6; overflow: hidden;}
        
        /* SIDEBAR (Copy từ mẫu chuẩn) */
        .sidebar { width: 250px; background: linear-gradient(180deg, #243b55, #141e30); color: white; display: flex; flex-direction: column; padding-top: 20px; position: relative;}
        .sidebar img { width: 60px; margin: 0 auto; display: block;}
        .sidebar h3 { text-align: center; color: #34eb71; margin: 10px 0 20px; font-weight: bold;}
        .sidebar a { padding: 15px 25px; text-decoration: none; color: #cdcdcd; display: block; border-left: 4px solid transparent; transition: 0.2s;}
        .sidebar a:hover, .sidebar a.active { background: rgba(255,255,255,0.1); color: #34eb71; border-left-color: #34eb71; font-weight: bold; }
        .sidebar-bottom { position: absolute; bottom: 20px; width: 100%; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 10px;}
        .sidebar-bottom a { color: #bdc3c7; }
        .sidebar-bottom a:hover { color: #e74c3c; border-left-color: #e74c3c; background: rgba(231, 76, 60, 0.1); }
        
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto;}
        
        /* HEADER LỊCH SỰ (Chỉ có Profile) */
        .header { height: 70px; background: white; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); z-index: 10;}
        .header-title { font-size: 20px; font-weight: 800; color: #2c3e50; text-transform: uppercase;}
        .profile-area { display: flex; align-items: center; gap: 12px; }
        .profile-area img { width: 40px; height: 40px; border-radius: 50%; border: 2px solid #aa42fc; padding: 2px;}
        .profile-info { display: flex; flex-direction: column; text-align: right;}
        .profile-name { font-weight: bold; font-size: 14px; color: #2c3e50;}
        .profile-role { font-size: 12px; color: #7f8c8d;}
        
        /* LAYOUT CHIA 2 CỘT */
        .content-body { padding: 25px; display: flex; gap: 25px; align-items: flex-start; }
        .crud-form { flex: 3; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.03); }
        .crud-table { flex: 7; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.03); height: 80vh; overflow-y: auto;}
        
        .crud-form label { display: block; font-weight: bold; margin-bottom: 5px; color: #555; font-size: 13px;}
        .crud-form input, .crud-form select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; margin-bottom: 15px; font-size: 14px;}
        .crud-form input[readonly] { background: #f1f2f6; cursor: not-allowed; }
        
        .btn-group { display: flex; gap: 10px;}
        .btn-group button { flex: 1; padding: 12px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; color: #fff; font-size: 13px;}
        .btn-add { background: #2ecc71; } 
        .btn-edit { background: #f1c40f; color: #333 !important;} 
        .btn-reset { background: #95a5a6; }
        
        /* TOOLBAR TÌM KIẾM */
        .toolbar { display: flex; background: #f8f9fa; padding: 15px; border-radius: 8px; border: 1px solid #eee; margin-bottom: 15px; }
        .toolbar form { display: flex; gap: 10px; width: 100%; align-items: center; }
        .toolbar input, .toolbar select { padding: 10px; border: 1px solid #ccc; border-radius: 5px; flex: 1; }
        .btn-filter { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; }
        
        /* BẢNG DỮ LIỆU ĐẸP */
        table { width: 100%; border-collapse: collapse; }
        table th, table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; font-size: 14px;}
        table th { background: #f8f9fa; color: #2c3e50; }
        table tr:hover { background: #f1f8ff; }
        
        .user-cell { display: flex; align-items: center; gap: 10px; font-weight: bold; color: #2c3e50;}
        .user-cell img { width: 32px; height: 32px; border-radius: 50%; }
        
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .badge.admin { background: rgba(231, 76, 60, 0.1); color: #c0392b; border: 1px solid #e74c3c;}
        .badge.staff { background: rgba(52, 152, 219, 0.1); color: #2980b9; border: 1px solid #3498db;}
        
        .status { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .status.active { background: #2ecc71; color: white; }
        .status.locked { background: #95a5a6; color: white; }
        
        .action-icon { font-size: 16px; text-decoration: none; margin-right: 10px; display: inline-block; transition: 0.2s;}
        .action-icon:hover { transform: scale(1.2); }
        .disabled-icon { filter: grayscale(100%); opacity: 0.3; cursor: not-allowed; }
    </style>
</head>
<body>
    <div class="sidebar">
        <img src="images/logo.png" alt="Logo">
        <h3>MERAKI TICKET</h3>
        <a href="DashboardController">📊 Tổng quan</a>
        <a href="NhanVienController" class="active">👥 Quản lý Nhân sự</a>
        <a href="DanhMucController">📁 Quản lý Danh mục</a>
        <a href="VeController">🎫 Quản lý Dịch vụ (Vé)</a>
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
            <div class="header-title">HỒ SƠ TÀI KHOẢN NHÂN SỰ</div>
            <div class="profile-area">
                <div class="profile-info">
                    <span class="profile-name"><%= fullName %></span>
                    <span class="profile-role">Quản trị hệ thống</span>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=aa42fc&color=fff" alt="Avatar">
            </div>
        </div>
        
        <div class="content-body">
            <!-- CỘT TRÁI: FORM NHẬP LIỆU -->
            <div class="crud-form">
                <h3 style="margin-bottom: 15px; color: #2c3e50; font-size: 16px;">📝 Thông tin tài khoản</h3>
                <form action="NhanVienController" method="POST">
                    <input type="hidden" name="action" id="action" value="add">
                    
                    <label>Tài khoản Đăng nhập (Username):</label>
                    <input type="text" name="username" id="username" placeholder="VD: nv03" required>
                    
                    <label>Họ và Tên đầy đủ:</label>
                    <input type="text" name="hoten" id="hoten" placeholder="VD: Trần Văn A" required>
                    
                    <label>Phân quyền hệ thống:</label>
                    <select name="role" id="role" required>
                        <option value="Staff">Staff (Nhân viên Quầy)</option>
                        <option value="Admin">Admin (Quản lý cấp cao)</option>
                    </select>

                    <label>Trạng thái hoạt động:</label>
                    <select name="status" id="status" required>
                        <option value="1">🟢 Đang hoạt động</option>
                        <option value="0">⚫ Đã khóa / Nghỉ việc</option>
                    </select>
                    
                    <p style="font-size: 11px; color: #e74c3c; font-style: italic; margin-bottom: 15px;">*Tài khoản mới sẽ có mật khẩu mặc định là 123456</p>
                    
                    <div class="btn-group">
                        <button type="submit" class="btn-add" onclick="document.getElementById('action').value='add'">THÊM</button>
                        <button type="submit" class="btn-edit" onclick="document.getElementById('action').value='update'">SỬA</button>
                        <button type="button" class="btn-reset" onclick="resetForm()">LÀM MỚI</button>
                    </div>
                </form>
            </div>

            <!-- CỘT PHẢI: BẢNG DỮ LIỆU -->
            <div class="crud-table">
                <div class="toolbar">
                    <form action="NhanVienController" method="GET">
                        <input type="text" name="keyword" value="${currentKeyword}" placeholder="🔍 Nhập tên hoặc username...">
                        <select name="roleFilter">
                            <option value="ALL">📂 Tất cả quyền</option>
                            <option value="Admin" ${currentRoleFilter == 'Admin' ? 'selected' : ''}>Quản lý (Admin)</option>
                            <option value="Staff" ${currentRoleFilter == 'Staff' ? 'selected' : ''}>Nhân viên (Staff)</option>
                        </select>
                        <button type="submit" class="btn-filter">LỌC DỮ LIỆU</button>
                        <a href="NhanVienController" style="padding: 10px 15px; background: #e74c3c; color: white; border-radius: 5px; text-decoration: none; font-weight: bold;">HỦY</a>
                    </form>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Nhân sự (Họ tên)</th>
                            <th>Tài khoản</th>
                            <th>Quyền hạn</th>
                            <th>Trạng thái</th>
                            <th style="text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listNV}" var="nv">
                            <tr>
                                <!-- Avatar Động siêu xịn -->
                                <td>
                                    <div class="user-cell">
                                        <img src="https://ui-avatars.com/api/?name=${nv.tenNV}&background=random&color=fff" alt="AVT">
                                        ${nv.tenNV}
                                    </div>
                                </td>
                                
                                <td style="color: #7f8c8d; font-weight: 500;">${nv.tenDangNhap}</td>
                                
                                <td>
                                    <span class="badge ${nv.quyen == 'Admin' || nv.quyen == 'Quản lý' ? 'admin' : 'staff'}">${nv.quyen}</span>
                                </td>
                                
                                <td>
                                    <span class="status ${nv.trangThai ? 'active' : 'locked'}">
                                        ${nv.trangThai ? 'Đang hoạt động' : 'Bị khóa'}
                                    </span>
                                </td>
                                
                                <td style="text-align: center;">
                                    <!-- NÚT SỬA (Lấy data đẩy lên Form) -->
                                    <a href="#" class="action-icon" title="Chỉnh sửa hồ sơ" 
                                       onclick="editRow('${nv.tenDangNhap}', '${nv.tenNV}', '${nv.quyen}', ${nv.trangThai})">✏️</a>
                                    
                                    <!-- NÚT RESET PASS -->
                                    <a href="NhanVienController?action=reset&username=${nv.tenDangNhap}" class="action-icon" 
                                       title="Cấp lại mật khẩu (123456)" onclick="return confirm('Xác nhận đặt lại mật khẩu cho ${nv.tenDangNhap} về 123456?');">🔑</a>
                                    
                                    <!-- NÚT XÓA (BẢO VỆ CHỐNG TỰ XÓA) -->
                                    <c:choose>
                                        <c:when test="${nv.tenDangNhap == sessionScope.currentUsername || nv.tenDangNhap == 'admin'}">
                                            <a href="#" class="action-icon disabled-icon" title="Không thể xóa tài khoản này!">🗑️</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="NhanVienController?action=delete&username=${nv.tenDangNhap}" class="action-icon" 
                                               title="Xóa tài khoản" onclick="return confirm('CẢNH BÁO: Xóa toàn bộ dữ liệu của nhân viên ${nv.tenNV}?');">🗑️</a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function editRow(username, hoten, quyen, trangthai) {
            document.getElementById('username').value = username;
            document.getElementById('username').setAttribute('readonly', true); // Không cho sửa Username
            document.getElementById('hoten').value = hoten;
            
            // Xử lý select box
            let roleSelect = document.getElementById('role');
            for(let i=0; i<roleSelect.options.length; i++) {
                if(roleSelect.options[i].value === quyen || (quyen==='Quản lý' && roleSelect.options[i].value ==='Admin')) {
                    roleSelect.selectedIndex = i; break;
                }
            }
            
            document.getElementById('status').value = trangthai ? "1" : "0";
            document.getElementById('action').value = "update";
        }
        
        function resetForm() {
            document.getElementById('username').value = "";
            document.getElementById('username').removeAttribute('readonly');
            document.getElementById('hoten').value = "";
            document.getElementById('role').selectedIndex = 0;
            document.getElementById('status').selectedIndex = 0;
            document.getElementById('action').value = "add";
        }
    </script>
</body>
</html>