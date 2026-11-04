import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';
import 'package:warsha/features/Ticket/data/modules/TicketImage.dart';

class ImagePreviewCard extends StatelessWidget {
  final TicketImage image;
  final int index;
  const ImagePreviewCard({super.key, required this.image, required this.index});

  @override
  Widget build(BuildContext context) {
    final ticketBloc = context.read<TicketBloc>();
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: image.isLocal()
                ? Image.file(image.localSource!, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: image.urlSource!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0058be),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              ticketBloc.add(DeletePickedImage(index: index));
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
