package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.List;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;

import dao.HoaDonDAO;
import model.HoaDon;
import model.ChiTietHoaDon;

@WebServlet("/LichSuController")
public class LichSuController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("currentRole");
        
        if (role == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        HoaDonDAO dao = new HoaDonDAO();
        String action = request.getParameter("action");
        
        String tuNgay = request.getParameter("tuNgay");
        String denNgay = request.getParameter("denNgay");
        String filter = request.getParameter("filter");

        if (filter == null && (tuNgay == null || tuNgay.isEmpty()) && (denNgay == null || denNgay.isEmpty())) {
            filter = "ALL";
        }

        // ========================================================
        // 🔥 XUẤT EXCEL BẰNG APACHE POI (ĐÃ KHÓA QUYỀN ADMIN)
        // ========================================================
        if ("exportExcel".equals(action)) {
            // Chặn đứng nếu không phải Admin/Quản lý
            if (!role.equalsIgnoreCase("admin") && !role.equalsIgnoreCase("quản lý")) {
                session.setAttribute("notification", "⛔ CẢNH BÁO BẢO MẬT: Bạn không có quyền xuất dữ liệu Excel!");
                response.sendRedirect("LichSuController");
                return;
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"BaoCaoDoanhThu_Meraki.xlsx\"");

            try (Workbook workbook = new XSSFWorkbook(); OutputStream out = response.getOutputStream()) {
                Sheet sheet = workbook.createSheet("Báo Cáo Doanh Thu");

                CellStyle titleStyle = workbook.createCellStyle();
                Font titleFont = workbook.createFont();
                titleFont.setBold(true);
                titleFont.setFontHeightInPoints((short) 16);
                titleFont.setColor(IndexedColors.DARK_BLUE.getIndex());
                titleStyle.setFont(titleFont);
                titleStyle.setAlignment(HorizontalAlignment.CENTER);

                CellStyle headerStyle = workbook.createCellStyle();
                Font headerFont = workbook.createFont();
                headerFont.setBold(true);
                headerFont.setColor(IndexedColors.WHITE.getIndex());
                headerStyle.setFont(headerFont);
                headerStyle.setFillForegroundColor(IndexedColors.TEAL.getIndex());
                headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
                headerStyle.setBorderBottom(BorderStyle.THIN);
                headerStyle.setBorderTop(BorderStyle.THIN);
                headerStyle.setBorderLeft(BorderStyle.THIN);
                headerStyle.setBorderRight(BorderStyle.THIN);
                headerStyle.setAlignment(HorizontalAlignment.CENTER);

                CellStyle currencyStyle = workbook.createCellStyle();
                DataFormat format = workbook.createDataFormat();
                currencyStyle.setDataFormat(format.getFormat("#,##0"));
                currencyStyle.setBorderBottom(BorderStyle.THIN);
                currencyStyle.setBorderTop(BorderStyle.THIN);
                currencyStyle.setBorderLeft(BorderStyle.THIN);
                currencyStyle.setBorderRight(BorderStyle.THIN);
                
                CellStyle normalStyle = workbook.createCellStyle();
                normalStyle.setBorderBottom(BorderStyle.THIN);
                normalStyle.setBorderTop(BorderStyle.THIN);
                normalStyle.setBorderLeft(BorderStyle.THIN);
                normalStyle.setBorderRight(BorderStyle.THIN);

                Row row0 = sheet.createRow(0);
                Cell cellTitle = row0.createCell(0);
                cellTitle.setCellValue("CÔNG TY CỔ PHẦN MERAKI TICKET");
                cellTitle.setCellStyle(titleStyle);
                sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 3)); 

                Row row1 = sheet.createRow(1);
                Cell r1c0 = row1.createCell(0);
                r1c0.setCellValue("Địa chỉ: Khu du lịch Núi Bà Đen, Tây Ninh");
                r1c0.getCellStyle().setAlignment(HorizontalAlignment.CENTER);
                sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 3));

                Row row2 = sheet.createRow(2);
                Cell r2c0 = row2.createCell(0);
                r2c0.setCellValue("BÁO CÁO DOANH THU ĐỊNH KỲ");
                r2c0.getCellStyle().setAlignment(HorizontalAlignment.CENTER);
                sheet.addMergedRegion(new CellRangeAddress(2, 2, 0, 3));

                String filterText = "Tất cả thời gian";
                if("today".equals(filter)) filterText = "Hôm nay";
                else if("week".equals(filter)) filterText = "Tuần này";
                else if("month".equals(filter)) filterText = "Tháng này";
                else if(tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
                    filterText = "Từ ngày: " + tuNgay + " Đến ngày: " + denNgay;
                }
                
                Row row3 = sheet.createRow(3);
                Cell r3c0 = row3.createCell(0);
                r3c0.setCellValue("Thời gian lọc: " + filterText);
                r3c0.getCellStyle().setAlignment(HorizontalAlignment.CENTER);
                sheet.addMergedRegion(new CellRangeAddress(3, 3, 0, 3));

                Row row5 = sheet.createRow(5);
                String[] headers = {"Mã Hóa Đơn", "Thời Gian Lập", "Thu Ngân", "Tổng Tiền (VNĐ)"};
                for (int i = 0; i < headers.length; i++) {
                    Cell cell = row5.createCell(i);
                    cell.setCellValue(headers[i]);
                    cell.setCellStyle(headerStyle);
                }

                List<HoaDon> listHDExport = dao.getHoaDonByDateFilter(tuNgay, denNgay, filter);
                int rowNum = 6;
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

                for (HoaDon hd : listHDExport) {
                    Row row = sheet.createRow(rowNum++);
                    
                    Cell c0 = row.createCell(0);
                    c0.setCellValue("HD-" + hd.getMaHD());
                    c0.setCellStyle(normalStyle);
                    
                    Cell c1 = row.createCell(1);
                    c1.setCellValue(sdf.format(hd.getNgayTao()));
                    c1.setCellStyle(normalStyle);
                    
                    Cell c2 = row.createCell(2);
                    c2.setCellValue(hd.getNguoiTao());
                    c2.setCellStyle(normalStyle);
                    
                    Cell c3 = row.createCell(3);
                    c3.setCellValue(hd.getTongTien());
                    c3.setCellStyle(currencyStyle);
                }

                Row totalRow = sheet.createRow(rowNum);
                Cell totalLabelCell = totalRow.createCell(2);
                totalLabelCell.setCellValue("TỔNG CỘNG DOANH THU:");
                totalLabelCell.setCellStyle(headerStyle);
                
                Cell sumCell = totalRow.createCell(3);
                if (rowNum > 6) {
                    sumCell.setCellFormula("SUM(D7:D" + rowNum + ")");
                } else {
                    sumCell.setCellValue(0);
                }
                
                CellStyle totalCurrencyStyle = workbook.createCellStyle();
                totalCurrencyStyle.cloneStyleFrom(currencyStyle);
                Font totalFont = workbook.createFont();
                totalFont.setBold(true);
                totalFont.setColor(IndexedColors.RED.getIndex());
                totalCurrencyStyle.setFont(totalFont);
                totalCurrencyStyle.setFillForegroundColor(IndexedColors.YELLOW.getIndex());
                totalCurrencyStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
                sumCell.setCellStyle(totalCurrencyStyle);

                // 🔥 Fix lỗi che chữ: Tự động căn chỉnh độ rộng cột theo dữ liệu thật
                for (int i = 0; i < 4; i++) {
                    sheet.autoSizeColumn(i);
                    // Cộng thêm một chút khoảng trắng cho nhìn thoáng mắt hơn
                    sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1200); 
                }

                workbook.write(out);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return; 
        }

        // ========================================================
        // NGHIỆP VỤ HỦY HÓA ĐƠN
        // ========================================================
        if ("delete".equals(action)) {
            if (role.equalsIgnoreCase("admin") || role.equalsIgnoreCase("quản lý")) {
                int maHD = Integer.parseInt(request.getParameter("maHD"));
                String result = dao.xoaHoaDon(maHD);
                
                if ("SUCCESS".equals(result)) {
                    session.setAttribute("notification", "✅ Hủy Hóa Đơn thành công! Toàn bộ vé đã được hoàn trả lại vào Kho.");
                } else {
                    session.setAttribute("notification", "❌ Lỗi hệ thống: " + result);
                }
            } else {
                session.setAttribute("notification", "⛔ CẢNH BÁO BẢO MẬT: Bạn không có quyền Hủy Hóa Đơn!");
            }
            
            String redirectUrl = "LichSuController?";
            if(tuNgay != null && !tuNgay.isEmpty()) redirectUrl += "tuNgay=" + tuNgay + "&";
            if(denNgay != null && !denNgay.isEmpty()) redirectUrl += "denNgay=" + denNgay + "&";
            if(filter != null && !filter.isEmpty()) redirectUrl += "filter=" + filter;
            
            response.sendRedirect(redirectUrl);
            return;
        }

        // ========================================================
        // XỬ LÝ LỌC VÀ HIỂN THỊ DANH SÁCH
        // ========================================================
        List<HoaDon> listHD = dao.getHoaDonByDateFilter(tuNgay, denNgay, filter);
        request.setAttribute("listHD", listHD);

        if ("view".equals(action)) {
            int maHD = Integer.parseInt(request.getParameter("maHD"));
            List<ChiTietHoaDon> listCT = dao.getChiTietByMaHD(maHD);
            
            // 🔥 Lấy thêm phương thức thanh toán đẩy ra giao diện
            String phuongThuc = dao.getHinhThucThanhToan(maHD);
            request.setAttribute("phuongThuc", phuongThuc);
            
            request.setAttribute("listCT", listCT);
            request.setAttribute("activeHD", maHD);
        }

        double tongDoanhThu = 0;
        for (HoaDon hd : listHD) {
            tongDoanhThu += hd.getTongTien();
        }
        request.setAttribute("tongDoanhThu", tongDoanhThu);

        request.getRequestDispatcher("lichsu.jsp").forward(request, response);
    }
}