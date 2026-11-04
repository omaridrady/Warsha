import 'package:image_picker/image_picker.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';

abstract class TicketEvent {}

class PickedImageSource extends TicketEvent {
  ImageSource source;
  PickedImageSource({required this.source});
}

class DeletePickedImage extends TicketEvent {
  int index;
  DeletePickedImage({required this.index});
}

class GetLocation extends TicketEvent {}

class SubmitTicket extends TicketEvent {
  String requestType;
  SubmitTicket({required this.requestType});
}

class DescriptionChange extends TicketEvent {
  String description;
  DescriptionChange({required this.description});
}

class InitiateEditMode extends TicketEvent{
  clsRequest request;
  InitiateEditMode({required this.request});
}

class UpdateTicket extends TicketEvent{
  String requestType;
  UpdateTicket({required this.requestType});
}


