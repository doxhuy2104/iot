package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ZoneRepository extends JpaRepository<Zone, Integer> {
    List<Zone> findByUser_UserId(Integer userId);

    @Query("SELECT z FROM Zone z WHERE z.autoMode = true AND z.pumpStatus = false")
    List<Zone> findZonesForAutoWatering();
}

