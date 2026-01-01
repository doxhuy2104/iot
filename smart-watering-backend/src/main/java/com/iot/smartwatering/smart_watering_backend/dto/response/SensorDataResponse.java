package com.iot.smartwatering.smart_watering_backend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class SensorDataResponse {
    private Long dataId;
    private Long zoneId;
    private String zoneName;
    private Float soilMoisture;
    private Float temperature;
    private Float humidity;
    private LocalDateTime createdAt;
}
