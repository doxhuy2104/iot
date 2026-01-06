package com.iot.smartwatering.smart_watering_backend.dto.response;

import com.iot.smartwatering.smart_watering_backend.entity.Notification;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private Long notiId;
    private Notification.NotificationType type;
    private String title;
    private String message;
    private Boolean isRead;
    private LocalDateTime createdAt;
    private Long alertId;
    private String zoneName;
}
