package com.iot.smartwatering.smart_watering_backend.entity;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id", nullable = false, unique = true)
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
