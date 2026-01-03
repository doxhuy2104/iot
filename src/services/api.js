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
  
  togglePump: (id, status) =>
    fetchApi(`/api/zones/${id}/pump`, {
      method: 'POST',
      body: JSON.stringify({ status }),
    }),
};

// Sensor API
export const sensorApi = {
  getData: (zoneId) => fetchApi(`/api/zones/${zoneId}/sensors`),
  
  getHistory: (zoneId, days = 7) =>
    fetchApi(`/api/zones/${zoneId}/sensors/history?days=${days}`),
};

// Schedule API
export const scheduleApi = {
  getByZone: (zoneId) => fetchApi(`/api/zones/${zoneId}/schedules`),
  
  create: (zoneId, data) =>
    fetchApi(`/api/zones/${zoneId}/schedules`, {
      method: 'POST',
      body: JSON.stringify(data),
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

export default fetchApi;
