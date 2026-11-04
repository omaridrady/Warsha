import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_event.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_state.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/user_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<GetUserData>((event, emit) async {
      clsUser? user = await UserService.getUser(event.userId);
      if(user!= null){
        emit(SettingsState(user: user, userId: user.id));
      }

    });
  }
}
