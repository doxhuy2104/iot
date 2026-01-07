import { NavLink } from 'react-router-dom';
import './Layout.css';
import { PiPottedPlantFill } from "react-icons/pi";
import { FaUser } from "react-icons/fa";
import { GoHomeFill } from "react-icons/go";

export default function Layout({ children }) {
  return (
    <div className="app-layout">
      <main className="app-main">
        {children}
      </main>
      
      {/* Bottom Navigation */}
      <nav className="bottom-nav">
        <NavLink to="/dashboard" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <span className="nav-icon"><GoHomeFill /></span>
          <span className="nav-label">Trang chủ</span>
        </NavLink>
        <NavLink to="/zones" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <span className="nav-icon"><PiPottedPlantFill className="text-2xl" /></span>
          <span className="nav-label">Khu vực</span>
        </NavLink>
        <NavLink to="/account" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <span className="nav-icon"><FaUser /></span>
          <span className="nav-label">Tài khoản</span>
        </NavLink>
      </nav>
    </div>
  );
}
