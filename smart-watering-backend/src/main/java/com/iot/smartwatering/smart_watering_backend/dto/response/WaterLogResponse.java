package com.iot.smartwatering.smart_watering_backend.dto.response;

import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WaterLogResponse {
    private Long logId;
    private Long zoneId;
    private String zoneName;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer durationSeconds;
    private Double volume;
    private String reason;
    private String status;
    private Integer deviceId;
    private String deviceName;
    private LocalDateTime createdAt;
}
