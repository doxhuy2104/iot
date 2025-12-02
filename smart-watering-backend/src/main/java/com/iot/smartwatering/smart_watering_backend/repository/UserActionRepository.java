package com.iot.smartwatering.smart_watering_backend.repository;

import com.iot.smartwatering.smart_watering_backend.entity.UserAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserActionRepository extends JpaRepository<UserAction, Long> {
    List<UserAction> findByUser_UserIdOrderByCreatedAtDesc(Integer userId);
    List<UserAction> findByZone_ZoneIdOrderByCreatedAtDesc(Integer zoneId);
}
