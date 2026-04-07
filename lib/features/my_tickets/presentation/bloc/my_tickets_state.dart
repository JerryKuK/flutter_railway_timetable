import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entity/ticket.dart';

part 'my_tickets_state.freezed.dart';

@freezed
abstract class MyTicketsState with _$MyTicketsState {
  const factory MyTicketsState({required List<Ticket> tickets}) =
      _MyTicketsState;
}
