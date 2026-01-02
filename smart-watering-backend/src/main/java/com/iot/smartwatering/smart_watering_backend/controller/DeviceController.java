package com.iot.smartwatering.smart_watering_backend.controller;

import com.iot.smartwatering.smart_watering_backend.dto.request.DeviceRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.DeviceResponse;
import com.iot.smartwatering.smart_watering_backend.service.DeviceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
public class DeviceController {
    @Autowired
    private final DeviceService deviceService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<DeviceResponse>>> getAllDevices() {
        List<DeviceResponse> devices = deviceService.getAllDevices();
        return ResponseEntity.ok(ApiResponse.success(devices));
    }

    @GetMapping("/{deviceId}")
    public ResponseEntity<ApiResponse<DeviceResponse>> getDeviceById(
            @PathVariable Integer deviceId) {
        DeviceResponse device = deviceService.getDeviceById(deviceId);
        return ResponseEntity.ok(ApiResponse.success(device));
    }

    @GetMapping("/zone/{zoneId}")
    public ResponseEntity<ApiResponse<List<DeviceResponse>>> getDevicesByZoneId(
            @PathVariable Long zoneId) {
        List<DeviceResponse> devices = deviceService.getDevicesByZoneId(zoneId);
        return ResponseEntity.ok(ApiResponse.success(devices));
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<List<DeviceResponse>>> getDevicesByType(
            @PathVariable String type) {
        List<DeviceResponse> devices = deviceService.getDevicesByType(type);
        return ResponseEntity.ok(ApiResponse.success(devices));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<ApiResponse<List<DeviceResponse>>> getDevicesByStatus(
            @PathVariable String status) {
        List<DeviceResponse> devices = deviceService.getDevicesByStatus(status);
        return ResponseEntity.ok(ApiResponse.success(devices));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<DeviceResponse>> createDevice(
            @Valid @RequestBody DeviceRequest request) {
        DeviceResponse device = deviceService.createDevice(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Device created successfully", device));
    }

    @PutMapping("/{deviceId}")
    public ResponseEntity<ApiResponse<DeviceResponse>> updateDevice(
            @PathVariable Integer deviceId,
            @Valid @RequestBody DeviceRequest request) {
        DeviceResponse device = deviceService.updateDevice(deviceId, request);
        return ResponseEntity.ok(ApiResponse.success("Device updated successfully", device));
    }

    @PatchMapping("/{deviceId}/status")
    public ResponseEntity<ApiResponse<DeviceResponse>> updateDeviceStatus(
            @PathVariable Integer deviceId,
            @RequestBody Map<String, String> statusUpdate) {
        String status = statusUpdate.get("status");
        if (status == null || status.isEmpty()) {
            throw new IllegalArgumentException("Status cannot be empty");
        }
        DeviceResponse device = deviceService.updateDeviceStatus(deviceId, status);
        return ResponseEntity.ok(ApiResponse.success("Device status updated successfully", device));
    }

    @DeleteMapping("/{deviceId}")
    public ResponseEntity<ApiResponse<Void>> deleteDevice(
            @PathVariable Integer deviceId) {
        deviceService.deleteDevice(deviceId);
        return ResponseEntity.ok(ApiResponse.success("Device deleted successfully", null));
    }
}
