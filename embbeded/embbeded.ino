#include <ArduinoJson.h>
#include <FlowSensor.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <WebServer.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>

#define SOIL_PIN 32
#define PUMP_PIN 17
#define RELAY_ON LOW
#define RELAY_OFF HIGH
#define FLOW_PIN 4
#define FLOW_SENSOR_TYPE YFS201

String ssid = "";
String password = "";

String zoneId = "";
int targetHumidity = 0;
int thresholdMin = 0;
int thresholdMax = 100;
bool autoMode = false;
bool weatherMode = false;

// Schedule & Mode Globals
// Schedule & Mode Globals
struct Schedule {
  int hour;
  int minute;
  int duration;
  float volume;
  String repeatDays;
};

#define MAX_SCHEDULES 10
Schedule schedules[MAX_SCHEDULES];
int scheduleCount = 0;

int currentSchedDuration = 0;
float currentSchedVolume = 0;

void saveSchedules() {
  prefs.begin("schedule", false);
  prefs.putInt("count", scheduleCount);
  for (int i = 0; i < scheduleCount; i++) {
    String p = "s" + String(i);
    prefs.putInt((p + "h").c_str(), schedules[i].hour);
    prefs.putInt((p + "m").c_str(), schedules[i].minute);
    prefs.putInt((p + "d").c_str(), schedules[i].duration);
    prefs.putFloat((p + "v").c_str(), schedules[i].volume);
    prefs.putString((p + "days").c_str(), schedules[i].repeatDays);
  }
  prefs.end();
}

void loadSchedules() {
  prefs.begin("schedule", true);
  scheduleCount = prefs.getInt("count", 0);
  if (scheduleCount > MAX_SCHEDULES)
    scheduleCount = MAX_SCHEDULES;

  for (int i = 0; i < scheduleCount; i++) {
    String p = "s" + String(i);
    schedules[i].hour = prefs.getInt((p + "h").c_str(), -1);
    schedules[i].minute = prefs.getInt((p + "m").c_str(), -1);
    schedules[i].duration = prefs.getInt((p + "d").c_str(), 0);
    schedules[i].volume = prefs.getFloat((p + "v").c_str(), 0.0);
    schedules[i].repeatDays = prefs.getString((p + "days").c_str(), "");
  }
  prefs.end();
  Serial.print("Loaded schedules: ");
  Serial.println(scheduleCount);
}

enum RunMode { MODE_NONE, MODE_SCHEDULE, MODE_AUTO, MODE_MANUAL };
RunMode currentMode = MODE_NONE;
RunMode pendingMode = MODE_NONE;
int lastCheckedMinute = -1;

String sessionStartTime = "";
unsigned long pumpStartMillis = 0;
float startVolume = 0;

Preferences prefs;

WebServer server(80);

bool isCheckWifi = true;
bool isReporting = false;

WiFiClientSecure mqttClient;
const char *mqtt_user = "iot20251";
const char *mqtt_pass = "IoT20251";
PubSubClient client(mqttClient);
unsigned long lastMsg = 0;

const char *mqtt_server = "3a68f76fcff7423cbb9b2b64ccf56eaa.s1.eu.hivemq.cloud";

const char *ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 7 * 3600; // GMT+7
const int daylightOffset_sec = 0;

#include <time.h>

FlowSensor flSensor(FLOW_SENSOR_TYPE, FLOW_PIN);
void IRAM_ATTR count() { flSensor.count(); }

String getCurrentTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return "";
  }
  char timeStringBuff[30];
  strftime(timeStringBuff, sizeof(timeStringBuff), "%Y-%m-%dT%H:%M:%S",
           &timeinfo);
  return String(timeStringBuff);
}

void turnPumpOn(String timeStr) {
  if (digitalRead(PUMP_PIN) == RELAY_OFF) {
    digitalWrite(PUMP_PIN, RELAY_ON);
    pumpStartMillis = millis();
    startVolume = flSensor.getVolume();

    if (timeStr != "") {
      sessionStartTime = timeStr;
    } else {
      sessionStartTime = getCurrentTime();
    }

    Serial.println("Pump turned ON. Start time: " + sessionStartTime);
  }
}

