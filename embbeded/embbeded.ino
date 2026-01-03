#include <ArduinoJson.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <WebServer.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#define SOIL_PIN 34
#define PUMP_PIN 16

String ssid = "";
String password = "";

Preferences prefs;

WebServer server(80);

bool isCheckWifi = true;

WiFiClientSecure mqttClient;
const char *mqtt_user = "iot20251"; // Thay username của bạn vào đây
const char *mqtt_pass = "IoT20251"; // Thay password của bạn vào đây
PubSubClient client(mqttClient);
unsigned long lastMsg = 0;
const char *mqtt_server = "3a68f76fcff7423cbb9b2b64ccf56eaa.s1.eu.hivemq.cloud";

// void readSoilAndControlPump() {
//   int raw = analogRead(SOIL_PIN);

//   int moisture = map(raw, DRY_VALUE, WET_VALUE, 0, 100);
//   moisture = constrain(moisture, 0, 100);

//   if (!pumpState && moisture < MOISTURE_ON) {
//     pumpState = true;
//     digitalWrite(PUMP_PIN, HIGH);
//     Serial.println("Pump ON");
//   }

//   if (pumpState && moisture > MOISTURE_OFF) {
//     pumpState = false;
//     digitalWrite(PUMP_PIN, LOW);
//     Serial.println("Pump OFF");
//   }

//   Serial.printf("Soil: %d%% | Pump: %s\n",
//                 moisture,
//                 pumpState ? "ON" : "OFF");
// }

void handleWifi() {
  StaticJsonDocument<200> doc;
  if (deserializeJson(doc, server.arg("plain"))) {
    server.send(400, "text/plain", "Invalid JSON");
    return;
  }

  String newSsid = doc["ssid"];
  String newPass = doc["password"];
  newSsid.trim();
  newPass.trim();

  WiFi.disconnect(true);
  delay(500);
  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(newSsid.c_str(), newPass.c_str());

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(300);
  }

  if (WiFi.status() == WL_CONNECTED) {
    prefs.begin("wifi-config", false);
    prefs.putString("ssid", newSsid);
    prefs.putString("password", newPass);
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
    String statusTopic = "device/" + clientId + "/status";

    // connect(clientId, username, password, willTopic, willQoS, willRetain,
    // willMessage)
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass,
                       statusTopic.c_str(), 1, true, "offline")) {
      Serial.println("connected");
      client.publish(statusTopic.c_str(), "online", true);
      String controlTopic = "device/" + clientId + "/control";
      client.subscribe(controlTopic.c_str());
      Serial.print("Subscribed to: ");
      Serial.println(controlTopic);
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

  String clientId = WiFi.macAddress();
  String controlTopic = "device/" + clientId + "/control";

  if (String(topic) == controlTopic) {
    if (message == "on") {
      digitalWrite(PUMP_PIN, HIGH);
      Serial.println("Pump turned ON via MQTT");
    } else if (message == "off") {
      digitalWrite(PUMP_PIN, LOW);
      Serial.println("Pump turned OFF via MQTT");
    } else {
      Serial.println("Unknown command: " + message);
    }
  } else {
    Serial.print("Topic mismatch. Expected: ");
    Serial.println(controlTopic);
  }

  /*
  StaticJsonDocument<256> doc;
  deserializeJson(doc, payload, length);
  */
}

void setup() {
  Serial.begin(115200);
  delay(2000); // Wait for Serial Monitor

  prefs.begin("wifi-config", true);
  // prefs.clear();
  ssid = prefs.getString("ssid", "");
  password = prefs.getString("password", "");

  Serial.print("Stored SSID: ");
  Serial.println(ssid);
  Serial.print("Stored Password: ");
  Serial.println(password);

  prefs.end();

  if (ssid != "") {
    ssid.trim();
    password.trim();

    WiFi.disconnect(true);
    delay(1000);
    WiFi.mode(WIFI_AP_STA);

    Serial.print("Connecting to: ");
    Serial.println(ssid);
    WiFi.begin(ssid.c_str(), password.c_str());
    // WiFi.begin("z9tb", "00000000");

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
      delay(500);
      Serial.print(".");
    }

    if (WiFi.status() == WL_CONNECTED) {
      // wifiState = WIFI_STA;
      Serial.println("\nWifi connected");
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

  mqttClient.setInsecure(); // Bỏ qua kiểm tra chứng chỉ SSL (quan trọng cho
                            // HiveMQ Cloud)
  client.setServer(mqtt_server, 8883);
  client.setCallback(callback);

  pinMode(PUMP_PIN, OUTPUT);
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
  if (millis() - lastRead > 3000) {
    lastRead = millis();
    // readSoilAndControlPump();
  }
}
boolean tryConnectWifi(String ssid, String pass) {
  Serial.println("Attempting to reconnect directly...");
  WiFi.disconnect(true);
  delay(1000);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid.c_str(), pass.c_str());

  unsigned long start = millis();
  while (millis() - start < 60000) { // Try for 1 minute
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
    // Try to reconnect first
    prefs.begin("wifi-config", true);
    String savedSsid = prefs.getString("ssid", "");
    String savedPass = prefs.getString("password", "");
    prefs.end();

    if (savedSsid != "" && tryConnectWifi(savedSsid, savedPass)) {
      return; // Reconnected, exit checkWifi
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
