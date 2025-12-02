package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.SensorData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;


@Repository
public interface SensorDataRepository extends JpaRepository<SensorData, Long> {
    List<SensorData> findByZone_ZoneIdOrderByCreatedAtDesc(Integer zoneId);

    @Query("SELECT sd FROM SensorData sd WHERE sd.zone.zoneId = :zoneId " +
            "AND sd.createdAt BETWEEN :startDate AND :endDate " +
            "ORDER BY sd.createdAt DESC")
    List<SensorData> findByZoneAndDateRange(
            @Param("zoneId") Integer zoneId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    @Query("SELECT sd FROM SensorData sd WHERE sd.zone.zoneId = :zoneId " +
            "ORDER BY sd.createdAt DESC LIMIT 1")
    SensorData findLatestByZone(@Param("zoneId") Integer zoneId);
}
