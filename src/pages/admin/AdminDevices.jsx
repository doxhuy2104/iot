import { useState, useEffect } from 'react';
import { adminApi } from '../../services/adminApi';
import AdminLayout from '../../components/admin/AdminLayout';
import { MdDelete, MdRefresh } from 'react-icons/md';

export default function AdminDevices() {
  const [loading, setLoading] = useState(true);
  const [devices, setDevices] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadDevices();
  }, []);

  const loadDevices = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await adminApi.getDevices();
      if (result.data) {
        setDevices(result.data);
      }
    } catch (err) {
      console.error('Failed to load devices:', err);
      setError('Không thể tải danh sách thiết bị');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (deviceId) => {
    if (!confirm('Bạn có chắc chắn muốn xóa thiết bị này?')) return;
    
    try {
      await adminApi.deleteDevice(deviceId);
      loadDevices();
    } catch (err) {
      console.error('Failed to delete device:', err);
      alert('Không thể xóa thiết bị');
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  };

  return (
    <AdminLayout>
      <div className="fade-in">
        <div className="admin-page-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1 className="admin-page-title">Quản lý thiết bị</h1>
              <p className="admin-page-subtitle">Danh sách tất cả thiết bị trong hệ thống</p>
            </div>
            <button className="btn btn-secondary" onClick={loadDevices} disabled={loading}>
              <MdRefresh className={loading ? 'spin' : ''} />
              Làm mới
            </button>
          </div>
        </div>

        {error && (
          <div className="card" style={{ background: 'rgba(255, 82, 82, 0.1)', color: 'var(--danger)', marginBottom: 'var(--spacing-lg)' }}>
            {error}
          </div>
        )}

        <div className="admin-table-container">
          <div className="admin-table-header">
            <h3 className="admin-table-title">Thiết bị ({devices.length})</h3>
          </div>
          
          {loading ? (
            <div className="admin-loading">Đang tải...</div>
          ) : devices.length === 0 ? (
            <div className="admin-empty">Không có thiết bị nào</div>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tên thiết bị</th>
                  <th>Identifier</th>
                  <th>Loại</th>
                  <th>Trạng thái</th>
                  <th>Khu vực</th>
                  <th>MQTT Publish</th>
                  <th>Ngày tạo</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {devices.map((device) => (
                  <tr key={device.deviceId}>
                    <td>{device.deviceId}</td>
                    <td><strong>{device.deviceName}</strong></td>
                    <td><code style={{ background: 'var(--background)', padding: '2px 6px', borderRadius: '4px' }}>{device.identifier}</code></td>
                    <td>{device.type || '-'}</td>
                    <td>
                      <span className={`admin-badge ${device.status?.toLowerCase()}`}>
                        {device.status === 'ONLINE' ? 'Online' : 'Offline'}
                      </span>
                    </td>
                    <td>{device.zoneName || '-'}</td>
                    <td><code style={{ background: 'var(--background)', padding: '2px 6px', borderRadius: '4px', fontSize: '12px' }}>{device.mqttTopicPublish || '-'}</code></td>
                    <td>{formatDate(device.createdAt)}</td>
                    <td>
                      <div className="admin-actions">
                        <button 
                          className="admin-action-btn delete" 
                          onClick={() => handleDelete(device.deviceId)}
                          title="Xóa"
                        >
                          <MdDelete />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
