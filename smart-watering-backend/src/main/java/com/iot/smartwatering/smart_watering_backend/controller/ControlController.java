package com.iot.smartwatering.smart_watering_backend.controller;


import com.iot.smartwatering.smart_watering_backend.dto.request.ControlRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.service.ControlService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/control")
@RequiredArgsConstructor
public class ControlController {

    private final ControlService controlService;

    @PostMapping("/water")
    public ResponseEntity<ApiResponse<String>> controlWatering(
            @Valid @RequestBody ControlRequest request) {
        String message = controlService.controlWatering(request);
        return ResponseEntity.ok(ApiResponse.success(message, null));
    }
}

