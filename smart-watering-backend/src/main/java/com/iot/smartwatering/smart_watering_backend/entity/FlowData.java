package com.iot.smartwatering.smart_watering_backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "flow_datas")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FlowData {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "flow_id")
    private Long flowId;
    @Column(name = "pulse_count")
    private Long pulseCount;

    @Column(name = "flow_rate_per_minute")
    private Double flowRatePerMinute;
    @Column(name = "cumulative_liters")
    private Double cumulativeLiters;
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id")
    private Zone zone;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id")
    private Device device;
}
