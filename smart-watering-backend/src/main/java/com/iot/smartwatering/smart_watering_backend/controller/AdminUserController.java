package com.iot.smartwatering.smart_watering_backend.controller;

import com.iot.smartwatering.smart_watering_backend.dto.request.UpdateUserRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.UserResponse;
import com.iot.smartwatering.smart_watering_backend.entity.User;
import com.iot.smartwatering.smart_watering_backend.enums.UserRole;
import com.iot.smartwatering.smart_watering_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Lấy danh sách tất cả users
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        List<User> users = userRepository.findAllOrderByCreatedAtDesc();
        List<UserResponse> response = users.stream()
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy thông tin user theo ID
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(ApiResponse.success(mapToUserResponse(user)));
    }

    /**
     * Lấy danh sách users theo role
     */
    @GetMapping("/role/{role}")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getUsersByRole(@PathVariable UserRole role) {
        List<User> users = userRepository.findByRole(role);
        List<UserResponse> response = users.stream()
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Lấy danh sách users theo trạng thái active
     */
    @GetMapping("/status/{isActive}")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getUsersByStatus(
            @PathVariable Boolean isActive) {
        List<User> users = userRepository.findByIsActive(isActive);
        List<UserResponse> response = users.stream()
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Cập nhật thông tin user
     */
    @PutMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
            @PathVariable Long userId,
            @RequestBody UpdateUserRequest request) {
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getEmail() != null) {
            // Kiểm tra email đã tồn tại
            if (userRepository.existsByEmail(request.getEmail()) && 
                !user.getEmail().equals(request.getEmail())) {
                return ResponseEntity.ok(ApiResponse.error("Email already exists"));
            }
            user.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }
        if (request.getRole() != null) {
            user.setRole(request.getRole());
        }
        if (request.getIsActive() != null) {
            user.setIsActive(request.getIsActive());
        }
        
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success("User updated successfully", 
                mapToUserResponse(user)));
    }

    /**
     * Thay đổi role của user
     */
    @PutMapping("/{userId}/role")
    public ResponseEntity<ApiResponse<UserResponse>> changeUserRole(
            @PathVariable Long userId,
            @RequestParam UserRole role) {
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setRole(role);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success("User role changed successfully", 
                mapToUserResponse(user)));
    }

    /**
     * Khóa user
     */
    @PutMapping("/{userId}/deactivate")
    public ResponseEntity<ApiResponse<UserResponse>> deactivateUser(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setIsActive(false);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success("User deactivated successfully", 
                mapToUserResponse(user)));
    }

    /**
     * Mở khóa user
     */
    @PutMapping("/{userId}/activate")
    public ResponseEntity<ApiResponse<UserResponse>> activateUser(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setIsActive(true);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success("User activated successfully", 
                mapToUserResponse(user)));
    }

    /**
     * Reset password user
     */
    @PutMapping("/{userId}/reset-password")
    public ResponseEntity<ApiResponse<String>> resetPassword(
            @PathVariable Long userId,
            @RequestParam String newPassword) {
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success("Password reset successfully"));
    }

    /**
     * Xóa user (soft delete bằng cách deactivate)
     */
    @DeleteMapping("/{userId}")
    public ResponseEntity<ApiResponse<String>> deleteUser(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Kiểm tra không xóa chính mình
        // Có thể thêm logic kiểm tra từ Authentication

        // Soft delete
        user.setIsActive(false);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        // Hoặc hard delete nếu muốn
        // userRepository.delete(user);

        return ResponseEntity.ok(ApiResponse.success("User deleted successfully"));
    }

    /**
     * Đếm số lượng users theo role
     */
    @GetMapping("/count/role/{role}")
    public ResponseEntity<ApiResponse<Long>> countUsersByRole(@PathVariable UserRole role) {
        Long count = userRepository.countByRole(role);
        return ResponseEntity.ok(ApiResponse.success(count));
    }

    /**
     * Đếm số lượng users theo trạng thái
     */
    @GetMapping("/count/status/{isActive}")
    public ResponseEntity<ApiResponse<Long>> countUsersByStatus(@PathVariable Boolean isActive) {
        Long count = userRepository.countByIsActive(isActive);
        return ResponseEntity.ok(ApiResponse.success(count));
    }

    private UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .totalZones(user.getZones() != null ? user.getZones().size() : 0)
                .totalDevices(user.getZones() != null ? 
                        user.getZones().stream()
                                .mapToInt(zone -> zone.getDevices().size())
                                .sum() : 0)
                .build();
    }
}
