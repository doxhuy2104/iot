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
