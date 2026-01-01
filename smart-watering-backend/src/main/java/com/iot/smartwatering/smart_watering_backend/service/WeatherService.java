package com.iot.smartwatering.smart_watering_backend.service;

import com.iot.smartwatering.smart_watering_backend.dto.response.WeatherResponse;
import com.iot.smartwatering.smart_watering_backend.dto.response.WeatherSummaryResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class WeatherService {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${weather.api.key}")
    private String apiKey;

    @Value("${weather.api.base-url}")
    private String baseUrl;

    @Value("${weather.api.default-location}")
    private String defaultLocation;

    @Value("${weather.check.rain-probability-threshold:60}")
    private Integer rainProbabilityThreshold;

    @Value("${weather.check.forecast-hours:3}")
    private Integer forecastHours;

    /**
     * Lấy thông tin thời tiết hiện tại
     */
    public WeatherResponse getCurrentWeather(String location) {
        if (location == null || location.isEmpty()) {
            location = defaultLocation;
        }

        String url = UriComponentsBuilder.fromHttpUrl(baseUrl + "/current.json")
                .queryParam("key", apiKey)
                .queryParam("q", location)
                .queryParam("aqi", "no")
                .toUriString();

        log.info("Fetching current weather for location: {}", location);
        
        try {
            WeatherResponse response = restTemplate.getForObject(url, WeatherResponse.class);
            log.info("Successfully fetched weather data for: {}", location);
            return response;
        } catch (Exception e) {
            log.error("Error fetching weather data: {}", e.getMessage());
            throw new RuntimeException("Không thể lấy thông tin thời tiết: " + e.getMessage());
        }
    }

    /**
     * Lấy dự báo thời tiết
     */
    public WeatherResponse getForecast(String location, Integer days) {
        if (location == null || location.isEmpty()) {
            location = defaultLocation;
        }
        if (days == null || days < 1) {
            days = 1;
        }

        String url = UriComponentsBuilder.fromHttpUrl(baseUrl + "/forecast.json")
                .queryParam("key", apiKey)
                .queryParam("q", location)
                .queryParam("days", days)
                .queryParam("aqi", "no")
                .queryParam("alerts", "no")
                .toUriString();

        log.info("Fetching forecast for location: {}, days: {}", location, days);
        
        try {
            WeatherResponse response = restTemplate.getForObject(url, WeatherResponse.class);
            log.info("Successfully fetched forecast data for: {}", location);
            return response;
        } catch (Exception e) {
            log.error("Error fetching forecast data: {}", e.getMessage());
            throw new RuntimeException("Không thể lấy dự báo thời tiết: " + e.getMessage());
        }
    }

    /**
     * Kiểm tra dự báo mưa và đưa ra khuyến nghị tưới
     */
    public WeatherSummaryResponse checkRainForecast(String location) {
        WeatherResponse forecast = getForecast(location, 1);
        
        if (forecast == null || forecast.getCurrent() == null) {
            throw new RuntimeException("Không thể lấy dữ liệu thời tiết");
        }

        // Thông tin thời tiết hiện tại
        WeatherSummaryResponse.CurrentCondition currentCondition = WeatherSummaryResponse.CurrentCondition.builder()
                .temperature(forecast.getCurrent().getTempC())
                .humidity(forecast.getCurrent().getHumidity())
                .condition(forecast.getCurrent().getCondition().getText())
                .precipitation(forecast.getCurrent().getPrecipMm())
                .cloudCover(forecast.getCurrent().getCloud())
                .build();

        // Phân tích dự báo mưa trong vài giờ tới
        WeatherSummaryResponse.RainForecast rainForecast = analyzeRainForecast(forecast);

        // Quyết định có nên dừng tưới không
        boolean shouldStopWatering = rainForecast.getWillRainSoon() && 
                                      rainForecast.getMaxChanceOfRain() >= rainProbabilityThreshold;

        // Tạo khuyến nghị
        String recommendation = generateRecommendation(rainForecast, currentCondition);

        return WeatherSummaryResponse.builder()
                .location(forecast.getLocation().getName() + ", " + forecast.getLocation().getCountry())
                .current(currentCondition)
                .rainForecast(rainForecast)
                .shouldStopWatering(shouldStopWatering)
                .recommendation(recommendation)
                .checkedAt(LocalDateTime.now())
                .build();
    }

    /**
     * Phân tích dự báo mưa từ dữ liệu forecast
     */
    private WeatherSummaryResponse.RainForecast analyzeRainForecast(WeatherResponse forecast) {
        if (forecast.getForecast() == null || 
            forecast.getForecast().getForecastday() == null || 
            forecast.getForecast().getForecastday().isEmpty()) {
            return WeatherSummaryResponse.RainForecast.builder()
                    .willRainSoon(false)
                    .hoursUntilRain(null)
                    .maxChanceOfRain(0)
                    .hourlyForecasts(new ArrayList<>())
                    .build();
        }

        WeatherResponse.ForecastDay today = forecast.getForecast().getForecastday().get(0);
        List<WeatherResponse.HourData> hourlyData = today.getHour();

        if (hourlyData == null || hourlyData.isEmpty()) {
            return WeatherSummaryResponse.RainForecast.builder()
                    .willRainSoon(false)
                    .hoursUntilRain(null)
                    .maxChanceOfRain(0)
                    .hourlyForecasts(new ArrayList<>())
                    .build();
        }

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        
        List<WeatherSummaryResponse.HourlyForecast> hourlyForecasts = new ArrayList<>();
        boolean willRainSoon = false;
        Integer hoursUntilRain = null;
        int maxChanceOfRain = 0;
        int hourCount = 0;

        for (WeatherResponse.HourData hour : hourlyData) {
            LocalDateTime hourTime = LocalDateTime.parse(hour.getTime(), formatter);
            
            // Chỉ xét các giờ trong tương lai
            if (hourTime.isAfter(now) && hourCount < forecastHours) {
                hourCount++;
                
                WeatherSummaryResponse.HourlyForecast hourlyForecast = WeatherSummaryResponse.HourlyForecast.builder()
                        .time(hour.getTime())
                        .chanceOfRain(hour.getChanceOfRain())
                        .precipitation(hour.getPrecipMm())
                        .condition(hour.getCondition().getText())
                        .temperature(hour.getTempC())
                        .build();
                
                hourlyForecasts.add(hourlyForecast);

                // Kiểm tra xác suất mưa
                if (hour.getChanceOfRain() > maxChanceOfRain) {
                    maxChanceOfRain = hour.getChanceOfRain();
                }

                // Nếu có khả năng mưa cao và chưa phát hiện
                if (!willRainSoon && hour.getChanceOfRain() >= rainProbabilityThreshold) {
                    willRainSoon = true;
                    hoursUntilRain = hourCount;
                }
            }
        }

        return WeatherSummaryResponse.RainForecast.builder()
                .willRainSoon(willRainSoon)
                .hoursUntilRain(hoursUntilRain)
                .maxChanceOfRain(maxChanceOfRain)
                .hourlyForecasts(hourlyForecasts)
                .build();
    }

    /**
     * Tạo khuyến nghị dựa trên dự báo thời tiết
     */
    private String generateRecommendation(WeatherSummaryResponse.RainForecast rainForecast, 
                                          WeatherSummaryResponse.CurrentCondition current) {
        StringBuilder recommendation = new StringBuilder();

        if (rainForecast.getWillRainSoon()) {
            if (rainForecast.getMaxChanceOfRain() >= rainProbabilityThreshold) {
                recommendation.append("⚠️ CẢnh BÁO: Khả năng mưa cao (")
                             .append(rainForecast.getMaxChanceOfRain())
                             .append("%) trong ")
                             .append(rainForecast.getHoursUntilRain())
                             .append(" giờ tới. ");
                recommendation.append("NÊN TẠM DỪNG TƯỚI để tránh lãng phí nước.");
            } else {
                recommendation.append("ℹ️ Có khả năng mưa nhẹ (")
                             .append(rainForecast.getMaxChanceOfRain())
                             .append("%) trong vài giờ tới. ");
                recommendation.append("Có thể cân nhắc giảm lượng nước tưới.");
            }
        } else {
            recommendation.append("✅ Thời tiết thuận lợi cho việc tưới. ");
            
            if (current.getHumidity() > 80) {
                recommendation.append("Độ ẩm cao (")
                             .append(current.getHumidity())
                             .append("%), có thể giảm lượng nước tưới.");
            } else if (current.getHumidity() < 40) {
                recommendation.append("Độ ẩm thấp (")
                             .append(current.getHumidity())
                             .append("%), cây cần nhiều nước hơn.");
            }
        }

        return recommendation.toString();
    }

    /**
     * Kiểm tra xem có nên dừng tưới không
     */
    public boolean shouldStopWatering(String location) {
        try {
            WeatherSummaryResponse summary = checkRainForecast(location);
            boolean shouldStop = summary.getShouldStopWatering();
            
            if (shouldStop) {
                log.warn("Watering should be stopped for location: {}. Reason: {}", 
                        location, summary.getRecommendation());
            }
            
            return shouldStop;
        } catch (Exception e) {
            log.error("Error checking weather for watering decision: {}", e.getMessage());
            // Nếu không lấy được thông tin thời tiết, không dừng tưới (an toàn)
            return false;
        }
    }
}
