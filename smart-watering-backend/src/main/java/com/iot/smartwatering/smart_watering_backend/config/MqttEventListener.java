package com.iot.smartwatering.smart_watering_backend.config;

import org.springframework.context.event.EventListener;
import org.springframework.integration.mqtt.event.MqttConnectionFailedEvent;
import org.springframework.integration.mqtt.event.MqttIntegrationEvent;
import org.springframework.integration.mqtt.event.MqttSubscribedEvent;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class MqttEventListener {

    @EventListener
    public void handleMqttEvent(MqttIntegrationEvent event) {
        log.info("MQTT General Event: {}", event.toString());

        if (event instanceof MqttConnectionFailedEvent) {
            log.error("CRITICAL: MQTT Connection FAILED! Cause: {}",
                    ((MqttConnectionFailedEvent) event).getCause().getMessage());
            ((MqttConnectionFailedEvent) event).getCause().printStackTrace();
        } else if (event instanceof MqttSubscribedEvent) {
            log.info("SUCCESS: MQTT Subscribed to topic: {}", ((MqttSubscribedEvent) event).getMessage());
        }
    }
}
