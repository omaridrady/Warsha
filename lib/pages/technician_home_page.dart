import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/communication_service.dart';
import 'package:warsha/features/Ticket/data/data_sources/request_service.dart';
import 'package:warsha/services/user_service.dart';
import '../modules/clsProposals.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

// Helper class to hold both objects together
class TechJob {
  final clsProposal proposal;
  final clsRequest request;
  TechJob({required this.proposal, required this.request});
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  clsUser? currentUser;
  List<TechJob> myJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("uid");

      if (userId != null) {
        currentUser = await UserService.getUser(userId);

        // Fetch proposals
        List<clsProposal> proposals =
            await RequestService.getProposalsByTechnician(userId);

        // For each proposal, fetch its parent request
        List<TechJob> combinedList = [];
        for (var p in proposals) {
          clsRequest? req = await RequestService.getRequestById(p.requestId);
          if (req != null) {
            combinedList.add(TechJob(proposal: p, request: req));
          }
        }

        // Sort: Working first, then Progressing, then Accepted, then Pending
        combinedList.sort((a, b) {
          final statusOrder = {
            "working": 0,
            "progressing": 1,
            "accepted": 2,
            "pending": 3,
          };
          int orderA = statusOrder[a.request.status] ?? 4;
          int orderB = statusOrder[b.request.status] ?? 4;
          return orderA.compareTo(orderB);
        });

        setState(() {
          myJobs = combinedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Filter helpers using the new TechJob wrapper
  List<TechJob> get workingJobs =>
      myJobs.where((j) => j.request.status == "working").toList();

  List<TechJob> get progressingJobs =>
      myJobs.where((j) => j.request.status == "progressing").toList();

  List<TechJob> get acceptedProposals =>
      myJobs.where((j) => j.proposal.status == "accepted").toList();

  List<TechJob> get pendingProposals =>
      myJobs.where((j) => j.proposal.status == "pending").toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[600],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // SECTION 1: Active Work (working status)
                          if (workingJobs.isNotEmpty)
                            _buildSection(
                              "🛠️ Active Work",
                              workingJobs,
                              Colors.blue,
                            ),

                          // SECTION 2: Progressing (needs confirmation to working)
                          if (progressingJobs.isNotEmpty)
                            _buildSection(
                              "⚠️ Ready to Start",
                              progressingJobs,
                              Colors.orange,
                              showConfirmButton: true,
                            ),

                          // SECTION 3: Accepted Proposals (with message & call)
                          if (acceptedProposals.isNotEmpty)
                            _buildSection(
                              "✅ Accepted Proposals",
                              acceptedProposals,
                              Colors.green,
                              showCommunication: true,
                            ),

                          // SECTION 4: Pending Proposals (awaiting review)
                          if (pendingProposals.isNotEmpty)
                            _buildSection(
                              "⏳ Pending Proposals",
                              pendingProposals,
                              Colors.grey,
                            ),

                          // Empty state
                          if (myJobs.isEmpty) _buildEmptyState(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // HEADER WIDGET
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              "Hi, ${currentUser?.name ?? 'Technician'}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              "Manage your proposals and active jobs",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // EMPTY STATE WIDGET
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              "No proposals sent yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start by sending proposals to available jobs.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION WIDGET
  Widget _buildSection(
    String title,
    List<TechJob> list,
    Color accentColor, {
    bool showConfirmButton = false,
    bool showCommunication = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  "${list.length}",
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...list.map(
          (job) => _buildProposalCard(
            job,
            accentColor,
            showConfirmButton: showConfirmButton,
            showCommunication: showCommunication,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // PROPOSAL CARD WIDGET
  Widget _buildProposalCard(
    TechJob job,
    Color accentColor, {
    bool showConfirmButton = false,
    bool showCommunication = false,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with request type and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.request.requestType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.request.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _getStatusChip(job.proposal.status, accentColor),
              ],
            ),

            const SizedBox(height: 12),

            // Price and location
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: accentColor),
                const SizedBox(width: 4),

                const SizedBox(width: 20),
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${job.request.location.lat}  ${job.request.location.lng}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Communication buttons (for accepted proposals)
            if (showCommunication)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => CommunicationService.launchWhatsApp(
                        job.request.clientPhone,
                      ),
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text("WhatsApp"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => CommunicationService.makeCall(
                        job.request.clientPhone,
                      ),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

            // Confirm button (for progressing jobs)
            if (showConfirmButton)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmStartWork(job),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text(
                      "START WORK",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // STATUS CHIP WIDGET
  Widget _getStatusChip(String status, Color accentColor) {
    Color chipColor = accentColor;
    String displayStatus = status.toUpperCase();

    if (status == "working") {
      displayStatus = "ACTIVE";
    } else if (status == "progressing") {
      displayStatus = "READY";
    } else if (status == "accepted") {
      displayStatus = "ACCEPTED";
    } else if (status == "pending") {
      displayStatus = "PENDING";
    }

    return Chip(
      label: Text(
        displayStatus,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: accentColor,
    );
  }

  // CONFIRM START WORK FUNCTION
  Future<void> _confirmStartWork(TechJob job) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Start Work?"),
          content: Text(
            "Are you ready to start working on '${job.request.requestType}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Update request status to "working"
                  job.request.status = "working";
                  await RequestService.updateRequest(job.request);

                  // Update proposal status to "working" as well
                  job.proposal.status = "working";
                  if (job.request.id != null) {
                    await RequestService.updateProposal(
                      job.proposal,
                      job.request.id!,
                    );
                  }
                  // Refresh the UI
                  _loadData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Work started! Good luck! 💪"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error starting work: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "START WORK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
