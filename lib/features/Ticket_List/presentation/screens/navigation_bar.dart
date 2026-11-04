import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_state.dart';

import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_bloc.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_event.dart';
import 'package:warsha/features/Ticket_List/presentation/widgets/custom_nav_bar.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/features/Ticket/Presentation/screens/home_page.dart';
import 'package:warsha/features/Settings/Presentation/Screens/profile_Screen.dart';
import 'package:warsha/pages/tech_profile_screen.dart';
import 'package:warsha/pages/technician_home_page.dart';
import 'package:warsha/features/Ticket_List/presentation/screens/my_tickets_screen.dart';

class PagesNavigator extends StatefulWidget {
  PagesNavigator({super.key});

  @override
  State<PagesNavigator> createState() => _PagesNavigatorState();
}

class _PagesNavigatorState extends State<PagesNavigator> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final clsUser? user = context.read<SettingsBloc>().state.user;
        if (user == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0056C6)),
            ),
          );
        }

        List<Widget> activePages = (user.role == "Client")
            ? [const HomePage(), MyTicketsScreen(), const ProfileScreen()]
            : [
                const TechnicianHomePage(),
                MyTicketsScreen(), // No error now!
                TechProfileScreen(user: user),
              ];
        return Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
          // 3. Use a local variable to decide which list to use for cleaner code
          body: activePages[_selectedIndex],

          bottomNavigationBar: CustomNavBar(
            selectedIndex: _selectedIndex,
            onTapChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) {
                context.read<TicketListBloc>().add(InitiateMyTicketScreen());
              }
            },
            isClient: user.role == "Client",
          ),
        );
      },
    );
  }
}
