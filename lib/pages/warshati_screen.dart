import 'package:flutter/material.dart';
import 'package:warsha/modules/clsProposals.dart';
import 'package:warsha/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/proposals_screen.dart';
import 'package:warsha/pages/request_screen.dart';
import 'package:warsha/services/request_service.dart';

class Warshati extends StatefulWidget {
  clsUser? user;

  Warshati({super.key, this.user});

  @override
  State<Warshati> createState() => _WarshatiState();
}

class _WarshatiState extends State<Warshati> {
  List<clsRequest>? requests;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fitchCorrectData();
  }

  Future<void> _fitchCorrectData() async {
    if (widget.user?.role == "Technician") {
      _getAllTechnicianRequests();
    } else {
      _getAllClientRequests();
    }
  }

  Future<void> _getAllClientRequests() async {
    setState(() => _isLoading = true);
    requests = await RequestService.getAllUserRequests();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getAllTechnicianRequests() async {
    setState(() => _isLoading = true);
    requests = await RequestService.getAllRequestsByType(
      widget.user?.specialty ?? "",
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    return Scaffold(
      body: requests == null
          ? Center(
              child: Text(
                "No Requests",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            )
          : ListView.builder(
              itemCount: requests!.length,
              itemBuilder: (BuildContext context, int index) {
                bool isClient =
                    widget.user!.role == "Client" || widget.user == null;
                return Container(
                  height: 200,

                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    // --- SHADOW ADDED HERE ---
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.2,
                        ), // Shadow color
                        spreadRadius: 1, // How much the shadow spreads
                        blurRadius: 8, // How "blurry" the shadow is
                        offset: const Offset(
                          0,
                          4,
                        ), // Moves shadow (x, y) - 4 is downward
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isClient
                                ? Text(
                                    requests![index].requestType,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(height: 10),
                            Text(
                              requests![index].description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isClient ? Colors.grey : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        isClient
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ProposalsScreen(
                                            request: requests![index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text("View Proposals"),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RequestPage(
                                                        requestType:
                                                            requests![index]
                                                                .requestType,
                                                        request:
                                                            requests![index],
                                                      ),
                                                ),
                                              )
                                              .then((_) => _fitchCorrectData());
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.orange[600],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmation(
                                            context,
                                            requests![index].id!,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _showPhotoGallery(
                                              context,
                                              requests![index].images,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          icon: Icon(
                                            Icons.photo,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Photos",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            /* Add Accept Logic */
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          icon: Icon(
                                            Icons.location_on_sharp,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Location",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        if (widget.user == null ||
                                            widget.user!.id == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Error: User profile not loaded properly.",
                                              ),
                                            ),
                                          );
                                          return; // Stop here so it doesn't crash
                                        }

                                        // 2. Safely build the proposal without using '!' operators where possible
                                        clsProposal newProposal = clsProposal(
                                          technicianId: widget
                                              .user!
                                              .id!, // We checked this above, so it's safe now
                                          technicianName: widget.user!.name,
                                          requestId: requests![index].id!,
                                          technicianPhoto:
                                              widget.user!.profileImage ??
                                              "https://res.cloudinary.com/dkepqbmf9/image/upload/v1778449965/zrqxlusqugvivzcueaca.jpg",
                                          rating: (widget.user!.rating ?? 0)
                                              .toDouble(),
                                          createdAt: DateTime.now(),
                                          status: "pending",
                                        );
                                        bool success =
                                            await RequestService.sendProposal(
                                              newProposal,
                                            );

                                        if (success && mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Proposal sent successfully!",
                                              ),
                                            ),
                                          );
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Failed to send proposal.",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      icon: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Send Request",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String requestId) {
    showDialog(
      context: context,
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
                RequestService.deleteRequest(requestId);
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
}
