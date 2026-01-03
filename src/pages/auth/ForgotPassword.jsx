import { useState } from 'react';
import { Link } from 'react-router-dom';

export default function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!email.includes('@')) {
      setError('Email không hợp lệ');
      return;
    }

    setLoading(true);
    try {
      // API call would go here
      // await authApi.forgotPassword(email);
      setSuccess(true);
    } catch (err) {
      setError(err.response?.data?.message || 'Có lỗi xảy ra');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="auth-container">
        <div className="card fade-in" style={{ textAlign: 'center' }}>
          <div style={{ fontSize: '48px', marginBottom: 'var(--spacing-md)' }}>✉️</div>
          <h2 className="text-h3" style={{ marginBottom: 'var(--spacing-sm)' }}>
            Kiểm tra email
          </h2>
          <p className="text-content">
            Chúng tôi đã gửi hướng dẫn đặt lại mật khẩu đến email của bạn.
          </p>
          <Link to="/login" className="btn btn-primary" style={{ marginTop: 'var(--spacing-lg)' }}>
            Quay lại đăng nhập
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="auth-container">
      <Link to="/login" className="text-content text-sm" style={{ marginBottom: 'var(--spacing-lg)', display: 'block' }}>
        ← Quay lại
      </Link>
      
      <h1 className="auth-title">Quên mật khẩu</h1>
      <p className="text-content" style={{ marginBottom: 'var(--spacing-xl)' }}>
        Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu.
      </p>
      
      <form className="auth-form" onSubmit={handleSubmit}>
        {error && (
          <div className="card" style={{ background: 'rgba(255,82,82,0.1)', color: 'var(--danger)' }}>
            {error}
          </div>
        )}
        
        <div className="input-group">
          <label className="input-label">Email</label>
          <div className="input-wrapper">
            <span className="input-icon">📧</span>
            <input
              type="email"
              className="input"
              placeholder="Nhập email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
        </div>

        <button type="submit" className="btn btn-primary" disabled={loading}
          style={{ width: '100%', marginTop: 'var(--spacing-md)' }}>
          {loading ? 'Đang xử lý...' : 'Gửi yêu cầu'}
        </button>
      </form>
    </div>
  );
}