void turnPumpOff() {
  if (digitalRead(PUMP_PIN) == RELAY_ON) {
    digitalWrite(PUMP_PIN, RELAY_OFF);
    unsigned long duration = (millis() - pumpStartMillis) / 1000;
    float volumeUsed = flSensor.getVolume() - startVolume;

    StaticJsonDocument<200> logDoc;
    if (sessionStartTime != "") {
      logDoc["startedAt"] = sessionStartTime;
    }
    logDoc["durationSeconds"] = duration;
    logDoc["volume"] = volumeUsed;

    char buffer[200];
    serializeJson(logDoc, buffer);
    String logTopic = "irrigation/log/zone/" + zoneId;
    client.publish(logTopic.c_str(), buffer);

    Serial.println("Pump turned OFF. Log sent: " + String(buffer));

    targetHumidity = 0;
    sessionStartTime = "";
  }
}

void handleWifi() {
  StaticJsonDocument<200> doc;
  if (deserializeJson(doc, server.arg("plain"))) {
    server.send(400, "text/plain", "Invalid JSON");
    return;
  }

  String newSsid = doc["ssid"];
  String newPass = doc["password"];
  String zoneId = doc["zoneId"];

  newSsid.trim();
  newPass.trim();
  zoneId.trim();
  WiFi.disconnect(true);
  delay(500);
  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(newSsid.c_str(), newPass.c_str());

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(300);
  }

  if (WiFi.status() == WL_CONNECTED) {
    prefs.begin("config", false);
    prefs.putString("ssid", newSsid);
    prefs.putString("password", newPass);
    prefs.putString("zoneId", zoneId);

    prefs.end();

    String res =
        "{\"status\":\"success\",\"mac\":\"" + WiFi.macAddress() + "\"}";
    server.send(200, "application/json", res);

    delay(2000);
    ESP.restart();
  } else {
    server.send(500, "application/json", "{\"status\":\"failed\"}");
  }
}

boolean tryConnectWifi(String ssid, String pass);

void reconnect() {
  while (!client.connected()) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println(
          "WiFi lost during MQTT reconnect. Attempting to reconnect...");
      if (!tryConnectWifi(ssid, password)) {
        Serial.println("WiFi reconnect failed. Exiting MQTT reconnect.");
        return;
      }
    }

    Serial.print("MQTT connection...");
    String clientId = WiFi.macAddress();
    String statusTopic = "irrigation/status/zone/" + zoneId;

    // connect(clientId, username, password, willTopic, willQoS, willRetain,
    // willMessage)
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass,
                       statusTopic.c_str(), 1, true, "offline")) {
      Serial.println("connected");
      client.publish(statusTopic.c_str(), "online", true);
      String controlTopic = "irrigation/control/zone/" + zoneId;
      client.subscribe(controlTopic.c_str());
      Serial.print("Subscribed to: ");
      Serial.println(controlTopic);
      String configTopic = "irrigation/config/zone/" + zoneId;
      client.subscribe(configTopic.c_str());

      String schedTopic = "irrigation/schedule/zone/" + zoneId;
      client.subscribe(schedTopic.c_str());

      String canOnTopic = "irrigation/can-on/zone/" + zoneId;
      client.subscribe(canOnTopic.c_str());

      String statusTopic = "irrigation/status/" + zoneId;
      client.subscribe(statusTopic.c_str());
      Serial.print("Subscribed to: ");
      Serial.println(statusTopic);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");

      delay(5000);
    }
  }
}

