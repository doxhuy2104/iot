package com.iot.smartwatering.smart_watering_backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_actions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserAction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "action_id")
    private Long actionId;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type")
    private ActionType actionType;

    @Column(columnDefinition = "TEXT")
    private String details;
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "zone_id")
    private Zone zone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id")
    private Device device;

    public enum ActionType {
        MANUAL_WATER_ON, MANUAL_WATER_OFF,
        AUTO_WATER_ON, AUTO_WATER_OFF,
        SYSTEM_WATER_CANCEL,
        SCHEDULE_CREATE, SCHEDULE_UPDATE, SCHEDULE_DELETE,
        ZONE_CREATE, ZONE_UPDATE, ZONE_DELETE,
        CONFIG_UPDATE, DEVICE_ADD, DEVICE_REMOVE,
        WEATHER_CHECK
    }
}
