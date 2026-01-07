import 'package:flutter_modular/flutter_modular.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/modules/base/data/repositories/repository.dart';
import 'package:app/modules/base/presentation/bloc/event.dart';
import 'package:app/modules/base/presentation/bloc/state.dart';

class Bloc extends HydratedBloc<Event, State> {
  final Repository repository;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();

  Bloc({required this.repository}) : super(const State.initial()) {
    on<Event>((event, emit) async {
      if (event is SignInRequest) {
        
      }
    });
  }

  @override
  State? fromJson(Map<String, dynamic> json) {
    return State.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(State state) {
    return state.toJson();
  }
}
