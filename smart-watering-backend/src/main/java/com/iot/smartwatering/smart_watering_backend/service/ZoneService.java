package com.iot.smartwatering.smart_watering_backend.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.iot.smartwatering.smart_watering_backend.dto.request.ZoneConfigRequest;
import com.iot.smartwatering.smart_watering_backend.dto.request.ZoneRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ZoneResponse;
import com.iot.smartwatering.smart_watering_backend.entity.User;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.repository.SensorDataRepository;
import com.iot.smartwatering.smart_watering_backend.repository.UserRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ZoneService {

    private final ZoneRepository zoneRepository;
    private final UserRepository userRepository;
    private final SensorDataRepository sensorDataRepository;
    private final MqttService mqttService;

    public void publishConfig(ZoneConfigRequest request) {
        String username = SecurityContextHolder.getContext()
                .getAuthentication().getName();

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Zone zone = zoneRepository.findById(request.getZoneId())
                .orElseThrow(() -> new RuntimeException("Zone not found"));

        if (!zone.getUser().getUserId().equals(user.getUserId())) {
            throw new RuntimeException("You don't have permission to access this zone");
        }

        // Apply new values to the zone in DB as well?
        // User request "publish lên mqtt", implies the main goal is MQTT.
        // But usually config implies persisting too.
        // For safety, I will only publish as requested, unless user asked to update.
        // User said: "thêm cho tôi api /zones/config publish lên mqtt..."
        // So I will just publish. If they wanted update, they would used PUT.

        java.util.Map<String, Object> config = new java.util.HashMap<>();
        config.put("thresholdMin", request.getThresholdMin());
        config.put("thresholdMax", request.getThresholdMax());
        config.put("userId", user.getUserId());
        // timestamp is added by MqttService

        mqttService.publishConfigUpdate(zone.getZoneId(), config);
    }

    @Transactional
    public ZoneResponse createZone(ZoneRequest request) {
        String username = SecurityContextHolder.getContext()
                .getAuthentication().getName();

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Zone zone = Zone.builder()
                .zoneName(request.getZoneName())
                .location(request.getLocation())
                .description(request.getDescription())
                .longitude(new BigDecimal(request.getLongitude()))
                .latitude(new BigDecimal(request.getLatitude()))
                .thresholdMin(request.getThresholdMin())
                .thresholdMax(request.getThresholdMax())
                .autoMode(Boolean.TRUE.equals(request.getAutoMode()))
                .weatherMode(Boolean.TRUE.equals(request.getWeatherMode()))
                .pumpStatus(false)
                .user(user)
                .build();

        zone = zoneRepository.save(zone);
        publishZoneConfig(zone);
        return mapToResponse(zone);
    }

    @Transactional(readOnly = true)
    public List<ZoneResponse> getAllZones() {
        String username = SecurityContextHolder.getContext()
                .getAuthentication().getName();

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return zoneRepository.findByUser_UserIdOrderByZoneIdDesc(user.getUserId())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ZoneResponse getZoneById(Long zoneId) {
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Zone not found"));
        return mapToResponse(zone);
    }

    @Transactional
    public ZoneResponse updateZone(Long zoneId, ZoneRequest request) {
        Zone zone = zoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Zone not found"));

        zone.setZoneName(request.getZoneName());
        zone.setLocation(request.getLocation());
        zone.setDescription(request.getDescription());
        zone.setLongitude(new BigDecimal(request.getLongitude()));
        zone.setLatitude(new BigDecimal(request.getLatitude()));
        zone.setThresholdMin(request.getThresholdMin());
        zone.setThresholdMax(request.getThresholdMax());

        if (request.getAutoMode() != null) {
            zone.setAutoMode(request.getAutoMode());
        }
        if (request.getWeatherMode() != null) {
            zone.setWeatherMode(request.getWeatherMode());
        }

        zone = zoneRepository.save(zone);
        publishZoneConfig(zone);
        return mapToResponse(zone);
    }

    @Transactional
    public void deleteZone(Long zoneId) {
        if (!zoneRepository.existsById(zoneId)) {
            throw new RuntimeException("Zone not found");
        }
        zoneRepository.deleteById(zoneId);

        // Publish deleted status to MQTT
        String topic = "irrigation/config/zone/" + zoneId;
        mqttService.publishRetained(topic, "deleted");
    }

    private void publishZoneConfig(Zone zone) {
        java.util.Map<String, Object> config = new java.util.HashMap<>();
        config.put("thresholdMin", zone.getThresholdMin());
        config.put("thresholdMax", zone.getThresholdMax());
        config.put("autoMode", zone.getAutoMode());
        config.put("weatherMode", zone.getWeatherMode());
        if (zone.getUser() != null) {
            config.put("userId", zone.getUser().getUserId());
        }

        mqttService.publishConfigUpdate(zone.getZoneId(), config);
    }

    private ZoneResponse mapToResponse(Zone zone) {
        Float currentMoisture = null;
        var latestData = sensorDataRepository.findLatestByZone(zone.getZoneId());
        if (latestData != null) {
            currentMoisture = latestData.getSoilMoisture();
        }

        return ZoneResponse.builder()
                .zoneId(zone.getZoneId())
                .zoneName(zone.getZoneName())
                .location(zone.getLocation())
                .description(zone.getDescription())
                .longitude(zone.getLongitude())
                .latitude(zone.getLatitude())
                .thresholdMin(zone.getThresholdMin())
                .thresholdMax(zone.getThresholdMax())
                .autoMode(zone.getAutoMode())
                .weatherMode(zone.getWeatherMode())
                .pumpStatus(zone.getPumpStatus())
                .currentMoisture(currentMoisture)
                .totalVolume(zone.getTotalVolume())
                .createdAt(zone.getCreatedAt())
                .updatedAt(zone.getUpdatedAt())
                .deviceIdentifier(zone.getDevice() != null ? zone.getDevice().getIdentifier() : null)
                .build();
    }
}
