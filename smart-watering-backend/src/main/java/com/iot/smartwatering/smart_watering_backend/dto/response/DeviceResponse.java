package com.iot.smartwatering.smart_watering_backend.dto.response;

import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DeviceResponse {
    private Integer deviceId;
    private String deviceName;
    private String type;
    private String identifier;
    private String status;
    private Long zoneId;
    private String zoneName;
    private LocalDateTime createdAt;
}
