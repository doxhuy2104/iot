import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { zoneApi, sensorApi } from '../../services/api';

export default function ZoneDetail() {
  const { id } = useParams();
  const [zone, setZone] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [pumpLoading, setPumpLoading] = useState(false);

  useEffect(() => {
    loadZone();
  }, [id]);

  const loadZone = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await zoneApi.getById(id);
      console.log('Zone loaded:', result);
      setZone(result.data);
    } catch (err) {
      console.error('Failed to load zone:', err);
      setError(err.message || 'Không thể tải thông tin khu vực');
    } finally {
      setLoading(false);
    }
  };

  const togglePump = async () => {
    if (!zone) return;
    
    try {
      setPumpLoading(true);
      await zoneApi.togglePump(id, !zone.pumpStatus);
      setZone({ ...zone, pumpStatus: !zone.pumpStatus });
    } catch (err) {
      console.error('Failed to toggle pump:', err);
      alert('Không thể điều khiển bơm: ' + err.message);
    } finally {
      setPumpLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="fade-in">
        <div className="navbar">
          <div className="container flex items-center gap-md">
            <Link to="/zones" className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
              ←
            </Link>
            <h1 className="navbar-title">Đang tải...</h1>
          </div>
        </div>
        <div style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
          <div className="text-lg">Đang tải thông tin khu vực...</div>
        </div>
      </div>
    );
  }

  if (error || !zone) {
    return (
      <div className="fade-in">
        <div className="navbar">
          <div className="container flex items-center gap-md">
            <Link to="/zones" className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
              ←
            </Link>
            <h1 className="navbar-title">Lỗi</h1>
          </div>
        </div>
        <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}>⚠️</div>
            <h3 className="text-h3 text-danger">{error || 'Không tìm thấy khu vực'}</h3>
            <Link to="/zones" className="btn btn-primary" style={{ marginTop: 'var(--spacing-lg)' }}>
              Quay lại
            </Link>
          </div>
        </div>
      </div>
    );
  }

  const moisturePercent = zone.soilMoisture ? Math.round(zone.soilMoisture * 100) : 0;

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to="/zones" className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title">{zone.zoneName || zone.name}</h1>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {/* Location Info */}
        <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
          <div className="flex items-center gap-md">
            <div className="zone-icon" style={{ background: '#7FC8A9' }}>📍</div>
            <div>
              <div className="font-semibold">{zone.location || 'Chưa có vị trí'}</div>
              <div className="text-sm text-content">{zone.description || 'Chưa có mô tả'}</div>
            </div>
          </div>
        </div>

        {/* Sensor Data */}
        <h3 className="text-h3" style={{ margin: 'var(--spacing-lg) 0 var(--spacing-md)' }}>
          Dữ liệu cảm biến
        </h3>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(2, 1fr)', 
          gap: 'var(--spacing-md)',
          marginBottom: 'var(--spacing-lg)',
        }}>
          <div className="card">
            <div className="text-content text-sm">Độ ẩm đất</div>
            <div className="text-h2 font-bold text-primary">{moisturePercent}%</div>
            <div className="progress-bar" style={{ marginTop: 'var(--spacing-sm)' }}>
              <div className="progress-bar-fill" style={{ width: `${moisturePercent}%` }} />
            </div>
          </div>
          
          <div className="card">
            <div className="text-content text-sm">Ngưỡng tưới</div>
            <div className="text-h2 font-bold" style={{ color: '#FFC857' }}>{zone.thresholdValue || 30}%</div>
          </div>
          
          <div className="card">
            <div className="text-content text-sm">Chế độ</div>
            <div className="text-h2 font-bold" style={{ color: zone.autoMode ? 'var(--primary)' : '#6CA0DC' }}>
              {zone.autoMode ? 'Tự động' : 'Thủ công'}
            </div>
          </div>
          
          <div className="card">
            <div className="text-content text-sm">Thời tiết</div>
            <div className="text-h2 font-bold">{zone.weatherMode ? 'BẬT' : 'TẮT'}</div>
          </div>
        </div>

        {/* Pump Control */}
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>
          Điều khiển bơm
        </h3>
        
        <div className="card">
          <div className="flex justify-between items-center">
            <div>
              <div className="font-semibold">Trạng thái bơm</div>
              <div className="text-sm text-content">
                {zone.pumpStatus ? 'Đang bật' : 'Đang tắt'}
              </div>
            </div>
            <button
              onClick={togglePump}
              disabled={pumpLoading}
              className="btn"
              style={{
                background: zone.pumpStatus ? 'var(--primary)' : 'var(--background)',
                color: zone.pumpStatus ? 'white' : 'var(--text-primary)',
                border: zone.pumpStatus ? 'none' : '1px solid var(--border-color)',
              }}
            >
              {pumpLoading ? '...' : zone.pumpStatus ? '💧 BẬT' : '🔘 TẮT'}
            </button>
          </div>
        </div>

        {/* Zone Info */}
        <div style={{ marginTop: 'var(--spacing-lg)', textAlign: 'center' }}>
          <p className="text-sm text-content">
            Zone ID: {zone.id || zone.zoneId} | 
            Tạo lúc: {zone.createdAt ? new Date(zone.createdAt).toLocaleDateString('vi-VN') : 'N/A'}
          </p>
        </div>
      </div>
    </div>
  );
}
