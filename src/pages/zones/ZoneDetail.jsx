import { useState, useEffect, useRef } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { zoneApi, sensorApi, deviceApi, scheduleApi, waterLogApi, weatherApi } from '../../services/api';
import { useMqtt } from '../../hooks/useMqtt';
import { FaRegTrashCan } from 'react-icons/fa6';
import { BiWater } from 'react-icons/bi';
import { IoIosWater } from 'react-icons/io';
import { GiPlantWatering } from 'react-icons/gi';
import { IoWater } from 'react-icons/io5';
import { IoMdTime } from 'react-icons/io';
import { RiZzzFill } from 'react-icons/ri';
import { FiEdit3 } from 'react-icons/fi';
import { FaLocationArrow } from 'react-icons/fa';

export default function ZoneDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [zone, setZone] = useState(null);
  const [sensorData, setSensorData] = useState(null);
  const [devices, setDevices] = useState([]);
  const [schedules, setSchedules] = useState([]);
  const [waterLogs, setWaterLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [pumpLoading, setPumpLoading] = useState(false);
  const [deleteLoading, setDeleteLoading] = useState(false);
  
  // Target humidity control
  const [enableTargetHumidity, setEnableTargetHumidity] = useState(false);
  const [targetHumidity, setTargetHumidity] = useState(80);
  
  // Weather data
  const [weather, setWeather] = useState(null);
  
  // Auto-refresh interval ref
  const refreshIntervalRef = useRef(null);
  
  // MQTT real-time data (like Flutter app)
  const { isConnected: mqttConnected, sensorData: mqttSensorData, isDeviceOnline: mqttDeviceOnline } = useMqtt(id);

  useEffect(() => {
    loadZone();
    loadSensorData();
    loadDevices();
    loadSchedules();
    loadWaterLogs();
    loadWeather();
    
    // Auto-refresh sensor data and device status every 30 seconds
    refreshIntervalRef.current = setInterval(() => {
      console.log('Auto-refreshing sensor data and device status...');
      loadSensorData();
      loadDevices();
    }, 30000);
    
    return () => {
      if (refreshIntervalRef.current) {
        clearInterval(refreshIntervalRef.current);
      }
    };
  }, [id]);

  const loadZone = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await zoneApi.getById(id);
      console.log('Zone loaded:', result);
      setZone(result.data);
      // Initialize target humidity from zone threshold
      if (result.data?.thresholdMax) {
        setTargetHumidity(result.data.thresholdMax);
      }
    } catch (err) {
      console.error('Failed to load zone:', err);
      setError(err.message || 'Không thể tải thông tin khu vực');
    } finally {
      setLoading(false);
    }
  };

  const loadSensorData = async () => {
    try {
      const result = await sensorApi.getLatest(id);
      console.log('Sensor data:', result);
      if (result.data) {
        setSensorData(result.data);
      }
    } catch (err) {
      console.error('Failed to load sensor data:', err);
    }
  };

  const loadWeather = async () => {
    try {
      // Use zone location or default to user's location
      const result = await weatherApi.getCurrent();
      console.log('Weather data:', result);
      if (result.data) {
        setWeather(result.data);
      }
    } catch (err) {
      console.error('Failed to load weather:', err);
    }
  };

  const loadDevices = async () => {
    try {
      const result = await deviceApi.getByZone(id);
      console.log('Devices:', result);
      if (result.data) {
        setDevices(result.data);
      }
    } catch (err) {
      console.error('Failed to load devices:', err);
    }
  };

  const loadSchedules = async () => {
    try {
      const result = await scheduleApi.getByZone(id);
      console.log('Schedules:', result);
      if (result.data) {
        setSchedules(result.data);
      }
    } catch (err) {
      console.error('Failed to load schedules:', err);
    }
  };

  const loadWaterLogs = async () => {
    try {
      const result = await waterLogApi.getByZone(id);
      console.log('Water logs:', result);
      if (result.data) {
        setWaterLogs(result.data.slice(0, 3)); // Show only 3 most recent
      }
    } catch (err) {
      console.error('Failed to load water logs:', err);
    }
  };

  const togglePump = async () => {
    if (!zone) return;
    
    try {
      setPumpLoading(true);
      const newStatus = !zone.pumpStatus;
      const humidityTarget = enableTargetHumidity && newStatus ? targetHumidity : null;
      await zoneApi.togglePump(id, newStatus, humidityTarget);
      setZone({ ...zone, pumpStatus: newStatus });
    } catch (err) {
      console.error('Failed to toggle pump:', err);
      alert('Không thể điều khiển bơm: ' + err.message);
    } finally {
      setPumpLoading(false);
    }
  };

  const toggleScheduleActive = async (scheduleId, currentActive) => {
    try {
      await scheduleApi.toggleActive(scheduleId, !currentActive);
      loadSchedules(); // Refresh
    } catch (err) {
      console.error('Failed to toggle schedule:', err);
      alert('Không thể cập nhật lịch: ' + err.message);
    }
  };

  const deleteSchedule = async (scheduleId) => {
    if (!confirm('Bạn có chắc muốn xóa lịch này?')) return;
    
    try {
      await scheduleApi.delete(scheduleId);
      loadSchedules(); // Refresh
    } catch (err) {
      console.error('Failed to delete schedule:', err);
      alert('Không thể xóa lịch: ' + err.message);
    }
  };

  const handleDelete = async () => {
    if (!confirm('Bạn có chắc muốn xóa khu vực này?')) return;
    
    try {
      setDeleteLoading(true);
      await zoneApi.delete(id);
      alert('Đã xóa khu vực thành công!');
      navigate('/zones');
    } catch (err) {
      console.error('Failed to delete zone:', err);
      alert('Không thể xóa khu vực: ' + err.message);
    } finally {
      setDeleteLoading(false);
    }
  };

  const getDeviceStatusColor = (status) => {
    switch (status) {
      case 'ONLINE': return '#4CAF50';
      case 'OFFLINE': return '#9E9E9E';
      case 'ERROR': return '#F44336';
      default: return '#9E9E9E';
    }
  };

  const getDeviceTypeIcon = (type) => {
    switch (type?.toLowerCase()) {
      case 'pump': return '💧';
      case 'sensor': return '📡';
      case 'controller': return '🎛️';
      default: return '📟';
    }
  };

  const formatTime = (timeStr) => {
    if (!timeStr) return '--:--';
    // Handle both HH:mm and full datetime formats
    if (timeStr.includes('T')) {
      return timeStr.split('T')[1]?.substring(0, 5) || '--:--';
    }
    return timeStr.substring(0, 5);
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
      hour: '2-digit',
      minute: '2-digit',
      day: '2-digit',
      month: '2-digit',
    });
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

  // Prioritize MQTT real-time data, then REST API, then zone defaults
  const moisture = mqttSensorData?.humidity ?? sensorData?.soilMoisture ?? zone.soilMoisture ?? 0;
  // If MQTT humidity is already in percentage (0-100), divide by 100
  const moisturePercent = mqttSensorData?.humidity != null 
    ? Math.round(mqttSensorData.humidity) 
    : Math.round(moisture * 100);
  // Use weather API for temperature and humidity if sensor data not available
  const temperature = sensorData?.temperature ?? weather?.current?.temp_c ?? '--';
  const humidity = sensorData?.humidity ?? weather?.current?.humidity ?? '--';
  // Use MQTT for flow data
  const flowRate = mqttSensorData?.flowRate ?? sensorData?.flowRate ?? 0;
  const totalVolume = mqttSensorData?.volume ?? sensorData?.volume ?? 0;
  const lastUpdate = sensorData?.createdAt 
    ? new Date(sensorData.createdAt).toLocaleString('vi-VN')
    : mqttConnected ? 'Real-time MQTT' : null;
  
  // Update device status based on MQTT if available
  const updatedDevices = devices.map(device => ({
    ...device,
    status: mqttDeviceOnline !== null 
      ? (mqttDeviceOnline ? 'ONLINE' : 'OFFLINE') 
      : device.status,
  }));
  
  // Pump status - prioritize MQTT real-time data
  const isPumpOn = mqttSensorData?.pump != null 
    ? mqttSensorData.pump === 'on' 
    : zone.pumpStatus;

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to="/zones" className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title" style={{ flex: 1 }}>{zone.zoneName || zone.name}</h1>
          <Link to={`/zones/${id}/edit`} className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            <FiEdit3 />
          </Link>
          <button
            onClick={handleDelete}
            disabled={deleteLoading}
            className="btn btn-icon"
            style={{ background: 'rgba(255,82,82,0.3)', color: 'white' }}
          >
            <FaRegTrashCan />
          </button>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {/* Location Info */}
        <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
          <div className="flex items-center gap-md">
            <div className="zone-icon" style={{ background: '#7FC8A9' }}><FaLocationArrow /></div>
            <div style={{ flex: 1 }}>
              <div className="font-semibold">{zone.location || 'Chưa có vị trí'}</div>
              <div className="text-sm text-content">{zone.description || 'Chưa có mô tả'}</div>
            </div>
          </div>
        </div>

        {/* Sensor Data */}
        <div className="flex justify-between items-center" style={{ margin: 'var(--spacing-lg) 0 var(--spacing-md)' }}>
          <h3 className="text-h3">Dữ liệu cảm biến</h3>
          {lastUpdate && (
            <span className="text-sm text-content">Cập nhật: {lastUpdate}</span>
          )}
        </div>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(2, 1fr)', 
          gap: 'var(--spacing-md)',
          marginBottom: 'var(--spacing-lg)',
        }}>
          <div className="card">
            <div className="text-content text-sm"> Độ ẩm đất</div>
            <div className="text-h2 font-bold text-primary">{moisturePercent}%</div>
            <div className="progress-bar" style={{ marginTop: 'var(--spacing-sm)' }}>
              <div className="progress-bar-fill" style={{ width: `${moisturePercent}%` }} />
            </div>
          </div>
          
          <div className="card">
            <div className="text-content text-sm"> Ngưỡng tưới</div>
            <div className="text-h2 font-bold" style={{ color: '#FFC857' }}>{zone.thresholdValue || 30}%</div>
          </div>
          
          <div className="card">
            <div className="text-content text-sm"> Nhiệt độ</div>
            <div className="text-h2 font-bold" style={{ color: '#FF6B6B' }}>
              {temperature !== '--' ? `${temperature}°C` : '--'}
            </div>
          </div>
          
          <div className="card">
            <div className="text-content text-sm"> Độ ẩm không khí</div>
            <div className="text-h2 font-bold" style={{ color: '#6CA0DC' }}>
              {humidity !== '--' ? `${humidity}%` : '--'}
            </div>
          </div>
        </div>

        {/* Flow Sensor Status */}
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Trạng thái lưu lượng</h3>
        <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-around' }}>
            <div style={{ textAlign: 'center' }}>
              <div className="text-sm text-content"><BiWater /> Flow Rate</div>
              <div className="text-h3 font-bold" style={{ color: 'var(--primary)' }}>
                {flowRate.toFixed(1)} L/m
              </div>
            </div>
            <div style={{ width: '1px', background: 'var(--border-color)' }} />
            <div style={{ textAlign: 'center' }}>
              <div className="text-sm text-content"><IoIosWater /> Tổng thể tích</div>
              <div className="text-h3 font-bold" style={{ color: '#00BCD4' }}>
                {totalVolume.toFixed(1)} L
              </div>
            </div>
          </div>
        </div>

        {/* Pump Control with Target Humidity */}
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>
          Điều khiển bơm
        </h3>
        
        <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
          {/* Pump icon */}
          <div style={{ textAlign: 'center', marginBottom: 'var(--spacing-md)' }}>
            <span style={{ fontSize: '48px' }}>
              {isPumpOn ? <GiPlantWatering /> : <RiZzzFill />}
            </span>
          </div>

          {/* Target Humidity Control */}
          <div style={{ 
            borderTop: '1px solid var(--border-color)', 
            borderBottom: '1px solid var(--border-color)',
            padding: 'var(--spacing-md) 0',
            marginBottom: 'var(--spacing-md)',
          }}>
            <div className="flex items-center gap-md" style={{ marginBottom: 'var(--spacing-sm)' }}>
              <input
                type="checkbox"
                id="enableTargetHumidity"
                checked={enableTargetHumidity && !isPumpOn}
                onChange={(e) => setEnableTargetHumidity(e.target.checked)}
                disabled={isPumpOn}
                style={{ width: '18px', height: '18px' }}
              />
              <label htmlFor="enableTargetHumidity" className="font-medium">
                Độ ẩm mục tiêu (%)
              </label>
              <span 
                className="font-bold" 
                style={{ 
                  marginLeft: 'auto',
                  color: enableTargetHumidity ? 'var(--primary)' : 'var(--text-content)',
                }}
              >
                {targetHumidity}%
              </span>
            </div>
            <input
              type="range"
              min={moisturePercent > 0 ? moisturePercent : 0}
              max="100"
              value={targetHumidity}
              onChange={(e) => setTargetHumidity(parseInt(e.target.value))}
              disabled={isPumpOn || !enableTargetHumidity}
              style={{ 
                width: '100%', 
                accentColor: 'var(--primary)',
                opacity: enableTargetHumidity ? 1 : 0.5,
              }}
            />
          </div>

          {/* Pump Toggle Button */}
          <div className="flex justify-between items-center">
            <div>
              <div className="font-semibold">Trạng thái bơm</div>
              <div className="text-sm text-content">
                {isPumpOn ? ' Đang bật' : ' Đang tắt'}
              </div>
            </div>
            <button
              onClick={togglePump}
              disabled={pumpLoading}
              className="btn"
              style={{
                background: isPumpOn ? 'var(--primary)' : 'var(--background)',
                color: isPumpOn ? 'white' : 'var(--text-primary)',
                border: isPumpOn ? 'none' : '1px solid var(--border-color)',
                minWidth: '100px',
              }}
            >
              {pumpLoading ? '...' : isPumpOn ? 'TẮT' : 'BẬT'}
            </button>
          </div>
        </div>

        {/* Schedules Section */}
        <div className="flex justify-between items-center" style={{ marginBottom: 'var(--spacing-md)' }}>
          <h3 className="text-h3">Lịch tưới</h3>
          <Link 
            to={`/zones/${id}/add-schedule`}
            className="btn"
            style={{ 
              background: 'var(--accent-blue)', 
              color: 'white',
              fontSize: '14px',
              padding: '6px 12px',
            }}
          >
            ➕ Thêm
          </Link>
        </div>
        
        {schedules.length > 0 ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-sm)', marginBottom: 'var(--spacing-lg)' }}>
            {schedules.map(schedule => (
              <div key={schedule.id || schedule.scheduleId} className="card" style={{ padding: 'var(--spacing-md)' }}>
                <div className="flex items-center gap-md">
                  <div style={{ flex: 1 }}>
                    <div className="font-bold text-lg">{formatTime(schedule.startTime)}</div>
                    <div className="text-sm text-content">
                      {schedule.repeatDays?.length > 0 
                        ? (Array.isArray(schedule.repeatDays) 
                            ? schedule.repeatDays.join(', ') 
                            : schedule.repeatDays)
                        : 'Một lần'}
                    </div>
                    <div className="text-sm text-content">
                      ⏱️ {schedule.duration}s • <IoWater /> {schedule.volume}L
                    </div>
                  </div>
                  <button
                    onClick={() => toggleScheduleActive(schedule.id || schedule.scheduleId, schedule.active)}
                    style={{
                      background: schedule.active ? 'var(--primary)' : 'var(--background)',
                      color: schedule.active ? 'white' : 'var(--text-content)',
                      border: schedule.active ? 'none' : '1px solid var(--border-color)',
                      padding: '8px 16px',
                      borderRadius: 'var(--radius-md)',
                      fontSize: '12px',
                    }}
                  >
                    {schedule.active ? 'BẬT' : 'TẮT'}
                  </button>
                  <button
                    onClick={() => deleteSchedule(schedule.id || schedule.scheduleId)}
                    style={{
                      background: 'transparent',
                      border: 'none',
                      cursor: 'pointer',
                      fontSize: '18px',
                    }}
                  >
                    <FaRegTrashCan />
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-lg)', marginBottom: 'var(--spacing-lg)' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-sm)' }}>📅</div>
            <div className="text-content">Chưa có lịch tưới nào</div>
          </div>
        )}

        {/* History Section */}
        <div className="flex justify-between items-center" style={{ marginBottom: 'var(--spacing-md)' }}>
          <h3 className="text-h3">Lịch sử tưới</h3>
          <Link 
            to={`/zones/${id}/history`}
            className="text-primary font-medium"
            style={{ fontSize: '14px' }}
          >
            Xem tất cả →
          </Link>
        </div>
        
        {waterLogs.length > 0 ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-sm)', marginBottom: 'var(--spacing-lg)' }}>
            {waterLogs.map((log, index) => (
              <div key={log.logId || index} className="card" style={{ padding: 'var(--spacing-md)' }}>
                <div className="flex justify-between items-center">
                  <div className="font-semibold">
                    {formatDate(log.startedAt)}
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <span style={{ color: 'var(--primary)', fontWeight: 'bold' }}>
                      <IoWater /> {(log.waterVolumeLiters || 0).toFixed(1)} L
                    </span>
                    <span className="text-content text-sm" style={{ marginLeft: '8px' }}>
                      <IoMdTime /> {log.durationSeconds || 0}s
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-lg)', marginBottom: 'var(--spacing-lg)' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-sm)' }}>📜</div>
            <div className="text-content">Chưa có lịch sử tưới</div>
          </div>
        )}

        {/* Devices Section */}
        <div className="flex justify-between items-center" style={{ marginBottom: 'var(--spacing-md)' }}>
          <h3 className="text-h3">Thiết bị ({devices.length})</h3>
          <Link 
            to={`/zones/${id}/setup-device`}
            className="btn"
            style={{ 
              background: 'var(--accent-blue)', 
              color: 'white',
              fontSize: '14px',
              padding: '6px 12px',
            }}
          >
            ➕ Thêm thiết bị
          </Link>
        </div>
        
        {devices.length > 0 ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-sm)', marginBottom: 'var(--spacing-lg)' }}>
            {updatedDevices.map(device => (
              <div key={device.deviceId} className="card" style={{ padding: 'var(--spacing-md)' }}>
                <div className="flex items-center gap-md">
                  <div style={{ fontSize: '24px' }}>
                    {getDeviceTypeIcon(device.deviceType)}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div className="font-semibold">{device.deviceName || `Device ${device.deviceId}`}</div>
                    <div className="text-sm text-content">
                      {device.deviceType || 'Unknown'} • {device.deviceIdentifier || 'N/A'}
                    </div>
                  </div>
                  <div style={{ 
                    display: 'flex', 
                    alignItems: 'center', 
                    gap: '6px',
                    padding: '4px 10px',
                    borderRadius: '12px',
                    background: `${getDeviceStatusColor(device.status)}20`,
                    color: getDeviceStatusColor(device.status),
                    fontSize: '12px',
                    fontWeight: '600',
                  }}>
                    <span style={{ 
                      width: '8px', 
                      height: '8px', 
                      borderRadius: '50%', 
                      background: getDeviceStatusColor(device.status),
                    }} />
                    {device.status || 'OFFLINE'}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-lg)', marginBottom: 'var(--spacing-lg)' }}>
            <div style={{ fontSize: '32px', marginBottom: 'var(--spacing-sm)' }}>📡</div>
            <div className="text-content">Chưa có thiết bị nào được kết nối</div>
          </div>
        )}

        {/* Mode Settings */}
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Cài đặt</h3>
        
        <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
          <div className="flex justify-between items-center" style={{ marginBottom: 'var(--spacing-sm)' }}>
            <span>Chế độ tự động</span>
            <span className={zone.autoMode ? 'text-primary font-semibold' : 'text-content'}>
              {zone.autoMode ? 'BẬT' : 'TẮT'}
            </span>
          </div>
          <div className="flex justify-between items-center">
            <span>Chế độ thời tiết</span>
            <span className={zone.weatherMode ? 'text-primary font-semibold' : 'text-content'}>
              {zone.weatherMode ? 'BẬT' : 'TẮT'}
            </span>
          </div>
        </div>

        {/* Zone Info Footer */}
        <div style={{ marginTop: 'var(--spacing-xl)', textAlign: 'center' }}>
          <p className="text-sm text-content">
            Zone ID: {zone.zoneId || zone.id} | 
            Tọa độ: {zone.latitude}, {zone.longitude}
          </p>
          <p className="text-sm text-content">
            Tạo lúc: {zone.createdAt ? new Date(zone.createdAt).toLocaleDateString('vi-VN') : 'N/A'}
          </p>
        </div>
      </div>
    </div>
  );
}
