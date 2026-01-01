package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ZoneRequest {
    @NotBlank(message = "Zone name không được để trống")
    private String zoneName;

    private BigDecimal location;
    private String description;
    private String longitude;
    private BigDecimal latitude;
    private Double thresholdValue;
    private Boolean autoMode;
    private Boolean weatherMode;
}
