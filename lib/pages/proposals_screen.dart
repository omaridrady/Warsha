import 'package:flutter/material.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/tech_profile_screen.dart';
import 'package:warsha/services/user_service.dart';
import '../modules/clsProposals.dart';
import '../features/Ticket/data/data_sources/request_service.dart';

class ProposalsScreen extends StatefulWidget {
  final clsRequest request;

  const ProposalsScreen({super.key, required this.request});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  late Future<List<clsProposal>> _proposalsFuture;

  @override
  void initState() {
    super.initState();
    _fetchProposals();
  }

  void _fetchProposals() {
    _proposalsFuture = RequestService.getProposalsForRequest(widget.request.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Proposals"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= CARD 1 (35 JOD | 4.5/5) =================
            _buildStaticProposalCard(
              context: context,
              technicianName: "Ahmad Hassan",
              photoUrl: "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
              rating: "4.5 / 5",
              date: "15/8",
              price: "35 JOD",
              buttonText: "Allow communication",
              buttonColor: const Color(0xFF0058BE),
            ),

            // ================= CARD 2 (100 JOD | 5.0/5) =================
            _buildStaticProposalCard(
              context: context,
              technicianName: "Samer Mahmoud",
              photoUrl: "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
              rating: "5.0 / 5",
              date: "14/8",
              price: "100 JOD",
              buttonText: "Hire technician",
              buttonColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to generate static cards with consistent design
  Widget _buildStaticProposalCard({
    required BuildContext context,
    required String technicianName,
    required String photoUrl,
    required String rating,
    required String date,
    required String price,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(photoUrl),
                ),
                const SizedBox(width: 12),

                // Technician Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technicianName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          Text(
                            " $rating",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sent on: $date",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Price Tag and Profile Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0058BE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        "View Profile",
                        style: TextStyle(
                          color: Color(0xFF0058BE),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}