import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/modules/base/data/datasources/api.dart';
import 'package:app/modules/base/data/repositories/repository.dart';
import 'package:app/modules/base/presentation/bloc/bloc.dart';

class BaseModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
    i.addSingleton(() => Api());
    i.addSingleton(() => Repository(api: Modular.get<Api>()));
    i.addSingleton(() => Bloc(repository: Modular.get<Repository>()));
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
  }
}
