import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_state.dart';

class SubmitButton extends StatelessWidget {
  String requestType;

  SubmitButton({super.key, required this.requestType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (state.isEditMode) {
                context.read<TicketBloc>().add(
                  UpdateTicket(requestType: requestType),
                );
              } else {
                context.read<TicketBloc>().add(
                  SubmitTicket(requestType: requestType),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: state.isSubmitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.isEditMode ? "Update Request" : 'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.send, color: Colors.white),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // Future<void> _submitRequest() async {
  //   if (_descriptionController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please enter a request description')),
  //     );
  //     return;
  //   }
  //   if (_selectedLocation == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Please select a location')));
  //     return;
  //   }
  //
  //   try {
  //     // Upload new images only
  //     if (_selectedImages.isNotEmpty) {
  //       await _saveImagesToCloudinary(_selectedImages);
  //     }
  //
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //     if (_isEditMode) {
  //       // Update existing request
  //       clsRequest updatedRequest = clsRequest(
  //         id: widget.request!.id,
  //         // Preserve the original ID
  //         clientId: widget.request!.clientId,
  //         clientName: widget.request!.clientName,
  //         clientPhone: widget.request!.clientPhone,
  //         // Preserve the original client ID
  //         description: _descriptionController.text,
  //         location: _selectedLocation!,
  //         images: _savedImages,
  //         // Combined old and new images
  //         status: widget.request!.status,
  //         // Preserve completion status
  //         requestType: widget.requestType,
  //         price: double.parse(_priceController.text),
  //         // Preserve original price
  //         createdAt:
  //         widget.request!.createdAt, // Preserve original creation date
  //         // Set update timestamp
  //       );
  //
  //       await RequestService.updateRequest(updatedRequest);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Request updated successfully!')),
  //       );
  //     } else {
  //       clsUser? user = await UserService.getUser(prefs.getString("uid")!);
  //       if (user != null) {
  //         clsRequest newRequest = clsRequest(
  //           clientId: prefs.getString("uid").toString(),
  //           clientName: user.name,
  //           clientPhone: user.phone,
  //           description: _descriptionController.text,
  //           location: _selectedLocation!,
  //           images: _savedImages,
  //           status: "Hold",
  //           requestType: widget.requestType,
  //           price: double.tryParse(_priceController.text) ?? 0,
  //           createdAt: DateTime.now(),
  //         );
  //         await RequestService.addRequest(request: newRequest);
  //       }
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Request submitted successfully!')),
  //       );
  //     }
  //
  //     // Clear form
  //     _descriptionController.clear();
  //     setState(() {
  //       _selectedImages.clear();
  //       _savedImages.clear();
  //       _selectedLocation = null;
  //     });
  //
  //     // Navigate back
  //     Navigator.pop(context);
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error submitting request: $e')));
  //   }
  // }
}
