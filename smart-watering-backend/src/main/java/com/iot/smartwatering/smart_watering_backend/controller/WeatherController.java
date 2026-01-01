package com.iot.smartwatering.smart_watering_backend.controller;

import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.WeatherResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.WeatherSummaryResponse;
import com.iot.smartwatering.smart_watering_backend.service.WeatherService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/weather")
@RequiredArgsConstructor
public class WeatherController {

    private final WeatherService weatherService;

    /**
     * Lấy thông tin thời tiết hiện tại
     * GET /api/weather/current?location=Ho Chi Minh City
     */
    @GetMapping("/current")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<WeatherResponse>> getCurrentWeather(
            @RequestParam(required = false) String location) {
        WeatherResponse weather = weatherService.getCurrentWeather(location);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin thời tiết thành công", weather));
    }

    /**
     * Lấy dự báo thời tiết
     * GET /api/weather/forecast?location=Ho Chi Minh City&days=3
     */
    @GetMapping("/forecast")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<WeatherResponse>> getForecast(
            @RequestParam(required = false) String location,
            @RequestParam(defaultValue = "3") Integer days) {
        WeatherResponse forecast = weatherService.getForecast(location, days);
        return ResponseEntity.ok(ApiResponse.success("Lấy dự báo thời tiết thành công", forecast));
    }

    /**
     * Kiểm tra dự báo mưa và khuyến nghị tưới
     * GET /api/weather/check-rain?location=Ho Chi Minh City
     */
    @GetMapping("/check-rain")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<WeatherSummaryResponse>> checkRainForecast(
            @RequestParam(required = false) String location) {
        WeatherSummaryResponse summary = weatherService.checkRainForecast(location);
        return ResponseEntity.ok(ApiResponse.success("Kiểm tra dự báo mưa thành công", summary));
    }

    /**
     * Kiểm tra xem có nên dừng tưới không
     * GET /api/weather/should-stop-watering?location=Ho Chi Minh City
     */
    @GetMapping("/should-stop-watering")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Boolean>> shouldStopWatering(
            @RequestParam(required = false) String location) {
        boolean shouldStop = weatherService.shouldStopWatering(location);
        String message = shouldStop ? 
            "Nên tạm dừng tưới do có khả năng mưa cao" : 
            "Có thể tiếp tục tưới bình thường";
        return ResponseEntity.ok(ApiResponse.success(message, shouldStop));
    }

    /**
     * TEST ONLY - Public endpoint để test weather API không cần authentication
     * GET /api/weather/test?location=Ho Chi Minh City
     * XÓA ENDPOINT NÀY TRƯỚC KHI DEPLOY PRODUCTION!
     */
    @GetMapping("/test")
    public ResponseEntity<ApiResponse<WeatherResponse>> testWeatherAPI(
            @RequestParam(required = false) String location,
            @RequestParam(defaultValue = "3") Integer days) {
        WeatherResponse forecast = weatherService.getForecast(location, days);
        return ResponseEntity.ok(ApiResponse.success("TEST - Lấy dự báo thời tiết thành công", forecast));
    }
}
