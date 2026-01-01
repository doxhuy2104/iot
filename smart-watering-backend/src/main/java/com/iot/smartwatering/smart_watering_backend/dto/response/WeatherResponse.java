package com.iot.smartwatering.smart_watering_backend.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeatherResponse {
    private LocationData location;
    private CurrentWeather current;
    private ForecastData forecast;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LocationData {
        private String name;
        private String region;
        private String country;
        private Double lat;
        private Double lon;
        
        @JsonProperty("tz_id")
        private String tzId;
        
        @JsonProperty("localtime")
        private String localtime;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CurrentWeather {
        @JsonProperty("last_updated")
        private String lastUpdated;
        
        @JsonProperty("temp_c")
        private Double tempC;
        
        @JsonProperty("temp_f")
        private Double tempF;
        
        @JsonProperty("is_day")
        private Integer isDay;
        
        private Condition condition;
        
        @JsonProperty("wind_kph")
        private Double windKph;
        
        @JsonProperty("wind_degree")
        private Integer windDegree;
        
        @JsonProperty("wind_dir")
        private String windDir;
        
        @JsonProperty("pressure_mb")
        private Double pressureMb;
        
        @JsonProperty("precip_mm")
        private Double precipMm;
        
        private Integer humidity;
        
        private Integer cloud;
        
        @JsonProperty("feelslike_c")
        private Double feelslikeC;
        
        @JsonProperty("feelslike_f")
        private Double feelslikeF;
        
        @JsonProperty("vis_km")
        private Double visKm;
        
        private Double uv;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Condition {
        private String text;
        private String icon;
        private Integer code;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ForecastData {
        private java.util.List<ForecastDay> forecastday;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ForecastDay {
        private String date;
        
        @JsonProperty("date_epoch")
        private Long dateEpoch;
        
        private DayData day;
        private Astro astro;
        private java.util.List<HourData> hour;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DayData {
        @JsonProperty("maxtemp_c")
        private Double maxtempC;
        
        @JsonProperty("mintemp_c")
        private Double mintempC;
        
        @JsonProperty("avgtemp_c")
        private Double avgtempC;
        
        @JsonProperty("maxwind_kph")
        private Double maxwindKph;
        
        @JsonProperty("totalprecip_mm")
        private Double totalprecipMm;
        
        @JsonProperty("avgvis_km")
        private Double avgvisKm;
        
        @JsonProperty("avghumidity")
        private Integer avghumidity;
        
        @JsonProperty("daily_will_it_rain")
        private Integer dailyWillItRain;
        
        @JsonProperty("daily_chance_of_rain")
        private Integer dailyChanceOfRain;
        
        private Condition condition;
        
        private Double uv;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Astro {
        private String sunrise;
        private String sunset;
        private String moonrise;
        private String moonset;
        
        @JsonProperty("moon_phase")
        private String moonPhase;
        
        @JsonProperty("moon_illumination")
        private Integer moonIllumination;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class HourData {
        @JsonProperty("time_epoch")
        private Long timeEpoch;
        
        private String time;
        
        @JsonProperty("temp_c")
        private Double tempC;
        
        @JsonProperty("is_day")
        private Integer isDay;
        
        private Condition condition;
        
        @JsonProperty("wind_kph")
        private Double windKph;
        
        @JsonProperty("wind_degree")
        private Integer windDegree;
        
        @JsonProperty("wind_dir")
        private String windDir;
        
        @JsonProperty("pressure_mb")
        private Double pressureMb;
        
        @JsonProperty("precip_mm")
        private Double precipMm;
        
        private Integer humidity;
        
        private Integer cloud;
        
        @JsonProperty("feelslike_c")
        private Double feelslikeC;
        
        @JsonProperty("windchill_c")
        private Double windchillC;
        
        @JsonProperty("heatindex_c")
        private Double heatindexC;
        
        @JsonProperty("dewpoint_c")
        private Double dewpointC;
        
        @JsonProperty("will_it_rain")
        private Integer willItRain;
        
        @JsonProperty("chance_of_rain")
        private Integer chanceOfRain;
        
        @JsonProperty("will_it_snow")
        private Integer willItSnow;
        
        @JsonProperty("chance_of_snow")
        private Integer chanceOfSnow;
        
        @JsonProperty("vis_km")
        private Double visKm;
        
        private Double uv;
    }
}
