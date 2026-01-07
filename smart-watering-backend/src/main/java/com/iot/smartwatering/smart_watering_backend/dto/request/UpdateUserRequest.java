package com.iot.smartwatering.smart_watering_backend.dto.request;

import com.iot.smartwatering.smart_watering_backend.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRequest {
    private String fullName;
    private String email;
    private String phone;
    private UserRole role;
    private Boolean isActive;
}
