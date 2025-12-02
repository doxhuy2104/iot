package com.iot.smartwatering.smart_watering_backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "alerts")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Alert {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "alert_id")
    private Long alertId;
    @Enumerated(EnumType.STRING)
    private AlertSeverity severity;
    @Column(columnDefinition = "TEXT")
    private String message;
    @Column(name = "is_handled")
    private Boolean isHandled = false;
    @Column(name = "handled_at")
    private LocalDateTime handledAt;
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @Column(name = "mqtt_payload", columnDefinition = "TEXT")
    private String mqttPayload;
    @Column(name = "mqtt_received_at")
    private LocalDateTime mqttReceivedAt;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id")
    private Zone zone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id")
    private Device device;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "handled_by")
    private User handledBy;
    @OneToOne(mappedBy = "alert", cascade = CascadeType.ALL)
    private Notification notification;
    public enum AlertSeverity {
        INFO, WARNING, ERROR, CRITICAL
    }
}
