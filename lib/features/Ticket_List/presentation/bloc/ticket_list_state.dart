
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';


class TicketListState {
  final List<clsRequest> requests;
  bool isScreenLoading;

  TicketListState({this.requests = const [], this.isScreenLoading = false});

  TicketListState copyWith({
    List<clsRequest>? requests,
    bool? isScreenLoading,
  }) {
    return TicketListState(
      requests: requests ?? this.requests,
      isScreenLoading: isScreenLoading ?? this.isScreenLoading,
    );
  }

  List<clsRequest> get activeTickets => requests
      .where((req) => req.status == "active" || req.status == "working")
      .toList();
  List<clsRequest> get pendingTickets => requests
      .where((req) => req.status == "pending" || req.status == "Hold")
      .toList();

  List<clsRequest> get historyTickets =>
      requests.where((req) => req.status == "completed").toList();
}
