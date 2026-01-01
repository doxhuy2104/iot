package com.iot.smartwatering.smart_watering_backend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class DeviceResponse {
    private Long deviceId;
    private String deviceName;
    private String type;
    private String identifier;
    private String status;
    private Long zoneId;
    private String zoneName;
    private LocalDateTime createdAt;
}
