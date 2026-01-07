import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { dashboardApi, weatherApi, zoneApi } from '../services/api';
import { PiPottedPlantFill } from "react-icons/pi";
import { SiTicktick } from "react-icons/si";
import { MdDevices } from "react-icons/md";
import { TiWarning } from "react-icons/ti";
import { WiHumidity } from "react-icons/wi";
import { FaWind } from "react-icons/fa";
import { FaLocationArrow } from "react-icons/fa";
import { FaUser } from "react-icons/fa";

export default function Dashboard() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalZones: 0,
    totalDevices: 0,
    onlineDevices: 0,
    unhandledAlerts: 0,
  });
  const [weather, setWeather] = useState(null);
  const [weatherError, setWeatherError] = useState(null);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      
      // Always load zones first for accurate user-specific count
      let zonesData = [];
      try {
        const zonesResult = await zoneApi.getAll();
        zonesData = zonesResult.data || [];
      } catch (err) {
        console.error('Failed to load zones:', err);
      }
      
      // Try to load dashboard stats for device info
      let deviceStats = { totalDevices: 0, onlineDevices: 0, unhandledAlerts: 0 };
      try {
        const statsResult = await dashboardApi.getStats();
        console.log('Dashboard stats:', statsResult);
        if (statsResult.data) {
          deviceStats = statsResult.data;
        }
      } catch (err) {
        console.error('Failed to load dashboard stats:', err);
      }
      
      // Combine: use zones API for zone count (accurate per user), dashboard for rest
      setStats({
        totalZones: zonesData.length, // Use zones API count (user-specific)
        totalDevices: deviceStats.totalDevices || zonesData.length,
        onlineDevices: deviceStats.onlineDevices || zonesData.filter(z => z.pumpStatus).length,
        unhandledAlerts: deviceStats.unhandledAlerts || 0,
      });
      
      // Load weather based on user's current location
      await loadWeather();
      
    } finally {
      setLoading(false);
    }
  };

  const loadWeather = async () => {
    // Try to get user's current location
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        async (position) => {
          // Use coordinates for weather (format: "lat,long")
          const location = `${position.coords.latitude},${position.coords.longitude}`;
          console.log('User location:', location);
          await fetchWeather(location);
        },
        async (error) => {
          console.log('Geolocation denied, using default:', error.message);
          // Fallback to Hanoi if location denied
          await fetchWeather('Hanoi, Vietnam');
        },
        { timeout: 5000 }
      );
    } else {
      // Browser doesn't support geolocation
      await fetchWeather('Hanoi, Vietnam');
    }
  };

  const fetchWeather = async (location) => {
    try {
      const weatherResult = await weatherApi.getCurrent(location);
      console.log('Weather:', weatherResult);
      if (weatherResult.data) {
        setWeather(weatherResult.data);
      }
    } catch (err) {
      console.error('Failed to load weather:', err);
      setWeatherError('Không thể tải thời tiết');
    }
  };

  // Format weather icon URL
  const getWeatherIcon = () => {
    if (weather?.current?.condition?.icon) {
      return `https:${weather.current.condition.icon}`;
    }
    return null;
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
            <span><FaLocationArrow /></span>
            <span className="text-md font-medium">
              {weather?.location?.name 
                ? `${weather.location.name}, ${weather.location.country}` 
                : 'Đang tải vị trí...'}
            </span>
          </div>

          {/* Weather Card */}
          <div className="card" style={{ 
            background: 'white', 
            color: 'var(--text-primary)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}>
            {weather ? (
              <>
                <div>
                  <div className="text-h2 font-bold text-primary">
                    {weather.current?.temp_c}°C
                  </div>
                  <div className="text-content">
                    {weather.current?.condition?.text || 'N/A'}
                  </div>
                  <div className="text-sm text-content" style={{ marginTop: '4px' }}>
                    <WiHumidity className="text-xl"/> {weather.current?.humidity}% | <FaWind className="text-xl" /> {weather.current?.wind_kph} km/h
                  </div>
                </div>
                {getWeatherIcon() && (
                  <img 
                    src={getWeatherIcon()} 
                    alt="Weather" 
                    style={{ width: '64px', height: '64px' }}
                  />
                )}
              </>
            ) : weatherError ? (
              <div className="text-content">{weatherError}</div>
            ) : (
              <div className="text-content">Đang tải thời tiết...</div>
            )}
          </div>
        </div>
      </div>

      <div className="container">
        {/* Quick Stats */}
        <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Tổng quan</h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(2, 1fr)', 
          gap: 'var(--spacing-md)',
          marginBottom: 'var(--spacing-xl)',
        }}>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}><PiPottedPlantFill className="text-2xl" /></div>
            <div className="text-h3 font-bold">
              {loading ? '...' : stats.totalZones}
            </div>
            <div className="text-sm text-content">Khu vực</div>
          </div>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}><MdDevices /></div>
            <div className="text-h3 font-bold">
              {loading ? '...' : stats.totalDevices}
            </div>
            <div className="text-sm text-content">Thiết bị</div>
          </div>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}><SiTicktick /></div>
            <div className="text-h3 font-bold text-primary">
              {loading ? '...' : stats.onlineDevices}
            </div>
            <div className="text-sm text-content">Online</div>
          </div>
          <div className="card" style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-xs)' }}><TiWarning /></div>
            <div className="text-h3 font-bold text-danger">
              {loading ? '...' : stats.unhandledAlerts}
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
            <div className="zone-icon" style={{ background: 'var(--accent-yellow)' }}><FaUser /></div>
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
