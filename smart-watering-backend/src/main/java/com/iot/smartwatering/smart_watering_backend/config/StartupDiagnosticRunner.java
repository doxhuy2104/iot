package com.iot.smartwatering.smart_watering_backend.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class StartupDiagnosticRunner implements CommandLineRunner {

    @Value("${mqtt.broker.url}")
    private String brokerUrl;

    @Value("${mqtt.broker.clientId}")
    private String clientId;

    @Value("${mqtt.broker.username:}")
    private String username;

    @Value("${mqtt.topics.sensor-data}")
    private String sensorTopic;

    @Autowired(required = false)
    private MqttPahoMessageDrivenChannelAdapter inboundAdapter;

    @Override
    public void run(String... args) throws Exception {
        log.info("=== STARTUP DIAGNOSTIC ===");
        log.info("MQTT Broker URL: {}", brokerUrl);
        log.info("MQTT Client ID: {}", clientId);
        log.info("MQTT Username: {}", (username != null && !username.isEmpty()) ? "****" : "NULL/EMPTY");
        log.info("MQTT Sensor Topic: {}", sensorTopic);

        if (inboundAdapter != null) {
            log.info("MqttPahoMessageDrivenChannelAdapter bean found.");
            log.info("Adapter is running: {}", inboundAdapter.isRunning());
            log.info("Adapter component type: {}", inboundAdapter.getComponentType());
            log.info("Adapter output channel: {}", inboundAdapter.getOutputChannel());
        } else {
            log.error("CRITICAL: MqttPahoMessageDrivenChannelAdapter bean NOT found!");
        }

        log.info("=== END DIAGNOSTIC ===");
    }
}
