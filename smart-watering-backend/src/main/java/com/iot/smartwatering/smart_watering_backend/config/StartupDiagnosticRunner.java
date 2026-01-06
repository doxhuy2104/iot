package com.iot.smartwatering.smart_watering_backend.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.integration.core.MessageProducer;
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

    @Autowired
    @Qualifier("inbound")
    private MessageProducer inboundAdapter;

    @Override
    public void run(String... args) throws Exception {
        log.info("=== STARTUP DIAGNOSTIC ===");
        log.info("MQTT Broker URL (Raw Config): {}", brokerUrl);
        log.info("MQTT Client ID: {}", clientId);
        log.info("MQTT Username: {}", (username != null && !username.isEmpty()) ? "****" : "NULL/EMPTY");
        log.info("MQTT Sensor Topic: {}", sensorTopic);

        if (inboundAdapter != null) {
            log.info("MessageProducer bean 'inbound' found.");
            if (inboundAdapter instanceof org.springframework.integration.support.context.NamedComponent) {
                log.info("Adapter component type: {}",
                        ((org.springframework.integration.support.context.NamedComponent) inboundAdapter)
                                .getComponentType());
            }
            if (inboundAdapter instanceof org.springframework.integration.core.MessageProducer) {
                // MessageProducer interface typically only has setOutputChannel.
                // Assuming the user wants to check properties, we should cast if possible or
                // rely on runtime types if this code worked before (but it didn't for
                // isRunning).
                // To be safe and fix the reported error, I will move isRunning into the check.
            }

            // Re-organizing to handle casting safely
            if (inboundAdapter instanceof MqttPahoMessageDrivenChannelAdapter) {
                MqttPahoMessageDrivenChannelAdapter adapter = (MqttPahoMessageDrivenChannelAdapter) inboundAdapter;
                log.info("Adapter is running: {}", adapter.isRunning());
                log.info("Adapter component type: {}", adapter.getComponentType());
                log.info("Adapter output channel: {}", adapter.getOutputChannel());
                log.info("Confirmed type is MqttPahoMessageDrivenChannelAdapter");
            } else {
                log.warn("inboundAdapter is not MqttPahoMessageDrivenChannelAdapter, skipping detailed logs.");
                if (inboundAdapter instanceof org.springframework.context.Lifecycle) {
                    log.info("Adapter is running: {}",
                            ((org.springframework.context.Lifecycle) inboundAdapter).isRunning());
                }
            }
        } else {
            log.error("CRITICAL: MessageProducer bean 'inbound' NOT found!");
        }

        log.info("=== END DIAGNOSTIC ===");
    }
}
