// Fetch-based API helper to avoid CORS issues
// All functions use native fetch with mode: 'same-origin'

const getToken = () => localStorage.getItem('token');

const fetchApi = async (url, options = {}) => {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(token && !url.includes('/api/auth/') ? { Authorization: `Bearer ${token}` } : {}),
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

// Auth API
export const authApi = {
  login: (username, password) =>
    fetchApi('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    }),

  register: (userData) =>
    fetchApi('/api/auth/register', {
      method: 'POST',
      body: JSON.stringify(userData),
    }),

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },
};

// Zone API
export const zoneApi = {
  getAll: () => fetchApi('/api/zones'),
  
  getById: (id) => fetchApi(`/api/zones/${id}`),
  
  create: (data) =>
    fetchApi('/api/zones', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  
  update: (id, data) =>
    fetchApi(`/api/zones/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  
  delete: (id) =>
    fetchApi(`/api/zones/${id}`, {
      method: 'DELETE',
    }),
  
  togglePump: (id, status, targetHumidity = null) =>
    fetchApi('/api/control/water', {
      method: 'POST',
      body: JSON.stringify({ 
        zoneId: parseInt(id), 
        pump: status ? 'ON' : 'OFF',
        ...(targetHumidity && { targetHumidity: parseInt(targetHumidity) }),
      }),
    }),
};

// Sensor API
export const sensorApi = {
  getLatest: (zoneId) => fetchApi(`/api/sensors/zone/${zoneId}/latest`),
  
  getByZone: (zoneId) => fetchApi(`/api/sensors/zone/${zoneId}`),
  
  getByRange: (zoneId, startDate, endDate) =>
    fetchApi(`/api/sensors/zone/${zoneId}/range?startDate=${startDate}&endDate=${endDate}`),
};

// Device API
export const deviceApi = {
  getAll: () => fetchApi('/api/devices'),
  
  getByZone: (zoneId) => fetchApi(`/api/devices/zone/${zoneId}`),
  
  getById: (deviceId) => fetchApi(`/api/devices/${deviceId}`),
  
  create: (data) =>
    fetchApi('/api/devices', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  
  updateStatus: (deviceId, status) =>
    fetchApi(`/api/devices/${deviceId}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    }),
  
  delete: (deviceId) =>
    fetchApi(`/api/devices/${deviceId}`, {
      method: 'DELETE',
    }),
};


// Schedule API
export const scheduleApi = {
  getByZone: (zoneId) => fetchApi(`/api/schedules/zone/${zoneId}`),
  
  create: (zoneId, data) =>
    fetchApi('/api/schedules', {
      method: 'POST',
      body: JSON.stringify({ ...data, zoneId }),
    }),
  
  update: (scheduleId, data) =>
    fetchApi(`/api/schedules/${scheduleId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  
  delete: (scheduleId) =>
    fetchApi(`/api/schedules/${scheduleId}`, {
      method: 'DELETE',
    }),

  toggleActive: (scheduleId, active) =>
    fetchApi(`/api/schedules/${scheduleId}/active?active=${active}`, {
      method: 'PATCH',
    }),
};

// Water Log API
export const waterLogApi = {
  getByZone: (zoneId) => fetchApi(`/api/water-logs/zone/${zoneId}`),
};

// User API
export const userApi = {
  getProfile: () => fetchApi('/api/users/me'),
  
  updateProfile: (data) =>
    fetchApi('/api/users/me', {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
};

// Dashboard API
export const dashboardApi = {
  getStats: () => fetchApi('/api/dashboard/stats'),
};

// Weather API
export const weatherApi = {
  getCurrent: (location) => 
    fetchApi(`/api/weather/current${location ? `?location=${encodeURIComponent(location)}` : ''}`),
  
  getForecast: (location, days = 3) =>
    fetchApi(`/api/weather/forecast?${location ? `location=${encodeURIComponent(location)}&` : ''}days=${days}`),
  
  checkRain: (location) =>
    fetchApi(`/api/weather/check-rain${location ? `?location=${encodeURIComponent(location)}` : ''}`),
};

export default fetchApi;

