import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/login_screen.dart';
import 'package:warsha/services/communication_service.dart';
import 'package:warsha/services/user_service.dart'; // Assume you have a service to update user data
import 'package:http/http.dart' as http;

class TechProfileScreen extends StatefulWidget {
  final clsUser user;
  bool isOwner = true;
  TechProfileScreen({super.key, required this.user, this.isOwner = true});

  @override
  State<TechProfileScreen> createState() => _TechProfileScreenState();
}

class _TechProfileScreenState extends State<TechProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Logic to pick and upload a photo
  Future<void> _addPortfolioImage() async {
    // 1. Change to pickMultiImage
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      widget.user.portfolio ??= [];
      setState(() => _isUploading = true);

      try {
        // 2. Loop through each image and upload
        for (var image in images) {
          String url = await uploadToCloudinary(image);
          widget.user.portfolio!.add(url);
        }

        // 3. Update Firestore once after all images are uploaded
        bool success = await UserService.updateUser(widget.user);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${images.length} photos added to portfolio!"),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
        actions: [
          widget.isOwner
              ? IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove("uid");
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                )
              : SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                (widget.user.profileImage == null ||
                        widget.user.profileImage == "")
                    ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
                    : widget.user.profileImage!,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.user.specialty ?? "Technician",
              style: TextStyle(color: Colors.grey[600]),
            ),
            widget.isOwner ? SizedBox(): Row( mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    CommunicationService.launchWhatsApp(widget.user.phone);
                  },
                  icon: Icon(Icons.message, color: Colors.green),
                ),
                IconButton(
                  onPressed: () {
                    CommunicationService.makeCall(widget.user.phone);
                  },
                  icon: Icon(Icons.call, color: Colors.red),
                ),
              ],
            ),
            const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),

            // Portfolio Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Work Photos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  widget.isOwner
                      ? IconButton(
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.orange,
                          ),
                          onPressed: _addPortfolioImage,
                        )
                      : SizedBox(),
                ],
              ),
            ),

            if (_isUploading) const LinearProgressIndicator(),

            // The Grid of Work
            GridView.builder(
              shrinkWrap: true, // Necessary inside a SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.user.portfolio?.length ?? 0,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.user.portfolio![index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

            if (widget.user.portfolio == null || widget.user.portfolio!.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "No photos added yet. Show off your work!",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadToCloudinary(XFile? pickedImage) async {
    File myImage = File(pickedImage!.path);
    String cloudName = "dkepqbmf9";
    String preset = "uplorder";

    final request = http.MultipartRequest(
      "POST",
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    request.fields["upload_preset"] = preset;
    request.files.add(await http.MultipartFile.fromPath('file', myImage.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);
    if (response.statusCode == 200) {
      print('url = ${decoded['secure_url']}');
      return decoded['secure_url'];
    } else {
      throw Exception(decoded['error']['message']);
    }
  }
}
