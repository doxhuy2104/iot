package com.iot.smartwatering.smart_watering_backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.iot.smartwatering.smart_watering_backend.dto.request.ZoneConfigRequest;
import com.iot.smartwatering.smart_watering_backend.dto.request.ZoneRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.ZoneResponse;
import com.iot.smartwatering.smart_watering_backend.service.ZoneService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/zones")
@RequiredArgsConstructor
public class ZoneController {

    private final ZoneService zoneService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ZoneResponse>>> getAllZones() {
        List<ZoneResponse> zones = zoneService.getAllZones();
        return ResponseEntity.ok(ApiResponse.success(zones));
    }

    @GetMapping("/{zoneId}")
    public ResponseEntity<ApiResponse<ZoneResponse>> getZoneById(
            @PathVariable Long zoneId) {
        ZoneResponse zone = zoneService.getZoneById(zoneId);
        return ResponseEntity.ok(ApiResponse.success(zone));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ZoneResponse>> createZone(
            @Valid @RequestBody ZoneRequest request) {
        ZoneResponse zone = zoneService.createZone(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Zone created successfully", zone));
    }

    @PutMapping("/{zoneId}")
    public ResponseEntity<ApiResponse<ZoneResponse>> updateZone(
            @PathVariable Long zoneId,
            @Valid @RequestBody ZoneRequest request) {
        ZoneResponse zone = zoneService.updateZone(zoneId, request);
        return ResponseEntity.ok(ApiResponse.success("Zone updated successfully", zone));
    }

    @DeleteMapping("/{zoneId}")
    public ResponseEntity<ApiResponse<Void>> deleteZone(
            @PathVariable Long zoneId) {
        zoneService.deleteZone(zoneId);
        return ResponseEntity.ok(ApiResponse.success("Zone deleted successfully", null));
    }

    @PostMapping("/config")
    public ResponseEntity<ApiResponse<Void>> publishConfig(
            @Valid @RequestBody ZoneConfigRequest request) {
        zoneService.publishConfig(request);
        return ResponseEntity.ok(ApiResponse.success("Config published successfully", null));
    }
}
