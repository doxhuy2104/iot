package com.iot.smartwatering.smart_watering_backend.dto.response;

import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ScheduleResponse {
    private Long scheduleId;
    private Long zoneId;
    private java.time.LocalTime startTime;
    private Long duration;
    private String repeatDays;
    private Double volume;
    private Boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
