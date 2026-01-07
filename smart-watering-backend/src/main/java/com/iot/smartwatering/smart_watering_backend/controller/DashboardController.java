package com.iot.smartwatering.smart_watering_backend.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.repository.AlertRepository;
import com.iot.smartwatering.smart_watering_backend.repository.DeviceRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('USER', 'ADMIN')")
public class DashboardController {

    private final ZoneRepository zoneRepository;
    private final DeviceRepository deviceRepository;
    private final AlertRepository alertRepository;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        stats.put("totalZones", zoneRepository.count());
        stats.put("totalDevices", deviceRepository.count());
        stats.put("onlineDevices", deviceRepository
                .findByStatus(com.iot.smartwatering.smart_watering_backend.entity.Device.DeviceStatus.ONLINE).size());
        stats.put("unhandledAlerts", alertRepository
                .findByIsHandledFalseOrderByCreatedAtDesc().size());

        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}