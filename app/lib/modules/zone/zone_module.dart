import 'package:app/modules/zone/general/zone_module_routes.dart';
import 'package:app/modules/zone/presentation/pages/zone_detail_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/modules/zone/data/datasources/zone_api.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:app/modules/zone/presentation/bloc/zone_bloc.dart';

class ZoneModule extends Module {
  @override
  void exportedBinds(Injector i) {
    super.exportedBinds(i);
    i.addSingleton(() => ZoneApi());
    i.addSingleton(() => ZoneRepository(api: Modular.get<ZoneApi>()));
    i.addSingleton(() => ZoneBloc(repository: Modular.get<ZoneRepository>()));
  }

  @override
  void routes(RouteManager r) {
    super.routes(r);

    r.child(ZoneModuleRoutes.zoneDetail, child: (context) => ZoneDetailPage());
  }
}
