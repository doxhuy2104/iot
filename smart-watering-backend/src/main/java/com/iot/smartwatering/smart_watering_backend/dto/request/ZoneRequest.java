package com.iot.smartwatering.smart_watering_backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ZoneRequest {
    @NotBlank(message = "Zone name không được để trống")
    private String zoneName;
    @NotBlank(message = "Location không được để trống")
    private String location;
    private String description;
    @NotBlank(message = "Longitude không được để trống")
    private String longitude;
    @NotBlank(message = "Latitude không được để trống")
    private String latitude;
    private Double thresholdValue;
    private Boolean autoMode;
    private Boolean weatherMode;
}
