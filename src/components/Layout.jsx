import { NavLink } from 'react-router-dom';
import './Layout.css';

export default function Layout({ children }) {
  return (
    <div className="app-layout">
      <main className="app-main">
        {children}
      </main>
      
      {/* Bottom Navigation */}
      <nav className="bottom-nav">
        <NavLink to="/dashboard" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <span className="nav-icon">🏠</span>
          <span className="nav-label">Trang chủ</span>
        </NavLink>
        <NavLink to="/zones" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <span className="nav-icon">🌱</span>
          <span className="nav-label">Khu vực</span>
        </NavLink>
        <NavLink to="/account" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <span className="nav-icon">👤</span>
          <span className="nav-label">Tài khoản</span>
        </NavLink>
      </nav>
    </div>
  );
}