void callback(char *topic, byte *payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  message.trim();

  // Handle case where some tools send data as JSON string "on" instead of raw
  // on
  if (message.startsWith("\"") && message.endsWith("\"")) {
    message = message.substring(1, message.length() - 1);
  }

  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] Val: [");
  Serial.print(message);
  Serial.println("]");

  String controlTopic = "irrigation/control/zone/" + zoneId;

  if (String(topic) == controlTopic) {
    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, message);

    if (!error) {
      String timeFromApp = "";
      if (doc.containsKey("time")) {
        timeFromApp = doc["time"].as<String>();
      }

      if (doc.containsKey("pump")) {
        String pumpCmd = doc["pump"];
        if (pumpCmd == "on") {
          turnPumpOn(timeFromApp);
          Serial.println("Pump turned ON via MQTT (JSON)");
        } else if (pumpCmd == "off") {
          turnPumpOff();
          Serial.println("Pump turned OFF via MQTT (JSON)");
        }
      }
      if (doc.containsKey("targetHumidity")) {
        targetHumidity = doc["targetHumidity"];
        Serial.print("Target Humidity set to: ");
        Serial.println(targetHumidity);
      }
    } else {
      if (message == "on") {
        turnPumpOn("");
        Serial.println("Pump turned ON via MQTT");
      } else if (message == "off") {
        turnPumpOff();
        Serial.println("Pump turned OFF via MQTT");
      } else {
        Serial.println("Unknown command: " + message);
      }
    }
  }

  String statusTopic = "irrigation/status/" + zoneId;
  if (String(topic) == statusTopic) {
    if (message == "online") {
      isReporting = true;
      Serial.println("Reporting enabled");
    } else if (message == "offline") {
      isReporting = false;
      Serial.println("Reporting disabled");
    }
  }

  String configTopic = "irrigation/config/zone/" + zoneId;
  if (String(topic) == configTopic) {
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, message);
    if (!error) {
      if (doc.containsKey("thresholdMin"))
        thresholdMin = doc["thresholdMin"];
      if (doc.containsKey("thresholdMax"))
        thresholdMax = doc["thresholdMax"];
      if (doc.containsKey("autoMode"))
        autoMode = doc["autoMode"];
      if (doc.containsKey("weatherMode"))
        weatherMode = doc["weatherMode"];

      prefs.begin("config", false);
      prefs.putInt("threshMin", thresholdMin);
      prefs.putInt("threshMax", thresholdMax);
      prefs.putBool("autoMode", autoMode);
      prefs.putBool("weatherMode", weatherMode);
      prefs.end();

      Serial.println("Config Updated & Saved:");
      Serial.printf("Min: %d, Max: %d, Auto: %d, Weather: %d\n", thresholdMin,
                    thresholdMax, autoMode, weatherMode);
    } else {
      Serial.println("Failed to parse config JSON");
    }
  }

  String scheduleTopic = "irrigation/schedule/zone/" + zoneId;
  if (String(topic) == scheduleTopic) {
    DynamicJsonDocument doc(2048);
    DeserializationError error = deserializeJson(doc, message);

    if (!error && doc.is<JsonArray>()) {
      JsonArray arr = doc.as<JsonArray>();
      scheduleCount = 0;
      for (JsonObject obj : arr) {
        if (scheduleCount >= MAX_SCHEDULES)
          break;

        String sTime = obj["startTime"];
        int h = 0, m = 0;
        int cIdx = sTime.indexOf(':');
        if (cIdx != -1) {
          h = sTime.substring(0, cIdx).toInt();
          m = sTime.substring(cIdx + 1).toInt();
        }

        schedules[scheduleCount].hour = h;
        schedules[scheduleCount].minute = m;
        schedules[scheduleCount].duration = obj["duration"];
        schedules[scheduleCount].volume = obj["volume"];
        schedules[scheduleCount].repeatDays = obj["repeatDays"].as<String>();
        scheduleCount++;
      }
      saveSchedules();
      Serial.printf("Saved %d schedules\n", scheduleCount);
    } else {
      Serial.println("Failed to parse schedule Array");
    }
  }

  String canOnTopic = "irrigation/can-on/zone/" + zoneId;
  if (String(topic) == canOnTopic) {
    if (message == "true") {
      turnPumpOn("");
      if (pendingMode != MODE_NONE) {
        currentMode = pendingMode;
        pendingMode = MODE_NONE;
      } else {
        currentMode = MODE_MANUAL;
      }
      Serial.println("Permission Granted. Pump ON. Mode: " +
                     String(currentMode));
    } else {
      pendingMode = MODE_NONE;
      Serial.println("Permission Denied.");
    }
  }

  /*
  StaticJsonDocument<256> doc;
  deserializeJson(doc, payload, length);
  */
}

