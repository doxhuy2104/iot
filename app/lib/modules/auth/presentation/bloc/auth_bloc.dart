import 'dart:math';

import 'package:app/core/components/app_dialog.dart';
import 'package:app/core/components/app_indicator.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/constants/app_stores.dart';
import 'package:app/core/helpers/auth_helper.dart';
import 'package:app/core/helpers/navigation_helper.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/models/user_model.dart';
import 'package:app/core/utils/globals.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/app/general/app_module_routes.dart';
import 'package:app/modules/auth/data/repositories/auth_repository.dart';
import 'package:app/modules/auth/general/auth_module_routes.dart';
import 'package:app/modules/auth/presentation/bloc/auth_event.dart';
import 'package:app/modules/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();

  AuthBloc({required this.repository}) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      if (event is SignInRequest) {
        final rt = await repository.login(
          username: event.username,
          password: event.password,
        );
        rt.fold(
          (l) {
            AppIndicator.hide();
            Utils.debugLog(l.reason);
          },
          (r) {
            // final user = UserModel(
            //   email: event.type == 'EMAIL' ? event.email : null,
            //   accessToken: event.token,
            // );
            Globals.globalAccessToken = r.token;
            Globals.globalUserId = r.userId.toString();
            sharedPreferenceHelper.set(
              key: AppStores.kAccessToken,
              value: r.token!,
            );
            sharedPreferenceHelper.set(
              key: AppStores.kUserId,
              value: r.userId.toString(),
            );
            sharedPreferenceHelper.set(
              key: AppStores.kPassword,
              value: event.password,
            );
            Utils.debugLog(r);
            emit(state.setState(user: r));
            AppIndicator.hide();
            NavigationHelper.replace(
              '${AppRoutes.moduleApp}${AppModuleRoutes.main}',
            );
          },
        );
      } else if (event is SignUpRequest) {
        final rt = await repository.register(
          username: event.username,
          email: event.email,
          password: event.password,
        );
        rt.fold(
          (l) {
            Utils.debugLog(l.reason);
            AppIndicator.hide();
          },
          (r) {
            emit(state.setState(email: event.email));
            // NavigationHelper.replace(
            //   '${AppRoutes.moduleApp}${AppModuleRoutes.main}',
            // );
            AppIndicator.hide();
            AppDialog.show(
              title: 'Đăng ký thành công',
              message: 'Vui lòng đăng nhập để tiếp tục',
              confirmText: 'Đăng nhập',
              onConfirm: () {
                NavigationHelper.replace(
                  '${AppRoutes.moduleAuth}${AuthModuleRoutes.signIn}',
                );
              },
            );
          },
        );
      } else if (event is SignOutRequest) {
        void forceLogout() {
          Globals.globalAccessToken = null;
          Globals.globalUserId = null;
          Globals.globalUserUUID = null;
          sharedPreferenceHelper.remove(key: AppStores.kAccessToken);
          sharedPreferenceHelper.remove(key: AppStores.kUserId);
          sharedPreferenceHelper.remove(key: AppStores.kUserUUID);
          emit(state.reset());

          AuthHelper.signOut()
              .then((value) {
                Utils.debugLogSuccess('FB Logout success');
              })
              .catchError((error) {
                Utils.debugLogError('FB Logout error: $error');
              });

          NavigationHelper.reset(
            '${AppRoutes.moduleAuth}${AuthModuleRoutes.signIn}',
          );
        }

        // if (Globals.globalAccessToken != null || Globals.globalUserId != null) {

        // rt.fold(
        //   (l) {
        //     Utils.debugLogError(l.reason);
        //   },
        //   (r) {
        // Utils.debugLogSuccess('Logout request success');
        forceLogout();
        // },
        // );
        // }
      }
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }
}
