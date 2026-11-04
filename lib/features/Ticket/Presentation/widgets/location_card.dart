import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_state.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Color(0xFFF8FAFC),
                  ),
                  child: state.mapImageUrl != null
                      ? Image.network(state.mapImageUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.location_on_sharp,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    context.read<TicketBloc>().add(GetLocation());
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    side: BorderSide(color: Color(0xFF0058be)),
                  ),
                  child: state.isLocationLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF0058be),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Get Your Location",
                          style: TextStyle(color: Color(0xFF0058be)),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
