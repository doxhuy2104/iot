package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeviceRepository extends JpaRepository<Device, Integer> {
    List<Device> findByZone_ZoneId(Long zoneId);
    Optional<Device> findByIdentifier(String identifier);
    List<Device> findByType(Device.DeviceType type);
    List<Device> findByStatus(Device.DeviceStatus status);
}