import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/timetable_bloc.dart';
import '../bloc/timetable_event.dart';
import '../bloc/timetable_state.dart';
import '../widget/train_card_widget.dart';
import '../widget/timetable_empty_state_widget.dart';
import '../../../../core/cubit/railway_type_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/enums/railway_type.dart';
import '../../../../core/theme/railway_theme.dart';
import '../../domain/repository/timetable_repository.dart';
import '../../domain/repository/thsr_timetable_repository.dart';
import '../../domain/usecase/get_daily_timetable_use_case.dart';

class TimetablePage extends StatelessWidget {
  final String origin;
  final String destination;
  final String date;
  final String time;
  final String originName;
  final String destinationName;
  final RailwayType railwayType;

  const TimetablePage({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    this.time = '',
    required this.originName,
    required this.destinationName,
    required this.railwayType,
  });

  @override
  Widget build(BuildContext context) {
    final isHsr = railwayType == RailwayType.hsr;
    final repo = isHsr
        ? getIt<ThsrTimetableRepository>()
        : getIt<TimetableRepository>();

    return BlocProvider(
      create: (_) => TimetableBloc(GetDailyTimetableUseCase(repo))
        ..add(TimetableEvent.load(
          origin: origin,
          destination: destination,
          date: date,
          time: time,
        )),
      child: _TimetableView(
        originName: originName,
        destinationName: destinationName,
        date: date,
        time: time,
      ),
    );
  }
}

class _TimetableView extends StatelessWidget {
  final String originName;
  final String destinationName;
  final String date;
  final String time;

  const _TimetableView({
    required this.originName,
    required this.destinationName,
    required this.date,
    required this.time,
  });

  String _formatDate(String date) {
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
    return BlocBuilder<RailwayTypeCubit, RailwayType>(
      builder: (context, railwayType) {
        final isHsr = railwayType == RailwayType.hsr;
        final theme = RailwayTheme.of(railwayType);
        return Scaffold(
          backgroundColor: const Color(0xFFEEF4FB),
          body: BlocBuilder<TimetableBloc, TimetableState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: _buildHeader(isHsr, theme)),
                  SliverToBoxAdapter(
                      child: _buildRouteInfo(theme)),
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
                        theme: theme,
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
      },
    );
  }

  Widget _buildHeader(bool isHsr, RailwayTheme theme) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.headerGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 62),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHsr ? '高鐵時刻表' : '台鐵時刻表',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isHsr ? 'HSR Timetable' : 'Train Timetable',
                    style: const TextStyle(
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

  Widget _buildRouteInfo(RailwayTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
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
              Icon(Icons.arrow_forward, size: 18, color: theme.accent),
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
          Text(
            time.isNotEmpty
                ? '${_formatDate(date)}　出發 $time 後'
                : _formatDate(date),
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
