import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';

enum TicketStatus { upcoming, completed }

@freezed
abstract class Ticket with _$Ticket {
  const factory Ticket({
    required String trainNo,
    required String trainTypeName,
    required String departureTime,
    required String arrivalTime,
    required String departureStation,
    required String arrivalStation,
    required String date,
    required String carriage,
    required String seat,
    required TicketStatus status,
  }) = _Ticket;
}
