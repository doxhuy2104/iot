package com.iot.smartwatering.smart_watering_backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SystemStatisticsResponse {
    private Long totalUsers;
    private Long activeUsers;
    private Long inactiveUsers;
    private Long adminUsers;
    private Long regularUsers;
    private Long totalZones;
    private Long totalDevices;
    private Long onlineDevices;
    private Long offlineDevices;
    private Long totalAlerts;
    private Long unhandledAlerts;
    private Long criticalAlerts;
    private Long totalSensorData;
    private Long totalFlowData;
}
