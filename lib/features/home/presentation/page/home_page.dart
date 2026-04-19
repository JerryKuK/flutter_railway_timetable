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
import '../widget/station_picker_modal.dart';
import '../widget/railway_type_segment_widget.dart';
import '../../../../core/cubit/railway_type_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/enums/railway_type.dart';
import '../../../../core/theme/railway_theme.dart';
import '../../../../features/timetable/domain/repository/timetable_repository.dart';
import '../../../../features/timetable/domain/repository/thsr_timetable_repository.dart';
import '../../domain/repository/recent_search_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final initialType = context.read<RailwayTypeCubit>().state;
    return BlocProvider(
      create: (_) => HomeBloc(
        getIt<RecentSearchRepository>(),
        getIt<TimetableRepository>(),
        getIt<ThsrTimetableRepository>(),
        initialDate: DateFormat('yyyy/MM/dd').format(DateTime.now()),
        initialTime: DateFormat('HH:mm').format(DateTime.now()),
        initialRailwayType: initialType,
      ),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (prev, curr) =>
              curr.navigateToTimetable && !prev.navigateToTimetable,
          listener: (context, state) {
            context.go(
              '/timetable',
              extra: {
                'origin': state.departureStationId,
                'destination': state.arrivalStationId,
                'date': state.date.replaceAll('/', '-'),
                'time': state.time,
                'originName': state.departureStation,
                'destinationName': state.arrivalStation,
                'railwayType': state.railwayType.name,
              },
            );
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (prev, curr) => prev.railwayType != curr.railwayType,
          listener: (context, state) {
            context.read<RailwayTypeCubit>().switchTo(state.railwayType);
          },
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
        final theme = RailwayTheme.of(state.railwayType);
        return Scaffold(
          backgroundColor: const Color(0xFFEEF4FB),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopSection(context, state, theme)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStationCard(context, state, theme),
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
                      _buildSearchButton(context, state, theme),
                      if (state.recentSearches
                          .where((s) => s.railwayType == state.railwayType.name)
                          .isNotEmpty) ...[
                        const SizedBox(height: 20),
                        RecentSearchListWidget(
                          searches: state.recentSearches
                              .where((s) =>
                                  s.railwayType == state.railwayType.name)
                              .toList(),
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
    ),
    );
  }

  Widget _buildTopSection(
      BuildContext context, HomeState state, RailwayTheme theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.headerGradient,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      child: Column(
        children: [
          RailwayTypeSegmentWidget(
            value: state.railwayType,
            onChanged: (type) =>
                context.read<HomeBloc>().add(HomeEvent.switchRailwayType(type)),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.train, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                state.railwayType == RailwayType.hsr ? '高鐵時刻表' : '台鐵時刻表',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(
      BuildContext context, HomeState state, RailwayTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10244878),
            blurRadius: 24,
            offset: Offset(0, 8),
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
            onTap: () => _openStationPicker(
              context,
              state,
              isDeparture: true,
            ),
          ),
          const SizedBox(height: 4),
          _buildDividerRow(context, state, theme),
          const SizedBox(height: 4),
          StationInputWidget(
            label: '到達站',
            stationName: state.arrivalStation,
            dotColor: const Color(0xFFE74C3C),
            onTap: () => _openStationPicker(
              context,
              state,
              isDeparture: false,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStationPicker(
    BuildContext context,
    HomeState state, {
    required bool isDeparture,
  }) async {
    final bloc = context.read<HomeBloc>();
    final isHsr = state.railwayType == RailwayType.hsr;
    final stations = isHsr ? state.hsrStations : state.traStations;

    final selected = await showStationPickerModal(
      context,
      title: isDeparture ? '選擇出發站' : '選擇到達站',
      stations: stations,
      selectedStationId: isDeparture
          ? state.departureStationId
          : state.arrivalStationId,
      isLoading: state.isLoadingStations,
      errorMessage: state.stationsError,
      showCityFilter: !isHsr,
      onRetry: () {
        Navigator.of(context).pop();
        bloc.add(const HomeEvent.loadStations());
      },
    );

    if (selected != null) {
      if (isDeparture) {
        bloc.add(HomeEvent.selectDepartureStation(selected));
      } else {
        bloc.add(HomeEvent.selectArrivalStation(selected));
      }
    }
  }

  Widget _buildDividerRow(
      BuildContext context, HomeState state, RailwayTheme theme) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFE0E8F0))),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () =>
              context.read<HomeBloc>().add(const HomeEvent.swapStations()),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.swap_vert, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: const Color(0xFFE0E8F0))),
      ],
    );
  }

  Widget _buildSearchButton(
      BuildContext context, HomeState state, RailwayTheme theme) {
    return GestureDetector(
      onTap: () => _onSearchTap(context, state),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.headerGradient.first, theme.accent],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: theme.accent.withValues(alpha: 0.38),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                letterSpacing: 1,
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
    context.read<HomeBloc>().add(const HomeEvent.search());
  }
}
