package com.iot.smartwatering.smart_watering_backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.iot.smartwatering.smart_watering_backend.entity.Schedule;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByZone_ZoneId(Long zoneId);

    List<Schedule> findByActiveTrue();

    List<Schedule> findByZone_ZoneIdAndActiveTrue(Long zoneId);
}
