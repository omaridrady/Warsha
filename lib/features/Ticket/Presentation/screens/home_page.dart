import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/profile_icon.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/search_bar.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/user_service.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/Service_type_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("WARSHA", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ProfileIcon(
            profileImage: context.read<SettingsBloc>().state.user!.profileImage,
          ),
        ],
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Your home,",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
            ),
            Text(
              "perfectly maintained.",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            CustomSearchBar(),
            SizedBox(height: 20),
            Text(
              "Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  ServiceTypeCard(text: "Plumbing", warshaIcon: Icons.plumbing),
                  ServiceTypeCard(text: "Electrical", warshaIcon: Icons.bolt),
                  ServiceTypeCard(text: "HVAC", warshaIcon: Icons.ac_unit),
                  ServiceTypeCard(
                    text: "Painting",
                    warshaIcon: Icons.format_paint,
                  ),
                  ServiceTypeCard(
                    text: "Carpentry",
                    warshaIcon: Icons.carpenter_outlined,
                  ),
                  ServiceTypeCard(
                    text: "Cleaning",
                    warshaIcon: Icons.cleaning_services_outlined,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
