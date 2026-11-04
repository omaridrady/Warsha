import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warsha/features/Ticket/data/modules/TicketImage.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/modules/clsLocation.dart';

class TicketState {
  clsRequest? updatedRequest;
  List<TicketImage> imagesPaths;
  clsLocation? location;
  bool isLocationLoading;
  bool isSubmitting;
  bool isSuccess;
  bool isEditMode;
  String? mapImageUrl;
  String? errorMessage;
  String description;
  String? requestId;
  DateTime? requestCreationTime;

  TicketState({
    this.updatedRequest,
    this.imagesPaths = const [],
    this.location,
    this.isLocationLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isEditMode = false,

    this.mapImageUrl,
    this.description = "",
    this.errorMessage,
    this.requestId,
    this.requestCreationTime,
  });

  TicketState copyWith({
    clsRequest? updatedRequest,
    List<TicketImage>? imagesPaths,
    clsLocation? location,
    bool? isLocationLoading,
    bool? isSubmiting,
    bool? isSuccess,
    bool? isEditMode,
    String? mapImageUrl,
    String? description,
    String? Function()? errorMessage,
    String? requestId,
    DateTime? requestCreationTime,
    List<clsRequest>? requests,
    bool? isScreenLoading,
  }) {
    return TicketState(
      updatedRequest: updatedRequest ?? this.updatedRequest,
      imagesPaths: imagesPaths ?? this.imagesPaths,
      location: location ?? this.location,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
      description: description ?? this.description,
      isSubmitting: isSubmiting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      requestId: requestId ?? this.requestId,
      requestCreationTime: requestCreationTime ?? this.requestCreationTime,
    );
  }

  factory TicketState.initial() => TicketState();

  static TicketState fromRequest(clsRequest editRequest){
    final List<TicketImage> ticketImages = editRequest.images
        .map((url) => TicketImage.remote(url))
        .toList();
    return TicketState.initial().copyWith(
      requestId: editRequest.id,
      description: editRequest.description,
      imagesPaths: ticketImages,
      location: editRequest.location,
      requestCreationTime: editRequest.createdAt,
      isEditMode: true,
      mapImageUrl: TicketState.getLocationImage(editRequest.location),
    );
  }

  static String getLocationImage (clsLocation location){
    const String apiKey = 'AIzaSyCGPdA0mcGk16Z4UI8LuLk7VAqePODWBqw';
    const int zoom = 16; // How close the camera is (1 to 20)
    const String size = '600x300';

    final String staticMapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?'
        'center=${location.lat},${location.lng}'
        '&zoom=$zoom'
        '&size=$size'
        '&markers=color:red%7C${location.lat},${location.lng}' // Puts a pin on their spot
        '&key=$apiKey';

    return staticMapUrl;
  }
}
