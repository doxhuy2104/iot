import 'package:flutter_modular/flutter_modular.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/modules/account/data/repositories/account_repository.dart';
import 'package:app/modules/account/presentation/bloc/account_event.dart';
import 'package:app/modules/account/presentation/bloc/account_state.dart';

class AccountBloc extends HydratedBloc<AccountEvent, AccountState> {
  final AccountRepository repository;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();

  AccountBloc({required this.repository}) : super(const AccountState.initial()) {
    on<AccountEvent>((event, emit) async {
      if (event is AccountEvent) {
        
      }
    });
  }

  @override
  AccountState? fromJson(Map<String, dynamic> json) {
    return AccountState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AccountState state) {
    return state.toJson();
  }
}
