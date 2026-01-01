package com.iot.smartwatering.smart_watering_backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeatherSummaryResponse {
    private String location;
    private CurrentCondition current;
    private RainForecast rainForecast;
    private Boolean shouldStopWatering;
    private String recommendation;
    private LocalDateTime checkedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CurrentCondition {
        private Double temperature;
        private Integer humidity;
        private String condition;
        private Double precipitation;
        private Integer cloudCover;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RainForecast {
        private Boolean willRainSoon;
        private Integer hoursUntilRain;
        private Integer maxChanceOfRain;
        private List<HourlyForecast> hourlyForecasts;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class HourlyForecast {
        private String time;
        private Integer chanceOfRain;
        private Double precipitation;
        private String condition;
        private Double temperature;
    }
}
