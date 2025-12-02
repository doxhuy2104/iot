package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Integer> {
    List<Schedule> findByZone_ZoneId(Integer zoneId);
    List<Schedule> findByActiveTrue();
    List<Schedule> findByZone_ZoneIdAndActiveTrue(Integer zoneId);
}
