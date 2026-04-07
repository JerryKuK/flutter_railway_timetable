import 'package:flutter/material.dart';
import '../../domain/entity/ticket.dart';

class TicketCardWidget extends StatelessWidget {
  final Ticket ticket;

  const TicketCardWidget({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = ticket.status == TicketStatus.upcoming;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ticket.trainTypeName} #${ticket.trainNo}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? '即將出發' : '已完成',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUpcoming ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _timeStation(ticket.departureTime, ticket.departureStation),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.red],
                      ),
                    ),
                  ),
                ),
                _timeStation(ticket.arrivalTime, ticket.arrivalStation,
                    align: CrossAxisAlignment.end),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${ticket.date}　${ticket.carriage}車 ${ticket.seat}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeStation(
    String time,
    String station, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(station, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
