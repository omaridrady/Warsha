import 'package:warsha/modules/clsUser.dart';

abstract class SettingsEvent {}

class GetUserData extends SettingsEvent {
  String userId;
  GetUserData({required this.userId});
}
