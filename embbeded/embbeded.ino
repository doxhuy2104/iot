#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFi.h>
#include <Preferences.h>
#include <WebServer.h>
#include <WiFiClient.h>

#define soidMoisPin 34

String ssid = "";
String password = "";

Preferences prefs;
NEW SKETCH

WebServer server(80);

bool isCheckWifi = true;

WiFiClient mqttClient;
PubSubClient client(mqttClient);
unsigned long lastMsg = 0;
const char *mqtt_server = "3a68f76fcff7423cbb9b2b64ccf56eaa.s1.eu.hivemq.cloud";

// void sendHtml() {
//   String html = "<html><body>"
//                 "<form action='/save'>"
//                 "SSID: <input name='ssid'><br>"
//                 "Password: <input name='password'><br>"
//                 "<input type='submit' value='Luu'>"
//                 "</form>"
//                 "</body></html>";
//   server.send(200, "text/html", html);
// }

void handleSave() {
  ssid = server.arg("ssid");
  password = server.arg("password");

  // Lưu vào preferences
  prefs.begin("wifi-config", false);
  prefs.putString("ssid", ssid);
  prefs.putString("password", password);
  prefs.end();
}

void reconnect()
{
  while (!client.connected())
  { 
    Serial.print("MQTT connection...");
    String clientId = "20225331";

    if (client.connect(clientId.c_str()))
    { 
      Serial.println("connected");
    }
    else
    {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void callback(char *topic, byte *payload, unsigned int length)
{
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++)
  {
    Serial.print((char)payload[i]);
  }
  Serial.println();
  StaticJsonDocument<256> doc;
  deserializeJson(doc, payload, length);
  
}


void setup() {
  Serial.begin(115200);

  Serial.println(WiFi.macAddress());

  preferences.begin("config", false);

  ssid     = prefs.getString("ssid", "");
  password = prefs.getString("password", "");
  prefs.end();

  if (ssid == "") {
    //Nếu chưa có cấu hình, thiết lập access point
    WiFi.softAP("Esp32", "00000000");

    Serial.print("IP: ");
    Serial.println(WiFi.softAPIP());
    
    server.on("/", sendHtml);
    server.on("/save", handleSave);
    server.begin();
  } else {

    WiFi.begin(ssid.c_str(), password.c_str());

    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }

    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("\nKet noi thanh cong!");
      Serial.print("IP: ");
      Serial.println(WiFi.localIP());
    }
  }

  client.setServer(mqtt_server, 8883);
  client.setCallback(callback);

}

void loop() {
  server.handleClient();
  delay(2);

  if (!client.connected())
    reconnect();
    client.loop();

  if (isCheckWifi) {
    checkWifi();
  }

}

void checkWifi() {
  if (WiFi.status() != WL_CONNECTED) {
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
    
    isCheckWifi = false;
    Serial.println(WiFi.status());
    // Serial.print("Connected with IP: ");
    // Serial.println(WiFi.localIP());
    isDone = false;

    WiFi.softAP("Esp32", "00000000");

    Serial.print("IP: ");
    Serial.println(WiFi.softAPIP());
    
    // server.on("/", sendHtml);
    // server.on("/save", handleSave);
    server.begin();
  }
}
