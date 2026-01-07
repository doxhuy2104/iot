package com.iot.smartwatering.smart_watering_backend.controller;

import com.iot.smartwatering.smart_watering_backend.dto.response.AlertResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.NotificationResponse;
import com.iot.smartwatering.smart_watering_backend.entity.Alert;
import com.iot.smartwatering.smart_watering_backend.entity.Notification;
import com.iot.smartwatering.smart_watering_backend.entity.User;
import com.iot.smartwatering.smart_watering_backend.repository.AlertRepository;
import com.iot.smartwatering.smart_watering_backend.repository.NotificationRepository;
import com.iot.smartwatering.smart_watering_backend.repository.UserRepository;
import com.iot.smartwatering.smart_watering_backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('USER', 'ADMIN')")
public class AlertController {

    private final AlertRepository alertRepository;
    private final NotificationRepository notificationRepository;
    private final NotificationService notificationService;
    private final UserRepository userRepository;

    /**
     * Lấy tất cả alerts
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<AlertResponse>>> getAllAlerts() {
        List<Alert> alerts = alertRepository.findAll();
        List<AlertResponse> response = alerts.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy alerts chưa xử lý
     */
    @GetMapping("/unhandled")
    public ResponseEntity<ApiResponse<List<AlertResponse>>> getUnhandledAlerts() {
        List<Alert> alerts = alertRepository.findByIsHandledFalseOrderByCreatedAtDesc();
        List<AlertResponse> response = alerts.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy alerts theo zone
     */
    @GetMapping("/zone/{zoneId}")
    public ResponseEntity<ApiResponse<List<AlertResponse>>> getAlertsByZone(@PathVariable Integer zoneId) {
        List<Alert> alerts = alertRepository.findByZone_ZoneIdOrderByCreatedAtDesc(zoneId);
        List<AlertResponse> response = alerts.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy alerts theo mức độ
     */
    @GetMapping("/severity/{severity}")
    public ResponseEntity<ApiResponse<List<AlertResponse>>> getAlertsBySeverity(
            @PathVariable Alert.AlertSeverity severity) {
        List<Alert> alerts = alertRepository.findBySeverityOrderByCreatedAtDesc(severity);
        List<AlertResponse> response = alerts.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Đánh dấu alert đã xử lý
     */
    @PutMapping("/{alertId}/handle")
    public ResponseEntity<ApiResponse<AlertResponse>> handleAlert(
            @PathVariable Long alertId,
            Authentication authentication) {
        
        Alert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found"));

        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        alert.setIsHandled(true);
        alert.setHandledAt(LocalDateTime.now());
        alert.setHandledBy(user);
        alertRepository.save(alert);

        return ResponseEntity.ok(ApiResponse.success(mapToResponse(alert)));
    }

    /**
     * Lấy notifications của user hiện tại
     */
    @GetMapping("/notifications")
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getMyNotifications(
            Authentication authentication) {
        
        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Notification> notifications = notificationRepository
                .findByUser_UserIdOrderByCreatedAtDesc(user.getUserId());

        List<NotificationResponse> response = notifications.stream()
                .map(this::mapToNotificationResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy notifications chưa đọc
     */
    @GetMapping("/notifications/unread")
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getUnreadNotifications(
            Authentication authentication) {
        
        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Notification> notifications = notificationRepository
                .findByUser_UserIdAndIsReadFalse(user.getUserId());

        List<NotificationResponse> response = notifications.stream()
                .map(this::mapToNotificationResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Đếm số notifications chưa đọc
     */
    @GetMapping("/notifications/unread/count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(Authentication authentication) {
        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        long count = notificationRepository.findByUser_UserIdAndIsReadFalse(user.getUserId()).size();
        return ResponseEntity.ok(ApiResponse.success(count));
    }

    /**
     * Đánh dấu notification đã đọc
     */
    @PutMapping("/notifications/{notificationId}/read")
    public ResponseEntity<ApiResponse<Void>> markNotificationAsRead(@PathVariable Long notificationId) {
        notificationService.markAsRead(notificationId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * Đánh dấu tất cả notifications đã đọc
     */
    @PutMapping("/notifications/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(Authentication authentication) {
        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        notificationService.markAllAsReadForUser(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    private AlertResponse mapToResponse(Alert alert) {
        return AlertResponse.builder()
                .alertId(alert.getAlertId())
                .zoneId(alert.getZone() != null ? alert.getZone().getZoneId() : null)
                .zoneName(alert.getZone() != null ? alert.getZone().getZoneName() : null)
                .deviceId(alert.getDevice() != null ? alert.getDevice().getDeviceId() : null)
                .deviceName(alert.getDevice() != null ? alert.getDevice().getDeviceName() : null)
                .severity(alert.getSeverity())
                .message(alert.getMessage())
                .isHandled(alert.getIsHandled())
                .handledAt(alert.getHandledAt())
                .handledByUsername(alert.getHandledBy() != null ? alert.getHandledBy().getUsername() : null)
                .createdAt(alert.getCreatedAt())
                .hasNotification(alert.getNotification() != null)
                .build();
    }

    private NotificationResponse mapToNotificationResponse(Notification notification) {
        return NotificationResponse.builder()
                .notiId(notification.getNotiId())
                .type(notification.getType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .isRead(notification.getIsRead())
                .createdAt(notification.getCreatedAt())
                .alertId(notification.getAlert() != null ? notification.getAlert().getAlertId() : null)
                .zoneName(notification.getAlert() != null && notification.getAlert().getZone() != null 
                        ? notification.getAlert().getZone().getZoneName() : null)
                .build();
    }
}
