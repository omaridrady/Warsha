import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/communication_service.dart';
import 'package:warsha/services/request_service.dart';
import 'package:warsha/services/user_service.dart';

import '../modules/clsProposals.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

// 1. A simple helper class to hold both objects together
class TechJob {
  final clsProposal proposal;
  final clsRequest request;
  TechJob({required this.proposal, required this.request});
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  clsUser? currentUser;
  List<TechJob> myJobs = []; // Now holds both Proposal + Request
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

        // 2. Fetch proposals first
        List<clsProposal> proposals = await RequestService.getProposalsByTechnician(userId);

        // 3. For each proposal, fetch its parent request to get the info you need
        List<TechJob> combinedList = [];
        for (var p in proposals) {
          clsRequest? req = await RequestService.getRequestById(p.requestId);
          if (req != null) {
            combinedList.add(TechJob(proposal: p, request: req));
          }
        }

        setState(() {
          myJobs = combinedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Filter helpers using the new TechJob wrapper
  List<TechJob> get workingJobs => myJobs.where((j) => j.proposal.status == "working").toList();
  List<TechJob> get hireRequests => myJobs.where((j) => j.proposal.status == "waiting_for_handshake").toList();
  List<TechJob> get acceptedJobs => myJobs.where((j) => j.proposal.status == "accepted").toList();
  List<TechJob> get pendingJobs => myJobs.where((j) => j.proposal.status == "pending").toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[600],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
        slivers: [
          _buildHeader(), // Defined below
          SliverToBoxAdapter(
            child: Container(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (workingJobs.isNotEmpty) _buildSection("🛠️ Active Work", workingJobs),
                    if (hireRequests.isNotEmpty) _buildSection("🚨 Action Required", hireRequests),
                    if (acceptedJobs.isNotEmpty) _buildSection("💬 Negotiations", acceptedJobs),
                    if (pendingJobs.isNotEmpty) _buildSection("⏳ Pending", pendingJobs),

                    if (myJobs.isEmpty) _buildEmptyState(), // Defined below
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MISSING FUNCTIONS DEFINED HERE ---

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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text("Manage your bids and active jobs", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No proposals sent yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<TechJob> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${list.length}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...list.map((job) => _buildProposalCard(job)).toList(),
      ],
    );
  }

  Widget _buildProposalCard(TechJob job) {
    bool isActionable = job.proposal.status == "accepted" ||
        job.proposal.status == "waiting_for_handshake" ||
        job.proposal.status == "working";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(job.request.requestType, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Offer: ${job.request.price} JOD"),
              trailing: _getStatusChip(job.proposal.status),
            ),

            // Communication buttons appear for specific statuses
            if (isActionable)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(

                      onPressed: () => CommunicationService.launchWhatsApp((job.request.clientId)),
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text("WhatsApp"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => CommunicationService.makeCall(job.request.clientPhone),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),

            // The Handshake Button
            if (job.proposal.status == "waiting_for_handshake")
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () => _confirmHandshake(job),
                    child: const Text("START WORK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusChip(String status) {
    Color color = Colors.grey;
    if (status == "working") color = Colors.blue;
    if (status == "accepted") color = Colors.green;
    if (status == "waiting_for_handshake") color = Colors.redAccent;

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
    );
  }

  Future<void> _confirmHandshake(TechJob job) async {
    // 1. Update status to working
    job.proposal.status = "working";
    job.request.status = "working";

    // 2. Save both
    await RequestService.updateProposal(job.proposal, job.request.id!);
    await RequestService.updateRequest(job.request);

    _loadData(); // Refresh UI
  }
}