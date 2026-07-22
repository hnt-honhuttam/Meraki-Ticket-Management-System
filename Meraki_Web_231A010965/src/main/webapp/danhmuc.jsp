<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String role = (String) session.getAttribute("currentRole");
    if (role == null || (!role.equalsIgnoreCase("admin") && !role.equalsIgnoreCase("quản lý"))) { 
        response.sendRedirect("login.jsp"); return; 
    }
    String fullName = (String) session.getAttribute("currentFullName");
    
    String msg = (String) session.getAttribute("notification");
    if (msg != null) { %><script>alert("<%= msg %>");</script><% session.removeAttribute("notification"); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Danh Mục - Meraki Ticket</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        body { display: flex; height: 100vh; background-color: #f4f7f6; overflow: hidden;}
        
        .sidebar { width: 250px; background: linear-gradient(180deg, #243b55, #141e30); color: white; display: flex; flex-direction: column; padding-top: 20px; position: relative;}
        .sidebar img { width: 60px; margin: 0 auto; display: block;}
        .sidebar h3 { text-align: center; color: #34eb71; margin: 10px 0 20px; font-weight: bold;}
        .sidebar a { padding: 15px 25px; text-decoration: none; color: #cdcdcd; display: block; border-left: 4px solid transparent; transition: 0.2s;}
        .sidebar a:hover, .sidebar a.active { background: rgba(255,255,255,0.1); color: #34eb71; border-left-color: #34eb71; font-weight: bold; }
        .sidebar-bottom { position: absolute; bottom: 20px; width: 100%; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 10px;}
        
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto;}
        
        .header { height: 70px; background: white; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); z-index: 10;}
        .header-title { font-size: 20px; font-weight: 800; color: #2c3e50; text-transform: uppercase;}
        .profile-area { display: flex; align-items: center; gap: 12px; }
        .profile-area img { width: 40px; height: 40px; border-radius: 50%; border: 2px solid #aa42fc; padding: 2px;}
        .profile-info { display: flex; flex-direction: column; text-align: right;}
        .profile-name { font-weight: bold; font-size: 14px; color: #2c3e50;}
        .profile-role { font-size: 12px; color: #7f8c8d;}
        
        .content-body { padding: 25px; display: flex; gap: 25px; align-items: flex-start; }
        .crud-form { flex: 3; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.03); }
        .crud-table { flex: 7; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.03); height: 80vh; overflow-y: auto;}
        
        .crud-form label { display: block; font-weight: bold; margin-bottom: 5px; color: #555; font-size: 13px;}
        .crud-form input, .crud-form textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; margin-bottom: 15px; font-size: 14px;}
        .crud-form input[readonly] { background: #f1f2f6; cursor: not-allowed; }
        
        .btn-group { display: flex; gap: 10px;}
        .btn-group button { flex: 1; padding: 12px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; color: #fff; font-size: 13px;}
        .btn-add { background: #2ecc71; } 
        .btn-edit { background: #f1c40f; color: #333 !important;} 
        .btn-reset { background: #95a5a6; }
        
        .toolbar { display: flex; background: #f8f9fa; padding: 15px; border-radius: 8px; border: 1px solid #eee; margin-bottom: 15px; }
        .toolbar form { display: flex; gap: 10px; width: 100%; align-items: center; }
        
        .input-with-icon { position: relative; flex: 1; }
        .input-with-icon span { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); font-size: 16px; }
        .input-with-icon input { width: 100%; padding: 10px 10px 10px 35px; border: 1px solid #ccc; border-radius: 5px; outline: none; transition: 0.2s;}
        .input-with-icon input:focus { border-color: #3498db; }
        
        .btn-filter { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; }
        
        table { width: 100%; border-collapse: collapse; }
        table th, table td { padding: 15px 12px; text-align: left; border-bottom: 1px solid #eee; font-size: 14px;}
        table th { background: #f8f9fa; color: #2c3e50; }
        table tr:hover { background: #f1f8ff; }
        
        .action-icon { font-size: 16px; text-decoration: none; margin-right: 10px; display: inline-block; transition: 0.2s;}
        .action-icon:hover { transform: scale(1.2); }
    </style>
</head>
<body>
    <div class="sidebar">
        <img src="images/logo.png" alt="Logo">
        <h3>MERAKI TICKET</h3>
        <a href="DashboardController">📊 Tổng quan</a>
        <a href="NhanVienController">👥 Quản lý Nhân sự</a>
        <a href="DanhMucController" class="active">📁 Quản lý Danh mục</a>
        <a href="VeController">🎫 Quản lý Dịch vụ (Vé)</a>
        <a href="POSController">🎟️ Bán vé tại quầy (POS)</a>
        <a href="LichSuController">🧾 Lịch sử giao dịch</a>
        <a href="SoatVeController">⛩️ Cổng soát vé điện tử</a>
        
        <div class="sidebar-bottom">
            <a href="DoiMatKhauController" style="color: #f1c40f; text-decoration: none; padding: 15px 25px; display: block; transition: 0.3s;" onmouseover="this.style.background='rgba(241, 196, 15, 0.1)'" onmouseout="this.style.background='transparent'">🔑 Đổi mật khẩu cá nhân</a>
            <a href="LogoutController" style="color: #bdc3c7; text-decoration: none; padding: 15px 25px; display: block; border-left: 4px solid transparent; transition: 0.3s;" onmouseover="this.style.color='#e74c3c'; this.style.backgroundColor='rgba(231, 76, 60, 0.1)';" onmouseout="this.style.color='#bdc3c7'; this.style.backgroundColor='transparent';" onclick="return confirm('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?');">🚪 Đăng xuất hệ thống</a>
        </div>
    </div>

    <div class="main-content">
        <div class="header">
            <div class="header-title">QUẢN LÝ DANH MỤC HỆ THỐNG</div>
            <div class="profile-area">
                <div class="profile-info">
                    <span class="profile-name"><%= fullName %></span>
                    <span class="profile-role">Quản trị hệ thống</span>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=aa42fc&color=fff" alt="Avatar">
            </div>
        </div>
        
        <div class="content-body">
            <div class="crud-form">
                <h3 style="margin-bottom: 15px; color: #2c3e50; font-size: 16px;">📝 Thuộc tính danh mục</h3>
                <form action="DanhMucController" method="POST">
                    <input type="hidden" name="action" id="action" value="add">
                    <input type="hidden" name="maDM" id="maDM">
                    
                    <label>Tên Danh Mục (*):</label>
                    <input type="text" name="tenDM" id="tenDM" placeholder="VD: Tuyến cáp đỉnh..." required>
                    
                    <label>Mô tả dịch vụ:</label>
                    <textarea name="moTa" id="moTa" rows="4" placeholder="Nhập mô tả ngắn gọn về danh mục này..."></textarea>
                    
                    <div class="btn-group">
                        <button type="submit" class="btn-add" onclick="document.getElementById('action').value='add'">THÊM</button>
                        <button type="submit" class="btn-edit" onclick="document.getElementById('action').value='update'">SỬA</button>
                        <button type="button" class="btn-reset" onclick="resetForm()">LÀM MỚI</button>
                    </div>
                </form>
            </div>

            <div class="crud-table">
                <div class="toolbar">
                    <form action="DanhMucController" method="GET">
                        <div class="input-with-icon">
                            <span>🔍</span>
                            <input type="text" name="keyword" value="${currentKeyword}" placeholder="Nhập tên hoặc mô tả danh mục...">
                        </div>
                        <button type="submit" class="btn-filter">LỌC DỮ LIỆU</button>
                        <a href="DanhMucController" style="padding: 10px 15px; background: #e74c3c; color: white; border-radius: 5px; text-decoration: none; font-weight: bold;">HỦY</a>
                    </form>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th style="width: 80px;">Mã DM</th>
                            <th>Tên Danh Mục</th>
                            <th>Mô Tả</th>
                            <th style="text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listDM}" var="dm">
                            <tr>
                                <td style="font-weight: bold; color: #7f8c8d;">#${dm.maDM}</td>
                                <td style="color: #2980b9; font-weight: bold; font-size: 15px;">${dm.tenDanhMuc}</td>
                                <td style="color: #7f8c8d; font-size: 13px;">${dm.moTa}</td>
                                <td style="text-align: center;">
                                    <a href="#" class="action-icon" title="Chỉnh sửa danh mục" 
                                       onclick="editRow('${dm.maDM}', '${dm.tenDanhMuc}', '${dm.moTa}')">✏️</a>
                                    
                                    <a href="DanhMucController?action=delete&maDM=${dm.maDM}" class="action-icon" 
                                       title="Xóa danh mục" onclick="return confirm('CẢNH BÁO: Xóa danh mục ${dm.tenDanhMuc}?');">🗑️</a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listDM}">
                            <tr><td colspan="4" style="text-align: center; color: #999; padding: 30px;">🔍 Không tìm thấy danh mục nào!</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function editRow(maDM, tenDM, moTa) {
            document.getElementById('maDM').value = maDM;
            document.getElementById('tenDM').value = tenDM;
            document.getElementById('moTa').value = moTa;
            document.getElementById('action').value = "update";
        }
        function resetForm() {
            document.getElementById('maDM').value = "";
            document.getElementById('tenDM').value = "";
            document.getElementById('moTa').value = "";
            document.getElementById('action').value = "add";
        }
    </script>
</body>
</html>