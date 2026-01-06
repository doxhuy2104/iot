package com.iot.smartwatering.smart_watering_backend.dto.response;

import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WaterLogResponse {
    private Long logId;
    private Long zoneId;
    private String zoneName;
    private Long deviceId;
    private String deviceName;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer durationSeconds;
    private Double waterVolumeLiters;
    private WaterLog.WaterReason reason;
    private WaterLog.WaterStatus status;
    private LocalDateTime createdAt;
}
