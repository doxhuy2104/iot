package com.iot.smartwatering.smart_watering_backend.config;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Configuration
public class MqttConfig {

    @Value("${mqtt.broker.url}")
    private String brokerUrl;

    @Value("${mqtt.broker.clientId}")
    private String clientId;

    private String getUniqueClientId() {
        return clientId + "-" + java.util.UUID.randomUUID().toString().substring(0, 8);
    }

    @Value("${mqtt.broker.username:}")
    private String username;

    @Value("${mqtt.broker.password:}")
    private String password;

    @Value("${mqtt.topics.sensor-data}")
    private String sensorTopic;

    @Value("${mqtt.topics.status}")
    private String statusTopic;

    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();

        // Sanitize Broker URL: HiveMQ Cloud (and others) require ssl:// for port 8883
        String formattedBrokerUrl = brokerUrl;
        if (brokerUrl != null && brokerUrl.startsWith("tcp://") && brokerUrl.contains(":8883")) {
            formattedBrokerUrl = brokerUrl.replace("tcp://", "ssl://");
            System.out
                    .println("WARNING: Correcting MQTT Broker URL from tcp:// to ssl:// for secure port 8883. New URL: "
                            + formattedBrokerUrl);
        }

        options.setServerURIs(new String[] { formattedBrokerUrl });
        options.setCleanSession(true);
        options.setAutomaticReconnect(true);
        options.setConnectionTimeout(10);
        options.setKeepAliveInterval(60);

        if (username != null && !username.isEmpty()) {
            options.setUserName(username);
            options.setPassword(password.toCharArray());
        }

        factory.setConnectionOptions(options);
        return factory;
    }

    // Channel for incoming messages
    @Bean
    public MessageChannel mqttInputChannel() {
        return new DirectChannel();
    }

    // Channel for outgoing messages
    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    // Inbound adapter for receiving messages
    @Bean
    public MessageProducer inbound() {
        String[] topics = { sensorTopic, statusTopic, "irrigation/log/zone/#", "irrigation/check-weather/zone/#",
                "irrigation/status/zone/#" };

        // Append unique suffix to avoid conflicts if running multiple instances or
        // quick restarts
        String uniqueClientId = getUniqueClientId() + "-inbound";

        MqttPahoMessageDrivenChannelAdapter adapter = new MqttPahoMessageDrivenChannelAdapter(
                uniqueClientId, mqttClientFactory(), topics);

        adapter.setCompletionTimeout(5000);
        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(1);
        adapter.setOutputChannel(mqttInputChannel());

        return adapter;
    }

    // Outbound adapter for sending messages
    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound() {
        // Append unique suffix
        String uniqueClientId = getUniqueClientId() + "-outbound";

        MqttPahoMessageHandler messageHandler = new MqttPahoMessageHandler(uniqueClientId, mqttClientFactory());

        messageHandler.setAsync(true);
        messageHandler.setDefaultTopic("irrigation/control");
        messageHandler.setDefaultQos(1);

        return messageHandler;
    }
}