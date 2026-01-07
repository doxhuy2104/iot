package com.iot.smartwatering.smart_watering_backend.service;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.iot.smartwatering.smart_watering_backend.dto.request.ScheduleRequest;
import com.iot.smartwatering.smart_watering_backend.dto.response.ScheduleResponse;
import com.iot.smartwatering.smart_watering_backend.entity.Schedule;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.repository.ScheduleRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final ZoneRepository zoneRepository;
    private final MqttService mqttService;

    @Scheduled(cron = "0 * * * * *") // Runs every minute at the top of the minute
    @Transactional(readOnly = true)
    public void checkScheduledWatering() {
        log.info("Checking for scheduled watering...");
        LocalDateTime now = LocalDateTime.now();
        LocalTime currentTime = now.toLocalTime().truncatedTo(ChronoUnit.MINUTES);
        DayOfWeek currentDay = now.getDayOfWeek();

        List<Schedule> activeSchedules = scheduleRepository.findByActiveTrue();

        for (Schedule schedule : activeSchedules) {
            try {
                if (shouldRun(schedule, currentTime, currentDay)) {
                    log.info("Triggering schedule ID: {} for Zone ID: {}", schedule.getScheduleId(),
                            schedule.getZone().getZoneId());
                    triggerWatering(schedule);
                }
            } catch (Exception e) {
                log.error("Error processing schedule ID: " + schedule.getScheduleId(), e);
            }
        }
    }

    private boolean shouldRun(Schedule schedule, LocalTime currentTime, DayOfWeek currentDay) {
        if (schedule.getStartTime() == null)
            return false;

        // Extract time from schedule start time
        LocalTime scheduleTime = schedule.getStartTime().toLocalTime().truncatedTo(ChronoUnit.MINUTES);

        // Check if times match (ignoring seconds)
        if (!currentTime.equals(scheduleTime)) {
            return false;
        }

        String repeatDays = schedule.getRepeatDays();

        if (repeatDays == null || repeatDays.trim().isEmpty()) {
            // Non-repeating: Check if the date matches today
            return schedule.getStartTime().toLocalDate().isEqual(LocalDateTime.now().toLocalDate());
        } else {
            // Repeating: Check if today is in the repeat days
            // Formats could be "MONDAY,TUESDAY" or "Mon,Tue" etc.
            String currentDayName = currentDay.name(); // MONDAY
            String currentDayShort = currentDayName.substring(0, 3); // MON

            String normalizedRepeatDays = repeatDays.toUpperCase();

            return normalizedRepeatDays.contains(currentDayName) ||
                    normalizedRepeatDays.contains(currentDayShort);
        }
    }

    private void triggerWatering(Schedule schedule) {
        if (schedule.getZone() == null) {
            log.warn("Schedule ID {} has no associated zone.", schedule.getScheduleId());
            return;
        }
        Long zoneId = schedule.getZone().getZoneId();

        // Publish ON command
        mqttService.publishControlCommand(zoneId, "on", null);
    }

    @Transactional
    public ScheduleResponse createSchedule(ScheduleRequest request) {
        Zone zone = zoneRepository.findById(Long.valueOf(request.getZoneId()))
                .orElseThrow(() -> new RuntimeException("Zone not found"));

        Schedule schedule = Schedule.builder()
                .zone(zone)
                .startTime(LocalDateTime.of(java.time.LocalDate.now(), request.getStartTime())) // ScheduleRequest has
                                                                                                // LocalTime?
                .duration(Long.valueOf(request.getDuration()))
                .volume(request.getVolume())
                .repeatDays(request.getRepeatDays())
                .active(request.getActive() != null ? request.getActive() : true)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        // Warning: ScheduleRequest startTime is LocalTime, Schedule entity startTime is
        // LocalDateTime.
        // Usually 'startTime' in schedule implies the *next* run time or just the time
        // of day.
        // If it's a repeating schedule, we use Time component.
        // However, the Entity has LocalDateTime.
        // I will set it to today + time.

        schedule = scheduleRepository.save(schedule);

        // Publish to MQTT
        ScheduleResponse response = mapToResponse(schedule);
        mqttService.publishScheduleUpdate(zone.getZoneId(), response);

        return response;
    }

    @Transactional(readOnly = true)
    public List<ScheduleResponse> getSchedulesByZoneId(Long zoneId) {
        // Validate zone exists ? Or just return empty list.
        // Repository returns list.
        return scheduleRepository.findByZone_ZoneId(zoneId).stream()
                .map(this::mapToResponse)
                .toList();
        // Note: .toList() is Java 16+. If using older Java, use
        // .collect(Collectors.toList())
    }

    @Transactional
    public void deleteSchedule(Long scheduleId) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Schedule not found"));

        Long zoneId = schedule.getZone().getZoneId();
        scheduleRepository.delete(schedule);

        // Publish empty schedule update or specific DELETE event
        // Sending the ID with "active": false is a good signal if device expects it
        // Or publish map with action DELETE
        // To be safe and minimal:

        // mqttService.publishScheduleUpdate(zoneId, Map.of("scheduleId", scheduleId,
        // "action", "DELETE"));
        // Since publishScheduleUpdate accepts Object, we can send a small map.

        java.util.Map<String, Object> deleteMessage = new java.util.HashMap<>();
        deleteMessage.put("scheduleId", scheduleId);
        deleteMessage.put("action", "DELETE");

        mqttService.publishScheduleUpdate(zoneId, deleteMessage);
    }

    @Transactional
    public ScheduleResponse toggleScheduleActive(Long scheduleId, boolean active) {
        Schedule schedule = scheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new RuntimeException("Schedule not found"));

        schedule.setActive(active);
        schedule = scheduleRepository.save(schedule);

        ScheduleResponse response = mapToResponse(schedule);
        mqttService.publishScheduleUpdate(schedule.getZone().getZoneId(), response);

        return response;
    }

    private ScheduleResponse mapToResponse(Schedule schedule) {
        return ScheduleResponse.builder()
                .scheduleId(schedule.getScheduleId())
                .zoneId(schedule.getZone().getZoneId())
                .startTime(schedule.getStartTime())
                .duration(schedule.getDuration())
                .volume(schedule.getVolume())
                .repeatDays(schedule.getRepeatDays())
                .active(schedule.getActive())
                .createdAt(schedule.getCreatedAt())
                .updatedAt(schedule.getUpdatedAt())
                .build();
    }
}
