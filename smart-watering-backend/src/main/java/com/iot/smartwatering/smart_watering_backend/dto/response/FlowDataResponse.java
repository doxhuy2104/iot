package com.iot.smartwatering.smart_watering_backend.dto.response;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FlowDataResponse {
    private Long flowId;
    private Long zoneId;
    private String zoneName;
    private Integer deviceId;
    private String deviceName;
    private Long pulseCount;
    private Float flowRatePerMinute;
    private Float cumulativeLiters;
    private LocalDateTime createdAt;
}
