package com.iot.smartwatering.smart_watering_backend.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.iot.smartwatering.smart_watering_backend.dto.request.CreateWaterLogRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.WaterLogResponse;
import com.iot.smartwatering.smart_watering_backend.service.WaterLogService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/water-logs")
@RequiredArgsConstructor
public class WaterLogController {

    private final WaterLogService waterLogService;

    @PostMapping
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<WaterLogResponse>> createWaterLog(
            @Valid @RequestBody CreateWaterLogRequest request) {
        WaterLogResponse response = waterLogService.createWaterLog(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Water log created successfully", response));
    }

    @GetMapping("/zone/{zoneId}")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<WaterLogResponse>>> getLogsByZone(
            @PathVariable Long zoneId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        List<WaterLogResponse> logs;
        if (start != null && end != null) {
            logs = waterLogService.getLogsByZoneIdAndDateRange(zoneId, start, end);
        } else {
            logs = waterLogService.getLogsByZoneId(zoneId);
        }
        return ResponseEntity.ok(ApiResponse.success("Successfully retrieved water logs", logs));
    }
}
