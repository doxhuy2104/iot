// Admin API Service - connects to backend admin APIs
// Requires ADMIN role for all endpoints

const getToken = () => localStorage.getItem('token');

const fetchApi = async (url, options = {}) => {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const response = await fetch(url, {
    mode: 'same-origin',
    ...options,
    headers,
  });

  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.message || `Request failed with status ${response.status}`);
  }

  return data;
};

// System Statistics
export const adminApi = {
  // Statistics
  getStatistics: () => fetchApi('/api/admin/statistics'),
  getDailyActivity: () => fetchApi('/api/admin/activity/daily'),
  exportStatistics: () => fetchApi('/api/admin/export/statistics'),

  // User Management
  getUsers: () => fetchApi('/api/admin/users'),
  getUserById: (userId) => fetchApi(`/api/admin/users/${userId}`),
  getUsersByRole: (role) => fetchApi(`/api/admin/users/role/${role}`),
  getUsersByStatus: (isActive) => fetchApi(`/api/admin/users/status/${isActive}`),
  
  updateUser: (userId, data) =>
    fetchApi(`/api/admin/users/${userId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  
  changeUserRole: (userId, role) =>
    fetchApi(`/api/admin/users/${userId}/role?role=${role}`, {
      method: 'PUT',
    }),
  
  activateUser: (userId) =>
    fetchApi(`/api/admin/users/${userId}/activate`, {
      method: 'PUT',
    }),
  
  deactivateUser: (userId) =>
    fetchApi(`/api/admin/users/${userId}/deactivate`, {
      method: 'PUT',
    }),
  
  resetPassword: (userId, newPassword) =>
    fetchApi(`/api/admin/users/${userId}/reset-password?newPassword=${encodeURIComponent(newPassword)}`, {
      method: 'PUT',
    }),
  
  deleteUser: (userId) =>
    fetchApi(`/api/admin/users/${userId}`, {
      method: 'DELETE',
    }),
  
  countUsersByRole: (role) => fetchApi(`/api/admin/users/count/role/${role}`),
  countUsersByStatus: (isActive) => fetchApi(`/api/admin/users/count/status/${isActive}`),

  // Zone Management
  getZones: () => fetchApi('/api/admin/zones'),
  getZoneById: (zoneId) => fetchApi(`/api/admin/zones/${zoneId}`),
  
  deleteZone: (zoneId) =>
    fetchApi(`/api/admin/zones/${zoneId}`, {
      method: 'DELETE',
    }),

  // Device Management
  getDevices: () => fetchApi('/api/admin/devices'),
  getDevicesByStatus: (status) => fetchApi(`/api/admin/devices/status/${status}`),
  
  deleteDevice: (deviceId) =>
    fetchApi(`/api/admin/devices/${deviceId}`, {
      method: 'DELETE',
    }),

  // Alert Management
  getAlerts: () => fetchApi('/api/admin/alerts'),
  
  deleteAlert: (alertId) =>
    fetchApi(`/api/admin/alerts/${alertId}`, {
      method: 'DELETE',
    }),
  
  deleteHandledAlerts: () =>
    fetchApi('/api/admin/alerts/handled', {
      method: 'DELETE',
    }),

  // Data Cleanup
  cleanupSensorData: (daysOld = 30) =>
    fetchApi(`/api/admin/cleanup/sensor-data?daysOld=${daysOld}`, {
      method: 'DELETE',
    }),
};

export default adminApi;
