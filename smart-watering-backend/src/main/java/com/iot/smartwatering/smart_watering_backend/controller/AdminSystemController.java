package com.iot.smartwatering.smart_watering_backend.controller;

import com.iot.smartwatering.smart_watering_backend.dto.response.*;
import com.iot.smartwatering.smart_watering_backend.entity.Alert;
import com.iot.smartwatering.smart_watering_backend.entity.Device;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.enums.UserRole;
import com.iot.smartwatering.smart_watering_backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Slf4j
public class AdminSystemController {

    private final UserRepository userRepository;
    private final ZoneRepository zoneRepository;
    private final DeviceRepository deviceRepository;
    private final AlertRepository alertRepository;
    private final SensorDataRepository sensorDataRepository;
    private final FlowDataRepository flowDataRepository;

    /**
     * Thống kê tổng quan hệ thống
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<SystemStatisticsResponse>> getSystemStatistics() {
        SystemStatisticsResponse stats = SystemStatisticsResponse.builder()
                // User statistics
                .totalUsers(userRepository.count())
                .activeUsers(userRepository.countByIsActive(true))
                .inactiveUsers(userRepository.countByIsActive(false))
                .adminUsers(userRepository.countByRole(UserRole.ADMIN))
                .regularUsers(userRepository.countByRole(UserRole.USER))
                
                // Zone statistics
                .totalZones(zoneRepository.count())
                
                // Device statistics
                .totalDevices(deviceRepository.count())
                .onlineDevices((long) deviceRepository.findByStatus(Device.DeviceStatus.ONLINE).size())
                .offlineDevices((long) deviceRepository.findByStatus(Device.DeviceStatus.OFFLINE).size())
                
                // Alert statistics
                .totalAlerts(alertRepository.count())
                .unhandledAlerts((long) alertRepository.findByIsHandledFalseOrderByCreatedAtDesc().size())
                .criticalAlerts((long) alertRepository.findBySeverityOrderByCreatedAtDesc(Alert.AlertSeverity.CRITICAL).size())
                
                // Data statistics
                .totalSensorData(sensorDataRepository.count())
                .totalFlowData(flowDataRepository.count())
                .build();

        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    /**
     * Lấy danh sách tất cả zones trong hệ thống
     */
    @GetMapping("/zones")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllZones() {
        List<Zone> zones = zoneRepository.findAll();
        List<Map<String, Object>> response = zones.stream()
                .map(this::mapZoneToMap)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy thông tin chi tiết zone theo ID
     */
    @GetMapping("/zones/{zoneId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getZoneById(@PathVariable Long zoneId) {
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Zone not found"));
        return ResponseEntity.ok(ApiResponse.success(mapZoneToMap(zone)));
    }

    /**
     * Xóa zone (admin only)
     */
    @DeleteMapping("/zones/{zoneId}")
    public ResponseEntity<ApiResponse<String>> deleteZone(@PathVariable Long zoneId) {
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Zone not found"));
        zoneRepository.delete(zone);
        return ResponseEntity.ok(ApiResponse.success("Zone deleted successfully"));
    }

    /**
     * Lấy danh sách tất cả devices trong hệ thống
     */
    @GetMapping("/devices")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllDevices() {
        List<Device> devices = deviceRepository.findAll();
        List<Map<String, Object>> response = devices.stream()
                .map(this::mapDeviceToMap)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy devices theo trạng thái
     */
    @GetMapping("/devices/status/{status}")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getDevicesByStatus(
            @PathVariable Device.DeviceStatus status) {
        List<Device> devices = deviceRepository.findByStatus(status);
        List<Map<String, Object>> response = devices.stream()
                .map(this::mapDeviceToMap)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Xóa device (admin only)
     */
    @DeleteMapping("/devices/{deviceId}")
    public ResponseEntity<ApiResponse<String>> deleteDevice(@PathVariable Integer deviceId) {
        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found"));
        deviceRepository.delete(device);
        return ResponseEntity.ok(ApiResponse.success("Device deleted successfully"));
    }

    /**
     * Lấy tất cả alerts trong hệ thống
     */
    @GetMapping("/alerts")
    public ResponseEntity<ApiResponse<List<AlertResponse>>> getAllAlerts() {
        List<Alert> alerts = alertRepository.findAll();
        List<AlertResponse> response = alerts.stream()
                .map(this::mapToAlertResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Xóa alert
     */
    @DeleteMapping("/alerts/{alertId}")
    public ResponseEntity<ApiResponse<String>> deleteAlert(@PathVariable Long alertId) {
        Alert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new RuntimeException("Alert not found"));
        alertRepository.delete(alert);
        return ResponseEntity.ok(ApiResponse.success("Alert deleted successfully"));
    }

    /**
     * Xóa tất cả alerts đã xử lý
     */
    @DeleteMapping("/alerts/handled")
    public ResponseEntity<ApiResponse<String>> deleteHandledAlerts() {
        List<Alert> handledAlerts = alertRepository.findAll().stream()
                .filter(Alert::getIsHandled)
                .collect(Collectors.toList());
        alertRepository.deleteAll(handledAlerts);
        return ResponseEntity.ok(ApiResponse.success(
                String.format("Deleted %d handled alerts", handledAlerts.size())));
    }

    /**
     * Thống kê hoạt động hệ thống theo thời gian
     */
    @GetMapping("/activity/daily")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDailyActivity() {
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        LocalDateTime endOfDay = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59);

        Map<String, Object> activity = new HashMap<>();
        activity.put("date", startOfDay.toLocalDate());
        activity.put("newUsers", userRepository.findAll().stream()
                .filter(u -> u.getCreatedAt() != null && 
                        u.getCreatedAt().isAfter(startOfDay) && 
                        u.getCreatedAt().isBefore(endOfDay))
                .count());
        activity.put("newAlerts", alertRepository.findAll().stream()
                .filter(a -> a.getCreatedAt() != null && 
                        a.getCreatedAt().isAfter(startOfDay) && 
                        a.getCreatedAt().isBefore(endOfDay))
                .count());
        activity.put("handledAlerts", alertRepository.findAll().stream()
                .filter(a -> a.getHandledAt() != null && 
                        a.getHandledAt().isAfter(startOfDay) && 
                        a.getHandledAt().isBefore(endOfDay))
                .count());

        return ResponseEntity.ok(ApiResponse.success(activity));
    }

    /**
     * Làm sạch dữ liệu cũ (cleanup)
     */
    @DeleteMapping("/cleanup/sensor-data")
    public ResponseEntity<ApiResponse<String>> cleanupOldSensorData(
            @RequestParam(defaultValue = "30") int daysOld) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(daysOld);
        List<com.iot.smartwatering.smart_watering_backend.entity.SensorData> oldData = 
                sensorDataRepository.findAll().stream()
                        .filter(sd -> sd.getCreatedAt() != null && sd.getCreatedAt().isBefore(cutoffDate))
                        .collect(Collectors.toList());
        
        sensorDataRepository.deleteAll(oldData);
        return ResponseEntity.ok(ApiResponse.success(
                String.format("Deleted %d sensor data records older than %d days", 
                        oldData.size(), daysOld)));
    }

    /**
     * Backup thống kê hệ thống
     */
    @GetMapping("/export/statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> exportStatistics() {
        Map<String, Object> exportData = new HashMap<>();
        exportData.put("exportedAt", LocalDateTime.now());
        
        try {
            ResponseEntity<ApiResponse<SystemStatisticsResponse>> statsResponse = getSystemStatistics();
            if (statsResponse != null && statsResponse.getBody() != null) {
                ApiResponse<SystemStatisticsResponse> body = statsResponse.getBody();
                if (body.getData() != null) {
                    exportData.put("statistics", body.getData());
                }
            }
        } catch (Exception e) {
            log.error("Error getting statistics for export", e);
        }
        
        exportData.put("totalZones", zoneRepository.count());
        exportData.put("totalDevices", deviceRepository.count());
        exportData.put("totalUsers", userRepository.count());
        
        return ResponseEntity.ok(ApiResponse.success(exportData));
    }

    // Helper methods
    private Map<String, Object> mapZoneToMap(Zone zone) {
        Map<String, Object> map = new HashMap<>();
        map.put("zoneId", zone.getZoneId());
        map.put("zoneName", zone.getZoneName());
        map.put("description", zone.getDescription());
        map.put("thresholdValue", zone.getThresholdValue());
        map.put("autoMode", zone.getAutoMode());
        map.put("weatherMode", zone.getWeatherMode());
        map.put("pumpStatus", zone.getPumpStatus());
        map.put("createdAt", zone.getCreatedAt());
        map.put("userId", zone.getUser() != null ? zone.getUser().getUserId() : null);
        map.put("username", zone.getUser() != null ? zone.getUser().getUsername() : null);
        map.put("deviceCount", zone.getDevices() != null ? zone.getDevices().size() : 0);
        return map;
    }

    private Map<String, Object> mapDeviceToMap(Device device) {
        Map<String, Object> map = new HashMap<>();
        map.put("deviceId", device.getDeviceId());
        map.put("deviceName", device.getDeviceName());
        map.put("identifier", device.getIdentifier());
        map.put("type", device.getType());
        map.put("status", device.getStatus());
        map.put("mqttTopicPublish", device.getMqttTopicPublish());
        map.put("mqttTopicSubscribe", device.getMqttTopicSubscribe());
        map.put("createdAt", device.getCreatedAt());
        map.put("zoneId", device.getZone() != null ? device.getZone().getZoneId() : null);
        map.put("zoneName", device.getZone() != null ? device.getZone().getZoneName() : null);
        return map;
    }

    private AlertResponse mapToAlertResponse(Alert alert) {
        return AlertResponse.builder()
                .alertId(alert.getAlertId())
                .zoneId(alert.getZone() != null ? alert.getZone().getZoneId() : null)
                .zoneName(alert.getZone() != null ? alert.getZone().getZoneName() : null)
                .deviceId(alert.getDevice() != null ? alert.getDevice().getDeviceId() : null)
                .deviceName(alert.getDevice() != null ? alert.getDevice().getDeviceName() : null)
                .severity(alert.getSeverity())
                .message(alert.getMessage())
                .isHandled(alert.getIsHandled())
                .handledAt(alert.getHandledAt())
                .handledByUsername(alert.getHandledBy() != null ? alert.getHandledBy().getUsername() : null)
                .createdAt(alert.getCreatedAt())
                .hasNotification(alert.getNotification() != null)
                .build();
    }
}
