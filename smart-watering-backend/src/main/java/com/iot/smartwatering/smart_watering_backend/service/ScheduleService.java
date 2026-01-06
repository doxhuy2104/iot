package com.iot.smartwatering.smart_watering_backend.service;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.iot.smartwatering.smart_watering_backend.entity.Schedule;
import com.iot.smartwatering.smart_watering_backend.repository.ScheduleRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
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
        // We can send duration as well if the device supports it, or just ON.
        // Assuming simplistic ON for now as per user request "kiểm tra đến lịch ...
        // publish".
        // Use a specialized message if needed, but existing control is generic.
        // We might want to send 'duration' in the payload if possible.
        // MqttService.publishControlCommand accepts (zoneId, action).
        // Action is String. Maybe we can pass "ON" or a JSON string?
        // The MqttService wraps action in a JSON payload: { "action": action }.
        // So passing "ON" is safe.
        mqttService.publishControlCommand(zoneId, "on", null);

        // Note: If we need to turn it OFF after duration, we need another mechanism
        // (e.g., Delayed task, or device handles it).
        // For this task, strictly checking schedule and publishing is the goal.
    }
}
