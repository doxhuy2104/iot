package com.iot.smartwatering.smart_watering_backend.service;

import java.time.LocalDateTime;
import java.util.Map;

import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.iot.smartwatering.smart_watering_backend.entity.Alert;
import com.iot.smartwatering.smart_watering_backend.entity.Device;
import com.iot.smartwatering.smart_watering_backend.entity.FlowData;
import com.iot.smartwatering.smart_watering_backend.entity.SensorData;
import com.iot.smartwatering.smart_watering_backend.entity.User;
import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.repository.AlertRepository;
import com.iot.smartwatering.smart_watering_backend.repository.DeviceRepository;
import com.iot.smartwatering.smart_watering_backend.repository.FlowDataRepository;
import com.iot.smartwatering.smart_watering_backend.repository.SensorDataRepository;
import com.iot.smartwatering.smart_watering_backend.repository.WaterLogRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class MqttMessageHandler {

    private final ObjectMapper objectMapper;
    private final SensorDataRepository sensorDataRepository;
    private final FlowDataRepository flowDataRepository;
    private final DeviceRepository deviceRepository;
    private final ZoneRepository zoneRepository;
    private final AlertRepository alertRepository;
    private final WaterLogRepository waterLogRepository;
    private final NotificationService notificationService;

    @ServiceActivator(inputChannel = "mqttInputChannel")
    @Transactional
    public void handleMessage(Message<?> message) {
        try {
            String topic = (String) message.getHeaders().get("mqtt_receivedTopic");
            String payload = message.getPayload().toString();

            log.info("Received MQTT message - Topic: {}, Payload: {}", topic, payload);

            if (topic.contains("sensor")) {
                handleSensorData(topic, payload);
            } else if (topic.contains("flow")) {
                handleFlowData(topic, payload);
            } else if (topic.contains("status")) {
                handleDeviceStatus(topic, payload);
            } else if (topic.contains("alert")) {
                handleAlert(topic, payload);
            } else if (topic.contains("log")) {
                handleWaterLog(topic, payload);
            }

        } catch (Exception e) {
            log.error("Error processing MQTT message", e);
        }
    }

    private void handleSensorData(String topic, String payload) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);

            // Validate required fields
            if (!data.containsKey("zoneId") || !data.containsKey("deviceId")) {
                log.warn("Missing required fields in sensor data. Payload: {}", payload);
                return;
            }

            String deviceId = (String) data.get("deviceId");
            Long zoneId = ((Number) data.get("zoneId")).longValue();

            Device device = deviceRepository.findByIdentifier(deviceId)
                    .orElseThrow(() -> new RuntimeException("Device not found: " + deviceId));

            Zone zone = zoneRepository.findById(zoneId)
                    .orElseThrow(() -> new RuntimeException("Zone not found: " + zoneId));

            // Safely extract sensor values
            Float moisture = data.containsKey("moisture") && data.get("moisture") != null
                    ? ((Number) data.get("moisture")).floatValue()
                    : null;
            Float temperature = data.containsKey("temperature") && data.get("temperature") != null
                    ? ((Number) data.get("temperature")).floatValue()
                    : null;
            Float humidity = data.containsKey("humidity") && data.get("humidity") != null
                    ? ((Number) data.get("humidity")).floatValue()
                    : null;

            SensorData sensorData = SensorData.builder()
                    .zone(zone)
                    .device(device)
                    .soilMoisture(moisture)
                    .temperature(temperature)
                    .humidity(humidity)
                    .build();

            sensorDataRepository.save(sensorData);
            log.info("Saved sensor data for zone: {}", zoneId);

            // Check threshold and create alert if needed
            checkThresholdAndAlert(zone, sensorData);

        } catch (Exception e) {
            log.error("Error handling sensor data", e);
        }
    }

    private void handleFlowData(String topic, String payload) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);

            String deviceId = (String) data.get("deviceId");
            Long zoneId = ((Number) data.get("zoneId")).longValue();

            Device device = deviceRepository.findByIdentifier(deviceId)
                    .orElseThrow(() -> new RuntimeException("Device not found"));

            Zone zone = zoneRepository.findById(zoneId)
                    .orElseThrow(() -> new RuntimeException("Zone not found"));

            FlowData flowData = FlowData.builder()
                    .zone(zone)
                    .device(device)
                    .pulseCount(((Number) data.get("pulseCount")).longValue())
                    .flowRatePerMinute(((Number) data.get("flowRate")).floatValue())
                    .cumulativeLiters(((Number) data.get("totalLiters")).floatValue())
                    .build();

            flowDataRepository.save(flowData);
            log.info("Saved flow data for zone: {}", zoneId);

        } catch (Exception e) {
            log.error("Error handling flow data", e);
        }
    }

    private void handleDeviceStatus(String topic, String payload) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);

            String deviceId = (String) data.get("deviceId");
            String status = (String) data.get("status");

            Device device = deviceRepository.findByIdentifier(deviceId)
                    .orElseThrow(() -> new RuntimeException("Device not found"));

            device.setStatus(Device.DeviceStatus.valueOf(status.toUpperCase()));
            deviceRepository.save(device);

            log.info("Updated device status: {} -> {}", deviceId, status);

        } catch (Exception e) {
            log.error("Error handling device status", e);
        }
    }

    private void handleAlert(String topic, String payload) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);

            Long zoneId = ((Number) data.get("zoneId")).longValue();
            String message = (String) data.get("message");
            String severity = (String) data.get("severity");

            Zone zone = zoneRepository.findById(zoneId)
                    .orElseThrow(() -> new RuntimeException("Zone not found"));

            Alert alert = Alert.builder()
                    .zone(zone)
                    .severity(Alert.AlertSeverity.valueOf(severity.toUpperCase()))
                    .message(message)
                    .mqttPayload(payload)
                    .mqttReceivedAt(LocalDateTime.now())
                    .build();

            alertRepository.save(alert);
            log.info("Created alert for zone: {}", zoneId);

        } catch (Exception e) {
            log.error("Error handling alert", e);
        }
    }

    private void checkThresholdAndAlert(Zone zone, SensorData sensorData) {
        if (zone.getThresholdMin() != null &&
                sensorData.getSoilMoisture() < zone.getThresholdMin()) {

            Alert alert = Alert.builder()
                    .zone(zone)
                    .device(sensorData.getDevice())
                    .severity(Alert.AlertSeverity.WARNING)
                    .message(String.format(
                            "Độ ẩm đất thấp (%,.1f%%) dưới ngưỡng minimum (%,.1f%%)",
                            sensorData.getSoilMoisture(),
                            zone.getThresholdMin()))
                    .createdAt(LocalDateTime.now())
                    .build();

            alertRepository.save(alert);
            log.info("Created alert for low moisture in zone: {}", zone.getZoneId());

            // Gửi notification và email cho user sở hữu zone
            try {
                User zoneOwner = zone.getUser();
                if (zoneOwner != null) {
                    // Tạo notification trong app
                    notificationService.createNotificationFromAlert(alert, zoneOwner);
                    log.info("Notification created for user: {}", zoneOwner.getUsername());
                }
            } catch (Exception e) {
                log.error("Error sending alert notifications for zone: {}", zone.getZoneId(), e);
            }
        }
    }

    private void handleWaterLog(String topic, String payload) {
        try {
            // Topic format: irrigation/log/zone/{zoneId}
            Long zoneId = Long.parseLong(topic.substring(topic.lastIndexOf('/') + 1));

            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);

            Zone zone = zoneRepository.findById(zoneId)
                    .orElseThrow(() -> new RuntimeException("Zone not found: " + zoneId));

            LocalDateTime startedAt = LocalDateTime.now();
            if (data.containsKey("startedAt") && data.get("startedAt") != null) {
                String startedAtStr = (String) data.get("startedAt");
                if (!startedAtStr.isEmpty()) {
                    try {
                        // Attempt to parse ISO_LOCAL_DATE_TIME
                        startedAt = LocalDateTime.parse(startedAtStr);
                    } catch (Exception e) {
                        log.warn("Failed to parse startedAt: {}. Using current time.", startedAtStr);
                    }
                }
            }

            Integer durationSeconds = data.containsKey("durationSeconds")
                    ? ((Number) data.get("durationSeconds")).intValue()
                    : 0;

            Double volume = data.containsKey("volume")
                    ? ((Number) data.get("volume")).doubleValue()
                    : 0.0;

            LocalDateTime endedAt = startedAt.plusSeconds(durationSeconds);

            WaterLog waterLog = WaterLog.builder()
                    .zone(zone)
                    // Device is unknown from this payload, leaving null
                    .startedAt(startedAt)
                    .endedAt(endedAt)
                    .durationSeconds(durationSeconds)
                    .volume(volume)
                    .reason(WaterLog.WaterReason.MANUAL) // Defaulting to MANUAL
                    .status(WaterLog.WaterStatus.COMPLETED)
                    .createdAt(LocalDateTime.now())
                    .build();

            waterLogRepository.save(waterLog);
            log.info("Saved water log for zone: {}", zoneId);

        } catch (Exception e) {
            log.error("Error handling water log", e);
        }
    }
}
