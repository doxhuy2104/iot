import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Account() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    if (window.confirm('Bạn có chắc muốn đăng xuất?')) {
      logout();
      navigate('/login');
    }
  };

  return (
    <div className="fade-in">
      {/* Header */}
      <div className="navbar">
        <div className="container">
          <h1 className="navbar-title">Tài khoản</h1>
        </div>
      </div>

      <div className="container" style={{ padding: 'var(--spacing-lg) var(--spacing-md)' }}>
        {/* User Info */}
        <div className="card" style={{ marginBottom: 'var(--spacing-lg)' }}>
          <div className="flex items-center gap-lg">
            <div style={{
              width: '64px',
              height: '64px',
              borderRadius: 'var(--radius-full)',
              background: 'var(--primary)',
              color: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '24px',
              fontWeight: 'bold',
            }}>
              {user?.username?.charAt(0)?.toUpperCase() || '👤'}
            </div>
            <div>
              <div className="text-lg font-semibold">{user?.username || 'Người dùng'}</div>
              <div className="text-content">{user?.email || 'email@example.com'}</div>
            </div>
          </div>
        </div>

        {/* Menu Items */}
        <div className="card" style={{ marginBottom: 'var(--spacing-md)' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-md)' }}>
            <Link to="/dashboard" style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: 'var(--spacing-md)',
              padding: 'var(--spacing-sm) 0',
            }}>
              <span>🏠</span>
              <span className="font-medium">Dashboard</span>
              <span style={{ marginLeft: 'auto' }} className="text-content">→</span>
            </Link>
            
            <Link to="/zones" style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: 'var(--spacing-md)',
              padding: 'var(--spacing-sm) 0',
            }}>
              <span>🌱</span>
              <span className="font-medium">Khu vực tưới</span>
              <span style={{ marginLeft: 'auto' }} className="text-content">→</span>
            </Link>
            
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: 'var(--spacing-md)',
              padding: 'var(--spacing-sm) 0',
              cursor: 'pointer',
            }}>
              <span>⚙️</span>
              <span className="font-medium">Cài đặt</span>
              <span style={{ marginLeft: 'auto' }} className="text-content">→</span>
            </div>

            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: 'var(--spacing-md)',
              padding: 'var(--spacing-sm) 0',
              cursor: 'pointer',
            }}>
              <span>ℹ️</span>
              <span className="font-medium">Về ứng dụng</span>
              <span style={{ marginLeft: 'auto' }} className="text-content">→</span>
            </div>
          </div>
        </div>

        {/* Logout Button */}
        <button 
          onClick={handleLogout}
          className="btn btn-danger"
          style={{ width: '100%' }}
        >
          🚪 Đăng xuất
        </button>
      </div>
    </div>
  );
}
