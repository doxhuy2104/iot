import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { zoneApi } from '../services/api';

export default function Dashboard() {
  const { user } = useAuth();
  const [zones, setZones] = useState([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalZones: 0,
    activeDevices: 0,
    pendingAlerts: 0,
  });

  // Mock weather data (could be replaced with real weather API)
  const weather = {
    temp: 28,
    condition: 'Nắng',
    icon: '☀️',
    location: 'Hà Nội, Việt Nam',
  };

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      const result = await zoneApi.getAll();
      const zonesData = result.data || [];
      setZones(zonesData);
      
      // Calculate stats from zones
      setStats({
        totalZones: zonesData.length,
        activeDevices: zonesData.filter(z => z.pumpStatus).length,
        pendingAlerts: zonesData.filter(z => (z.soilMoisture || 0) < 0.3).length,
      });
    } catch (err) {
      console.error('Failed to load dashboard data:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fade-in">
      {/* Header with weather background */}
      <div style={{
        background: 'linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%)',
        borderRadius: '0 0 var(--radius-xl) var(--radius-xl)',
        padding: 'var(--spacing-lg)',
        color: 'white',
        marginBottom: 'var(--spacing-lg)',
      }}>
        <div className="container">
          {/* Welcome */}
          <div className="flex items-center justify-center gap-sm" style={{ marginBottom: 'var(--spacing-md)' }}>
            <span className="text-sm" style={{ opacity: 0.8 }}>
              Xin chào, {user?.username || 'Người dùng'}
            </span>
          </div>
          <div className="flex items-center justify-center gap-xs" style={{ marginBottom: 'var(--spacing-lg)' }}>
            <span style={{ color: '#ff6b35' }}>📍</span>
            <span className="text-md font-medium">{weather.location}</span>
          </div>

          {/* Weather Card */}
          <div className="card" style={{ 
            background: 'white', 
            color: 'var(--text-primary)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}>
            <div>
              <div className="text-h2 font-bold text-primary">{weather.temp}°C</div>
              <div className="text-content">{weather.condition}</div>
            </div>
            <div style={{ fontSize: '64px' }}>{weather.icon}</div>
          </div>
        </div>
      </div>

      <div className="container">
        {/* Quick Stats */}
        <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Tổng quan</h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(3, 1fr)', 
          gap: 'var(--spacing-md)',
          marginBottom: 'var(--spacing-xl)',
        }}>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}>🌱</div>
            <div className="text-h3 font-bold">
              {loading ? '...' : stats.totalZones}
            </div>
            <div className="text-sm text-content">Khu vực</div>
          </div>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}>💧</div>
            <div className="text-h3 font-bold">
              {loading ? '...' : stats.activeDevices}
            </div>
            <div className="text-sm text-content">Đang tưới</div>
          </div>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}>⚠️</div>
            <div className="text-h3 font-bold text-danger">
              {loading ? '...' : stats.pendingAlerts}
            </div>
            <div className="text-sm text-content">Cảnh báo</div>
          </div>
        </div>

        {/* Quick Actions */}
        <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Thao tác nhanh</h2>
        
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-md)' }}>
          <Link to="/zones" className="card" style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: 'var(--spacing-md)',
            cursor: 'pointer',
          }}>
            <div className="zone-icon" style={{ background: 'var(--accent-green)' }}>🌿</div>
            <div style={{ flex: 1 }}>
              <div className="font-semibold">Quản lý khu vực</div>
              <div className="text-sm text-content">
                {loading ? 'Đang tải...' : `${stats.totalZones} khu vực`}
              </div>
            </div>
            <span className="text-content">→</span>
          </Link>
          
          <Link to="/zones/add" className="card" style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: 'var(--spacing-md)',
            cursor: 'pointer',
          }}>
            <div className="zone-icon" style={{ background: 'var(--accent-blue)' }}>➕</div>
            <div style={{ flex: 1 }}>
              <div className="font-semibold">Thêm khu vực mới</div>
              <div className="text-sm text-content">Kết nối thiết bị và tạo khu vực</div>
            </div>
            <span className="text-content">→</span>
          </Link>

          <Link to="/account" className="card" style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: 'var(--spacing-md)',
            cursor: 'pointer',
          }}>
            <div className="zone-icon" style={{ background: 'var(--accent-yellow)' }}>👤</div>
            <div style={{ flex: 1 }}>
              <div className="font-semibold">Tài khoản</div>
              <div className="text-sm text-content">Quản lý thông tin cá nhân</div>
            </div>
            <span className="text-content">→</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
