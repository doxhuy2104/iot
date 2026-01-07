import { useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { scheduleApi } from '../../services/api';

export default function AddSchedule() {
  const { id: zoneId } = useParams();
  const navigate = useNavigate();
  
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // Form state
  const [startTime, setStartTime] = useState('07:00');
  const [duration, setDuration] = useState(30);
  const [volume, setVolume] = useState(5);
  const [isRecurring, setIsRecurring] = useState(true);
  const [selectedDays, setSelectedDays] = useState([true, true, true, true, true, true, true]); // All days selected
  
  const daysOfWeek = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  const dayValues = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const toggleDay = (index) => {
    const newDays = [...selectedDays];
    newDays[index] = !newDays[index];
    setSelectedDays(newDays);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError(null);
      
      // Backend expects repeatDays as comma-separated string, e.g. "Mon,Tue,Wed"
      const repeatDays = isRecurring 
        ? selectedDays.map((selected, i) => selected ? dayValues[i] : null).filter(Boolean).join(',')
        : null;
      
      await scheduleApi.create(zoneId, {
        startTime,
        duration: parseInt(duration),
        volume: parseFloat(volume),
        repeatDays,
        active: true,
      });
      
      alert('Tạo lịch tưới thành công!');
      navigate(`/zones/${zoneId}`);
    } catch (err) {
      console.error('Failed to create schedule:', err);
      setError(err.message || 'Không thể tạo lịch tưới');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to={`/zones/${zoneId}`} className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title">Thêm lịch tưới</h1>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {error && (
          <div className="card" style={{ background: '#FFEBEE', color: '#C62828', marginBottom: 'var(--spacing-md)' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          {/* Time Picker */}
          <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
            <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Thời gian bắt đầu</h3>
            <input
              type="time"
              value={startTime}
              onChange={(e) => setStartTime(e.target.value)}
              style={{
                width: '100%',
                padding: 'var(--spacing-md)',
                fontSize: '24px',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-color)',
                textAlign: 'center',
              }}
            />
          </div>

          {/* Duration & Volume */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--spacing-md)', marginBottom: 'var(--spacing-lg)' }}>
            <div className="card">
              <label className="text-sm text-content">Thời lượng (giây)</label>
              <input
                type="number"
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
                min="1"
                style={{
                  width: '100%',
                  padding: 'var(--spacing-sm)',
                  fontSize: '18px',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-color)',
                  marginTop: 'var(--spacing-xs)',
                }}
              />
            </div>
            <div className="card">
              <label className="text-sm text-content">Lượng nước (L)</label>
              <input
                type="number"
                value={volume}
                onChange={(e) => setVolume(e.target.value)}
                min="0.1"
                step="0.1"
                style={{
                  width: '100%',
                  padding: 'var(--spacing-sm)',
                  fontSize: '18px',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-color)',
                  marginTop: 'var(--spacing-xs)',
                }}
              />
            </div>
          </div>

          {/* Repeat Settings */}
          <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
            <div className="flex justify-between items-center" style={{ marginBottom: 'var(--spacing-md)' }}>
              <h3 className="text-h3">Lặp lại</h3>
              <button
                type="button"
                onClick={() => setIsRecurring(!isRecurring)}
                style={{
                  background: isRecurring ? 'var(--primary)' : 'var(--background)',
                  color: isRecurring ? 'white' : 'var(--text-primary)',
                  padding: '8px 16px',
                  borderRadius: 'var(--radius-md)',
                  border: isRecurring ? 'none' : '1px solid var(--border-color)',
                }}
              >
                {isRecurring ? 'BẬT' : 'TẮT'}
              </button>
            </div>

            {isRecurring && (
              <div style={{ display: 'flex', justifyContent: 'space-between', gap: '4px' }}>
                {daysOfWeek.map((day, index) => (
                  <button
                    key={day}
                    type="button"
                    onClick={() => toggleDay(index)}
                    style={{
                      width: '40px',
                      height: '40px',
                      borderRadius: '50%',
                      border: selectedDays[index] ? 'none' : '1px solid var(--border-color)',
                      background: selectedDays[index] ? 'var(--primary)' : 'transparent',
                      color: selectedDays[index] ? 'white' : 'var(--text-content)',
                      fontWeight: '600',
                      fontSize: '12px',
                    }}
                  >
                    {day}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="btn btn-primary"
            style={{ width: '100%', padding: 'var(--spacing-md)' }}
          >
            {loading ? 'Đang tạo...' : 'Lưu lịch tưới'}
          </button>
        </form>
      </div>
    </div>
  );
}
