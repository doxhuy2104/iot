package com.iot.smartwatering.smart_watering_backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "sensor_datas"
        , indexes = {
        @Index(name = "idx_zone_created", columnList = "zone_id, created_at"),
        @Index(name = "idx_device_created",columnList = "device_id, created_at")
}

)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SensorData {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "data_id")
    private Long dataId;

    @Column(name = "soil_moisture", nullable = false)
    private Double soilMoisture;
    @Column(name = "temparature")
    private Double temparature;
    @Column(name = "humidity")
    private Double humidity;
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id", nullable = false)
    private Zone zone;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id", nullable = false)
    private Device device;
}
