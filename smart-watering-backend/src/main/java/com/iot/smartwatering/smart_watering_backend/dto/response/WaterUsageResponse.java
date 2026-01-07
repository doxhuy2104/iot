package com.iot.smartwatering.smart_watering_backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WaterUsageResponse {
    private Long zoneId;
    private String zoneName;
    private LocalDate date;
    private String period; // "daily", "monthly", "yearly"
    private Float totalLiters;
    private Long dataPointCount;
    private Float averageFlowRate;
    private Float minFlowRate;
    private Float maxFlowRate;
}
