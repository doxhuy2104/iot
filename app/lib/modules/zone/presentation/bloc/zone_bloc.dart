import 'package:flutter_modular/flutter_modular.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:app/modules/zone/presentation/bloc/zone_event.dart';
import 'package:app/modules/zone/presentation/bloc/zone_state.dart';

class ZoneBloc extends HydratedBloc<ZoneEvent, ZoneState> {
  final ZoneRepository repository;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();

  ZoneBloc({required this.repository}) : super(const ZoneState.initial()) {
    on<ZoneEvent>((event, emit) async {
      if (event is SignInRequest) {
        
      }
    });
  }

  @override
  ZoneState? fromJson(Map<String, dynamic> json) {
    return ZoneState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ZoneState state) {
    return state.toJson();
  }
}
