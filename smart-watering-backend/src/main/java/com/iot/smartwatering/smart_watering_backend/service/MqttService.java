package com.iot.smartwatering.smart_watering_backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.messaging.MessageChannel;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class MqttService {

    private final MessageChannel mqttOutboundChannel;
    private final ObjectMapper objectMapper;

    public void publishControlCommand(Long zoneId, String action) {
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("zoneId", zoneId);
            payload.put("action", action);
            payload.put("timestamp", System.currentTimeMillis());

            String jsonPayload = objectMapper.writeValueAsString(payload);
            String topic = "irrigation/control/zone/" + zoneId;

            mqttOutboundChannel.send(
                    MessageBuilder.withPayload(jsonPayload)
                            .setHeader("mqtt_topic", topic)
                            .build()
            );

            log.info("Published control command to topic: {} - {}", topic, jsonPayload);

        } catch (JsonProcessingException e) {
            log.error("Error creating JSON payload", e);
        }
    }

    public void publishConfigUpdate(Long zoneId, Map<String, Object> config) {
        try {
            Map<String, Object> payload = new HashMap<>(config);
            payload.put("zoneId", zoneId);
            payload.put("timestamp", System.currentTimeMillis());

            String jsonPayload = objectMapper.writeValueAsString(payload);
            String topic = "irrigation/config/zone/" + zoneId;

            mqttOutboundChannel.send(
                    MessageBuilder.withPayload(jsonPayload)
                            .setHeader("mqtt_topic", topic)
                            .build()
            );

            log.info("Published config update to topic: {}", topic);

        } catch (JsonProcessingException e) {
            log.error("Error creating JSON payload", e);
        }
    }
}