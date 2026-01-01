package com.iot.smartwatering.smart_watering_backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.iot.smartwatering.smart_watering_backend.entity.*;
import com.iot.smartwatering.smart_watering_backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;

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
            Float moisture = data.containsKey("moisture") && data.get("moisture") != null ?
                    ((Number) data.get("moisture")).floatValue() : null;
            Float temperature = data.containsKey("temperature") && data.get("temperature") != null ?
                    ((Number) data.get("temperature")).floatValue() : null;
            Float humidity = data.containsKey("humidity") && data.get("humidity") != null ?
                    ((Number) data.get("humidity")).floatValue() : null;

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
        if (zone.getThresholdValue() != null &&
                sensorData.getSoilMoisture() < zone.getThresholdValue()) {

            Alert alert = Alert.builder()
                    .zone(zone)
                    .severity(Alert.AlertSeverity.WARNING)
                    .message(String.format(
                            "Độ ẩm đất thấp (%,.1f%%) dưới ngưỡng (%,.1f%%)",
                            sensorData.getSoilMoisture(),
                            zone.getThresholdValue()))
                    .build();

            alertRepository.save(alert);
        }
    }
}

