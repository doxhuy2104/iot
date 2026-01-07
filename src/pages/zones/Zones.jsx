import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { zoneApi } from '../../services/api';
import { useMqtt } from '../../hooks/useMqtt';
import { PiPottedPlantFill } from "react-icons/pi";
import { FaLocationArrow } from "react-icons/fa";
import { FaDroplet } from "react-icons/fa6";

function ZoneCard({ zone }) {
  // MQTT real-time data
  const { isConnected: mqttConnected, sensorData: mqttSensorData, isDeviceOnline: mqttDeviceOnline } = useMqtt(zone.id || zone.zoneId);

  // Default values for missing data, prioritize MQTT
  const apiMoisture = zone.soilMoisture ? Math.round(zone.soilMoisture * 100) : 0;
  
  // Use MQTT humidity if available (already in %), else API moisture
  const moisturePercent = mqttSensorData?.humidity != null 
    ? Math.round(mqttSensorData.humidity) 
    : apiMoisture;
    
  const accent = zone.accent || '#7FC8A9';
  
  // Pump status from MQTT or API
  const isPumpOn = mqttSensorData?.pump != null 
    ? mqttSensorData.pump === 'on' 
    : zone.pumpStatus;
  
  return (
    <div className="card fade-in">
      {/* Header */}
      <div className="card-header">
        <div className="zone-icon" style={{ background: accent }}>
          <FaLocationArrow />
        </div>
        <div style={{ flex: 1 }}>
          <div className="font-semibold text-lg">{zone.zoneName || zone.name || 'Khu vực'}</div>
          <div className="text-content text-sm">
            {zone.location || 'Chưa có vị trí'}
            {mqttConnected && <span className="text-success" style={{ fontSize: '10px', marginLeft: '6px' }}>● Live</span>}
          </div>
        </div>
        <span style={{ color: isPumpOn ? 'var(--primary)' : 'var(--text-secondary)' }}>
          {isPumpOn ? '💧' : ''}
        </span>
      </div>

      {/* Moisture Metric */}
      <div className="metric-tile">
        <div className="metric-label">Độ ẩm đất</div>
        <div className="metric-value">{moisturePercent}%</div>
        <div className="progress-bar">
          <div 
            className="progress-bar-fill" 
            style={{ width: `${moisturePercent}%` }}
          />
        </div>
      </div>

      {/* Footer with info */}
      <div className="flex items-center gap-md" style={{ marginTop: 'var(--spacing-md)' }}>
        <div className="chip chip-success">
          <span className="chip-icon">⚙️</span>
          {zone.autoMode ? 'Tự động' : 'Thủ công'}
        </div>
        <div className={`chip ${isPumpOn ? 'chip-success' : ''}`}>
          <span className="chip-icon"><FaDroplet /></span>
          {isPumpOn ? 'Đang tưới' : 'Tắt'}
        </div>
        <div style={{ flex: 1 }} />
        <Link 
          to={`/zones/${zone.id || zone.zoneId}`} 
          className="text-primary font-semibold"
          style={{ cursor: 'pointer' }}
        >
          Chi tiết
        </Link>
      </div>
    </div>
  );
}

export default function Zones() {
  const [zones, setZones] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadZones();
  }, []);

  const loadZones = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await zoneApi.getAll();
      console.log('Zones loaded:', result);
      setZones(result.data || []);
    } catch (err) {
      console.error('Failed to load zones:', err);
      setError(err.message || 'Không thể tải danh sách khu vực');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex justify-between items-center">
          <h1 className="navbar-title">Khu vực</h1>
          <Link to="/zones/add" className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ➕
          </Link>
        </div>
      </div>

      {/* Zone List */}
      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div className="text-lg">Đang tải...</div>
          </div>
        ) : error ? (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}>⚠️</div>
            <h3 className="text-h3 text-danger">{error}</h3>
            <button onClick={loadZones} className="btn btn-primary" style={{ marginTop: 'var(--spacing-lg)' }}>
              Thử lại
            </button>
          </div>
        ) : zones.length > 0 ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-md)' }}>
            {zones.map(zone => (
              <ZoneCard key={zone.id || zone.zoneId} zone={zone} />
            ))}
          </div>
        ) : (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}><PiPottedPlantFill className="text-2xl" /></div>
            <h3 className="text-h3">Chưa có khu vực nào</h3>
            <p className="text-content" style={{ marginBottom: 'var(--spacing-lg)' }}>
              Thêm khu vực đầu tiên để bắt đầu quản lý hệ thống tưới
            </p>
            <Link to="/zones/add" className="btn btn-primary">
              Thêm khu vực
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
