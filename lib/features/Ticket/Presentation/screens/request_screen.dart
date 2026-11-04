import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/attachment_box.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/image_preview_card.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/location_card.dart';
import 'package:warsha/features/Ticket/Presentation/widgets/submit_button.dart';
import 'package:warsha/features/Ticket/data/modules/TicketImage.dart';

import '../bloc/ticket_state.dart';

class RequestScreen extends StatefulWidget {
  String requestType;

  RequestScreen({super.key, required this.requestType});
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  late final IconData warshaIcon;

  @override
  void initState() {
    super.initState();
    warshaIcon = getWarshaIcon();

    _descriptionController.text = context.read<TicketBloc>().state.description;
  }

  IconData getWarshaIcon() {
    switch (widget.requestType) {
      case "Plumbing":
        return Icons.plumbing;

      case "Electrical":
        return Icons.bolt;

      case "HVAC":
        return Icons.ac_unit;

      case "Painting":
        return Icons.format_paint;

      case "Carpentry":
        return Icons.carpenter_outlined;

      case "Cleaning":
        return Icons.cleaning_services_outlined;
    }
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: BlocBuilder<TicketBloc, TicketState>(
          buildWhen: (prev, current) => prev.isEditMode != current.isEditMode,
          builder: (context, state) {
            return Text(
              state.isEditMode ? "Edit Request" : "New Request",
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: BlocListener<TicketBloc, TicketState>(
        listenWhen: (prev, current) =>
            prev.isSuccess != current.isSuccess ||
            prev.errorMessage != current.errorMessage,
        listener: (BuildContext context, TicketState state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isEditMode ? "Ticket Updated" : 'Ticket Submitted',
                ),
                backgroundColor: Colors.green,
              ),
            );
            if (state.isEditMode) {
              Navigator.of(context).pop(state.updatedRequest);
            } else {
              Navigator.of(context).pop();
            }
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.lightBlue[100],
                      ),
                      child: Center(
                        child: Icon(warshaIcon, color: Color(0xFF0058be)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.requestType,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Maintenance & Repair",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "ISSUE DETAILS",
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 10),
                // Description input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(blurRadius: 2)],
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in a few words... ',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Colors.black,
                    ),
                    onChanged: (value) {
                      context.read<TicketBloc>().add(
                        DescriptionChange(description: value),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "ATTACHMENTS",
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 10),

                BlocBuilder<TicketBloc, TicketState>(
                  buildWhen: (prev, current) =>
                      prev.imagesPaths != current.imagesPaths,
                  builder: (context, state) {
                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        const AttachmentBox(),
                        ...List.generate(state.imagesPaths.length, (index) {
                          final TicketImage image = state.imagesPaths[index];
                          return ImagePreviewCard(image: image, index: index);
                        }),
                      ],
                    );
                  },
                ),

                SizedBox(height: 10),
                // Location section
                Text('LOCATION', style: TextStyle(fontWeight: FontWeight.w300)),
                SizedBox(height: 8),
                LocationCard(),

                SizedBox(height: 30),
                SubmitButton(requestType: widget.requestType),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
