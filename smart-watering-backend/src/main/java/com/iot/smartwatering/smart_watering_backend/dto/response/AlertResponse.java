package com.iot.smartwatering.smart_watering_backend.dto.response;

import java.time.LocalDateTime;

import com.iot.smartwatering.smart_watering_backend.entity.Alert;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AlertResponse {
    private Long alertId;
    private Long zoneId;
    private String zoneName;
    private Integer deviceId;
    private String deviceName;
    private Alert.AlertSeverity severity;
    private String message;
    private Boolean isHandled;
    private LocalDateTime handledAt;
    private String handledByUsername;
    private LocalDateTime createdAt;
    private Boolean hasNotification;
}
