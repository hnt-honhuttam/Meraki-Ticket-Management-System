package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnect {
    
    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Đánh thức thư viện JDBC trước khi kết nối
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // Đã sửa lại user=sa và password=123456 chuẩn với SQL Server
            String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=Meraki_DB;user=sa;password=123456;encrypt=false;trustServerCertificate=true;";
            
            conn = DriverManager.getConnection(dbURL);
            System.out.println("✅ KẾT NỐI DATABASE MERAKI THÀNH CÔNG VỚI SA!");
            
        } catch (ClassNotFoundException e) {
            System.out.println("❌ LỖI: TOMCAT KHÔNG TÌM THẤY FILE JDBC (.jar) TRONG THƯ MỤC WEB-INF/lib");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ LỖI SAI TÀI KHOẢN, MẬT KHẨU HOẶC TÊN DATABASE!");
            e.printStackTrace();
        }
        return conn;
    }

    public static void main(String[] args) {
        getConnection();
    }
}