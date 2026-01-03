import 'package:app/modules/zone/data/datasources/zone_api.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:app/modules/zone/general/zone_module_routes.dart';
import 'package:app/modules/zone/presentation/bloc/zone_bloc.dart';
import 'package:app/modules/zone/presentation/pages/add_device_page.dart';
import 'package:app/modules/zone/presentation/pages/create_zone_page.dart';
import 'package:app/modules/zone/presentation/pages/zone_detail_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

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

    r.child(
      ZoneModuleRoutes.zoneDetail,
      child: (context) => ZoneDetailPage(zoneId: r.args.data['zoneId']),
    );
    r.child(
      ZoneModuleRoutes.addDevice,
      child: (context) => AddDevicePage(zoneId: r.args.data['zoneId']),
    );
    r.child(ZoneModuleRoutes.createZone, child: (context) => CreateZonePage());
  }
}
