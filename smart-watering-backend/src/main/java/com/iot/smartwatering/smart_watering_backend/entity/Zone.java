package com.iot.smartwatering.smart_watering_backend.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@Table(name = "zones")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Zone {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "zone_id")
    private Long zoneId;
    @Column(nullable = false, name = "zone_name")
    private String zoneName;
    @Column(columnDefinition = "TEXT")
    private String description;
    @Column(nullable = false)
    private BigDecimal location;
    @Column(nullable = false)
    private BigDecimal latitude;
    @Column(nullable = false)
    private String longitude;
    @Column(name = "threshold_value")
    private Double thresholdValue;
    @Column(name = "auto_mode")
    @Builder.Default
    private Boolean autoMode = false;
    @Column(name = "weather_mode")
    @Builder.Default
    private Boolean weatherMode = false;
    @Column(name = "pump_status")
    @Builder.Default
    private Boolean pumpStatus = false;
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToOne(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    private Device device;

    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<SensorData> sensorData = new HashSet<>();

    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<FlowData> flowData = new HashSet<>();

    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<WaterLog> waterLogs = new HashSet<>();

    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Schedule> schedules = new HashSet<>();

    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL)
    @Builder.Default
    private Set<Alert> alerts = new HashSet<>();
}