void setup() {
  Serial.begin(115200);
  Serial.println("\nSystem Starting...");
  delay(2000);
  pinMode(PUMP_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, HIGH);

  prefs.begin("config", true);
  // prefs.clear();
  ssid = prefs.getString("ssid", "");
  password = prefs.getString("password", "");
  zoneId = prefs.getString("zoneId", "");

  thresholdMin = prefs.getInt("threshMin", 0);
  thresholdMax = prefs.getInt("threshMax", 100);
  autoMode = prefs.getBool("autoMode", false);
  weatherMode = prefs.getBool("weatherMode", false);

  Serial.print("Stored SSID: ");
  Serial.println(ssid);
  Serial.print("Stored Password: ");
  Serial.println(password);
  Serial.print("Stored Zone ID: ");
  Serial.println(zoneId);

  prefs.end();

  loadSchedules();

  if (ssid != "") {
    ssid.trim();
    password.trim();

    WiFi.disconnect(true);
    delay(1000);
    WiFi.mode(WIFI_AP_STA);

    Serial.print("Connecting to: ");
    Serial.println(ssid);
    WiFi.begin(ssid.c_str(), password.c_str());
    // WiFi.begin("PHONG 1906", "phongyenlinhnam100106");

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
      delay(500);
      Serial.print(".");
    }

    if (WiFi.status() == WL_CONNECTED) {
      // wifiState = WIFI_STA;
      Serial.println("\nWifi connected");
      configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
    } else {
      Serial.println("\nConnect failed, switching to AP");
      WiFi.softAP("ESP32", "00000000");
      // wifiState = WIFI_AP;
    }
  } else {
    WiFi.softAP("ESP32", "00000000");
    // wifiState = WIFI_AP;
  }

  server.on("/wifi", HTTP_POST, handleWifi);
  server.begin();

  mqttClient.setInsecure();
  client.setServer(mqtt_server, 8883);
  client.setCallback(callback);

  pinMode(PUMP_PIN, OUTPUT);
  flSensor.begin(count);
}

