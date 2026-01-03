package com.iot.smartwatering.smart_watering_backend.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

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
    private String deviceIdentifier;
}
