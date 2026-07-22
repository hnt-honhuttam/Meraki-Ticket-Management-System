<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("currentUsername") == null) { 
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 🔥 LẤY QUYỀN ĐỂ ĐIỀU HƯỚNG NÚT THOÁT ĐỘNG
    String role = (String) session.getAttribute("currentRole");
    boolean isAdmin = role != null && (role.equalsIgnoreCase("admin") || role.equalsIgnoreCase("quản lý"));
    String exitUrl = isAdmin ? "DashboardController" : "POSController"; // Admin về Tổng quan, Staff về POS
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trạm Soát Vé Điện Tử - Meraki Gate</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Courier New', Courier, monospace; }
        
        /* Chế độ Kiosk màn hình đen */
        body { 
            background-color: #0b1120; color: #fff; height: 100vh; display: flex; 
            flex-direction: column; align-items: center; justify-content: center;
            transition: background-color 0.3s ease; overflow: hidden;
        }

        /* Các trạng thái chớp nháy màu của toàn bộ màn hình */
        body.state-success { background-color: #064e3b; } /* Xanh lá */
        body.state-error { background-color: #7f1d1d; } /* Đỏ rực */
        body.state-warning { background-color: #78350f; } /* Cam/Vàng */

        .header-top { position: absolute; top: 20px; width: 100%; padding: 0 40px; display: flex; justify-content: space-between; align-items: center; }
        .logo-text { font-size: 24px; font-weight: bold; color: #34eba9; text-shadow: 0 0 10px rgba(52,235,169,0.5); }
        .btn-exit { background: transparent; border: 1px solid #475569; color: #94a3b8; padding: 10px 20px; cursor: pointer; border-radius: 5px; text-decoration: none; font-family: 'Segoe UI', Tahoma, sans-serif; font-weight: bold; }
        .btn-exit:hover { background: #334155; color: #fff; }

        /* Vùng quét mã Barcode/QR */
        .scanner-container { background: #1e293b; padding: 40px; border-radius: 15px; border: 2px solid #334155; width: 600px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); position: relative; }
        .scanner-container h2 { font-family: 'Segoe UI', Tahoma, sans-serif; color: #38bdf8; margin-bottom: 20px; font-size: 22px; display: flex; align-items: center; justify-content: center; gap: 10px;}
        
        .input-wrapper { position: relative; overflow: hidden; border-radius: 8px; border: 2px solid #34eba9; box-shadow: 0 0 15px rgba(52,235,169,0.2); }
        
        /* Hiệu ứng tia Laser quét ngang */
        .laser-line { position: absolute; left: 0; width: 100%; height: 2px; background: #34eba9; box-shadow: 0 0 15px #34eba9; animation: scan 2s infinite linear; pointer-events: none; }
        @keyframes scan { 0% { top: 0; opacity: 0;} 10% { opacity: 1; } 90% { opacity: 1; } 100% { top: 100%; opacity: 0;} }

        /* Ô input bị làm cho vô hình nhưng vẫn nhận chữ */
        #maHD { width: 100%; padding: 25px; background: #0f172a; border: none; color: #34eba9; font-size: 30px; text-align: center; font-weight: bold; outline: none; letter-spacing: 5px;}
        #maHD::placeholder { color: #334155; letter-spacing: 2px; font-weight: normal; }

        /* Khu vực báo trạng thái chi tiết */
        #statusArea { margin-top: 30px; min-height: 150px; display: flex; flex-direction: column; justify-content: center; }
        .status-icon { font-size: 60px; margin-bottom: 10px; }
        .status-title { font-size: 28px; font-weight: bold; margin-bottom: 15px; font-family: 'Segoe UI', Tahoma, sans-serif; }
        .status-details { background: rgba(0,0,0,0.3); padding: 15px; border-radius: 8px; text-align: left; display: none; }

        /* Lệnh rung lắc báo lỗi */
        .shake { animation: shake 0.4s cubic-bezier(.36,.07,.19,.97) both; }
        @keyframes shake { 10%, 90% { transform: translate3d(-2px, 0, 0); } 20%, 80% { transform: translate3d(4px, 0, 0); } 30%, 50%, 70% { transform: translate3d(-6px, 0, 0); } 40%, 60% { transform: translate3d(6px, 0, 0); } }

    </style>
</head>
<body>

    <div class="header-top">
        <div class="logo-text">[ MERAKI TICKET GATE ]</div>
        <a href="<%= exitUrl %>" class="btn-exit">⬅ THOÁT VỀ HỆ THỐNG</a>
    </div>

    <div class="scanner-container" id="scannerBox">
        <h2><span style="font-size: 28px;">📷</span> VUI LÒNG QUÉT MÃ QR TRÊN VÉ</h2>
        
        <form id="scanForm" onsubmit="handleScan(event)">
            <div class="input-wrapper">
                <div class="laser-line"></div>
                <input type="text" id="maHD" name="maHD" placeholder="HD-..." autocomplete="off">
            </div>
        </form>

        <div id="statusArea">
            <div style="color: #64748b; font-size: 16px; margin-top: 50px;">Đang chờ tín hiệu từ máy quét...</div>
        </div>
    </div>

    <script>
        const inputField = document.getElementById('maHD');
        const statusArea = document.getElementById('statusArea');
        const scannerBox = document.getElementById('scannerBox');

        // 🔥 THUẬT TOÁN GIỮ FOCUS CHO SÚNG BẮN MÃ VẠCH KHÔNG BAO GIỜ TRƯỢT
        inputField.focus();
        document.addEventListener('click', () => inputField.focus());
        inputField.addEventListener('blur', () => { setTimeout(() => inputField.focus(), 10); });

        // 🔥 BỘ TẠO ÂM THANH KHÔNG CẦN FILE MP3 (WEB AUDIO API)
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        const audioCtx = new AudioContext();

        function playSound(type) {
            if (audioCtx.state === 'suspended') audioCtx.resume();
            const osc = audioCtx.createOscillator();
            const gainNode = audioCtx.createGain();
            osc.connect(gainNode);
            gainNode.connect(audioCtx.destination);

            if (type === 'success') {
                // Tiếng Ting! (Cửa mở)
                osc.type = 'sine';
                osc.frequency.setValueAtTime(880, audioCtx.currentTime); 
                osc.frequency.exponentialRampToValueAtTime(1760, audioCtx.currentTime + 0.1);
                gainNode.gain.setValueAtTime(0.5, audioCtx.currentTime);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.5);
                osc.start(); osc.stop(audioCtx.currentTime + 0.5);
            } else if (type === 'error') {
                // Tiếng Buzzer Bíp! Bíp! (Lỗi)
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(150, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.5, audioCtx.currentTime);
                
                // Lặp tiếng bíp 2 lần
                osc.start();
                gainNode.gain.setValueAtTime(0, audioCtx.currentTime + 0.15);
                gainNode.gain.setValueAtTime(0.5, audioCtx.currentTime + 0.2);
                gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.4);
                osc.stop(audioCtx.currentTime + 0.4);
            }
        }

        // 🔥 XỬ LÝ DỮ LIỆU KHI SÚNG BẮN XONG (ENTER)
        function handleScan(event) {
            event.preventDefault(); // Chặn tải lại trang
            const maHD = inputField.value.trim();
            if(!maHD) return;

            inputField.value = ""; // Xóa mã cũ đi chờ quét mã mới

            // Gửi AJAX xuống Controller
            fetch('SoatVeController', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maHD=' + encodeURIComponent(maHD)
            })
            .then(response => response.json())
            .then(data => {
                scannerBox.classList.remove('shake'); // Reset hiệu ứng rung
                document.body.className = ''; // Reset màu nền
                void scannerBox.offsetWidth; // Trigger reflow
                
                let html = '';
                
                if (data.status === 'SUCCESS') {
                    document.body.classList.add('state-success');
                    playSound('success');
                    html = `
                        <div class="status-icon">✅</div>
                        <div class="status-title" style="color: #34eba9;">HỢP LỆ - MỞ CỔNG</div>
                        <div class="status-details" style="display: block; border-left: 4px solid #34eba9;">
                            <div style="font-size: 14px; color: #94a3b8; margin-bottom: 8px;">CHI TIẾT VÉ SỬ DỤNG:</div>
                            \${data.details}
                        </div>
                    `;
                } 
                else if (data.status === 'ALREADY_USED') {
                    document.body.classList.add('state-error');
                    scannerBox.classList.add('shake');
                    playSound('error');
                    html = `
                        <div class="status-icon">⛔</div>
                        <div class="status-title" style="color: #f87171;">VÉ ĐÃ QUA SỬ DỤNG!</div>
                        <div style="color: #cbd5e1; margin-bottom: 15px;">Mã QR này đã được quét qua cổng trước đó. TỪ CHỐI MỞ CỔNG.</div>
                        <div class="status-details" style="display: block; border-left: 4px solid #f87171;">
                            <div style="font-size: 14px; color: #94a3b8; margin-bottom: 8px;">THÔNG TIN VÉ GỐC:</div>
                            \${data.details}
                        </div>
                    `;
                } 
                else {
                    document.body.classList.add('state-warning');
                    scannerBox.classList.add('shake');
                    playSound('error');
                    html = `
                        <div class="status-icon">⚠️</div>
                        <div class="status-title" style="color: #fbbf24;">MÃ VÉ KHÔNG TỒN TẠI</div>
                        <div style="color: #cbd5e1;">Mã quét được: <b>\${maHD}</b></div>
                        <div style="color: #cbd5e1; font-size: 14px; margin-top: 10px;">Vui lòng kiểm tra lại vé hoặc hướng dẫn khách mua vé mới.</div>
                    `;
                }
                
                statusArea.innerHTML = html;
                
                // Tự động tắt cảnh báo sau 5 giây để chờ khách tiếp theo
                setTimeout(() => {
                    document.body.className = '';
                }, 5000);
            })
            .catch(error => console.error('Error:', error));
        }
    </script>
</body>
</html>