import { useState, useEffect } from 'react';
import { adminApi } from '../../services/adminApi';
import AdminLayout from '../../components/admin/AdminLayout';
import { MdEdit, MdDelete, MdRefresh } from 'react-icons/md';
import { FaCheck, FaTimes } from 'react-icons/fa';

export default function AdminUsers() {
  const [loading, setLoading] = useState(true);
  const [users, setUsers] = useState([]);
  const [error, setError] = useState(null);
  const [editingUser, setEditingUser] = useState(null);
  const [editForm, setEditForm] = useState({});

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const result = await adminApi.getUsers();
      if (result.data) {
        setUsers(result.data);
      }
    } catch (err) {
      console.error('Failed to load users:', err);
      setError('Không thể tải danh sách người dùng');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleActive = async (user) => {
    try {
      if (user.isActive) {
        await adminApi.deactivateUser(user.userId);
      } else {
        await adminApi.activateUser(user.userId);
      }
      loadUsers();
    } catch (err) {
      console.error('Failed to toggle user status:', err);
      alert('Không thể thay đổi trạng thái người dùng');
    }
  };

  const handleDelete = async (userId) => {
    if (!confirm('Bạn có chắc chắn muốn xóa người dùng này?')) return;
    
    try {
      await adminApi.deleteUser(userId);
      loadUsers();
    } catch (err) {
      console.error('Failed to delete user:', err);
      alert('Không thể xóa người dùng');
    }
  };

  const handleEdit = (user) => {
    setEditingUser(user);
    setEditForm({
      fullName: user.fullName || '',
      email: user.email || '',
      phone: user.phone || '',
      role: user.role || 'USER',
    });
  };

  const handleSaveEdit = async () => {
    try {
      await adminApi.updateUser(editingUser.userId, editForm);
      setEditingUser(null);
      loadUsers();
    } catch (err) {
      console.error('Failed to update user:', err);
      alert('Không thể cập nhật người dùng');
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  };

  return (
    <AdminLayout>
      <div className="fade-in">
        <div className="admin-page-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1 className="admin-page-title">Quản lý người dùng</h1>
              <p className="admin-page-subtitle">Danh sách tất cả người dùng trong hệ thống</p>
            </div>
            <button className="btn btn-secondary" onClick={loadUsers} disabled={loading}>
              <MdRefresh className={loading ? 'spin' : ''} />
              Làm mới
            </button>
          </div>
        </div>

        {error && (
          <div className="card" style={{ background: 'rgba(255, 82, 82, 0.1)', color: 'var(--danger)', marginBottom: 'var(--spacing-lg)' }}>
            {error}
          </div>
        )}

        <div className="admin-table-container">
          <div className="admin-table-header">
            <h3 className="admin-table-title">Người dùng ({users.length})</h3>
          </div>
          
          {loading ? (
            <div className="admin-loading">Đang tải...</div>
          ) : users.length === 0 ? (
            <div className="admin-empty">Không có người dùng nào</div>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Tên đăng nhập</th>
                  <th>Họ tên</th>
                  <th>Email</th>
                  <th>Vai trò</th>
                  <th>Trạng thái</th>
                  <th>Khu vực</th>
                  <th>Ngày tạo</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr key={user.userId}>
                    <td>{user.userId}</td>
                    <td><strong>{user.username}</strong></td>
                    <td>{user.fullName || '-'}</td>
                    <td>{user.email || '-'}</td>
                    <td>
                      <span className={`admin-badge ${user.role?.toLowerCase()}`}>
                        {user.role}
                      </span>
                    </td>
                    <td>
                      <span className={`admin-badge ${user.isActive ? 'active' : 'inactive'}`}>
                        {user.isActive ? 'Hoạt động' : 'Bị khóa'}
                      </span>
                    </td>
                    <td>{user.totalZones || 0}</td>
                    <td>{formatDate(user.createdAt)}</td>
                    <td>
                      <div className="admin-actions">
                        <button 
                          className="admin-action-btn edit" 
                          onClick={() => handleEdit(user)}
                          title="Chỉnh sửa"
                        >
                          <MdEdit />
                        </button>
                        <button 
                          className={`admin-action-btn ${user.isActive ? 'delete' : 'success'}`}
                          onClick={() => handleToggleActive(user)}
                          title={user.isActive ? 'Khóa' : 'Mở khóa'}
                        >
                          {user.isActive ? <FaTimes /> : <FaCheck />}
                        </button>
                        <button 
                          className="admin-action-btn delete" 
                          onClick={() => handleDelete(user.userId)}
                          title="Xóa"
                        >
                          <MdDelete />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        {/* Edit Modal */}
        {editingUser && (
          <div className="admin-modal-overlay" onClick={() => setEditingUser(null)}>
            <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
              <h2 className="admin-modal-title">Chỉnh sửa người dùng</h2>
              
              <div className="admin-form-group">
                <label className="admin-form-label">Họ tên</label>
                <input
                  type="text"
                  className="admin-form-input"
                  value={editForm.fullName}
                  onChange={(e) => setEditForm({ ...editForm, fullName: e.target.value })}
                />
              </div>
              
              <div className="admin-form-group">
                <label className="admin-form-label">Email</label>
                <input
                  type="email"
                  className="admin-form-input"
                  value={editForm.email}
                  onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                />
              </div>
              
              <div className="admin-form-group">
                <label className="admin-form-label">Số điện thoại</label>
                <input
                  type="text"
                  className="admin-form-input"
                  value={editForm.phone}
                  onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                />
              </div>
              
              <div className="admin-form-group">
                <label className="admin-form-label">Vai trò</label>
                <select
                  className="admin-form-select"
                  value={editForm.role}
                  onChange={(e) => setEditForm({ ...editForm, role: e.target.value })}
                >
                  <option value="USER">USER</option>
                  <option value="ADMIN">ADMIN</option>
                </select>
              </div>
              
              <div className="admin-modal-actions">
                <button className="btn btn-secondary" onClick={() => setEditingUser(null)}>
                  Hủy
                </button>
                <button className="btn btn-primary" onClick={handleSaveEdit}>
                  Lưu thay đổi
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
