import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { zoneApi } from '../../services/api';

function ZoneCard({ zone }) {
  // Default values for missing data
  const moisturePercent = zone.soilMoisture ? Math.round(zone.soilMoisture * 100) : 0;
  const accent = zone.accent || '#7FC8A9';
  
  return (
    <div className="card fade-in">
      {/* Header */}
      <div className="card-header">
        <div className="zone-icon" style={{ background: accent }}>
          📍
        </div>
        <div style={{ flex: 1 }}>
          <div className="font-semibold text-lg">{zone.zoneName || zone.name || 'Khu vực'}</div>
          <div className="text-content text-sm">{zone.location || 'Chưa có vị trí'}</div>
        </div>
        <span style={{ color: zone.pumpStatus ? 'var(--primary)' : 'var(--text-secondary)' }}>
          {zone.pumpStatus ? '💧' : '💨'}
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
        <div className={`chip ${zone.pumpStatus ? 'chip-success' : ''}`}>
          <span className="chip-icon">💧</span>
          {zone.pumpStatus ? 'Đang tưới' : 'Tắt'}
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
            <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}>🌱</div>
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
