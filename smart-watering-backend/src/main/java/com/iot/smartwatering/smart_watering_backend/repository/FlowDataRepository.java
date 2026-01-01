package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.FlowData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface FlowDataRepository extends JpaRepository<FlowData, Long> {
    List<FlowData> findByZone_ZoneIdOrderByCreatedAtDesc(Integer zoneId);

    @Query("SELECT SUM(fd.cumulativeLiters) FROM FlowData fd " +
            "WHERE fd.zone.zoneId = :zoneId " +
            "AND fd.createdAt BETWEEN :startDate AND :endDate")
    Float getTotalWaterUsage(
            @Param("zoneId") Integer zoneId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );
}