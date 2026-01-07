package com.iot.smartwatering.smart_watering_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
// @EnableScheduling
public class SmartWateringBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(SmartWateringBackendApplication.class, args);
	}

}
