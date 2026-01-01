package com.iot.smartwatering.smart_watering_backend.controller;


import com.iot.smartwatering.smart_watering_backend.dto.request.ControlRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.service.ControlService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/control")
@RequiredArgsConstructor
public class ControlController {

    private final ControlService controlService;

    /**
     * Điều khiển tưới thủ công (không kiểm tra thời tiết)
     */
    @PostMapping("/water")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<String>> controlWatering(
            @Valid @RequestBody ControlRequest request) {
        String message = controlService.controlWatering(request);
        return ResponseEntity.ok(ApiResponse.success(message, null));
    }

    /**
     * Bật tưới tự động với kiểm tra thời tiết
     * POST /api/control/water/auto
     * Body: { "zoneId": 1, "durationMinutes": 30, "location": "Ho Chi Minh City" }
     */
    @PostMapping("/water/auto")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<String>> startWateringWithWeatherCheck(
            @RequestParam Long zoneId,
            @RequestParam(required = false) Integer durationMinutes,
            @RequestParam(required = false) String location) {
        String message = controlService.startWateringWithWeatherCheck(zoneId, durationMinutes, location);
        return ResponseEntity.ok(ApiResponse.success(message, null));
    }
}

