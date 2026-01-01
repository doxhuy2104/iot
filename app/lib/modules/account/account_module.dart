import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/modules/account/data/datasources/account_api.dart';
import 'package:app/modules/account/data/repositories/account_repository.dart';
import 'package:app/modules/account/presentation/bloc/account_bloc.dart';

class AccountModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
    i.addSingleton(() => AccountApi());
    i.addSingleton(() => AccountRepository(api: Modular.get<AccountApi>()));
    i.addSingleton(() => AccountBloc(repository: Modular.get<AccountRepository>()));
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);
  }
}
