import { useState, useEffect } from 'react';
import { adminApi } from '../../services/adminApi';
import AdminLayout from '../../components/admin/AdminLayout';
import { MdDelete, MdRefresh, MdVisibility } from 'react-icons/md';

export default function AdminZones() {
  const [loading, setLoading] = useState(true);
  const [zones, setZones] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadZones();
  }, []);

  const loadZones = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await adminApi.getZones();
      if (result.data) {
        setZones(result.data);
      }
    } catch (err) {
      console.error('Failed to load zones:', err);
      setError('Không thể tải danh sách khu vực');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (zoneId) => {
    if (!confirm('Bạn có chắc chắn muốn xóa khu vực này? Tất cả dữ liệu liên quan sẽ bị xóa.')) return;
    
    try {
      await adminApi.deleteZone(zoneId);
      loadZones();
    } catch (err) {
      console.error('Failed to delete zone:', err);
      alert('Không thể xóa khu vực');
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
              <h1 className="admin-page-title">Quản lý khu vực</h1>
              <p className="admin-page-subtitle">Danh sách tất cả khu vực trong hệ thống</p>
            </div>
            <button className="btn btn-secondary" onClick={loadZones} disabled={loading}>
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
            <h3 className="admin-table-title">Khu vực ({zones.length})</h3>
          </div>
          
          {loading ? (
            <div className="admin-loading">Đang tải...</div>
          ) : zones.length === 0 ? (
            <div className="admin-empty">Không có khu vực nào</div>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tên khu vực</th>
                  <th>Mô tả</th>
                  <th>Chủ sở hữu</th>
                  <th>Ngưỡng độ ẩm</th>
                  <th>Chế độ</th>
                  <th>Thiết bị</th>
                  <th>Ngày tạo</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {zones.map((zone) => (
                  <tr key={zone.zoneId}>
                    <td>{zone.zoneId}</td>
                    <td><strong>{zone.zoneName}</strong></td>
                    <td>{zone.description || '-'}</td>
                    <td>{zone.username || '-'}</td>
                    <td>{zone.thresholdMin}% - {zone.thresholdMax}%</td>
                    <td>
                      <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                        {zone.autoMode && <span className="admin-badge active">Tự động</span>}
                        {zone.weatherMode && <span className="admin-badge info">Thời tiết</span>}
                        {!zone.autoMode && !zone.weatherMode && <span className="admin-badge inactive">Thủ công</span>}
                      </div>
                    </td>
                    <td>{zone.deviceCount || 0}</td>
                    <td>{formatDate(zone.createdAt)}</td>
                    <td>
                      <div className="admin-actions">
                        <button 
                          className="admin-action-btn delete" 
                          onClick={() => handleDelete(zone.zoneId)}
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
