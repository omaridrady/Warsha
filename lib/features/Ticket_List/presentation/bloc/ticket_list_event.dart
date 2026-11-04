import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';

abstract class TicketListEvent {}

class InitiateMyTicketScreen extends TicketListEvent{}

class UpdatePendingTicket extends TicketListEvent{

  clsRequest request;
  UpdatePendingTicket({required this.request});
}

class DeleteTicket extends TicketListEvent{
  String requestId;
  DeleteTicket({required this.requestId});
}