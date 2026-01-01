package com.iot.smartwatering.smart_watering_backend.entity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Data
@Table(name = "devices")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Device {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "device_id")
    private Long deviceId;
    @Column(name = "device_name", nullable = false)
    private String deviceName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DeviceType type;
    @Column(unique = true)
    private String identifier;
    @Column(name = "mqtt_topic_publish", length = 255)
    private String mqttTopicPublish;
    @Column(name = "mqtt_topic_subscribe", length = 255)
    private String mqttTopicSubscribe;
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private DeviceStatus status = DeviceStatus.OFFLINE;
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id", nullable = false)
    private Zone zone;

    @OneToMany(mappedBy = "device", cascade = CascadeType.ALL)
    @Builder.Default
    private Set<SensorData> sensorData = new HashSet<>();

    @OneToMany(mappedBy = "device", cascade = CascadeType.ALL)
    @Builder.Default
    private Set<FlowData> flowData = new HashSet<>();

    @OneToMany(mappedBy = "device", cascade = CascadeType.ALL)
    @Builder.Default
    private Set<WaterLog> waterLog = new HashSet<>();
    public enum DeviceType {
        SOIL_MOISTURE_SENSOR,
        FLOW_SENSOR,
        PUMP,
        VALVE,
        ESP32_CONTROLLER
    }
    public enum DeviceStatus {
        ONLINE,
        OFFLINE,
        ERROR,
        MAINTENANCE
    }
}
