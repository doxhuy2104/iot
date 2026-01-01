import 'package:app/core/components/app_dialog.dart';
import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/components/buttons/primary_button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/modules/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox(
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
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).paddingOnly(top: 500, left: 16, right: 16),
    );
  }
}
