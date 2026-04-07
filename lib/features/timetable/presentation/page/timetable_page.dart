import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/timetable_bloc.dart';
import '../bloc/timetable_event.dart';
import '../bloc/timetable_state.dart';
import '../widget/train_card_widget.dart';
import '../widget/timetable_empty_state_widget.dart';
import '../../../../core/di/injection.dart';

class TimetablePage extends StatelessWidget {
  final String origin;
  final String destination;
  final String date;
  final String originName;
  final String destinationName;

  const TimetablePage({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.originName,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TimetableBloc>()
        ..add(TimetableEvent.load(
          origin: origin,
          destination: destination,
          date: date,
        )),
      child: _TimetableView(
        originName: originName,
        destinationName: destinationName,
        date: date,
      ),
    );
  }
}

class _TimetableView extends StatelessWidget {
  final String originName;
  final String destinationName;
  final String date;

  const _TimetableView({
    required this.originName,
    required this.destinationName,
    required this.date,
  });

  String _formatDate(String date) {
    // date is "yyyy-MM-dd"
    try {
      final d = DateTime.parse(date);
      const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      final weekday = weekdays[d.weekday - 1];
      return '${date.replaceAll('-', '/')}（$weekday）';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD),
      body: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildRouteInfo()),
              state.map(
                initial: (_) =>
                    const SliverToBoxAdapter(child: SizedBox()),
                loading: (_) => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                loaded: (s) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TrainCardWidget(train: s.trains[i]),
                      ),
                      childCount: s.trains.length,
                    ),
                  ),
                ),
                empty: (_) => SliverFillRemaining(
                  child: TimetableEmptyStateWidget(
                    onRetry: () => context.go('/home'),
                  ),
                ),
                error: (e) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          '載入失敗：${e.message}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<TimetableBloc>()
                              .add(const TimetableEvent.retry()),
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF4A90D9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar spacing
          const SizedBox(height: 62),
          // Title area
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '時刻表',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Train Timetable',
                    style: TextStyle(
                      color: Color(0xBBFFFFFF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          // Station names row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                originName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward,
                  size: 18, color: Color(0xFF4A90D9)),
              const SizedBox(width: 8),
              Text(
                destinationName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date
          Text(
            _formatDate(date),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8899AA),
            ),
          ),
        ],
      ),
    );
  }
}
