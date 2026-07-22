package util;

import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

public class SecurityUtil {
    
    // Hàm băm mật khẩu bằng thuật toán SHA-256
    public static String hashPassword(String base) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            // Lấy byte của chuỗi mật khẩu gốc
            byte[] hash = digest.digest(base.getBytes(StandardCharsets.UTF_8));
            
            // Chuyển mảng byte thành chuỗi Hex (hệ cơ số 16) để lưu vào DB
            StringBuilder hexString = new StringBuilder();
            for (int i = 0; i < hash.length; i++) {
                String hex = Integer.toHexString(0xff & hash[i]);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
            
        } catch (Exception ex) {
            throw new RuntimeException("Lỗi mã hóa SHA-256", ex);
        }
    }
}