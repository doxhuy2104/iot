import 'package:app/modules/home/data/datasources/home_api.dart';
import 'package:app/modules/home/data/repositories/home_repository.dart';
import 'package:app/modules/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomeModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
    // Create a separate Dio instance for HomeApi to avoid baseUrl conflicts
    i.addSingleton(() => HomeApi());
    i.addSingleton(() => HomeRepository(api: Modular.get<HomeApi>()));
    i.addSingleton(() => HomeBloc(repository: Modular.get<HomeRepository>()));
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
    // r.child(HomeModuleRoutes.signUp, child: (context) => SignUpPage());
  }
}
