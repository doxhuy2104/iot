package com.iot.smartwatering.smart_watering_backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.iot.smartwatering.smart_watering_backend.entity.Zone;

@Repository
public interface ZoneRepository extends JpaRepository<Zone, Long> {
    List<Zone> findByUser_UserIdOrderByZoneIdDesc(Long userId);

    @Query("SELECT z FROM Zone z WHERE z.autoMode = true AND z.pumpStatus = false")
    List<Zone> findZonesForAutoWatering();
}
