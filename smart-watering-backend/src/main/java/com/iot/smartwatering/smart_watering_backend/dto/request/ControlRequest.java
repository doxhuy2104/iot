package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ControlRequest {
    @NotNull(message = "Zone ID không được để trống")
    private Long zoneId;

    @NotNull(message = "Pump command (ON/OFF) không được để trống")
    private String pump; // "ON" or "OFF"

    private Integer durationMinutes; // For timed watering

    private Integer targetHumidity; // For timed watering
}
