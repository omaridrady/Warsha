import 'package:warsha/modules/clsUser.dart';

class SettingsState {
  clsUser? user;
  String? userId;

  SettingsState({this.user, this.userId});
  // SettingsState copyWith({clsUser? user, String? userId}) {
  //   return SettingsState(
  //     user: user ?? this.user,
  //     userId: userId ?? this.userId,
  //   );
  // }
}
