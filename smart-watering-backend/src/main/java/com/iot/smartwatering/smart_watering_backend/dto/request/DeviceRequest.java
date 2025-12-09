package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DeviceRequest {
    @NotBlank(message = "Device name không được để trống")
    private String deviceName;

    @NotNull(message = "Zone ID không được để trống")
    private Integer zoneId;

    @NotBlank(message = "Device type không được để trống")
    private String type;

    @NotBlank(message = "Identifier không được để trống")
    private String identifier;

    private String mqttTopicPublish;
    private String mqttTopicSubscribe;
}
