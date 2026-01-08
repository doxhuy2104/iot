import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import './AdminLayout.css';
import { MdDashboard, MdPeople, MdDevices, MdNotifications, MdLogout } from 'react-icons/md';
import { PiPottedPlantFill } from 'react-icons/pi';
import { RiAdminFill } from 'react-icons/ri';

export default function AdminLayout({ children }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="admin-layout">
      {/* Sidebar */}
      <aside className="admin-sidebar">
        <div className="admin-logo">
          <RiAdminFill className="admin-logo-icon" />
          <span>Admin Panel</span>
        </div>
        
        <nav className="admin-nav">
          <NavLink to="/admin" end className={({ isActive }) => `admin-nav-item ${isActive ? 'active' : ''}`}>
            <MdDashboard className="admin-nav-icon" />
            <span>Dashboard</span>
          </NavLink>
          <NavLink to="/admin/users" className={({ isActive }) => `admin-nav-item ${isActive ? 'active' : ''}`}>
            <MdPeople className="admin-nav-icon" />
            <span>Người dùng</span>
          </NavLink>
          <NavLink to="/admin/zones" className={({ isActive }) => `admin-nav-item ${isActive ? 'active' : ''}`}>
            <PiPottedPlantFill className="admin-nav-icon" />
            <span>Khu vực</span>
          </NavLink>
          <NavLink to="/admin/devices" className={({ isActive }) => `admin-nav-item ${isActive ? 'active' : ''}`}>
            <MdDevices className="admin-nav-icon" />
            <span>Thiết bị</span>
          </NavLink>
          <NavLink to="/admin/alerts" className={({ isActive }) => `admin-nav-item ${isActive ? 'active' : ''}`}>
            <MdNotifications className="admin-nav-icon" />
            <span>Cảnh báo</span>
          </NavLink>
        </nav>

        <div className="admin-sidebar-footer">
          <div className="admin-user-info">
            <span className="admin-user-name">{user?.username || 'Admin'}</span>
            <span className="admin-user-role">Administrator</span>
          </div>
          <button className="admin-logout-btn" onClick={handleLogout}>
            <MdLogout className="admin-nav-icon" />
            <span>Đăng xuất</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="admin-main">
        {children}
      </main>
    </div>
  );
}
