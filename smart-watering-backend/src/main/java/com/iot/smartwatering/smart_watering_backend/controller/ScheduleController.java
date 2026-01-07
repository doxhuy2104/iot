package com.iot.smartwatering.smart_watering_backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.iot.smartwatering.smart_watering_backend.dto.request.ScheduleRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.ScheduleResponse;
import com.iot.smartwatering.smart_watering_backend.service.ScheduleService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @PostMapping
    public ResponseEntity<ApiResponse<ScheduleResponse>> createSchedule(
            @Valid @RequestBody ScheduleRequest request) {
        ScheduleResponse schedule = scheduleService.createSchedule(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Schedule created successfully", schedule));
    }

    @GetMapping("/zone/{zoneId}")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> getSchedulesByZoneId(
            @PathVariable Long zoneId) {
        List<ScheduleResponse> schedules = scheduleService.getSchedulesByZoneId(zoneId);
        return ResponseEntity.ok(ApiResponse.success(schedules));
    }
}
