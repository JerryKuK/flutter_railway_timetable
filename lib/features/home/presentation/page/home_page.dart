import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widget/station_input_widget.dart';
import '../widget/date_time_row_widget.dart';
import '../widget/recent_search_list_widget.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repository/recent_search_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        getIt<RecentSearchRepository>(),
        initialDate: DateFormat('yyyy/MM/dd').format(DateTime.now()),
        initialTime: DateFormat('HH:mm').format(DateTime.now()),
      ),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => curr.navigateToTimetable && !prev.navigateToTimetable,
      listener: (context, state) {
        context.go(
          '/timetable',
          extra: {
            'origin': state.departureStationId,
            'destination': state.arrivalStationId,
            'date': state.date.replaceAll('/', '-'),
            'originName': state.departureStation,
            'destinationName': state.arrivalStation,
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE8F4FD),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopSection()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStationCard(context, state),
                      const SizedBox(height: 16),
                      DateTimeRowWidget(
                        date: state.date,
                        time: state.time,
                        onDateChanged: (d) =>
                            context.read<HomeBloc>().add(HomeEvent.updateDate(d)),
                        onTimeChanged: (t) =>
                            context.read<HomeBloc>().add(HomeEvent.updateTime(t)),
                      ),
                      const SizedBox(height: 16),
                      _buildSearchButton(context, state),
                      if (state.recentSearches.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        RecentSearchListWidget(
                          searches: state.recentSearches,
                          onClearAll: () => context
                              .read<HomeBloc>()
                              .add(const HomeEvent.clearHistory()),
                          onSelect: (s) => context
                              .read<HomeBloc>()
                              .add(HomeEvent.selectRecentSearch(s)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF4A90D9)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text(
            '鐵路時刻表',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(BuildContext context, HomeState state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StationInputWidget(
            label: '出發站',
            stationName: state.departureStation,
            dotColor: const Color(0xFF4A90D9),
            onTap: null,
          ),
          const SizedBox(height: 4),
          _buildDividerRow(context),
          const SizedBox(height: 4),
          StationInputWidget(
            label: '到達站',
            stationName: state.arrivalStation,
            dotColor: const Color(0xFFE74C3C),
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildDividerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFE0E8F0))),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () =>
              context.read<HomeBloc>().add(const HomeEvent.swapStations()),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.swap_vert, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: const Color(0xFFE0E8F0))),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context, HomeState state) {
    return GestureDetector(
      onTap: () => _onSearchTap(context, state),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x404A90D9),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              '查詢班次',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchTap(BuildContext context, HomeState state) {
    if (state.departureStation.isEmpty || state.arrivalStation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填入出發站與到達站')),
      );
      return;
    }
    // Navigation happens via BlocListener after save completes
    context.read<HomeBloc>().add(const HomeEvent.search());
  }
}
