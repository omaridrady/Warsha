import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:warsha/modules/clsLocation.dart';
import 'package:warsha/modules/clsRequest.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/request_service.dart';
import 'package:warsha/services/user_service.dart';

class RequestPage extends StatefulWidget {
  String requestType;
  clsRequest? request;
  RequestPage({super.key, required this.requestType, this.request});
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<File> _selectedImages = [];
  List<String> _savedImages = [];
  clsLocation? _selectedLocation;
  bool _isLoadingLocation = false;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  // Initialize form with existing data if editing
  void _initializeForm() {
    _isEditMode = widget.request != null;
    if (_isEditMode) {
      _descriptionController.text = widget.request!.description;
      _selectedLocation = widget.request!.location;
      _savedImages = List.from(widget.request!.images);
      _priceController.text = widget.request!.price.toString();
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is denied')),
        );
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _selectedLocation = clsLocation(
        lat: position.latitude,
        lng: position.longitude, // Fixed: was position.latitude before
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Take photo with camera
  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  // Remove image from selection
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Remove saved image (for edit mode)
  void _removeSavedImage(int index) {
    setState(() {
      _savedImages.removeAt(index);
    });
  }

  Future<void> _saveImagesToCloudinary(List<File> images) async {
    for (File image in images) {
      String url = await uploadToCloudinary(XFile(image.path));
      _savedImages.add(url);
    }
  }

  // Submit request (create or update)
  Future<void> _submitRequest() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a request description')),
      );
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a location')));
      return;
    }

    try {
      // Upload new images only
      if (_selectedImages.isNotEmpty) {
        await _saveImagesToCloudinary(_selectedImages);
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_isEditMode) {
        // Update existing request
        clsRequest updatedRequest = clsRequest(
          id: widget.request!.id, // Preserve the original ID
          clientId: widget.request!.clientId,
          clientName: widget.request!.clientName,
          clientPhone:
              widget.request!.clientPhone, // Preserve the original client ID
          description: _descriptionController.text,
          location: _selectedLocation!,
          images: _savedImages, // Combined old and new images
          status: widget.request!.status, // Preserve completion status
          requestType: widget.requestType,
          price: double.parse(_priceController.text), // Preserve original price
          createdAt:
              widget.request!.createdAt, // Preserve original creation date
          // Set update timestamp
        );

        await RequestService.updateRequest(updatedRequest);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request updated successfully!')),
        );
      } else {
        clsUser? user = await UserService.getUser(prefs.getString("uid")!);
        if (user != null) {
          clsRequest newRequest = clsRequest(
            clientId: prefs.getString("uid").toString(),
            clientName: user.name,
            clientPhone: user.phone,
            description: _descriptionController.text,
            location: _selectedLocation!,
            images: _savedImages,
            status: "Hold",
            requestType: widget.requestType,
            price: double.tryParse(_priceController.text) ?? 0,
            createdAt: DateTime.now(),
          );
          await RequestService.addRequest(request: newRequest);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully!')),
        );
      }

      // Clear form
      _descriptionController.clear();
      setState(() {
        _selectedImages.clear();
        _savedImages.clear();
        _selectedLocation = null;
      });

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting request: $e')));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Request' : 'Create Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'What\'s your request?',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    fillColor: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Location section
              Text(
                'Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blue),
                  title: Text(
                    _selectedLocation != null
                        ? 'Location: ${_selectedLocation!.lat.toStringAsFixed(4)}, ${_selectedLocation!.lng.toStringAsFixed(4)}'
                        : 'Add your location',
                    style: TextStyle(
                      color: _selectedLocation != null
                          ? Colors.white
                          : Colors.grey[500],
                    ),
                  ),
                  trailing: _isLoadingLocation
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          ),
                        )
                      : Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: _isLoadingLocation ? null : _getCurrentLocation,
                ),
              ),
              SizedBox(height: 20),

              // Images section
              Text(
                'Photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Saved images preview (for edit mode)
              if (_savedImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Existing Photos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _savedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(_savedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeSavedImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),

              // Selected images preview (new images)
              if (_selectedImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Photos',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),

              // Image picker buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: Icon(Icons.image),
                      label: Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhotoWithCamera,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black),
                  // Restricts input to digits only
                  inputFormatters: [
                    // 2. This regex allows digits and a single optional decimal point
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter your price',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixText: 'JOD', // Or your local currency
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {},
                ),
              ),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isEditMode ? 'Update Request' : 'Submit Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
