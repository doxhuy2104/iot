package com.iot.smartwatering.smart_watering_backend.controller;


import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.SensorDataResponse;
import com.iot.smartwatering.smart_watering_backend.entity.SensorData;
import com.iot.smartwatering.smart_watering_backend.repository.SensorDataRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/sensors")
@RequiredArgsConstructor
public class SensorController {

    private final SensorDataRepository sensorDataRepository;

    @GetMapping("/zone/{zoneId}")
    public ResponseEntity<ApiResponse<List<SensorDataResponse>>> getSensorData(
            @PathVariable Long zoneId) {
        List<SensorData> data = sensorDataRepository
                .findByZone_ZoneIdOrderByCreatedAtDesc(zoneId);

        List<SensorDataResponse> response = data.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/zone/{zoneId}/range")
    public ResponseEntity<ApiResponse<List<SensorDataResponse>>> getSensorDataByRange(
            @PathVariable Long zoneId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime endDate) {

        List<SensorData> data = sensorDataRepository
                .findByZoneAndDateRange(zoneId, startDate, endDate);

        List<SensorDataResponse> response = data.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/zone/{zoneId}/latest")
    public ResponseEntity<ApiResponse<SensorDataResponse>> getLatestSensorData(
            @PathVariable Long zoneId) {
        SensorData data = sensorDataRepository.findLatestByZone(zoneId);

        if (data == null) {
            return ResponseEntity.ok(ApiResponse.error("No sensor data found"));
        }

        return ResponseEntity.ok(ApiResponse.success(mapToResponse(data)));
    }

    private SensorDataResponse mapToResponse(SensorData data) {
        return SensorDataResponse.builder()
                .dataId(data.getDataId())
                .zoneId(data.getZone().getZoneId())
                .zoneName(data.getZone().getZoneName())
                .soilMoisture(data.getSoilMoisture())
                .temperature(data.getTemperature())
                .humidity(data.getHumidity())
                .createdAt(data.getCreatedAt())
                .build();
    }
}
