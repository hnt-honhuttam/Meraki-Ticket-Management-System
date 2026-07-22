<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("currentUsername") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("currentRole"))) { 
        response.sendRedirect("login.jsp");
        return; 
    }
    String msg = (String) session.getAttribute("notification");
    if (msg != null) { %><script>alert("<%= msg %>");</script><% session.removeAttribute("notification");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Vé Dịch Vụ</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; }
        body { display: flex; height: 100vh; background-color: #f4f7f6; overflow: hidden;}
        .sidebar { width: 250px; background: linear-gradient(180deg, #243b55, #141e30); color: white; display: flex; flex-direction: column; padding-top: 20px;}
        .sidebar img { width: 60px; margin: 0 auto; display: block;}
        .sidebar h3 { text-align: center; color: #34eb71; margin: 10px 0 20px; font-weight: bold;}
        .sidebar a { padding: 15px 25px; text-decoration: none; color: #cdcdcd; display: block; border-left: 4px solid transparent; }
        .sidebar a:hover, .sidebar a.active { background: rgba(255,255,255,0.1); color: #34eb71; border-left-color: #34eb71; font-weight: bold; }
        .main-content { flex: 1; display: flex; flex-direction: column; padding: 25px; overflow-y: auto;}
        
        .crud-container { display: flex; gap: 25px; align-items: flex-start; }
        .crud-form { flex: 3; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .crud-table { flex: 7; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); height: 85vh; overflow-y: auto;}
        
        .crud-form label { display: block; font-weight: bold; margin-bottom: 5px; color: #333; font-size: 14px;}
        .crud-form input, .crud-form select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 5px; margin-bottom: 15px;}
        .btn-group { display: flex; gap: 10px;}
        .btn-group button { flex: 1; padding: 12px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; color: #fff;}
        .btn-add { background: #2ecc71; } 
        .btn-edit { background: #f1c40f; color: #333 !important;} 
        .btn-reset { background: #95a5a6; }
        
        /* 🔥 CSS TOOLBAR GIỐNG BẢN THIẾT KẾ CỦA SẾP */
        .toolbar { display: flex; background: white; padding: 15px; border-radius: 8px; border: 1px solid #eee; margin-bottom: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.02);}
        .toolbar form { display: flex; gap: 15px; width: 100%; align-items: center; }
        
        .input-with-icon { position: relative; flex: 2; }
        .input-with-icon span { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); font-size: 16px; }
        .input-with-icon input { width: 100%; padding: 12px 10px 12px 35px; border: 2px solid #333; border-radius: 6px; outline: none; font-size: 14px; transition: 0.2s;}
        .input-with-icon input:focus { border-color: #3498db; }

        .select-with-icon { position: relative; flex: 1.2; }
        .select-with-icon span { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); font-size: 16px;}
        .select-with-icon select { width: 100%; padding: 12px 10px 12px 35px; border: 1px solid #ccc; border-radius: 6px; outline: none; font-size: 14px; appearance: none; cursor: pointer; background-color: white;}
        
        .btn-filter { padding: 12px 25px; background: #3498db; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; font-size: 14px; transition: 0.2s;}
        .btn-filter:hover { background: #2980b9; }
        
        .btn-clear { padding: 12px 25px; background: #e74c3c; color: white; border: none; border-radius: 6px; font-weight: bold; text-decoration: none; display: inline-block; font-size: 14px; transition: 0.2s;}
        .btn-clear:hover { background: #c0392b; }
        
        table { width: 100%; border-collapse: collapse; }
        table th, table td { padding: 15px 12px; text-align: left; border-bottom: 1px solid #eee; }
        table th { background: #f8f9fa; color: #2c3e50; }
        table tr:hover { background: #f1f2f6; }
        
        .badge-dm { display: inline-block; background: #e8f6f3; color: #16a085; font-size: 11px; padding: 3px 8px; border-radius: 12px; margin-top: 5px; font-weight: bold; border: 1px solid #1abc9c;}
    </style>
</head>
<body>
    <div class="sidebar">
        <img src="images/logo.png">
        <h3>MERAKI TICKET</h3>
        <a href="DashboardController">📊 Tổng quan</a>
        <a href="NhanVienController">👥 Quản lý Nhân sự</a>
        <a href="DanhMucController">📁 Quản lý Danh mục</a>
        <a href="VeController" class="active">🎫 Quản lý Dịch vụ (Vé)</a>
        <a href="POSController">🎟️ Bán vé tại quầy (POS)</a>
        <a href="LichSuController">🧾 Lịch sử giao dịch</a> 
        <a href="SoatVeController">⛩️ Cổng soát vé điện tử</a>
        
        <div class="sidebar-bottom" style="position: absolute; bottom: 20px; width: 100%; border-top: 1px solid rgba(255,255,255,0.1); padding-top: 10px;">
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
        <h2 style="margin-bottom: 20px; color: #243b55;">KHO VÉ & DỊCH VỤ</h2>
        
        <div class="crud-container">
            <div class="crud-form">
                <form action="VeController" method="POST">
                    <input type="hidden" name="action" id="action" value="add">
                    <input type="hidden" name="maVe" id="maVe">
                    
                    <label>Phân loại Danh mục:</label>
                    <select name="maDM" id="maDM" required>
                        <c:forEach items="${listDM}" var="dm">
                            <option value="${dm.maDM}">${dm.tenDanhMuc}</option>
                        </c:forEach>
                    </select>
                    
                    <label>Tên Vé Dịch vụ (*):</label>
                    <input type="text" name="tenVe" id="tenVe" required>
                    
                    <label>Giá Bán (VNĐ):</label>
                    <input type="number" name="giaBan" id="giaBan" required>

                    <label>Số lượng tồn kho ban đầu:</label>
                    <input type="number" name="soLuongTon" id="soLuongTon" required>
                    
                    <div class="btn-group">
                        <button type="submit" class="btn-add" onclick="document.getElementById('action').value='add'">THÊM</button>
                        <button type="submit" class="btn-edit" onclick="document.getElementById('action').value='update'">SỬA</button>
                        <button type="button" class="btn-reset" onclick="resetForm()">LÀM MỚI</button>
                    </div>
                </form>
            </div>

            <div class="crud-table">
                
                <div class="toolbar">
                    <form action="VeController" method="GET">
                        
                        <div class="input-with-icon">
                            <span>🔍</span>
                            <input type="text" name="keyword" value="${currentKeyword}" placeholder="Nhập tên hoặc mã vé...">
                        </div>
                        
                        <div class="select-with-icon">
                            <span>📂</span>
                            <select name="filterDM">
                                <option value="ALL">Tất cả danh mục</option>
                                <c:forEach items="${listDM}" var="dm">
                                    <c:set var="isSelected" value="" />
                                    <c:if test="${currentFilterDM != null && currentFilterDM ne 'ALL' && currentFilterDM == dm.maDM}">
                                        <c:set var="isSelected" value="selected" />
                                    </c:if>
                                    <option value="${dm.maDM}" ${isSelected}>${dm.tenDanhMuc}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <button type="submit" class="btn-filter">LỌC</button>
                        <a href="VeController" class="btn-clear">❌ HỦY</a>
                    </form>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Mã</th>
                            <th>Tên Vé Dịch Vụ</th>
                            <th style="text-align: right;">Giá Bán</th>
                            <th style="text-align: center;">Tồn Kho</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listVe}" var="ve">
                            <tr>
                                <td style="font-weight: bold; color: #7f8c8d;">V${ve.maVe}</td>
                                
                                <td>
                                    <div style="color: #2980b9; font-weight: bold; cursor: pointer; font-size: 15px;" 
                                         onclick="editRow('${ve.maVe}', '${ve.maDM}', '${ve.tenVe}', '${ve.giaBan}', '${ve.soLuongTon}')">
                                        ${ve.tenVe}
                                    </div>
                                    <span class="badge-dm">📂 ${ve.tenDM}</span>
                                </td>
                                
                                <td style="text-align: right; color: #e74c3c; font-weight: bold; font-size: 15px;">
                                    ${String.format('%,.0f', ve.giaBan)} đ
                                </td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${ve.soLuongTon < 5}">
                                            <span style="background: #e74c3c; color: white; padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold;">${ve.soLuongTon} (Sắp hết)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #27ae60; font-weight: bold; font-size: 15px;">${ve.soLuongTon}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="VeController?action=delete&maVe=${ve.maVe}" 
                                       onclick="return confirm('Cảnh báo: Bạn có chắc chắn muốn xóa Vé ${ve.tenVe}?');" 
                                       style="color: #e74c3c; text-decoration: none; font-weight: bold; font-size: 13px;">[x] Xóa</a>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <c:if test="${empty listVe}">
                            <tr><td colspan="5" style="text-align: center; color: #999; padding: 40px; font-size: 16px;">🔍 Không tìm thấy vé nào phù hợp với yêu cầu lọc!</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function editRow(maVe, maDM, tenVe, giaBan, soLuongTon) {
            document.getElementById('maVe').value = maVe;
            document.getElementById('maDM').value = maDM;
            document.getElementById('tenVe').value = tenVe;
            document.getElementById('giaBan').value = parseFloat(giaBan);
            document.getElementById('soLuongTon').value = soLuongTon;
            document.getElementById('action').value = "update";
        }
        function resetForm() {
            document.getElementById('maVe').value = "";
            document.getElementById('maDM').selectedIndex = 0;
            document.getElementById('tenVe').value = "";
            document.getElementById('giaBan').value = "";
            document.getElementById('soLuongTon').value = "";
            document.getElementById('action').value = "add";
        }
    </script>
</body>
</html>