import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/modules/home/general/home_module_routes.dart';
import 'package:app/modules/home/presentation/pages/home_page.dart';

class HomeModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
    // i.addSingleton(() => HomeApi());
    // i.addSingleton(() => HomeRepository(api: Modular.get<HomeApi>()));
    // i.addSingleton(() => HomeBloc(repository: Modular.get<HomeRepository>()));
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
    // r.child(HomeModuleRoutes.signUp, child: (context) => SignUpPage());
    // r.child(
    //   HomeModuleRoutes.forgotPassword,
    //   child: (context) => ForgotPasswordPage(),
    // );
  }
}
