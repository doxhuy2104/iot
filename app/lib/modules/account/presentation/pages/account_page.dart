import 'package:app/core/components/app_dialog.dart';
import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/models/user_model.dart';
import 'package:app/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/modules/auth/presentation/bloc/auth_event.dart';
import 'package:app/modules/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        bloc: Modular.get<AuthBloc>(),
        builder: (context, state) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 30),
                _buildMenuSection(),
                const SizedBox(height: 30),
                _buildLogoutButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              user?.fullName?.isNotEmpty == true
                  ? user!.fullName![0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Huy',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Unknown Email',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // Navigate to Edit Profile
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // Navigate to Change Password
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // Navigate to About
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Button(
        onPress: () {
          AppDialog.show(
            title: 'Xác nhận đăng xuất',
            cancelText: 'Huỷ',
            confirmText: 'Xác nhận',
            message: 'Bạn có chắc muốn đăng xuất',
            dismissible: false,
            onConfirm: () {
              Modular.get<AuthBloc>().add(SignOutRequest());
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_outlined, color: AppColors.danger, size: 20),
              SizedBox(width: 8),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
