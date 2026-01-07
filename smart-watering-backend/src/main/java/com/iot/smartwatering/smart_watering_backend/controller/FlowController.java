package com.iot.smartwatering.smart_watering_backend.controller;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.iot.smartwatering.smart_watering_backend.dto.response.ApiResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.FlowDataResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.WaterLogResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.WaterUsageResponse;
import com.iot.smartwatering.smart_watering_backend.entity.FlowData;
import com.iot.smartwatering.smart_watering_backend.entity.WaterLog;
import com.iot.smartwatering.smart_watering_backend.entity.Zone;
import com.iot.smartwatering.smart_watering_backend.repository.FlowDataRepository;
import com.iot.smartwatering.smart_watering_backend.repository.WaterLogRepository;
import com.iot.smartwatering.smart_watering_backend.repository.ZoneRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/flow")
@RequiredArgsConstructor
public class FlowController {

        private final FlowDataRepository flowDataRepository;
        private final WaterLogRepository waterLogRepository;
        private final ZoneRepository zoneRepository;

        /**
         * Lấy tất cả flow data của zone
         */
        @GetMapping("/zone/{zoneId}")
        public ResponseEntity<ApiResponse<List<FlowDataResponse>>> getFlowDataByZone(
                        @PathVariable Long zoneId) {
                List<FlowData> flowDataList = flowDataRepository.findByZone_ZoneIdOrderByCreatedAtDesc(zoneId);
                List<FlowDataResponse> response = flowDataList.stream()
                                .map(this::mapToFlowDataResponse)
                                .collect(Collectors.toList());
                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Lấy flow data mới nhất của zone
         */
        @GetMapping("/zone/{zoneId}/latest")
        public ResponseEntity<ApiResponse<FlowDataResponse>> getLatestFlowData(
                        @PathVariable Long zoneId) {
                FlowData flowData = flowDataRepository.findLatestByZone(zoneId);
                if (flowData == null) {
                        return ResponseEntity.ok(ApiResponse.error("No flow data found"));
                }
                return ResponseEntity.ok(ApiResponse.success(mapToFlowDataResponse(flowData)));
        }

        /**
         * Lấy flow data trong khoảng thời gian
         */
        @GetMapping("/zone/{zoneId}/range")
        public ResponseEntity<ApiResponse<List<FlowDataResponse>>> getFlowDataByRange(
                        @PathVariable Long zoneId,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

                List<FlowData> flowDataList = flowDataRepository.findByZoneAndDateRange(zoneId, startDate, endDate);
                List<FlowDataResponse> response = flowDataList.stream()
                                .map(this::mapToFlowDataResponse)
                                .collect(Collectors.toList());
                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Xem tổng lưu lượng nước theo ngày
         */
        @GetMapping("/zone/{zoneId}/daily")
        public ResponseEntity<ApiResponse<WaterUsageResponse>> getDailyWaterUsage(
                        @PathVariable Long zoneId,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

                Zone zone = zoneRepository.findById(zoneId)
                                .orElseThrow(() -> new RuntimeException("Zone not found"));

                LocalDateTime startOfDay = date.atStartOfDay();
                LocalDateTime endOfDay = date.atTime(23, 59, 59);

                WaterUsageResponse response = buildWaterUsageResponse(
                                zoneId, zone.getZoneName(), date, "daily", startOfDay, endOfDay);

                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Xem tổng lưu lượng nước theo tháng
         */
        @GetMapping("/zone/{zoneId}/monthly")
        public ResponseEntity<ApiResponse<WaterUsageResponse>> getMonthlyWaterUsage(
                        @PathVariable Long zoneId,
                        @RequestParam int year,
                        @RequestParam int month) {

                Zone zone = zoneRepository.findById(zoneId)
                                .orElseThrow(() -> new RuntimeException("Zone not found"));

                YearMonth yearMonth = YearMonth.of(year, month);
                LocalDateTime startOfMonth = yearMonth.atDay(1).atStartOfDay();
                LocalDateTime endOfMonth = yearMonth.atEndOfMonth().atTime(23, 59, 59);
                LocalDate date = LocalDate.of(year, month, 1);

                WaterUsageResponse response = buildWaterUsageResponse(
                                zoneId, zone.getZoneName(), date, "monthly", startOfMonth, endOfMonth);

                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Xem tổng lưu lượng nước theo năm
         */
        @GetMapping("/zone/{zoneId}/yearly")
        public ResponseEntity<ApiResponse<WaterUsageResponse>> getYearlyWaterUsage(
                        @PathVariable Long zoneId,
                        @RequestParam int year) {

                Zone zone = zoneRepository.findById(zoneId)
                                .orElseThrow(() -> new RuntimeException("Zone not found"));

                LocalDateTime startOfYear = LocalDate.of(year, 1, 1).atStartOfDay();
                LocalDateTime endOfYear = LocalDate.of(year, 12, 31).atTime(23, 59, 59);
                LocalDate date = LocalDate.of(year, 1, 1);

                WaterUsageResponse response = buildWaterUsageResponse(
                                zoneId, zone.getZoneName(), date, "yearly", startOfYear, endOfYear);

                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Lấy water logs của zone
         */
        @GetMapping("/zone/{zoneId}/logs")
        public ResponseEntity<ApiResponse<List<WaterLogResponse>>> getWaterLogs(
                        @PathVariable Long zoneId) {
                List<WaterLog> logs = waterLogRepository.findByZone_ZoneIdOrderByCreatedAtDesc(zoneId);
                List<WaterLogResponse> response = logs.stream()
                                .map(this::mapToWaterLogResponse)
                                .collect(Collectors.toList());
                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Lấy water logs trong khoảng thời gian
         */
        @GetMapping("/zone/{zoneId}/logs/range")
        public ResponseEntity<ApiResponse<List<WaterLogResponse>>> getWaterLogsByRange(
                        @PathVariable Long zoneId,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

                List<WaterLog> logs = waterLogRepository.findByZone_ZoneIdAndCreatedAtBetween(
                                zoneId, startDate, endDate);
                List<WaterLogResponse> response = logs.stream()
                                .map(this::mapToWaterLogResponse)
                                .collect(Collectors.toList());
                return ResponseEntity.ok(ApiResponse.success(response));
        }

        /**
         * Tính tổng lưu lượng trong khoảng thời gian tùy chỉnh
         */
        @GetMapping("/zone/{zoneId}/usage/custom")
        public ResponseEntity<ApiResponse<WaterUsageResponse>> getCustomWaterUsage(
                        @PathVariable Long zoneId,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {

                Zone zone = zoneRepository.findById(zoneId)
                                .orElseThrow(() -> new RuntimeException("Zone not found"));

                WaterUsageResponse response = buildWaterUsageResponse(
                                zoneId, zone.getZoneName(), startDate.toLocalDate(), "custom", startDate, endDate);

                return ResponseEntity.ok(ApiResponse.success(response));
        }

        // Helper methods
        private WaterUsageResponse buildWaterUsageResponse(
                        Long zoneId, String zoneName, LocalDate date, String period,
                        LocalDateTime startDate, LocalDateTime endDate) {

                Float totalLiters = flowDataRepository.getTotalWaterUsage(zoneId, startDate, endDate);
                Long dataPointCount = flowDataRepository.countByZoneAndDateRange(zoneId, startDate, endDate);
                Float avgFlowRate = flowDataRepository.getAverageFlowRate(zoneId, startDate, endDate);
                Float minFlowRate = flowDataRepository.getMinFlowRate(zoneId, startDate, endDate);
                Float maxFlowRate = flowDataRepository.getMaxFlowRate(zoneId, startDate, endDate);

                return WaterUsageResponse.builder()
                                .zoneId(zoneId)
                                .zoneName(zoneName)
                                .date(date)
                                .period(period)
                                .totalLiters(totalLiters != null ? totalLiters : 0f)
                                .dataPointCount(dataPointCount)
                                .averageFlowRate(avgFlowRate)
                                .minFlowRate(minFlowRate)
                                .maxFlowRate(maxFlowRate)
                                .build();
        }

        private FlowDataResponse mapToFlowDataResponse(FlowData flowData) {
                return FlowDataResponse.builder()
                                .flowId(flowData.getFlowId())
                                .zoneId(flowData.getZone() != null ? flowData.getZone().getZoneId() : null)
                                .zoneName(flowData.getZone() != null ? flowData.getZone().getZoneName() : null)
                                .deviceId(flowData.getDevice() != null ? flowData.getDevice().getDeviceId() : null)
                                .deviceName(flowData.getDevice() != null ? flowData.getDevice().getDeviceName() : null)
                                .pulseCount(flowData.getPulseCount())
                                .flowRatePerMinute(flowData.getFlowRatePerMinute())
                                .cumulativeLiters(flowData.getCumulativeLiters())
                                .createdAt(flowData.getCreatedAt())
                                .build();
        }

        private WaterLogResponse mapToWaterLogResponse(WaterLog log) {
                return WaterLogResponse.builder()
                                .logId(log.getLogId())
                                .zoneId(log.getZone() != null ? log.getZone().getZoneId() : null)
                                .zoneName(log.getZone() != null ? log.getZone().getZoneName() : null)
                                .deviceId(log.getDevice() != null ? log.getDevice().getDeviceId() : null)
                                .deviceName(log.getDevice() != null ? log.getDevice().getDeviceName() : null)
                                .startedAt(log.getStartedAt())
                                .endedAt(log.getEndedAt())
                                .durationSeconds(log.getDurationSeconds())
                                .volume(log.getVolume())
                                .reason(log.getReason() != null ? log.getReason().name() : null)
                                .status(log.getStatus() != null ? log.getStatus().name() : null)
                                .createdAt(log.getCreatedAt())
                                .build();
        }
}
