import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { authApi } from '../../services/api';

export default function Login() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (username.length < 3) {
      setError('Tên đăng nhập phải có ít nhất 3 ký tự');
      return;
    }
    if (password.length < 8) {
      setError('Mật khẩu phải có ít nhất 8 ký tự');
      return;
    }

    setLoading(true);
    try {
      console.log('Attempting login with:', { username });
      const result = await authApi.login(username, password);
      console.log('Login response:', result);
      
      // API returns: { success, data: { token, userId, username, email, role } }
      const { data } = result;
      const user = {
        id: data.userId,
        username: data.username,
        email: data.email,
        role: data.role,
      };
      login(user, data.token);
      navigate('/dashboard');
    } catch (err) {
      console.error('Login error:', err);
      setError(err.message || 'Đăng nhập thất bại');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <h1 className="auth-title">Đăng nhập</h1>
      
      <form className="auth-form" onSubmit={handleSubmit}>
        {error && (
          <div className="card" style={{ background: 'rgba(255,82,82,0.1)', color: 'var(--danger)' }}>
            {error}
          </div>
        )}
        
        <div className="input-group">
          <label className="input-label">Tên đăng nhập</label>
          <div className="input-wrapper">
            <span className="input-icon">📧</span>
            <input
              type="text"
              className="input"
              placeholder="Nhập tên đăng nhập"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>
        </div>

        <div className="input-group">
          <label className="input-label">Mật khẩu</label>
          <div className="input-wrapper">
            <span className="input-icon">🔒</span>
            <input
              type="password"
              className="input"
              placeholder="Nhập mật khẩu"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
        </div>

        <div style={{ textAlign: 'right' }}>
          <Link to="/forgot-password" className="text-content text-sm">
            Quên mật khẩu?
          </Link>
        </div>

        <button type="submit" className="btn btn-primary" disabled={loading}
          style={{ width: '100%', marginTop: 'var(--spacing-md)' }}>
          {loading ? 'Đang xử lý...' : 'Đăng nhập'}
        </button>
      </form>

      <div className="auth-footer">
        <div className="auth-divider">
          <span className="text-content text-sm">Hoặc đăng nhập với</span>
        </div>
        
        <p className="text-md" style={{ marginTop: 'var(--spacing-lg)' }}>
          Chưa có tài khoản?{' '}
          <Link to="/register" className="auth-link">Đăng ký</Link>
        </p>
      </div>
    </div>
  );
}
