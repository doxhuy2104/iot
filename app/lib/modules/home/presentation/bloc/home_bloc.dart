import 'package:app/core/utils/utils.dart';
import 'package:app/modules/home/data/models/location_model.dart';
import 'package:app/modules/home/data/models/weather_model.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/modules/home/data/repositories/home_repository.dart';
import 'package:app/modules/home/presentation/bloc/home_event.dart';
import 'package:app/modules/home/presentation/bloc/home_state.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();

  HomeBloc({required this.repository}) : super(const HomeState.initial()) {
    on<HomeEvent>((event, emit) async {
      if (event is GetWeather) {
        final rt = await repository.getWeather();

        rt.fold(
          (l) {
            Utils.debugLog(l.reason);
          },
          (r) {
            final LocationModel location = r['location'] as LocationModel;
            final WeatherModel weather = r['weather'] as WeatherModel;

            emit(state.setState(location: location, weather: weather));
          },
        );
      }
    });
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state.toJson();
  }
}
