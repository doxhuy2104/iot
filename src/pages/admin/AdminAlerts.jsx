import { useState, useEffect } from 'react';
import { adminApi } from '../../services/adminApi';
import AdminLayout from '../../components/admin/AdminLayout';
import { MdDelete, MdRefresh, MdDeleteSweep } from 'react-icons/md';

export default function AdminAlerts() {
  const [loading, setLoading] = useState(true);
  const [alerts, setAlerts] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadAlerts();
  }, []);

  const loadAlerts = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await adminApi.getAlerts();
      if (result.data) {
        setAlerts(result.data);
      }
    } catch (err) {
      console.error('Failed to load alerts:', err);
      setError('Không thể tải danh sách cảnh báo');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (alertId) => {
    if (!confirm('Bạn có chắc chắn muốn xóa cảnh báo này?')) return;
    
    try {
      await adminApi.deleteAlert(alertId);
      loadAlerts();
    } catch (err) {
      console.error('Failed to delete alert:', err);
      alert('Không thể xóa cảnh báo');
    }
  };

  const handleDeleteHandled = async () => {
    if (!confirm('Bạn có chắc chắn muốn xóa tất cả cảnh báo đã xử lý?')) return;
    
    try {
      await adminApi.deleteHandledAlerts();
      loadAlerts();
    } catch (err) {
      console.error('Failed to delete handled alerts:', err);
      alert('Không thể xóa cảnh báo đã xử lý');
    }
  };

  const formatDateTime = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getSeverityBadge = (severity) => {
    const severityMap = {
      CRITICAL: { class: 'critical', label: 'Nghiêm trọng' },
      WARNING: { class: 'warning', label: 'Cảnh báo' },
      INFO: { class: 'info', label: 'Thông tin' },
    };
    const config = severityMap[severity] || { class: 'info', label: severity };
    return <span className={`admin-badge ${config.class}`}>{config.label}</span>;
  };

  const handledCount = alerts.filter(a => a.isHandled).length;

  return (
    <AdminLayout>
      <div className="fade-in">
        <div className="admin-page-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1 className="admin-page-title">Quản lý cảnh báo</h1>
              <p className="admin-page-subtitle">Danh sách tất cả cảnh báo trong hệ thống</p>
            </div>
            <div style={{ display: 'flex', gap: 'var(--spacing-sm)' }}>
              {handledCount > 0 && (
                <button className="btn btn-danger" onClick={handleDeleteHandled}>
                  <MdDeleteSweep />
                  Xóa đã xử lý ({handledCount})
                </button>
              )}
              <button className="btn btn-secondary" onClick={loadAlerts} disabled={loading}>
                <MdRefresh className={loading ? 'spin' : ''} />
                Làm mới
              </button>
            </div>
          </div>
        </div>

        {error && (
          <div className="card" style={{ background: 'rgba(255, 82, 82, 0.1)', color: 'var(--danger)', marginBottom: 'var(--spacing-lg)' }}>
            {error}
          </div>
        )}

        <div className="admin-table-container">
          <div className="admin-table-header">
            <h3 className="admin-table-title">Cảnh báo ({alerts.length})</h3>
          </div>
          
          {loading ? (
            <div className="admin-loading">Đang tải...</div>
          ) : alerts.length === 0 ? (
            <div className="admin-empty">Không có cảnh báo nào</div>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Mức độ</th>
                  <th>Nội dung</th>
                  <th>Khu vực</th>
                  <th>Thiết bị</th>
                  <th>Trạng thái</th>
                  <th>Xử lý bởi</th>
                  <th>Thời gian</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {alerts.map((alert) => (
                  <tr key={alert.alertId}>
                    <td>{alert.alertId}</td>
                    <td>{getSeverityBadge(alert.severity)}</td>
                    <td style={{ maxWidth: '200px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {alert.message}
                    </td>
                    <td>{alert.zoneName || '-'}</td>
                    <td>{alert.deviceName || '-'}</td>
                    <td>
                      <span className={`admin-badge ${alert.isHandled ? 'active' : 'inactive'}`}>
                        {alert.isHandled ? 'Đã xử lý' : 'Chưa xử lý'}
                      </span>
                    </td>
                    <td>{alert.handledByUsername || '-'}</td>
                    <td>{formatDateTime(alert.createdAt)}</td>
                    <td>
                      <div className="admin-actions">
                        <button 
                          className="admin-action-btn delete" 
                          onClick={() => handleDelete(alert.alertId)}
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
