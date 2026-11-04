import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';

class AttachmentBox extends StatelessWidget {
  const AttachmentBox({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _ShowImageSource(context),
      child: SizedBox(
        child: Stack(
          children: [
            // Border layer — fills the whole box
            Positioned.fill(
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Colors.grey,
                  strokeWidth: 2,
                  dashPattern: const [8, 2],
                  radius: const Radius.circular(24),
                ),
                child: const SizedBox.expand(), // empty, just for border shape
              ),
            ),
            // Content layer — truly centered, independent of DottedBorder
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Add Photo", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ShowImageSource(BuildContext context) {
    final ticketBloc = context.read<TicketBloc>();

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ticketBloc.add(PickedImageSource(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ticketBloc.add(
                    PickedImageSource(source: ImageSource.gallery),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
