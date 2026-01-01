package com.iot.smartwatering.smart_watering_backend.controller;

import com.iot.smartwatering.smart_watering_backend.dto.request.ZoneRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.ZoneResponse;
import com.iot.smartwatering.smart_watering_backend.service.ZoneService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
}
