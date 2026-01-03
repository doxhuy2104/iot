import 'dart:io';

import 'package:app/core/utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient? client;

  Future<void> connect() async {
    String? mqttUrl = dotenv.env['MQTT_URL'];
    if (mqttUrl == null) {
      Utils.debugLog('MQTT_URL not found in .env');
      return;
    }

    // Parse URL (assuming tcp://broker:port)
    final uri = Uri.parse(mqttUrl);
    final server = uri.host;
    final port = uri.port;

    client = MqttServerClient.withPort(
      server,
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      port,
    );
    client!.logging(on: true);
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;
    client!.secure = true;
    client!.securityContext = SecurityContext.defaultContext;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        )
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client!.connectionMessage = connMess;

    try {
      Utils.debugLog('Connecting to MQTT...');
      final username = dotenv.env['MQTT_USERNAME'];
      final password = dotenv.env['MQTT_PASSWORD'];

      if (username != null && password != null) {
        await client!.connect(username, password);
      } else {
        await client!.connect();
      }
    } on NoConnectionException catch (e) {
      Utils.debugLog('MQTT Client exception: $e');
      client!.disconnect();
    } on SocketException catch (e) {
      Utils.debugLog('MQTT Socket exception: $e');
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      Utils.debugLog('MQTT Client Connected');
    } else {
      Utils.debugLog(
        'MQTT Client Connection Failed - Status is ${client!.connectionStatus}',
      );
      client!.disconnect();
    }
  }

  void onConnected() {
    Utils.debugLog('MQTT Connected');
  }

  void onDisconnected() {
    Utils.debugLog('MQTT Disconnected');
    if (client!.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      Utils.debugLog('MQTT Disconnected callback: Solicited disconnect');
    }
  }

  void onSubscribed(String topic) {
    Utils.debugLog('MQTT Subscribed to $topic');
  }

  void subscribe(String topic) {
    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.subscribe(topic, MqttQos.atMostOnce);
    } else {
      Utils.debugLog('MQTT Client not connected, cannot subscribe.');
    }
  }
}
