import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { waterLogApi } from '../../services/api';
import { FaDroplet } from "react-icons/fa6";

export default function History() {
  const { id: zoneId } = useParams();
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadLogs();
  }, [zoneId]);

  const loadLogs = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await waterLogApi.getByZone(zoneId);
      console.log('Water logs:', result);
      setLogs(result.data || []);
    } catch (err) {
      console.error('Failed to load water logs:', err);
      setError(err.message || 'Không thể tải lịch sử tưới');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
      hour: '2-digit',
      minute: '2-digit',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  };

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container flex items-center gap-md">
          <Link to={`/zones/${zoneId}`} className="btn btn-icon" style={{ background: 'rgba(255,255,255,0.2)' }}>
            ←
          </Link>
          <h1 className="navbar-title">Lịch sử tưới</h1>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div className="text-lg">Đang tải...</div>
          </div>
        ) : error ? (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}>⚠️</div>
            <p className="text-danger">{error}</p>
          </div>
        ) : logs.length === 0 ? (
          <div className="card" style={{ textAlign: 'center', padding: 'var(--spacing-xl)' }}>
            <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}>📜</div>
            <p className="text-content">Chưa có lịch sử tưới nào</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-sm)' }}>
            {logs.map((log, index) => (
              <div key={log.logId || index} className="card" style={{ padding: 'var(--spacing-md)' }}>
                <div className="flex justify-between items-center">
                  <div>
                    <div className="font-semibold">
                      {formatDate(log.startedAt)}
                    </div>
                    <div className="text-sm text-content">
                      {log.source || 'Manual'}
                    </div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div className="flex items-center gap-xs" style={{ color: 'var(--primary)' }}>
                      <span><FaDroplet /></span>
                      <span className="font-bold">{(log.waterVolumeLiters || 0).toFixed(1)} L</span>
                    </div>
                    <div className="flex items-center gap-xs text-sm text-content">
                      <span>⏱️</span>
                      <span>{log.durationSeconds || 0} giây</span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
