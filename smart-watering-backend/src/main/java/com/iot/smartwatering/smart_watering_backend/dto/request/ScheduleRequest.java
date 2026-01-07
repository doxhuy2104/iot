package com.iot.smartwatering.smart_watering_backend.dto.request;

import java.time.LocalTime;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ScheduleRequest {
    @NotNull(message = "Zone ID không được để trống")
    private Integer zoneId;

    @NotNull(message = "Start time không được để trống")
    private LocalTime startTime;

    @NotNull(message = "Duration không được để trống")
    private Integer duration;

    @NotNull(message = "Volume không được để trống")
    private Double volume;

    private String repeatDays; // "Mon,Tue,Wed,..."

    private Boolean active;
}
