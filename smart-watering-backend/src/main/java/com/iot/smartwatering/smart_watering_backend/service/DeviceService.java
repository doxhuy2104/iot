package com.iot.smartwatering.smart_watering_backend.service;

import com.iot.smartwatering.smart_watering_backend.dto.request.DeviceRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.DeviceResponse;
import com.iot.smartwatering.smart_watering_backend.entity.Device;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.exception.ResourceNotFoundException;
import com.iot.smartwatering.smart_watering_backend.repository.DeviceRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeviceService {

    private final DeviceRepository deviceRepository;
    private final ZoneRepository zoneRepository;

    public List<DeviceResponse> getAllDevices() {
        log.info("Fetching all devices");
        return deviceRepository.findAll().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public DeviceResponse getDeviceById(Integer deviceId) {
        log.info("Fetching device with ID: {}", deviceId);
        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Device not found with ID: " + deviceId));
        return convertToResponse(device);
    }

    public List<DeviceResponse> getDevicesByZoneId(Long zoneId) {
        log.info("Fetching devices for zone ID: {}", zoneId);
        // Check if zone exists
        if (!zoneRepository.existsById(zoneId)) {
            throw new ResourceNotFoundException("Zone not found with ID: " + zoneId);
        }
        return deviceRepository.findByZone_ZoneId(zoneId).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<DeviceResponse> getDevicesByType(String type) {
        log.info("Fetching devices by type: {}", type);
        Device.DeviceType deviceType;
        try {
            deviceType = Device.DeviceType.valueOf(type.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid device type: " + type);
        }
        return deviceRepository.findByType(deviceType).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<DeviceResponse> getDevicesByStatus(String status) {
        log.info("Fetching devices by status: {}", status);
        Device.DeviceStatus deviceStatus;
        try {
            deviceStatus = Device.DeviceStatus.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid device status: " + status);
        }
        return deviceRepository.findByStatus(deviceStatus).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public DeviceResponse createDevice(DeviceRequest request) {
        log.info("Creating new device: {}", request.getDeviceName());

        // Check if zone exists
        Zone zone = zoneRepository.findById(request.getZoneId())
                .orElseThrow(() -> new ResourceNotFoundException("Zone not found with ID: " + request.getZoneId()));

        // Check if identifier already exists
        if (deviceRepository.findByIdentifier(request.getIdentifier()).isPresent()) {
            throw new IllegalArgumentException("Device with identifier '" + request.getIdentifier() + "' already exists");
        }

        // Parse device type
        Device.DeviceType deviceType;
        try {
            deviceType = Device.DeviceType.valueOf(request.getType().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid device type: " + request.getType());
        }

        // Create device
        Device device = Device.builder()
                .deviceName(request.getDeviceName())
                .type(deviceType)
                .identifier(request.getIdentifier())
                .mqttTopicPublish(request.getMqttTopicPublish())
                .mqttTopicSubscribe(request.getMqttTopicSubscribe())
                .status(Device.DeviceStatus.OFFLINE)
                .zone(zone)
                .createdAt(LocalDateTime.now())
                .build();

        Device savedDevice = deviceRepository.save(device);
        log.info("Device created successfully with ID: {}", savedDevice.getDeviceId());
        return convertToResponse(savedDevice);
    }

    @Transactional
    public DeviceResponse updateDevice(Integer deviceId, DeviceRequest request) {
        log.info("Updating device with ID: {}", deviceId);

        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Device not found with ID: " + deviceId));

        // Check if zone exists if zoneId is provided
        if (request.getZoneId() != null && !request.getZoneId().equals(device.getZone().getZoneId())) {
            Zone zone = zoneRepository.findById(request.getZoneId())
                    .orElseThrow(() -> new ResourceNotFoundException("Zone not found with ID: " + request.getZoneId()));
            device.setZone(zone);
        }

        // Check if identifier is being changed and if it already exists
        if (!device.getIdentifier().equals(request.getIdentifier())) {
            if (deviceRepository.findByIdentifier(request.getIdentifier()).isPresent()) {
                throw new IllegalArgumentException("Device with identifier '" + request.getIdentifier() + "' already exists");
            }
            device.setIdentifier(request.getIdentifier());
        }

        // Parse device type if provided
        if (request.getType() != null) {
            Device.DeviceType deviceType;
            try {
                deviceType = Device.DeviceType.valueOf(request.getType().toUpperCase());
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid device type: " + request.getType());
            }
            device.setType(deviceType);
        }

        device.setDeviceName(request.getDeviceName());
        device.setMqttTopicPublish(request.getMqttTopicPublish());
        device.setMqttTopicSubscribe(request.getMqttTopicSubscribe());

        Device updatedDevice = deviceRepository.save(device);
        log.info("Device updated successfully with ID: {}", updatedDevice.getDeviceId());
        return convertToResponse(updatedDevice);
    }

    @Transactional
    public void deleteDevice(Integer deviceId) {
        log.info("Deleting device with ID: {}", deviceId);
        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Device not found with ID: " + deviceId));
        deviceRepository.delete(device);
        log.info("Device deleted successfully with ID: {}", deviceId);
    }

    @Transactional
    public DeviceResponse updateDeviceStatus(Integer deviceId, String status) {
        log.info("Updating device status with ID: {} to {}", deviceId, status);

        Device device = deviceRepository.findById(deviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Device not found with ID: " + deviceId));

        Device.DeviceStatus deviceStatus;
        try {
            deviceStatus = Device.DeviceStatus.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid device status: " + status);
        }

        device.setStatus(deviceStatus);
        Device updatedDevice = deviceRepository.save(device);
        log.info("Device status updated successfully with ID: {}", updatedDevice.getDeviceId());
        return convertToResponse(updatedDevice);
    }

    private DeviceResponse convertToResponse(Device device) {
        return DeviceResponse.builder()
                .deviceId(device.getDeviceId().longValue())
                .deviceName(device.getDeviceName())
                .type(device.getType().name())
                .identifier(device.getIdentifier())
                .status(device.getStatus().name())
                .zoneId(device.getZone().getZoneId())
                .zoneName(device.getZone().getZoneName())
                .createdAt(device.getCreatedAt())
                .build();
    }
}
