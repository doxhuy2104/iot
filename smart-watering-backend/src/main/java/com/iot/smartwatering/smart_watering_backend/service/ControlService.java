package com.iot.smartwatering.smart_watering_backend.service;

import com.iot.smartwatering.smart_watering_backend.dto.request.ControlRequest;
import com.iot.smartwatering.smart_watering_backend.entity.UserAction;
import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.repository.UserActionRepository;
import com.iot.smartwatering.smart_watering_backend.repository.UserRepository;
import com.iot.smartwatering.smart_watering_backend.repository.WaterLogRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@Slf4j
@RequiredArgsConstructor
public class ControlService {

    private final ZoneRepository zoneRepository;
    private final MqttService mqttService;
    private final WaterLogRepository waterLogRepository;
    private final UserRepository userRepository;
    private final UserActionRepository userActionRepository;
    private final WeatherService weatherService;

    @Value("${weather.check.enabled:true}")
    private Boolean weatherCheckEnabled;

    @Transactional
    public String controlWatering(ControlRequest request) {
        Zone zone = zoneRepository.findById(request.getZoneId())
                .orElseThrow(() -> new RuntimeException("Zone not found"));

        String action = request.getAction().toUpperCase();

        if ("ON".equals(action)) {
            return startWatering(zone, request.getDurationMinutes(), false);
        } else if ("OFF".equals(action)) {
            return stopWatering(zone);
        } else {
            throw new RuntimeException("Invalid action: " + action);
        }
    }

    /**
     * Bật tưới với kiểm tra thời tiết (auto mode)
     */
    @Transactional
    public String startWateringWithWeatherCheck(Long zoneId, Integer durationMinutes, String location) {
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Zone not found"));

        return startWatering(zone, durationMinutes, true, location);
    }

    private String startWatering(Zone zone, Integer durationMinutes, boolean checkWeather) {
        return startWatering(zone, durationMinutes, checkWeather, null);
    }

    private String startWatering(Zone zone, Integer durationMinutes, boolean checkWeather, String location) {
        if (zone.getPumpStatus()) {
            return "Bơm đang chạy";
        }

        // Kiểm tra thời tiết nếu được bật
        if (checkWeather && weatherCheckEnabled) {
            boolean shouldStop = weatherService.shouldStopWatering(location);
            if (shouldStop) {
                String message = "⚠️ Tạm dừng tưới: Có khả năng mưa cao trong vài giờ tới. " +
                               "Hệ thống đã tự động hủy lệnh tưới để tiết kiệm nước.";
                
                // Log action
                logUserAction(zone, UserAction.ActionType.SYSTEM_WATER_CANCEL, 
                            "Hủy tưới tự động do dự báo mưa");
                
                log.warn("Watering cancelled for zone {} due to rain forecast", zone.getZoneId());
                return message;
            }
        }

        // Update zone status
        zone.setPumpStatus(true);
        zoneRepository.save(zone);

        // Send MQTT command
        mqttService.publishControlCommand(zone.getZoneId(), "PUMP_ON");

        // Create water log
        WaterLog waterLog = WaterLog.builder()
                .zone(zone)
                .startedAt(LocalDateTime.now())
                .reason(checkWeather ? WaterLog.WaterReason.AUTO_MOISTURE : WaterLog.WaterReason.MANUAL)
                .status(WaterLog.WaterStatus.PENDING)
                .build();
        waterLogRepository.save(waterLog);

        // Log user action
        String actionDetail = (checkWeather ? "Bật tưới tự động" : "Bật tưới thủ công") + 
                            (durationMinutes != null ? " - Thời gian: " + durationMinutes + " phút" : "");
        logUserAction(zone, checkWeather ? 
                     UserAction.ActionType.AUTO_WATER_ON : UserAction.ActionType.MANUAL_WATER_ON,
                     actionDetail);

        log.info("Started watering for zone: {}", zone.getZoneId());
        return "Đã bật tưới";
    }

    private String stopWatering(Zone zone) {
        if (!zone.getPumpStatus()) {
            return "Bơm đã tắt";
        }

        // Update zone status
        zone.setPumpStatus(false);
        zoneRepository.save(zone);

        // Send MQTT command
        mqttService.publishControlCommand(zone.getZoneId(), "PUMP_OFF");

        // Update water log
        waterLogRepository.findPendingLogs().stream()
                .filter(log -> log.getZone().getZoneId().equals(zone.getZoneId()))
                .findFirst()
                .ifPresent(log -> {
                    log.setEndedAt(LocalDateTime.now());
                    log.setStatus(WaterLog.WaterStatus.COMPLETED);
                    waterLogRepository.save(log);
                });

        // Log user action
        logUserAction(zone, UserAction.ActionType.MANUAL_WATER_OFF, "Tắt tưới thủ công");

        log.info("Stopped watering for zone: {}", zone.getZoneId());
        return "Đã tắt tưới";
    }

    private void logUserAction(Zone zone, UserAction.ActionType actionType, String details) {
        String username = SecurityContextHolder.getContext()
                .getAuthentication().getName();

        userRepository.findByUsername(username).ifPresent(user -> {
            UserAction action = UserAction.builder()
                    .user(user)
                    .zone(zone)
                    .actionType(actionType)
                    .details(details)
                    .build();
            userActionRepository.save(action);
        });
    }
}