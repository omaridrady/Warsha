import 'package:flutter/material.dart';
import 'package:warsha/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/tech_profile_screen.dart';
import 'package:warsha/services/user_service.dart';
import '../modules/clsProposals.dart';
import '../services/request_service.dart';

class ProposalsScreen extends StatefulWidget {
  final clsRequest request;

  const ProposalsScreen({super.key, required this.request});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  // 1. Create a variable to hold the future
  late Future<List<clsProposal>> _proposalsFuture;

  @override
  void initState() {
    super.initState();
    // 2. Assign it ONCE when the screen loads
    _fetchProposals();
  }

  // 3. A helper function so we can refresh the list manually
  void _fetchProposals() {
    _proposalsFuture = RequestService.getProposalsForRequest(widget.request.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Proposals"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<clsProposal>>(
        future: _proposalsFuture, // 4. Use the variable here, NOT the function call directly
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final proposals = snapshot.data ?? [];

          if (proposals.isEmpty) {
            return const Center(
              child: Text(
                "No proposals received yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: proposals.length,
            itemBuilder: (context, index) {
              final proposal = proposals[index];

              final String photoUrl = (proposal.technicianPhoto == null || proposal.technicianPhoto!.isEmpty)
                  ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png" // Fallback
                  : proposal.technicianPhoto!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                // FIX: You need a Column here because a Card can only have ONE child,
                // and you have both a ListTile AND a Button.
                child: Column(
                  children: [
                    // 1. The Technician Info
                    ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          photoUrl
                        ),
                      ),
                      title: Text(
                        proposal.technicianName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              Text(
                                " ${proposal.rating} / 5",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Sent on: ${proposal.createdAt.day}/${proposal.createdAt.month}",
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          clsUser? techUser = await UserService.getUser(
                            proposal.technicianId,
                          );
                          if (techUser != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TechProfileScreen(
                                  user: techUser,
                                  isOwner: false,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text("View Profile"),
                      ),
                    ),

                    // 2. The Allow/Hire Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (proposal.status == "pending") {
                            proposal.status = "accepted";
                            setState(() {});

                            await RequestService.updateProposal(
                              proposal,
                              widget.request.id!,
                            );
                          } else {
                            if (widget.request.status == "Hold" &&
                                proposal.status == "accepted") {
                              _showHireConfirmation(context, widget.request, proposal);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: proposal.status == "accepted"
                              ? Colors.red
                              : Colors.green,
                        ),
                        child: proposal.status == "accepted"
                            ? const Text("Hire technician", style: TextStyle(color: Colors.white))
                            : const Text("Allow communication", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ], // End of Column children
                ), // End of Column
              ); // End of Card
            },
          );
        },
      ),
    );
  }

  // I updated this to also accept the proposal so we can update it
  void _showHireConfirmation(BuildContext context, clsRequest request, clsProposal proposal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Hiring"),
          content: const Text(
            "Are you sure you want to send a hire request to this technician?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                // Close dialog first
                Navigator.of(context).pop();

                // 1. Update Request
                request.status = "progressing";
                await RequestService.updateRequest(request); // Make sure you await this

                // 2. Update Proposal to handshake state (optional based on your logic)
                proposal.status = "waiting_for_handshake";
                await RequestService.updateProposal(proposal, request.id!);

                // 3. Refresh the UI by calling our helper function
                setState(() {
                  _fetchProposals();
                });

                // FIX: Fixed the typo in your SnackBar message!
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hired successfully!")),
                );
              },
              child: const Text("Hire", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
