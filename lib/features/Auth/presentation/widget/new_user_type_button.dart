import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:warsha/features/Auth/presentation/screens/client_register_screen.dart';
import 'package:warsha/features/Auth/presentation/screens/technician_register_screen.dart';

class NewUserTypeButton extends StatelessWidget {
  final bool isClient;
  const NewUserTypeButton({super.key, required this.isClient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => AuthBloc(),
              child: isClient
                  ? ClientRegisterScreen()
                  : TechnicianRegisterScreen(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  isClient ? Icons.person : Icons.build,
                  color: Color(0xFF0058be),
                  size: 30,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isClient ? "Client" : "Technician",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isClient
                        ? "A user who want to post maintenance requests."
                        : "A user who wants to provide services.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
