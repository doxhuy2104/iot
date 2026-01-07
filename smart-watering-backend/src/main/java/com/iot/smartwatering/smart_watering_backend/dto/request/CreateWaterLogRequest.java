package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateWaterLogRequest {
    @NotNull(message = "Zone ID không được để trống")
    private Long zoneId;
    private Integer deviceId;
    private String reason; // MANUAL, AUTO_MOISTURE, SCHEDULED, WEATHER_BASED
    private java.time.LocalDateTime startedAt;
    private java.time.LocalDateTime endedAt;
    private Integer durationSeconds;
    private Double volume;
}
