import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warsha/features/Ticket/data/data_sources/request_service.dart';
import 'package:warsha/features/Ticket/data/modules/clsRequest.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_event.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_state.dart';

class TicketListBloc extends Bloc<TicketListEvent, TicketListState> {
  TicketListBloc() : super(TicketListState()) {
    on<InitiateMyTicketScreen>((event, emit) async {
      emit(state.copyWith(isScreenLoading: true));

      final List<clsRequest>? requests =
          await RequestService.getAllUserRequests();

      if (requests != null) {
        emit(state.copyWith(requests: requests, isScreenLoading: false));
      } else {
        emit(state.copyWith(isScreenLoading: false));
      }
    });
    on<UpdatePendingTicket>((event, emit) {
       final List<clsRequest> updated = [...state.requests];

      final int index = updated.indexWhere((e) => e.id == event.request.id);
      updated[index] = event.request;
      emit(state.copyWith(requests: updated));
    });

    on<DeleteTicket>((event,emit){

      final List<clsRequest> updated = state.requests.where((request) => request.id != event.requestId).toList();
      emit(state.copyWith(requests: updated));
    });
  }
}
