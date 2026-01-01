package com.iot.smartwatering.smart_watering_backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "water_logs")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WaterLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long logId;

    @Column(name = "started_at")
    private LocalDateTime startedAt;
    @Column(name = "ended_at")
    private LocalDateTime endedAt;
    @Column(name = "duration_seconds")
    private Integer durationSeconds;
    @Column(name = "water_volume_liters")
    private Double waterVolumeLiters;
    @Enumerated(EnumType.STRING)
    private WaterReason reason;
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private WaterStatus status = WaterStatus.PENDING;
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id")
    private Zone zone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id")
    private Device device;

    public enum WaterReason {
        MANUAL, AUTO_MOISTURE, SCHEDULED, WEATHER_BASED
    }

    public enum WaterStatus {
        PENDING, COMPLETED, NOT_YET, INTERRUPTED
    }
}
