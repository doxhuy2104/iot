import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { adminApi } from '../../services/adminApi';
import AdminLayout from '../../components/admin/AdminLayout';
import { MdPeople, MdDevices, MdNotifications, MdRefresh } from 'react-icons/md';
import { PiPottedPlantFill } from 'react-icons/pi';
import { FaCheckCircle, FaTimesCircle } from 'react-icons/fa';

export default function AdminDashboard() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadStatistics();
  }, []);

  const loadStatistics = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await adminApi.getStatistics();
      if (result.data) {
        setStats(result.data);
      }
    } catch (err) {
      console.error('Failed to load statistics:', err);
      setError('Không thể tải dữ liệu thống kê');
    } finally {
      setLoading(false);
    }
  };

  return (
    <AdminLayout>
      <div className="fade-in">
        <div className="admin-page-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1 className="admin-page-title">Dashboard</h1>
              <p className="admin-page-subtitle">Tổng quan hệ thống tưới tiêu thông minh</p>
            </div>
            <button className="btn btn-secondary" onClick={loadStatistics} disabled={loading}>
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

        {loading ? (
          <div className="admin-loading">Đang tải dữ liệu...</div>
        ) : stats ? (
          <>
            {/* User Statistics */}
            <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)' }}>Người dùng</h2>
            <div className="admin-stats-grid">
              <div className="admin-stat-card">
                <div className="admin-stat-icon users">
                  <MdPeople />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.totalUsers || 0}</div>
                  <div className="admin-stat-label">Tổng người dùng</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon success">
                  <FaCheckCircle />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.activeUsers || 0}</div>
                  <div className="admin-stat-label">Đang hoạt động</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon danger">
                  <FaTimesCircle />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.inactiveUsers || 0}</div>
                  <div className="admin-stat-label">Bị khóa</div>
                </div>
              </div>
            </div>

            {/* Zone & Device Statistics */}
            <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)', marginTop: 'var(--spacing-lg)' }}>Khu vực & Thiết bị</h2>
            <div className="admin-stats-grid">
              <div className="admin-stat-card">
                <div className="admin-stat-icon zones">
                  <PiPottedPlantFill />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.totalZones || 0}</div>
                  <div className="admin-stat-label">Tổng khu vực</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon devices">
                  <MdDevices />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.totalDevices || 0}</div>
                  <div className="admin-stat-label">Tổng thiết bị</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon success">
                  <MdDevices />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.onlineDevices || 0}</div>
                  <div className="admin-stat-label">Thiết bị online</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon danger">
                  <MdDevices />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.offlineDevices || 0}</div>
                  <div className="admin-stat-label">Thiết bị offline</div>
                </div>
              </div>
            </div>

            {/* Alert Statistics */}
            <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)', marginTop: 'var(--spacing-lg)' }}>Cảnh báo</h2>
            <div className="admin-stats-grid">
              <div className="admin-stat-card">
                <div className="admin-stat-icon alerts">
                  <MdNotifications />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.totalAlerts || 0}</div>
                  <div className="admin-stat-label">Tổng cảnh báo</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon danger">
                  <MdNotifications />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.unhandledAlerts || 0}</div>
                  <div className="admin-stat-label">Chưa xử lý</div>
                </div>
              </div>
              <div className="admin-stat-card">
                <div className="admin-stat-icon danger">
                  <MdNotifications />
                </div>
                <div className="admin-stat-info">
                  <div className="admin-stat-value">{stats.criticalAlerts || 0}</div>
                  <div className="admin-stat-label">Nghiêm trọng</div>
                </div>
              </div>
            </div>

            {/* Quick Links */}
            <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-md)', marginTop: 'var(--spacing-lg)' }}>Thao tác nhanh</h2>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 'var(--spacing-md)' }}>
              <Link to="/admin/users" className="card" style={{ textAlign: 'center', cursor: 'pointer' }}>
                <MdPeople style={{ fontSize: '32px', color: 'var(--primary)', marginBottom: 'var(--spacing-sm)' }} />
                <div className="font-semibold">Quản lý người dùng</div>
              </Link>
              <Link to="/admin/zones" className="card" style={{ textAlign: 'center', cursor: 'pointer' }}>
                <PiPottedPlantFill style={{ fontSize: '32px', color: 'var(--primary)', marginBottom: 'var(--spacing-sm)' }} />
                <div className="font-semibold">Quản lý khu vực</div>
              </Link>
              <Link to="/admin/devices" className="card" style={{ textAlign: 'center', cursor: 'pointer' }}>
                <MdDevices style={{ fontSize: '32px', color: 'var(--primary)', marginBottom: 'var(--spacing-sm)' }} />
                <div className="font-semibold">Quản lý thiết bị</div>
              </Link>
              <Link to="/admin/alerts" className="card" style={{ textAlign: 'center', cursor: 'pointer' }}>
                <MdNotifications style={{ fontSize: '32px', color: 'var(--primary)', marginBottom: 'var(--spacing-sm)' }} />
                <div className="font-semibold">Quản lý cảnh báo</div>
              </Link>
            </div>
          </>
        ) : null}
      </div>
    </AdminLayout>
  );
}
