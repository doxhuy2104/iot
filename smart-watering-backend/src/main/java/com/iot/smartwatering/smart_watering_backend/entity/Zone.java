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
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

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
    private String location;
    @Column(nullable = false)
    private BigDecimal latitude;
    @Column(nullable = false)
    private BigDecimal longitude;

    @Column(name = "threshold_min")
    private Double thresholdMin;
    @Column(name = "threshold_max")
    private Double thresholdMax;
    @Column(name = "total_volume")
    @Builder.Default
    private Double totalVolume = 0.0;
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
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToOne(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    private Device device;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<SensorData> sensorData = new HashSet<>();

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<FlowData> flowData = new HashSet<>();

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<WaterLog> waterLogs = new HashSet<>();

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Schedule> schedules = new HashSet<>();

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL)
    @Builder.Default
    private Set<Alert> alerts = new HashSet<>();

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "zone", cascade = CascadeType.ALL, orphanRemoval = true) // Changed to orphanRemoval = true to
                                                                                   // delete actions when zone is
                                                                                   // deleted
    @Builder.Default
    private Set<UserAction> userActions = new HashSet<>();
}
