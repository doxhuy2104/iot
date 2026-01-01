package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {
    List<Alert> findByZone_ZoneIdOrderByCreatedAtDesc(Integer zoneId);
    List<Alert> findByIsHandledFalseOrderByCreatedAtDesc();
    List<Alert> findBySeverityOrderByCreatedAtDesc(Alert.AlertSeverity severity);
}
