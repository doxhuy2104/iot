#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFi.h>
#include <Preferences.h>
#include <BLEServer.h>
#include <BLEDevice.h>
#include <BLEUtils.h>


//Bluetooth
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

String WIFI_SSID = "";
String WIFI_PASSWORD = "";

Preferences preferences;

bool isCheckWifi = true;

//CallBacks function of bluetooth
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();
    if (value.length() > 0) {
      String received = "";
      for (int i = 0; i < value.length(); i++) {
        received += value[i];
      }
      Serial.print("received: ");
      Serial.println(received);
      if (value[0] == 'n') {
        for (int i = 1; i < value.length(); i++) {
          WIFI_SSID += value[i];
        }
        Serial.print("WIFI_SSID: ");
        Serial.println(WIFI_SSID);
        preferences.putString("ssid", WIFI_SSID);
      } else if (value[0] == 'p') {
        for (int i = 1; i < value.length(); i++) {
          WIFI_PASSWORD += value[i];
        }
        Serial.print("WIFI_PASSWORD: ");
        Serial.println(WIFI_PASSWORD);
        WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
        preferences.putString("password", WIFI_PASSWORD);
        Serial.print("Connecting to Wi-Fi");
        int count = 0;
        while (WiFi.status() != WL_CONNECTED) {
          Serial.print(".");
          delay(500);
          count++;
          if (count >= 18) {
            WiFi.disconnect(true);
            pCharacteristic->setValue("WIFI_FAILED");
            pCharacteristic->notify();
            WIFI_SSID.clear();
            WIFI_PASSWORD.clear();
            preferences.putString("ssid", "");
            preferences.putString("password", "");
            return;
          }
        }
        Serial.println();
        Serial.print("Connected with IP: ");
        Serial.println(WiFi.localIP());
        Serial.println();
        pCharacteristic->setValue("Connected");
        pCharacteristic->notify();
      } else if (value[0] == 'u') {
        for (int i = 1; i < value.length(); i++) {
          uid += value[i];
        }
        Serial.print("uid: ");
        Serial.println(uid);
        preferences.putString("uid", uid);
        pCharacteristic->setValue("Done");
        pCharacteristic->notify();
        isDone = true;
      }
      //  else if (value[0] == '-') {
      //   for (int i = 0; i < value.length(); i++) {
      //     id += value[i];
      //   }
      //   Serial.print("id: ");
      //   Serial.println(id);
      //   preferences.putString("id", id);

      //   pCharacteristic->setValue("Done");
      //   pCharacteristic->notify();
      //   BLEDevice::deinit(true);
      //   isDone = true;
      // }
    }
  }
};

class MyCallbacks2 : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();
    if (value.length() > 0) {
      String received = "";
      for (int i = 0; i < value.length(); i++) {
        received += value[i];
      }
      Serial.print("received: ");
      Serial.println(received);
      if (value[0] == 'n') {
        for (int i = 1; i < value.length(); i++) {
          WIFI_SSID += value[i];
        }
        Serial.print("WIFI_SSID: ");
        Serial.println(WIFI_SSID);
        preferences.putString("ssid", WIFI_SSID);
      } else if (value[0] == 'p') {
        for (int i = 1; i < value.length(); i++) {
          WIFI_PASSWORD += value[i];
        }
        Serial.print("WIFI_PASSWORD: ");
        Serial.println(WIFI_PASSWORD);
        WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
        preferences.putString("password", WIFI_PASSWORD);
        Serial.print("Connecting to Wi-Fi");
        int count = 0;
        while (WiFi.status() != WL_CONNECTED) {
          Serial.print(".");
          delay(500);
          count++;
          if (count >= 18) {
            WiFi.disconnect(true);
            pCharacteristic->setValue("WIFI_FAILED");
            pCharacteristic->notify();
            WIFI_SSID.clear();
            WIFI_PASSWORD.clear();
            preferences.putString("ssid", "");
            preferences.putString("password", "");
            return;
          }
        }
        Serial.println();
        Serial.print("Connected with IP: ");
        Serial.println(WiFi.localIP());
        Serial.println();
        pCharacteristic->setValue("Connected");
        pCharacteristic->notify();
        isCheckWifi = true;
      }
    }
  }
};


void setup() {
  Serial.begin(115200);

  Serial.println(WiFi.macAddress());

  preferences.begin("config", false);

  WIFI_SSID = preferences.getString("ssid", "");
  WIFI_PASSWORD = preferences.getString("password", "");

  if (WIFI_SSID != "" && WIFI_PASSWORD != "") {
    Serial.println("Khôi phục thông tin từ bộ nhớ:");
    Serial.print("SSID: ");
    Serial.println(WIFI_SSID);
    Serial.print("Password: ");
    Serial.println(WIFI_PASSWORD);

    // Kết nối WiFi với thông tin đã lưu
    WiFi.begin(WIFI_SSID.c_str(), WIFI_PASSWORD.c_str());
    Serial.print("Connecting to Wi-Fi");
    int count = 0;
    while (WiFi.status() != WL_CONNECTED) {
      Serial.print(".");
      delay(500);
      count++;
      // if (count >= 18) {
      //   Serial.println("Kết nối WiFi thất bại, chờ thông tin mới");
      //   WiFi.disconnect(true);
      //   // Xóa thông tin đã lưu để yêu cầu nhập lại
      //   preferences.putString("ssid", "");
      //   preferences.putString("password", "");
      //   preferences.putString("uid", "");
      //   preferences.putString("id", "");
      //   WIFI_SSID.clear();
      //   WIFI_PASSWORD.clear();
      //   uid.clear();
      //   id.clear();
      //   break;
      // }
    }
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println();
      Serial.print("Connected with IP: ");
      Serial.println(WiFi.localIP());
      isDone = true;
    }
  } else {
    Serial.println("Không tìm thấy thông tin đầy đủ trong bộ nhớ");
  }

 if (WIFI_SSID == "" && WIFI_PASSWORD == "") {
    //bluetooth
    BLEDevice::init("My Lock");
    BLEAddress bleAddress = BLEDevice::getAddress();
    id = bleAddress.toString();
    id.toUpperCase();
    preferences.putString("id", id);
    BLEServer *pServer = BLEDevice::createServer();

    BLEService *pService = pServer->createService(SERVICE_UUID);

    BLECharacteristic *pCharacteristic =
      pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

    pCharacteristic->setCallbacks(new MyCallbacks());

    pCharacteristic->setValue("Hello World");
    pService->start();

    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();


    // pinMode(RELAY_PIN, OUTPUT);
    // digitalWrite(RELAY_PIN, HIGH);


    while (!isDone) {
      delay(100);
    }
    delay(5000);
    BLEDevice::deinit(true);
  }
}

void loop() {
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


    BLEDevice::init("My Lock");
    BLEAddress bleAddress = BLEDevice::getAddress();
    Serial.println(bleAddress.toString());

    BLEServer *pServer = BLEDevice::createServer();

    BLEService *pService = pServer->createService(SERVICE_UUID);

    BLECharacteristic *pCharacteristic =
      pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

    pCharacteristic->setCallbacks(new MyCallbacks2());

    pCharacteristic->setValue("Hello World");
    pService->start();

    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();

    WiFi.begin(WIFI_SSID.c_str(), WIFI_PASSWORD.c_str());
    Serial.print("Connecting to Wi-Fi");
    while(WiFi.status() != WL_CONNECTED){
      readRFID();
      enterPIN();
    }
    delay(2000);
    BLEDevice::deinit();
  }
}
