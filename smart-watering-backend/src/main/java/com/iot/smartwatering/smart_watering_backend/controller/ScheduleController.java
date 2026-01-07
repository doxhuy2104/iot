package com.iot.smartwatering.smart_watering_backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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

    @DeleteMapping("/{scheduleId}")
    public ResponseEntity<ApiResponse<Void>> deleteSchedule(@PathVariable Long scheduleId) {
        scheduleService.deleteSchedule(scheduleId);
        return ResponseEntity.ok(ApiResponse.success("Schedule deleted successfully", null));
    }

    @PatchMapping("/{scheduleId}/active")
    public ResponseEntity<ApiResponse<ScheduleResponse>> toggleScheduleActive(
            @PathVariable Long scheduleId,
            @RequestParam boolean active) {
        ScheduleResponse schedule = scheduleService.toggleScheduleActive(scheduleId, active);
        return ResponseEntity.ok(ApiResponse.success("Schedule updated successfully", schedule));
    }

    @PostMapping("/zone/{zoneId}/sync")
    public ResponseEntity<ApiResponse<Void>> syncSchedules(@PathVariable Long zoneId) {
        scheduleService.syncZoneSchedules(zoneId);
        return ResponseEntity.ok(ApiResponse.success("Schedules synced successfully", null));
    }
}
