package com.iot.smartwatering.smart_watering_backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.iot.smartwatering.smart_watering_backend.entity.FlowData;

@Repository
public interface FlowDataRepository extends JpaRepository<FlowData, Long> {
        List<FlowData> findByZone_ZoneIdOrderByCreatedAtDesc(Long zoneId);

        @Query("SELECT fd FROM FlowData fd WHERE fd.zone.zoneId = :zoneId " +
                        "ORDER BY fd.createdAt DESC LIMIT 1")
        FlowData findLatestByZone(@Param("zoneId") Long zoneId);

        @Query("SELECT fd FROM FlowData fd WHERE fd.zone.zoneId = :zoneId " +
                        "AND fd.createdAt BETWEEN :startDate AND :endDate " +
                        "ORDER BY fd.createdAt DESC")
        List<FlowData> findByZoneAndDateRange(
                        @Param("zoneId") Long zoneId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        @Query("SELECT SUM(fd.cumulativeLiters) FROM FlowData fd " +
                        "WHERE fd.zone.zoneId = :zoneId " +
                        "AND fd.createdAt BETWEEN :startDate AND :endDate")
        Float getTotalWaterUsage(
                        @Param("zoneId") Long zoneId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        @Query("SELECT COUNT(fd) FROM FlowData fd " +
                        "WHERE fd.zone.zoneId = :zoneId " +
                        "AND fd.createdAt BETWEEN :startDate AND :endDate")
        Long countByZoneAndDateRange(
                        @Param("zoneId") Long zoneId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        @Query("SELECT AVG(fd.flowRatePerMinute) FROM FlowData fd " +
                        "WHERE fd.zone.zoneId = :zoneId " +
                        "AND fd.createdAt BETWEEN :startDate AND :endDate")
        Float getAverageFlowRate(
                        @Param("zoneId") Long zoneId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        @Query("SELECT MIN(fd.flowRatePerMinute) FROM FlowData fd " +
                        "WHERE fd.zone.zoneId = :zoneId " +
                        "AND fd.createdAt BETWEEN :startDate AND :endDate")
        Float getMinFlowRate(
                        @Param("zoneId") Long zoneId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        @Query("SELECT MAX(fd.flowRatePerMinute) FROM FlowData fd " +
                        "WHERE fd.zone.zoneId = :zoneId " +
                        "AND fd.createdAt BETWEEN :startDate AND :endDate")
        Float getMaxFlowRate(
                        @Param("zoneId") Long zoneId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);
}