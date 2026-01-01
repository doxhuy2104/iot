package com.iot.smartwatering.smart_watering_backend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class ZoneResponse {
    private Long zoneId;
    private String zoneName;
    private BigDecimal location;
    private String description;
    private String longitude;
    private BigDecimal latitude;
    private Double thresholdValue;
    private Boolean autoMode;
    private Boolean weatherMode;
    private Boolean pumpStatus;
    private Float currentMoisture;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
