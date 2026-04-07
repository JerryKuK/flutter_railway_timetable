import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_railway_timetable/features/my_tickets/domain/entity/ticket.dart';
import 'package:flutter_railway_timetable/features/my_tickets/presentation/bloc/my_tickets_bloc.dart';
import 'package:flutter_railway_timetable/features/my_tickets/presentation/bloc/my_tickets_state.dart';

void main() {
  group('MyTicketsBloc', () {
    late MyTicketsBloc bloc;

    setUp(() => bloc = MyTicketsBloc());
    tearDown(() => bloc.close());

    test('initial state has exactly 3 fake tickets', () {
      expect(bloc.state.tickets.length, 3);
    });

    test('has 1 upcoming and 2 completed tickets', () {
      final tickets = bloc.state.tickets;
      expect(
        tickets.where((t) => t.status == TicketStatus.upcoming).length,
        1,
      );
      expect(
        tickets.where((t) => t.status == TicketStatus.completed).length,
        2,
      );
    });

    test('first ticket is upcoming (自強3000 #171)', () {
      final first = bloc.state.tickets.first;
      expect(first.trainNo, '171');
      expect(first.status, TicketStatus.upcoming);
      expect(first.departureStation, '台北車站');
      expect(first.arrivalStation, '高雄車站');
    });

    test('emits MyTicketsState with correct type', () {
      expect(bloc.state, isA<MyTicketsState>());
    });
  });
}
