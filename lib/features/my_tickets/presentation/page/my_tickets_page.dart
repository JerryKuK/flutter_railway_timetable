import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/my_tickets_bloc.dart';
import '../bloc/my_tickets_state.dart';
import '../widget/ticket_card_widget.dart';

class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyTicketsBloc(),
      child: const _MyTicketsView(),
    );
  }
}

class _MyTicketsView extends StatelessWidget {
  const _MyTicketsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF60A5FA), Color(0xFF93C5FD)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: const Row(
                children: [
                  Icon(Icons.confirmation_number, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '我的車票',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<MyTicketsBloc, MyTicketsState>(
            builder: (context, state) {
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => TicketCardWidget(ticket: state.tickets[i]),
                    childCount: state.tickets.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
