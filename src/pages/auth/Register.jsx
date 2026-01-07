import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { authApi } from '../../services/api';
import { FaUser } from "react-icons/fa";
import { IoLockClosedSharp } from "react-icons/io5";

export default function Register() {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (formData.username.length < 3) {
      setError('Tên đăng nhập phải có ít nhất 3 ký tự');
      return;
    }
    if (!formData.email.includes('@')) {
      setError('Email không hợp lệ');
      return;
    }
    if (formData.password.length < 8) {
      setError('Mật khẩu phải có ít nhất 8 ký tự');
      return;
    }
    if (formData.password !== formData.confirmPassword) {
      setError('Mật khẩu xác nhận không khớp');
      return;
    }

    setLoading(true);
    try {
      const result = await authApi.register({
        username: formData.username,
        email: formData.email,
        password: formData.password,
      });
      console.log('Register success:', result);
      alert('Đăng ký thành công! Vui lòng đăng nhập.');
      navigate('/login');
    } catch (err) {
      console.error('Register error:', err);
      if (err.message?.includes('403') || err.message?.includes('tồn tại')) {
        setError('Tên đăng nhập hoặc email đã tồn tại trong hệ thống');
      } else {
        setError(err.message || 'Đăng ký thất bại');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <h1 className="auth-title">Đăng ký</h1>
      
      <form className="auth-form" onSubmit={handleSubmit}>
        {error && (
          <div className="card" style={{ background: 'rgba(255,82,82,0.1)', color: 'var(--danger)' }}>
            {error}
          </div>
        )}
        
        <div className="input-group">
          <label className="input-label">Tên đăng nhập</label>
          <div className="input-wrapper">
            <span className="input-icon"><FaUser /></span>
            <input
              type="text"
              name="username"
              className="input"
              placeholder="Nhập tên đăng nhập"
              value={formData.username}
              onChange={handleChange}
            />
          </div>
        </div>

        <div className="input-group">
          <label className="input-label">Email</label>
          <div className="input-wrapper">
            <span className="input-icon"><FaUser /></span>
            <input
              type="email"
              name="email"
              className="input"
              placeholder="Nhập email"
              value={formData.email}
              onChange={handleChange}
            />
          </div>
        </div>

        <div className="input-group">
          <label className="input-label">Mật khẩu</label>
          <div className="input-wrapper">
            <span className="input-icon"><IoLockClosedSharp /></span>
            <input
              type="password"
              name="password"
              className="input"
              placeholder="Nhập mật khẩu"
              value={formData.password}
              onChange={handleChange}
            />
          </div>
        </div>

        <div className="input-group">
          <label className="input-label">Xác nhận mật khẩu</label>
          <div className="input-wrapper">
            <span className="input-icon"><IoLockClosedSharp /></span>
            <input
              type="password"
              name="confirmPassword"
              className="input"
              placeholder="Nhập lại mật khẩu"
              value={formData.confirmPassword}
              onChange={handleChange}
            />
          </div>
        </div>

        <button type="submit" className="btn btn-primary" disabled={loading}
          style={{ width: '100%', marginTop: 'var(--spacing-md)' }}>
          {loading ? 'Đang xử lý...' : 'Đăng ký'}
        </button>
      </form>

      <div className="auth-footer">
        <p className="text-md" style={{ marginTop: 'var(--spacing-lg)' }}>
          Đã có tài khoản?{' '}
          <Link to="/login" className="auth-link">Đăng nhập</Link>
        </p>
      </div>
    </div>
  );
}
