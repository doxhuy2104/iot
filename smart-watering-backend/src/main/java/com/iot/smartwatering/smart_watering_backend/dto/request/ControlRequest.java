package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ControlRequest {
    @NotNull(message = "Zone ID không được để trống")
    private Long zoneId;

    @NotNull(message = "Action không được để trống")
    private String action; // "ON" or "OFF"

    private Integer durationMinutes; // For timed watering
}
