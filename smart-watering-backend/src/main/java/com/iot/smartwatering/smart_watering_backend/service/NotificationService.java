package com.iot.smartwatering.smart_watering_backend.service;

import com.iot.smartwatering.smart_watering_backend.entity.Alert;
import com.iot.smartwatering.smart_watering_backend.entity.Notification;
import com.iot.smartwatering.smart_watering_backend.entity.User;
import com.iot.smartwatering.smart_watering_backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@Slf4j
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    /**
     * Tạo notification trong app cho user khi có alert
     */
    @Transactional
    public Notification createNotificationFromAlert(Alert alert, User user) {
        try {
            Notification notification = Notification.builder()
                    .type(Notification.NotificationType.ALERT)
                    .title(getAlertTitle(alert))
                    .message(alert.getMessage())
                    .user(user)
                    .alert(alert)
                    .isRead(false)
                    .createdAt(LocalDateTime.now())
                    .build();

            notificationRepository.save(notification);
            log.info("Created notification for user: {} - Alert: {}", user.getUserId(), alert.getAlertId());
            
            return notification;
        } catch (Exception e) {
            log.error("Error creating notification for alert: {}", alert.getAlertId(), e);
            throw e;
        }
    }

    /**
     * Đánh dấu notification đã đọc
     */
    @Transactional
    public void markAsRead(Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(notification -> {
            notification.setIsRead(true);
            notificationRepository.save(notification);
            log.info("Marked notification as read: {}", notificationId);
        });
    }

    /**
     * Đánh dấu tất cả notification của user đã đọc
     */
    @Transactional
    public void markAllAsReadForUser(Long userId) {
        notificationRepository.findByUser_UserIdAndIsReadFalse(userId).forEach(notification -> {
            notification.setIsRead(true);
            notificationRepository.save(notification);
        });
        log.info("Marked all notifications as read for user: {}", userId);
    }

    private String getAlertTitle(Alert alert) {
        return switch (alert.getSeverity()) {
            case CRITICAL -> "⚠️ Cảnh báo nghiêm trọng";
            case ERROR -> "❌ Lỗi hệ thống";
            case WARNING -> "⚡ Cảnh báo độ ẩm";
            case INFO -> "ℹ️ Thông báo";
        };
    }
}