void loop() {
  static unsigned long lastRead = 0;
  static unsigned long lastWifiCheck = 0;
  server.handleClient();
  if (millis() - lastWifiCheck > 1000) {
    lastWifiCheck = millis();
    checkWifi();
  }

  if (
      // wifiState == WIFI_STA &&
      WiFi.status() == WL_CONNECTED) {
    if (!client.connected())
      reconnect();
    client.loop();
  }
  if (millis() - lastRead > 1000) {
    lastRead = millis();

    int soilValue = analogRead(SOIL_PIN);
    bool isPumpOn = digitalRead(PUMP_PIN) == RELAY_ON;
    flSensor.read();
    float flowRate = flSensor.getFlowRate_m();
    float totalVolume = flSensor.getVolume();

    int humidityPercent = map(soilValue, 4095, 0, 0, 100);
    humidityPercent = constrain(humidityPercent, 0, 100);

    // Schedule Check
    struct tm timeinfo;
    if (getLocalTime(&timeinfo)) {
      if (timeinfo.tm_min != lastCheckedMinute) {
        lastCheckedMinute = timeinfo.tm_min;

        for (int i = 0; i < scheduleCount; i++) {
          if (schedules[i].hour == timeinfo.tm_hour &&
              schedules[i].minute == timeinfo.tm_min) {
            String days[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
            if (schedules[i].repeatDays.indexOf(days[timeinfo.tm_wday]) != -1) {
              if (digitalRead(PUMP_PIN) == RELAY_OFF &&
                  pendingMode == MODE_NONE) {
                Serial.printf("Schedule #%d Match. Requesting permission...\n",
                              i);

                // Store run limits for this schedule
                currentSchedDuration = schedules[i].duration;
                currentSchedVolume = schedules[i].volume;

                pendingMode = MODE_SCHEDULE;
                String checkTopic = "irrigation/check-weather/zone/" + zoneId;
                client.publish(checkTopic.c_str(), "check");

                // Only trigger one schedule per minute
                break;
              }
            }
          }
        }
      }
    }

    if (autoMode) {
      if (humidityPercent < thresholdMin) {
        if (digitalRead(PUMP_PIN) == RELAY_OFF && pendingMode == MODE_NONE) {
          if (weatherMode) {
            Serial.println("Auto + Weather. Requesting permission...");
            pendingMode = MODE_AUTO;
            String checkTopic = "irrigation/check-weather/zone/" + zoneId;
            client.publish(checkTopic.c_str(), "check");
          } else {
            Serial.println("Auto Mode (No Weather). Pump ON.");
            turnPumpOn("");
            currentMode = MODE_AUTO;
          }
        }
      } else if (humidityPercent >= thresholdMax) {
        if (digitalRead(PUMP_PIN) == RELAY_ON && currentMode == MODE_AUTO) {
          turnPumpOff();
          currentMode = MODE_NONE;
          Serial.println("AutoMode: Max humidity reached. Pump OFF.");
        }
      }
    }

    // Stop Logic for Schedule
    if (isPumpOn && currentMode == MODE_SCHEDULE) {
      unsigned long runSeconds = (millis() - pumpStartMillis) / 1000;
      float volumeUsed = flSensor.getVolume() - startVolume;
      if (runSeconds >= currentSchedDuration ||
          volumeUsed >= currentSchedVolume) {
        turnPumpOff();
        currentMode = MODE_NONE;
        Serial.println("Schedule Complete (Limit Reached). Pump OFF.");
      }
    }

    if (targetHumidity > 0 && humidityPercent >= targetHumidity) {
      if (digitalRead(PUMP_PIN) == RELAY_ON &&
          currentMode == MODE_MANUAL) { // Only stop if Manual? Or Generic?
        turnPumpOff();
        currentMode = MODE_NONE;
        Serial.println("Target humidity reached. Pump turned OFF.");
      }
    }

    isPumpOn = digitalRead(PUMP_PIN) == RELAY_ON;

    if (isReporting) {

      StaticJsonDocument<200> doc;
      doc["humidity"] = humidityPercent;
      doc["flowRate"] = flowRate;
      doc["volume"] = totalVolume;

      doc["pump"] = isPumpOn ? "on" : "off";

      char buffer[200];
      serializeJson(doc, buffer);

      String sensorTopic = "irrigation/sensor/zone/" + zoneId;
      client.publish(sensorTopic.c_str(), buffer);
      // Serial.print("Published sensor data: ");
      // Serial.println(buffer);
    }
  }
}
boolean tryConnectWifi(String ssid, String pass) {
  Serial.println("Attempting to reconnect directly...");
  WiFi.disconnect(true);
  delay(1000);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid.c_str(), pass.c_str());

  unsigned long start = millis();
  while (millis() - start < 60000) {
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("\nReconnected successfully!");
      return true;
    }
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nReconnect failed.");
  return false;
}

void checkWifi() {
  if (WiFi.status() != WL_CONNECTED && isCheckWifi) {
    prefs.begin("config", true);
    String savedSsid = prefs.getString("ssid", "");
    String savedPass = prefs.getString("password", "");
    prefs.end();

    if (savedSsid != "" && tryConnectWifi(savedSsid, savedPass)) {
      return;
    }

    Serial.println("Lost WiFi connection. Switching to AP mode: ESP32");
    WiFi.disconnect();
    WiFi.mode(WIFI_AP);
    WiFi.softAP("ESP32", "00000000");

    Serial.print("AP IP address: ");
    Serial.println(WiFi.softAPIP());

    server.begin();
    isCheckWifi = false;
  }
}
