import 'package:app/modules/zone/zone_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/core/constants/app_environment.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/network/dio_client.dart';
import 'package:app/modules/app/app_module.dart';
import 'package:app/modules/auth/auth_module.dart';
import 'package:app/modules/home/home_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainModule extends Module {
  final SharedPreferences sharedPreferences;

  MainModule({required this.sharedPreferences});

  @override
  void binds(Injector i) {
    super.binds(i);

    i.addSingleton(
      () => SharedPreferenceHelper(sharedPreferences: sharedPreferences),
    );

    i.addSingleton(() => Dio());

    i.addSingleton(() => DioClient(Modular.get<Dio>(), AppEnvironment.baseUrl));

    // i.addSingleton(() => AppLanguageBloc());
  }

  @override
  List<Module> get imports => [AppModule(), AuthModule(), ZoneModule()];

  @override
  void routes(RouteManager r) {
    super.routes(r);
    r.module(AppRoutes.moduleApp, module: AppModule());
    r.module(AppRoutes.moduleAuth, module: AuthModule());
    r.module(AppRoutes.moduleHome, module: HomeModule());
    r.module(AppRoutes.moduleZone, module: ZoneModule());
  }
}
