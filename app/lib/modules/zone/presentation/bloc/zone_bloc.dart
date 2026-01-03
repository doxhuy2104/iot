import 'package:app/core/components/app_indicator.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/models/zone_model.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:app/modules/zone/presentation/bloc/zone_event.dart';
import 'package:app/modules/zone/presentation/bloc/zone_state.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ZoneBloc extends HydratedBloc<ZoneEvent, ZoneState> {
  final ZoneRepository repository;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();

  ZoneBloc({required this.repository}) : super(const ZoneState.initial()) {
    on<ZoneEvent>((event, emit) async {
      if (event is CreateZone) {
        // emit(state.copyWith(status: ZoneStatus.loading));
        final result = await repository.createZone(
          zoneName: event.zoneName,
          location: event.location,
          description: event.description,
          longitude: event.longitude,
          latitude: event.latitude,
          thresholdValue: event.thresholdValue,
          autoMode: event.autoMode,
          weatherMode: event.weatherMode,
        );

        result.fold(
          (failure) {
            emit(state.reset());
            AppIndicator.hide();
          },
          (data) {
            AppIndicator.hide();
            Utils.debugLog(data);
            final currentZones = state.zones;
            // Assuming data is Map<String, dynamic> and might be wrapped in "data" field
            final mapData = data is Map<String, dynamic>
                ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
                : data;
            final newZone = ZoneModel.fromJson(mapData);
            if (newZone != null) {
              final updatedZones = List<ZoneModel>.from(currentZones)
                ..add(newZone);
              emit(state.setState(zones: updatedZones));
            }
            // event.onSuccess?.call(data);
          },
        );
      } else if (event is GetZones) {
        final result = await repository.getZones();
        result.fold(
          (failure) {
            Utils.debugLog(failure.reason);
          },
          (zones) {
            emit(state.setState(zones: zones));
          },
        );
      } else if (event is UpdateZoneEvent) {
        AppIndicator.show();
        final result = await repository.updateZone(
          id: event.zoneId,
          zoneName: event.zoneName,
          location: event.location,
          description: event.description,
          longitude: event.longitude,
          latitude: event.latitude,
          thresholdValue: event.thresholdValue,
          autoMode: event.autoMode,
          weatherMode: event.weatherMode,
          pumpStatus: event.pumpStatus,
        );
        result.fold(
          (failure) {
            Utils.debugLog(failure.reason);
            Utils.showToast(failure.reason);
            AppIndicator.hide();
          },
          (updatedZone) {
            AppIndicator.hide();
            final currentZones = List<ZoneModel>.from(state.zones);
            final index = currentZones.indexWhere(
              (z) => z.zoneId == updatedZone.zoneId,
            );
            if (index != -1) {
              currentZones[index] = updatedZone;
              emit(state.setState(zones: currentZones));
            }
            Utils.showToast('Updated zone successfully');
          },
        );
      } else if (event is DeleteZoneEvent) {
        AppIndicator.show();
        final result = await repository.deleteZone(event.zoneId);
        result.fold(
          (failure) {
            Utils.debugLog(failure.reason);
            Utils.showToast(failure.reason);
            AppIndicator.hide();
          },
          (success) {
            AppIndicator.hide();
            final currentZones = List<ZoneModel>.from(state.zones);
            currentZones.removeWhere((z) => z.zoneId == event.zoneId);
            emit(state.setState(zones: currentZones));
            Utils.showToast('Deleted zone successfully');
          },
        );
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
