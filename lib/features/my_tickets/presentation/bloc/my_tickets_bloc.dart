import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/ticket.dart';
import 'my_tickets_state.dart';

class MyTicketsBloc extends Cubit<MyTicketsState> {
  MyTicketsBloc() : super(MyTicketsState(tickets: _fakeTickets));

  static final List<Ticket> _fakeTickets = [
    const Ticket(
      trainNo: '171',
      trainTypeName: '自強3000',
      departureTime: '08:15',
      arrivalTime: '11:57',
      departureStation: '台北車站',
      arrivalStation: '高雄車站',
      date: '2026/04/05 (日)',
      carriage: '3',
      seat: '12A',
      status: TicketStatus.upcoming,
    ),
    const Ticket(
      trainNo: '129',
      trainTypeName: '自強3000',
      departureTime: '09:30',
      arrivalTime: '13:08',
      departureStation: '板橋車站',
      arrivalStation: '高雄車站',
      date: '2026/04/03 (五)',
      carriage: '5',
      seat: '08B',
      status: TicketStatus.completed,
    ),
    const Ticket(
      trainNo: '51',
      trainTypeName: '莒光',
      departureTime: '13:20',
      arrivalTime: '18:30',
      departureStation: '桃園車站',
      arrivalStation: '新竹車站',
      date: '2026/03/28 (六)',
      carriage: '2',
      seat: '05C',
      status: TicketStatus.completed,
    ),
  ];
}
