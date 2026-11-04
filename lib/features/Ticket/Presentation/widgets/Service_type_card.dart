import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/screens/request_screen.dart';
import 'package:warsha/modules/clsUser.dart';

class ServiceTypeCard extends StatelessWidget {
  String text;
  IconData warshaIcon;

  ServiceTypeCard({super.key, required this.text, required this.warshaIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlue[100],
              ),
              child: Center(child: Icon(warshaIcon, color: Color(0xFF0058be))),
            ),
            SizedBox(height: 15),
            Text(text),
          ],
        ),
      ),
      onTap: () {
        final clsUser currentUser = context.read<SettingsBloc>().state.user!;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) {
                final bloc = TicketBloc(currentUser: currentUser);

                return bloc;
              },
              child: RequestScreen(requestType: text),
            ),
          ),
        );
      },
    );
  }
}
