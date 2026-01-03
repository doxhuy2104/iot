import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { zoneApi } from '../../services/api';

export default function AddZone() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    zoneName: '',
    location: '',
    description: '',
    latitude: '',
    longitude: '',
    thresholdValue: 30,
    autoMode: true,
    weatherMode: false,
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [gettingLocation, setGettingLocation] = useState(false);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({ 
      ...formData, 
      [name]: type === 'checkbox' ? checked : value 
    });
  };

  // Get current location
  const getCurrentLocation = () => {
    if (!navigator.geolocation) {
      setError('Trình duyệt không hỗ trợ định vị');
      return;
    }

    setGettingLocation(true);
    navigator.geolocation.getCurrentPosition(
      (position) => {
        setFormData({
          ...formData,
          latitude: position.coords.latitude.toFixed(6),
          longitude: position.coords.longitude.toFixed(6),
        });
        setGettingLocation(false);
      },
      (err) => {
        console.error('Geolocation error:', err);
        setError('Không thể lấy vị trí. Vui lòng nhập thủ công.');
        setGettingLocation(false);
      }
    );
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!formData.zoneName.trim()) {
      setError('Vui lòng nhập tên khu vực');
      return;
    }
    if (!formData.latitude || !formData.longitude) {
      setError('Vui lòng nhập hoặc lấy vị trí tọa độ');
      return;
    }
    
    setLoading(true);
    
    try {
      const result = await zoneApi.create({
        zoneName: formData.zoneName,
        location: formData.location,
        description: formData.description,
        latitude: formData.latitude.toString(),
        longitude: formData.longitude.toString(),
        thresholdValue: parseInt(formData.thresholdValue),
        autoMode: formData.autoMode,
        weatherMode: formData.weatherMode,
      });
      console.log('Zone created:', result);
      alert('Tạo khu vực thành công!');
      navigate('/zones');
    } catch (err) {
      console.error('Failed to create zone:', err);
      setError(err.message || 'Không thể tạo khu vực');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to="/zones" className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title">Thêm khu vực</h1>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        <form onSubmit={handleSubmit}>
          {error && (
            <div className="card" style={{ 
              background: 'rgba(255,82,82,0.1)', 
              color: 'var(--danger)',
              marginBottom: 'var(--spacing-md)',
            }}>
              {error}
            </div>
          )}
          
          {/* Basic Info */}
          <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
            <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
              Thông tin khu vực
            </h3>
            
            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Tên khu vực *</label>
              <input
                type="text"
                name="zoneName"
                className="input"
                style={{ paddingLeft: 'var(--spacing-md)' }}
                placeholder="VD: Nhà kính A"
                value={formData.zoneName}
                onChange={handleChange}
                required
              />
            </div>

            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Vị trí (địa chỉ)</label>
              <input
                type="text"
                name="location"
                className="input"
                style={{ paddingLeft: 'var(--spacing-md)' }}
                placeholder="VD: Khu vườn phía Bắc, Hà Nội"
                value={formData.location}
                onChange={handleChange}
              />
            </div>

            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Mô tả</label>
              <textarea
                name="description"
                className="input"
                style={{ 
                  paddingLeft: 'var(--spacing-md)', 
                  minHeight: '80px',
                  resize: 'vertical',
                }}
                placeholder="Mô tả về khu vực tưới..."
                value={formData.description}
                onChange={handleChange}
              />
            </div>
          </div>

          {/* Location Coordinates */}
          <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
            <div className="flex justify-between items-center" style={{ marginBottom: 'var(--spacing-md)' }}>
              <h3 className="text-lg font-semibold">Tọa độ GPS *</h3>
              <button
                type="button"
                onClick={getCurrentLocation}
                disabled={gettingLocation}
                className="btn"
                style={{ 
                  background: 'var(--accent-blue)', 
                  color: 'white',
                  fontSize: '14px',
                  padding: '8px 12px',
                }}
              >
                {gettingLocation ? '📍 Đang lấy...' : '📍 Lấy vị trí hiện tại'}
              </button>
            </div>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--spacing-md)' }}>
              <div className="input-group">
                <label className="input-label">Vĩ độ (Latitude) *</label>
                <input
                  type="number"
                  name="latitude"
                  className="input"
                  style={{ paddingLeft: 'var(--spacing-md)' }}
                  placeholder="VD: 21.0285"
                  step="any"
                  value={formData.latitude}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="input-group">
                <label className="input-label">Kinh độ (Longitude) *</label>
                <input
                  type="number"
                  name="longitude"
                  className="input"
                  style={{ paddingLeft: 'var(--spacing-md)' }}
                  placeholder="VD: 105.8542"
                  step="any"
                  value={formData.longitude}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
            <p className="text-sm text-content" style={{ marginTop: 'var(--spacing-sm)' }}>
              Dùng để theo dõi thời tiết tại khu vực
            </p>
          </div>

          {/* Irrigation Settings */}
          <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
            <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
              Cài đặt tưới
            </h3>
            
            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Ngưỡng độ ẩm tự động tưới (%)</label>
              <input
                type="range"
                name="thresholdValue"
                min="10"
                max="90"
                value={formData.thresholdValue}
                onChange={handleChange}
                style={{ width: '100%' }}
              />
              <div className="flex justify-between text-sm text-content">
                <span>10%</span>
                <span className="font-semibold text-primary">{formData.thresholdValue}%</span>
                <span>90%</span>
              </div>
            </div>

            <div style={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              alignItems: 'center',
              padding: 'var(--spacing-sm) 0',
              borderTop: '1px solid var(--border-color)',
            }}>
              <div>
                <span>Chế độ tự động</span>
                <p className="text-sm text-content">Tự động tưới khi độ ẩm dưới ngưỡng</p>
              </div>
              <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  name="autoMode"
                  checked={formData.autoMode}
                  onChange={handleChange}
                  style={{ width: '20px', height: '20px' }}
                />
              </label>
            </div>

            <div style={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              alignItems: 'center',
              padding: 'var(--spacing-sm) 0',
              borderTop: '1px solid var(--border-color)',
            }}>
              <div>
                <span>Chế độ thời tiết</span>
                <p className="text-sm text-content">Điều chỉnh theo dự báo thời tiết</p>
              </div>
              <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  name="weatherMode"
                  checked={formData.weatherMode}
                  onChange={handleChange}
                  style={{ width: '20px', height: '20px' }}
                />
              </label>
            </div>
          </div>

          <button 
            type="submit" 
            className="btn btn-primary" 
            disabled={loading || !formData.zoneName}
            style={{ width: '100%' }}
          >
            {loading ? 'Đang tạo...' : 'Tạo khu vực'}
          </button>
        </form>
      </div>
    </div>
  );
}
