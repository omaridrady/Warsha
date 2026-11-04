import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_event.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_state.dart';
import 'package:warsha/features/Ticket/data/data_sources/request_service.dart';
import 'package:warsha/features/Ticket/data/modules/TicketImage.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/modules/clsLocation.dart';
import 'package:http/http.dart' as http;
import 'package:warsha/modules/clsUser.dart';


class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final ImagePicker _pickedImage = ImagePicker();

  final clsUser currentUser;
  final clsRequest? editReuqest;

  TicketBloc({required this.currentUser, this.editReuqest})
    : super(
        editReuqest == null
            ? TicketState.initial()
            : TicketState.fromRequest(editReuqest),
      ) {
    // 1. Define your map configuration parameters

    on<PickedImageSource>((event, emit) async {
      try {
        final XFile? image = await _pickedImage.pickImage(source: event.source);

        if (image != null) {
          final TicketImage ticketImage = TicketImage.local(File(image.path));
          final List<TicketImage> updatedList = List<TicketImage>.from(
            state.imagesPaths,
          )..add(ticketImage);
          emit(state.copyWith(imagesPaths: updatedList));
        }
      } catch (e) {
        print("Error picking image: $e");
      }
    }); // Ended cleanly here!
    on<DeletePickedImage>((event, emit) {
      final List<TicketImage> updatedList = List<TicketImage>.from(
        state.imagesPaths,
      )..removeAt(event.index);

      emit(state.copyWith(imagesPaths: updatedList));
    });

    on<GetLocation>((event, emit) async {
      emit(state.copyWith(isLocationLoading: true));
      try {
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.deniedForever) {
          print("No permission for location");
          return;
        }
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Width x Height of the image match your UI box ratio

        // 2. Build the dynamic URL string using string interpolation

        final clsLocation selectedLocation = clsLocation(
          lat: position.latitude,
          lng: position.longitude,
        );

        emit(
          state.copyWith(
            location: selectedLocation,
            mapImageUrl: TicketState.getLocationImage(selectedLocation),
          ),
        );
      } catch (e) {
        print(e);
      } finally {
        emit(state.copyWith(isLocationLoading: false));
      }
    });

    on<DescriptionChange>((event, emit) {
      emit(state.copyWith(description: event.description));
    });

    on<SubmitTicket>((event, emit) async {
      emit(state.copyWith(errorMessage: () => null));

      if (state.description.isEmpty) {
        emit(state.copyWith(errorMessage: () => "Please Enter a description"));
        return;
      }
      if (state.location == null) {
        emit(state.copyWith(errorMessage: () => "please select location"));
        return;
      }
      if (state.imagesPaths.isEmpty) {
        emit(state.copyWith(errorMessage: () => "Please add images or videos"));
        return;
      }

      emit(state.copyWith(isSubmiting: true));
      try {
        List<String> cloudinaryLinks = [];
        for (TicketImage image in state.imagesPaths) {
          String url = await _uploadToCloudinary(image.localSource!);
          cloudinaryLinks.add(url);
        }

        clsRequest newRequest = clsRequest(
          clientId: currentUser.id!,
          clientName: currentUser.name,
          clientPhone: currentUser.phone,
          description: state.description,
          location: state.location!,
          images: cloudinaryLinks,
          status: "Hold",
          requestType: event.requestType,
          createdAt: DateTime.now(),
        );

        final bool isSuccess = await RequestService.addRequest(
          request: newRequest,
        );

        if (isSuccess) {
          emit(state.copyWith(isSuccess: true, isSubmiting: false));
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: () => "Ticket Submition failed"));
      }
    });

    on<UpdateTicket>((event, emit) async {
      emit(state.copyWith(errorMessage: () => null));

      if (state.description.isEmpty) {
        emit(state.copyWith(errorMessage: () => "Please Enter a description"));
        return;
      }
      if (state.location == null) {
        emit(state.copyWith(errorMessage: () => "please select location"));
        return;
      }
      if (state.imagesPaths.isEmpty) {
        emit(state.copyWith(errorMessage: () => "Please add images or videos"));
        return;
      }

      emit(state.copyWith(isSubmiting: true));
      try {
        List<String> cloudinaryLinks = [];

        for (TicketImage image in state.imagesPaths) {
          if (image.isLocal()) {
            String url = await _uploadToCloudinary(image.localSource!);
            cloudinaryLinks.add(url);
          } else {
            cloudinaryLinks.add(image.urlSource!);
          }
        }

        clsRequest updatedRequest = clsRequest(
          id: state.requestId,
          clientId: currentUser.id!,
          clientName: currentUser.name,
          clientPhone: currentUser.phone,
          description: state.description,
          location: state.location!,
          images: cloudinaryLinks,
          status: "Hold",
          requestType: event.requestType,
          createdAt: state.requestCreationTime!,
        );

        final bool isSuccess = await RequestService.updateRequest(
          updatedRequest,
        );

        if (isSuccess) {
          emit(state.copyWith(isSuccess: true, isSubmiting: false,updatedRequest: updatedRequest));
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: () => "Ticket Submition failed"));
      }
    });
  }
  Future<String> _uploadToCloudinary(File pickedImage) async {
    String cloudName = "dkepqbmf9";
    String preset = "uplorder";

    final request = http.MultipartRequest(
      "POST",
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    request.fields["upload_preset"] = preset;
    request.files.add(
      await http.MultipartFile.fromPath('file', pickedImage.path),
    );

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
