package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ZoneConfigRequest {
    @NotNull(message = "Zone ID is required")
    private Long zoneId;

    @NotNull(message = "Threshold min is required")
    private Double thresholdMin;

    @NotNull(message = "Threshold max is required")
    private Double thresholdMax;
}
