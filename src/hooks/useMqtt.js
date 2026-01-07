import { useEffect, useRef, useState, useCallback } from 'react';
import mqtt from 'mqtt';

// MQTT Configuration - use environment variables or defaults
const MQTT_BROKER_URL = import.meta.env.VITE_MQTT_URL || 'wss://broker.hivemq.com:8884/mqtt';
const MQTT_USERNAME = import.meta.env.VITE_MQTT_USERNAME || '';
const MQTT_PASSWORD = import.meta.env.VITE_MQTT_PASSWORD || '';

/**
 * Custom hook for MQTT connection and subscription
 * Provides real-time sensor data and device status like Flutter app
 */
export function useMqtt(zoneId) {
  const clientRef = useRef(null);
  const [isConnected, setIsConnected] = useState(false);
  const [sensorData, setSensorData] = useState({
    humidity: null,
    flowRate: 0,
    volume: 0,
    pump: null,
  });
  const [isDeviceOnline, setIsDeviceOnline] = useState(null);

  const connect = useCallback(() => {
    if (clientRef.current) return;

    console.log('Connecting to MQTT broker:', MQTT_BROKER_URL);
    console.log('Using credentials:', MQTT_USERNAME ? 'Yes' : 'No');
    
    const options = {
      clientId: `web_client_${Date.now()}`,
      clean: true,
      reconnectPeriod: 5000,
      connectTimeout: 30 * 1000,
    };

    if (MQTT_USERNAME && MQTT_PASSWORD) {
      options.username = MQTT_USERNAME;
      options.password = MQTT_PASSWORD;
    }

    const client = mqtt.connect(MQTT_BROKER_URL, options);
    clientRef.current = client;

    client.on('connect', () => {
      console.log('MQTT Connected!');
      setIsConnected(true);

      // Subscribe to sensor data topic
      const sensorTopic = `irrigation/sensor/zone/${zoneId}`;
      const statusTopic = `irrigation/status/zone/${zoneId}`;
      
      client.subscribe(sensorTopic, (err) => {
        if (err) {
          console.error('Failed to subscribe to sensor topic:', err);
        } else {
          console.log('Subscribed to:', sensorTopic);
        }
      });

      client.subscribe(statusTopic, (err) => {
        if (err) {
          console.error('Failed to subscribe to status topic:', err);
        } else {
          console.log('Subscribed to:', statusTopic);
        }
      });
    });

    client.on('message', (topic, message) => {
      const payload = message.toString();
      console.log('MQTT Message:', topic, payload);

      // Handle device status
      if (topic === `irrigation/status/zone/${zoneId}`) {
        setIsDeviceOnline(payload !== 'offline');
      }

      // Handle sensor data
      if (topic === `irrigation/sensor/zone/${zoneId}`) {
        try {
          const data = JSON.parse(payload);
          setSensorData(prev => ({
            humidity: data.humidity ?? prev.humidity,
            flowRate: data.flowRate ?? prev.flowRate,
            volume: data.volume ?? prev.volume,
            pump: data.pump ?? prev.pump,
          }));
        } catch (e) {
          console.error('Failed to parse sensor data:', e);
        }
      }
    });

    client.on('error', (err) => {
      console.error('MQTT Error:', err);
    });

    client.on('offline', () => {
      console.log('MQTT Offline');
      setIsConnected(false);
    });

    client.on('reconnect', () => {
      console.log('MQTT Reconnecting...');
    });
  }, [zoneId]);

  const disconnect = useCallback(() => {
    if (clientRef.current) {
      clientRef.current.end();
      clientRef.current = null;
      setIsConnected(false);
    }
  }, []);

  useEffect(() => {
    connect();
    return () => disconnect();
  }, [connect, disconnect]);

  return {
    isConnected,
    sensorData,
    isDeviceOnline,
    reconnect: connect,
  };
}

export default useMqtt;
