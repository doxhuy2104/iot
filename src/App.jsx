import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';

// Pages
import Login from './pages/auth/Login';
import Register from './pages/auth/Register';
import ForgotPassword from './pages/auth/ForgotPassword';
import Dashboard from './pages/Dashboard';
import Zones from './pages/zones/Zones';
import ZoneDetail from './pages/zones/ZoneDetail';
import AddZone from './pages/zones/AddZone';
import EditZone from './pages/zones/EditZone';
import SetupDevice from './pages/devices/SetupDevice';
import AddSchedule from './pages/zones/AddSchedule';
import History from './pages/zones/History';
import Account from './pages/Account';

// Admin Pages
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminUsers from './pages/admin/AdminUsers';
import AdminZones from './pages/admin/AdminZones';
import AdminDevices from './pages/admin/AdminDevices';
import AdminAlerts from './pages/admin/AdminAlerts';

// Components
import Layout from './components/Layout';

// Protected Route wrapper
function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();
  
  if (loading) {
    return (
      <div style={{ 
        minHeight: '100vh', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center' 
      }}>
        <div className="text-lg">Đang tải...</div>
      </div>
    );
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return <Layout>{children}</Layout>;
}

// Admin Route - only for ADMIN role
function AdminRoute({ children }) {
  const { isAuthenticated, user, loading } = useAuth();
  
  if (loading) {
    return (
      <div style={{ 
        minHeight: '100vh', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center' 
      }}>
        <div className="text-lg">Đang tải...</div>
      </div>
    );
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  // Check if user has ADMIN role
  if (user?.role !== 'ADMIN') {
    return <Navigate to="/dashboard" replace />;
  }
  
  return children;
}

// Public Route - redirect to dashboard if already logged in
function PublicRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();
  
  if (loading) {
    return (
      <div style={{ 
        minHeight: '100vh', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center' 
      }}>
        <div className="text-lg">Đang tải...</div>
      </div>
    );
  }
  
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }
  
  return children;
}

function AppRoutes() {
  return (
    <Routes>
      {/* Public Routes */}
      <Route path="/login" element={<PublicRoute><Login /></PublicRoute>} />
      <Route path="/register" element={<PublicRoute><Register /></PublicRoute>} />
      <Route path="/forgot-password" element={<PublicRoute><ForgotPassword /></PublicRoute>} />
      
      {/* Protected Routes */}
      <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
      <Route path="/zones" element={<ProtectedRoute><Zones /></ProtectedRoute>} />
      <Route path="/zones/add" element={<ProtectedRoute><AddZone /></ProtectedRoute>} />
      <Route path="/zones/:id" element={<ProtectedRoute><ZoneDetail /></ProtectedRoute>} />
      <Route path="/zones/:id/edit" element={<ProtectedRoute><EditZone /></ProtectedRoute>} />
      <Route path="/zones/:id/setup-device" element={<ProtectedRoute><SetupDevice /></ProtectedRoute>} />
      <Route path="/zones/:id/add-schedule" element={<ProtectedRoute><AddSchedule /></ProtectedRoute>} />
      <Route path="/zones/:id/history" element={<ProtectedRoute><History /></ProtectedRoute>} />
      <Route path="/account" element={<ProtectedRoute><Account /></ProtectedRoute>} />
      
      {/* Admin Routes - ADMIN role only */}
      <Route path="/admin" element={<AdminRoute><AdminDashboard /></AdminRoute>} />
      <Route path="/admin/users" element={<AdminRoute><AdminUsers /></AdminRoute>} />
      <Route path="/admin/zones" element={<AdminRoute><AdminZones /></AdminRoute>} />
      <Route path="/admin/devices" element={<AdminRoute><AdminDevices /></AdminRoute>} />
      <Route path="/admin/alerts" element={<AdminRoute><AdminAlerts /></AdminRoute>} />
      
      {/* Default redirect */}
      <Route path="/" element={<Navigate to="/login" replace />} />
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
