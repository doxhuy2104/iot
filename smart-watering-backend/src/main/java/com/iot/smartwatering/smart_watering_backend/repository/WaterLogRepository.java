package com.iot.smartwatering.smart_watering_backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;

@Repository
public interface WaterLogRepository extends JpaRepository<WaterLog, Long> {
    List<WaterLog> findByZone_ZoneIdOrderByCreatedAtDesc(Long zoneId);

    List<WaterLog> findByZone_ZoneIdAndCreatedAtBetween(
            Long zoneId,
            LocalDateTime start,
            LocalDateTime end);

    @Query("SELECT wl FROM WaterLog wl WHERE wl.status = 'PENDING' OR wl.status = 'NOT_YET'")
    List<WaterLog> findPendingLogs();
}