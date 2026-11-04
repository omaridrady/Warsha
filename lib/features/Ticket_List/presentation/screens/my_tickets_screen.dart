import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_state.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_bloc.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_state.dart';
import 'package:warsha/features/Ticket_List/presentation/widgets/active_ticket_card.dart';
import 'package:warsha/features/Ticket_List/presentation/widgets/histrotical_ticket_card.dart';
import 'package:warsha/features/Ticket_List/presentation/widgets/pending_ticket_card.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/profile_icon.dart';
import 'package:warsha/modules/clsProposals.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/map_page.dart';
import 'package:warsha/pages/proposals_screen.dart';
import 'package:warsha/features/Ticket/Presentation/screens/request_screen.dart';
import 'package:warsha/features/Ticket/data/data_sources/request_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTicketsScreen extends StatefulWidget {


  MyTicketsScreen({super.key,});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("WARSHA", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
        backgroundColor: Color(0xFFF8FAFC),
      body: BlocBuilder<TicketListBloc, TicketListState>(
        buildWhen: (prev, current) => prev.requests != current.requests ,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 16),
            child: CustomScrollView(
              slivers: [
                if (state.activeTickets.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Text(
                      "Active Tickets",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: state.activeTickets.length,
                    itemBuilder: (context, index) {
                      return ActiveTicketCard(
                        request: state.activeTickets[index],
                      );
                    },
                  ),
                ],
                if (state.pendingTickets.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Text(
                      "Pending Tickets",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: state.pendingTickets.length,
                    itemBuilder: (context, index) {
                      return PendingTicketCard(
                        request: state.pendingTickets[index],
                      );
                    },
                  ),
                ],

                if (state.historyTickets.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Text(
                      "History Tickets",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: state.historyTickets.length,
                    itemBuilder: (context, index) {
                      return HistoricalTicketCard(request: state.historyTickets[index]);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }



  void _showPhotoGallery(BuildContext context, List<String> imageUrls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows it to take up more screen space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Request Photos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: imageUrls.isEmpty
                      ? const Center(
                          child: Text("No photos uploaded for this request."),
                        )
                      : GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                // Shows a loader while the image is downloading
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                // Handles broken links
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Future<void> openGoogleMapsDirections(double lat, double lng) async {
  //   final Uri googleMapsUrl = Uri.parse(
  //     'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  //   );
  //
  //   if (await canLaunchUrl(googleMapsUrl)) {
  //     await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not open Google Maps';
  //   }
  // }
}
