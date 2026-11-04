import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/screens/request_screen.dart';
import 'package:warsha/features/Ticket/data/data_sources/request_service.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_bloc.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_event.dart';
import 'package:warsha/modules/clsUser.dart';

class PendingTicketCard extends StatelessWidget {
  clsRequest request;
  PendingTicketCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Icon(request.getWarshaIcon, color: Colors.grey[700]),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      request.description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Requested: ${request.formatedDate}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final clsUser currentUser = context
                      .read<SettingsBloc>()
                      .state
                      .user!;

                  final result = await Navigator.of(context).push<clsRequest?>(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => TicketBloc(
                          currentUser: currentUser,
                          editReuqest: request,
                        ),

                        child: RequestScreen(requestType: request.requestType),
                      ),
                    ),
                  );
                  if(result != null){
                    context.read<TicketListBloc>().add(UpdatePendingTicket(request: result));
                  }
                },
                icon: Icon(Icons.edit_outlined, color: Colors.grey),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, request.id!),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext innerContext, String requestId) {
    showDialog(
      context: innerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this request? "),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Closes the dialog
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            // Delete Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                RequestService.deleteRequest(request.id!);
                innerContext.read<TicketListBloc>().add(DeleteTicket(requestId: request.id!));
                Navigator.of(context).pop();

                // 3. (Optional) Show a success SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Request deleted successfully")),
                );
              },
              child: const Text(
                "DELETE",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
