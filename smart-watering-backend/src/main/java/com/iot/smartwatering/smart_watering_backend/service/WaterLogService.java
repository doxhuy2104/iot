package com.iot.smartwatering.smart_watering_backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.iot.smartwatering.smart_watering_backend.dto.request.CreateWaterLogRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.WaterLogResponse;
import com.iot.smartwatering.smart_watering_backend.entity.Device;
import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.repository.DeviceRepository;
import com.iot.smartwatering.smart_watering_backend.repository.WaterLogRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class WaterLogService {

    private final WaterLogRepository waterLogRepository;
    private final ZoneRepository zoneRepository;
    private final DeviceRepository deviceRepository;

    @Transactional
    public WaterLogResponse createWaterLog(CreateWaterLogRequest request) {
        Zone zone = zoneRepository.findById(request.getZoneId())
                .orElseThrow(() -> new RuntimeException("Zone not found"));

        Device device = null;
        if (request.getDeviceId() != null) {
            device = deviceRepository.findById(request.getDeviceId())
                    .orElseThrow(() -> new RuntimeException("Device not found"));
        }

        WaterLog.WaterReason reason = WaterLog.WaterReason.MANUAL;
        if (request.getReason() != null) {
            try {
                reason = WaterLog.WaterReason.valueOf(request.getReason().toUpperCase());
            } catch (IllegalArgumentException e) {
                // Default to MANUAL if invalid
                log.warn("Invalid water reason: {}. Defaulting to MANUAL.", request.getReason());
            }
        }

        WaterLog waterLog = WaterLog.builder()
                .zone(zone)
                .device(device)
                .reason(reason)
                .status(WaterLog.WaterStatus.PENDING)
                .createdAt(LocalDateTime.now())
                .startedAt(request.getStartedAt() != null ? request.getStartedAt() : LocalDateTime.now())
                .endedAt(request.getEndedAt())
                .durationSeconds(request.getDurationSeconds())
                .volume(request.getVolume())
                .build();

        waterLogRepository.save(waterLog);
        log.info("Created water log for zone: {}", zone.getZoneId());

        // Update zone total volume
        if (waterLog.getVolume() != null && waterLog.getVolume() > 0) {
            Double currentTotal = zone.getTotalVolume() == null ? 0.0 : zone.getTotalVolume();
            zone.setTotalVolume(currentTotal + waterLog.getVolume());
            zoneRepository.save(zone);
        }

        return mapToResponse(waterLog);
    }

    @Transactional(readOnly = true)
    public List<WaterLogResponse> getLogsByZoneId(Long zoneId) {
        List<WaterLog> logs = waterLogRepository.findByZone_ZoneIdOrderByCreatedAtDesc(zoneId);
        return logs.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<WaterLogResponse> getLogsByZoneIdAndDateRange(Long zoneId, LocalDateTime start, LocalDateTime end) {
        List<WaterLog> logs = waterLogRepository.findByZone_ZoneIdAndCreatedAtBetween(zoneId, start, end);
        return logs.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    private WaterLogResponse mapToResponse(WaterLog log) {
        return WaterLogResponse.builder()
                .logId(log.getLogId())
                .zoneId(log.getZone() != null ? log.getZone().getZoneId() : null)
                .zoneName(log.getZone() != null ? log.getZone().getZoneName() : null)
                .deviceId(log.getDevice() != null ? log.getDevice().getDeviceId() : null)
                .deviceName(log.getDevice() != null ? log.getDevice().getDeviceName() : null)
                .startedAt(log.getStartedAt())
                .endedAt(log.getEndedAt())
                .durationSeconds(log.getDurationSeconds())
                .volume(log.getVolume())
                .reason(log.getReason() != null ? log.getReason().name() : null)
                .status(log.getStatus() != null ? log.getStatus().name() : null)
                .createdAt(log.getCreatedAt())
                .build();
    }
}
