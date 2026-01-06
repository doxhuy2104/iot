package com.iot.smartwatering.smart_watering_backend.service;

import com.iot.smartwatering.smart_watering_backend.entity.Alert;
import com.iot.smartwatering.smart_watering_backend.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;

@Service
@Slf4j
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:noreply@smartwatering.com}")
    private String fromEmail;

    @Value("${app.email.enabled:false}")
    private boolean emailEnabled;

    /**
     * Gửi email cảnh báo độ ẩm thấp
     */
    @Async
    public void sendLowMoistureAlert(Alert alert, User user) {
        if (!emailEnabled) {
            log.info("Email sending is disabled. Skipping email for alert: {}", alert.getAlertId());
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(user.getEmail());
            message.setSubject(getEmailSubject(alert));
            message.setText(buildEmailContent(alert, user));

            mailSender.send(message);
            log.info("Sent email alert to: {} for alert: {}", user.getEmail(), alert.getAlertId());
        } catch (Exception e) {
            log.error("Failed to send email to: {} for alert: {}", user.getEmail(), alert.getAlertId(), e);
        }
    }

    /**
     * Gửi email cảnh báo chung
     */
    @Async
    public void sendAlertEmail(Alert alert, User user) {
        sendLowMoistureAlert(alert, user);
    }

    private String getEmailSubject(Alert alert) {
        return switch (alert.getSeverity()) {
            case CRITICAL -> "[NGHIÊM TRỌNG] Cảnh báo hệ thống Smart Watering";
            case ERROR -> "[LỖI] Thông báo hệ thống Smart Watering";
            case WARNING -> "[CẢNH BÁO] Độ ẩm đất thấp - Smart Watering";
            case INFO -> "[THÔNG BÁO] Hệ thống Smart Watering";
        };
    }

    private String buildEmailContent(Alert alert, User user) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        
        StringBuilder content = new StringBuilder();
        content.append("Xin chào ").append(user.getUsername()).append(",\n\n");
        content.append("Hệ thống Smart Watering gửi đến bạn thông báo:\n\n");
        content.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        content.append("📍 Khu vực: ").append(alert.getZone() != null ? alert.getZone().getZoneName() : "N/A").append("\n");
        content.append("⚠️  Mức độ: ").append(getSeverityText(alert.getSeverity())).append("\n");
        content.append("📝 Chi tiết: ").append(alert.getMessage()).append("\n");
        content.append("🕐 Thời gian: ").append(alert.getCreatedAt().format(formatter)).append("\n");
        content.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n");
        
        if (alert.getSeverity() == Alert.AlertSeverity.WARNING) {
            content.append("💡 Khuyến nghị:\n");
            content.append("- Kiểm tra hệ thống tưới tiêu\n");
            content.append("- Xem xét bật chế độ tự động tưới\n");
            content.append("- Kiểm tra cảm biến độ ẩm\n\n");
        }
        
        content.append("Vui lòng truy cập hệ thống để xem chi tiết và xử lý.\n\n");
        content.append("Trân trọng,\n");
        content.append("Smart Watering System\n");
        content.append("\n---\n");
        content.append("Email này được gửi tự động, vui lòng không trả lời.");
        
        return content.toString();
    }

    private String getSeverityText(Alert.AlertSeverity severity) {
        return switch (severity) {
            case CRITICAL -> "Nghiêm trọng";
            case ERROR -> "Lỗi";
            case WARNING -> "Cảnh báo";
            case INFO -> "Thông tin";
        };
    }
}
