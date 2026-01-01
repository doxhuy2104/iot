package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalTime;

@Data
public class ScheduleRequest {
    @NotNull(message = "Zone ID không được để trống")
    private Integer zoneId;

    @NotNull(message = "Start time không được để trống")
    private LocalTime startTime;

    @NotNull(message = "Duration không được để trống")
    private Integer durationMinutes;

    private String repeatDays; // "Mon,Tue,Wed,..."
    private Boolean active;
}
