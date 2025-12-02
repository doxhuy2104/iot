package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface WaterLogRepository extends JpaRepository<WaterLog, Long> {
    List<WaterLog> findByZone_ZoneIdOrderByCreatedAtDesc(Integer zoneId);

    List<WaterLog> findByZone_ZoneIdAndCreatedAtBetween(
            Integer zoneId,
            LocalDateTime start,
            LocalDateTime end
    );

    @Query("SELECT wl FROM WaterLog wl WHERE wl.status = 'PENDING' OR wl.status = 'NOT_YET'")
    List<WaterLog> findPendingLogs();
}