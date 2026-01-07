import { useState, useEffect } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { zoneApi } from '../../services/api';

export default function EditZone() {
  const { id } = useParams();
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
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    loadZone();
  }, [id]);

  const loadZone = async () => {
    try {
      setLoading(true);
      const result = await zoneApi.getById(id);
      console.log('Zone loaded for edit:', result);
      if (result.data) {
        const zone = result.data;
        setFormData({
          zoneName: zone.zoneName || '',
          location: zone.location || '',
          description: zone.description || '',
          latitude: zone.latitude || '',
          longitude: zone.longitude || '',
          thresholdValue: zone.thresholdValue || 30,
          autoMode: zone.autoMode ?? true,
          weatherMode: zone.weatherMode ?? false,
        });
      }
    } catch (err) {
      console.error('Failed to load zone:', err);
      setError('Không thể tải thông tin khu vực');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({ 
      ...formData, 
      [name]: type === 'checkbox' ? checked : value 
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!formData.zoneName.trim()) {
      setError('Vui lòng nhập tên khu vực');
      return;
    }
    if (!formData.latitude || !formData.longitude) {
      setError('Vui lòng nhập tọa độ');
      return;
    }
    
    setSaving(true);
    
    try {
      const result = await zoneApi.update(id, {
        zoneName: formData.zoneName,
        location: formData.location,
        description: formData.description,
        latitude: formData.latitude.toString(),
        longitude: formData.longitude.toString(),
        thresholdValue: parseInt(formData.thresholdValue),
        autoMode: formData.autoMode,
        weatherMode: formData.weatherMode,
      });
      console.log('Zone updated:', result);
      alert('Cập nhật khu vực thành công!');
      navigate(`/zones/${id}`);
    } catch (err) {
      console.error('Failed to update zone:', err);
      setError(err.message || 'Không thể cập nhật khu vực');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="fade-in">
        <div className="navbar">
          <div className="container flex items-center gap-md">
            <Link to={`/zones/${id}`} className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
              ←
            </Link>
            <h1 className="navbar-title">Đang tải...</h1>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to={`/zones/${id}`} className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title">Chỉnh sửa khu vực</h1>
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
                value={formData.zoneName}
                onChange={handleChange}
                required
              />
            </div>

            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Vị trí</label>
              <input
                type="text"
                name="location"
                className="input"
                style={{ paddingLeft: 'var(--spacing-md)' }}
                value={formData.location}
                onChange={handleChange}
              />
            </div>

            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Mô tả</label>
              <textarea
                name="description"
                className="input"
                style={{ paddingLeft: 'var(--spacing-md)', minHeight: '80px', resize: 'vertical' }}
                value={formData.description}
                onChange={handleChange}
              />
            </div>
          </div>

          {/* Coordinates */}
          <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
            <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
              Tọa độ GPS
            </h3>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--spacing-md)' }}>
              <div className="input-group">
                <label className="input-label">Vĩ độ *</label>
                <input
                  type="number"
                  name="latitude"
                  className="input"
                  style={{ paddingLeft: 'var(--spacing-md)' }}
                  step="any"
                  value={formData.latitude}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="input-group">
                <label className="input-label">Kinh độ *</label>
                <input
                  type="number"
                  name="longitude"
                  className="input"
                  style={{ paddingLeft: 'var(--spacing-md)' }}
                  step="any"
                  value={formData.longitude}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
          </div>

          {/* Irrigation Settings */}
          <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
            <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
              Cài đặt tưới
            </h3>
            
            <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
              <label className="input-label">Ngưỡng độ ẩm (%)</label>
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
              <span>Chế độ tự động</span>
              <input
                type="checkbox"
                name="autoMode"
                checked={formData.autoMode}
                onChange={handleChange}
                style={{ width: '20px', height: '20px' }}
              />
            </div>

            <div style={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              alignItems: 'center',
              padding: 'var(--spacing-sm) 0',
              borderTop: '1px solid var(--border-color)',
            }}>
              <span>Chế độ thời tiết</span>
              <input
                type="checkbox"
                name="weatherMode"
                checked={formData.weatherMode}
                onChange={handleChange}
                style={{ width: '20px', height: '20px' }}
              />
            </div>
          </div>

          <button 
            type="submit" 
            className="btn btn-primary" 
            disabled={saving}
            style={{ width: '100%' }}
          >
            {saving ? 'Đang lưu...' : 'Lưu thay đổi'}
          </button>
        </form>
      </div>
    </div>
  );
}
