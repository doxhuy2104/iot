import { useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { deviceApi } from '../../services/api';

export default function SetupDevice() {
  const { id: zoneId } = useParams();
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [wifiCredentials, setWifiCredentials] = useState({
    ssid: '',
    password: '',
  });
  const [deviceInfo, setDeviceInfo] = useState({
    deviceName: '',
    deviceType: 'SENSOR',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const ESP32_IP = 'http://192.168.4.1';

  const handleWifiSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // Send WiFi credentials to ESP32
      const response = await fetch(`${ESP32_IP}/save?ssid=${encodeURIComponent(wifiCredentials.ssid)}&password=${encodeURIComponent(wifiCredentials.password)}`, {
        method: 'GET',
        mode: 'no-cors', // ESP32 doesn't support CORS
      });
      
      // Since we can't read the response with no-cors, assume success if no error
      setStep(3);
    } catch (err) {
      console.error('Failed to configure ESP32:', err);
      setError('Không thể kết nối đến ESP32. Hãy chắc chắn bạn đã kết nối WiFi "Esp32"');
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterDevice = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await deviceApi.create({
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        zoneId: parseInt(zoneId),
        status: 'OFFLINE', // Will become ONLINE when ESP32 sends data
      });
      setSuccess(true);
      setTimeout(() => {
        navigate(`/zones/${zoneId}`);
      }, 2000);
    } catch (err) {
      console.error('Failed to register device:', err);
      setError(err.message || 'Không thể đăng ký thiết bị');
    } finally {
      setLoading(false);
    }
  };

  const renderStep1 = () => (
    <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
      <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
        Bước 1: Kết nối WiFi ESP32
      </h3>
      
      <div style={{ 
        background: 'var(--accent-blue)', 
        color: 'white',
        padding: 'var(--spacing-md)',
        borderRadius: 'var(--radius-md)',
        marginBottom: 'var(--spacing-md)',
      }}>
        <div style={{ fontSize: '24px', marginBottom: 'var(--spacing-sm)' }}>📡</div>
        <p><strong>WiFi Name:</strong> Esp32</p>
        <p><strong>Password:</strong> 00000000</p>
      </div>

      <ol style={{ paddingLeft: '20px', lineHeight: '1.8' }}>
        <li>Cắm nguồn cho ESP32</li>
        <li>Đợi 10 giây để ESP32 khởi động</li>
        <li>Mở cài đặt WiFi trên máy tính/điện thoại</li>
        <li>Kết nối với WiFi <strong>"Esp32"</strong></li>
        <li>Nhập mật khẩu: <strong>00000000</strong></li>
      </ol>

      <div style={{ 
        background: 'rgba(255,193,7,0.1)', 
        border: '1px solid #FFC107',
        padding: 'var(--spacing-sm)',
        borderRadius: 'var(--radius-md)',
        marginTop: 'var(--spacing-md)',
        fontSize: '14px',
      }}>
        ⚠️ <strong>Lưu ý:</strong> Sau khi kết nối WiFi ESP32, bạn sẽ mất kết nối Internet tạm thời.
      </div>

      <button 
        className="btn btn-primary" 
        style={{ width: '100%', marginTop: 'var(--spacing-lg)' }}
        onClick={() => setStep(2)}
      >
        Đã kết nối WiFi ESP32 → Tiếp tục
      </button>
    </div>
  );

  const renderStep2 = () => (
    <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
      <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
        Bước 2: Cấu hình WiFi nhà
      </h3>
      
      <p className="text-content" style={{ marginBottom: 'var(--spacing-md)' }}>
        Nhập thông tin WiFi nhà bạn để ESP32 kết nối Internet:
      </p>

      <form onSubmit={handleWifiSubmit}>
        {error && (
          <div style={{ 
            background: 'rgba(255,82,82,0.1)', 
            color: 'var(--danger)',
            padding: 'var(--spacing-sm)',
            borderRadius: 'var(--radius-md)',
            marginBottom: 'var(--spacing-md)',
          }}>
            {error}
          </div>
        )}

        <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
          <label className="input-label">Tên WiFi (SSID)</label>
          <input
            type="text"
            className="input"
            style={{ paddingLeft: 'var(--spacing-md)' }}
            placeholder="VD: MyHomeWiFi"
            value={wifiCredentials.ssid}
            onChange={(e) => setWifiCredentials({ ...wifiCredentials, ssid: e.target.value })}
            required
          />
        </div>

        <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
          <label className="input-label">Mật khẩu WiFi</label>
          <input
            type="password"
            className="input"
            style={{ paddingLeft: 'var(--spacing-md)' }}
            placeholder="Mật khẩu WiFi nhà bạn"
            value={wifiCredentials.password}
            onChange={(e) => setWifiCredentials({ ...wifiCredentials, password: e.target.value })}
            required
          />
        </div>

        <div style={{ display: 'flex', gap: 'var(--spacing-md)' }}>
          <button 
            type="button"
            className="btn" 
            style={{ flex: 1, background: 'var(--background)', border: '1px solid var(--border-color)' }}
            onClick={() => setStep(1)}
          >
            ← Quay lại
          </button>
          <button 
            type="submit"
            className="btn btn-primary" 
            style={{ flex: 1 }}
            disabled={loading}
          >
            {loading ? 'Đang gửi...' : 'Gửi cấu hình'}
          </button>
        </div>
      </form>
    </div>
  );

  const renderStep3 = () => (
    <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
      <h3 className="text-lg font-semibold" style={{ marginBottom: 'var(--spacing-md)' }}>
        Bước 3: Đăng ký thiết bị
      </h3>
      
      <div style={{ 
        background: 'rgba(76,175,80,0.1)', 
        border: '1px solid #4CAF50',
        padding: 'var(--spacing-md)',
        borderRadius: 'var(--radius-md)',
        marginBottom: 'var(--spacing-md)',
      }}>
        ✅ Đã gửi cấu hình WiFi cho ESP32. ESP32 đang kết nối Internet...
      </div>

      <p className="text-content" style={{ marginBottom: 'var(--spacing-md)' }}>
        Bây giờ hãy kết nối lại WiFi nhà và đăng ký thiết bị:
      </p>

      <form onSubmit={handleRegisterDevice}>
        {error && (
          <div style={{ 
            background: 'rgba(255,82,82,0.1)', 
            color: 'var(--danger)',
            padding: 'var(--spacing-sm)',
            borderRadius: 'var(--radius-md)',
            marginBottom: 'var(--spacing-md)',
          }}>
            {error}
          </div>
        )}

        <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
          <label className="input-label">Tên thiết bị</label>
          <input
            type="text"
            className="input"
            style={{ paddingLeft: 'var(--spacing-md)' }}
            placeholder="VD: Cảm biến khu vườn"
            value={deviceInfo.deviceName}
            onChange={(e) => setDeviceInfo({ ...deviceInfo, deviceName: e.target.value })}
            required
          />
        </div>

        <div className="input-group" style={{ marginBottom: 'var(--spacing-md)' }}>
          <label className="input-label">Loại thiết bị</label>
          <select
            className="input"
            style={{ paddingLeft: 'var(--spacing-md)' }}
            value={deviceInfo.deviceType}
            onChange={(e) => setDeviceInfo({ ...deviceInfo, deviceType: e.target.value })}
          >
            <option value="SENSOR"> Cảm biến</option>
            <option value="PUMP"> Bơm nước</option>
            <option value="CONTROLLER">Bộ điều khiển</option>
          </select>
        </div>

        <button 
          type="submit"
          className="btn btn-primary" 
          style={{ width: '100%' }}
          disabled={loading}
        >
          {loading ? 'Đang đăng ký...' : 'Đăng ký thiết bị'}
        </button>
      </form>
    </div>
  );

  const renderSuccess = () => (
    <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
      <div style={{ fontSize: '64px', marginBottom: 'var(--spacing-md)' }}>🎉</div>
      <h3 className="text-h3 text-primary">Thành công!</h3>
      <p className="text-content" style={{ marginTop: 'var(--spacing-sm)' }}>
        Thiết bị đã được đăng ký. Đang chuyển hướng...
      </p>
    </div>
  );

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to={`/zones/${zoneId}`} className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title">Cấu hình thiết bị</h1>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {/* Progress */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'center',
          gap: 'var(--spacing-md)',
          marginBottom: 'var(--spacing-xl)',
        }}>
          {[1, 2, 3].map(s => (
            <div 
              key={s}
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: '600',
                background: step >= s ? 'var(--primary)' : 'var(--background)',
                color: step >= s ? 'white' : 'var(--text-content)',
                border: step >= s ? 'none' : '2px solid var(--border-color)',
              }}
            >
              {success && s === 3 ? '✓' : s}
            </div>
          ))}
        </div>

        {success ? renderSuccess() : (
          <>
            {step === 1 && renderStep1()}
            {step === 2 && renderStep2()}
            {step === 3 && renderStep3()}
          </>
        )}
      </div>
    </div>
  );
}
