import 'package:flutter/material.dart';
import 'package:flutter_railway_timetable/features/timetable/domain/entity/station.dart';

class StationPickerModal extends StatefulWidget {
  final String title;
  final List<Station> stations;
  final String? selectedStationId;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const StationPickerModal({
    super.key,
    required this.title,
    required this.stations,
    this.selectedStationId,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<StationPickerModal> createState() => _StationPickerModalState();
}

class _StationPickerModalState extends State<StationPickerModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCity = '全部';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 台灣縣市由北到南的地理順序
  static const _geoOrder = [
    '基隆市', '臺北市', '台北市', '新北市', '桃園市',
    '新竹市', '新竹縣', '苗栗縣', '臺中市', '台中市',
    '彰化縣', '南投縣', '雲林縣', '嘉義市', '嘉義縣',
    '臺南市', '台南市', '高雄市', '屏東縣',
    '宜蘭縣', '花蓮縣', '臺東縣', '台東縣',
  ];

  List<String> get _cities {
    final cities = widget.stations
        .map((s) => s.city)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) {
        final ai = _geoOrder.indexOf(a);
        final bi = _geoOrder.indexOf(b);
        if (ai == -1 && bi == -1) return a.compareTo(b);
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });
    return ['全部', ...cities];
  }

  List<Station> get _filteredStations {
    return widget.stations.where((station) {
      final matchesSearch = _searchQuery.isEmpty ||
          station.stationName.contains(_searchQuery);
      final matchesCity =
          _selectedCity == '全部' || station.city == _selectedCity;
      return matchesSearch && matchesCity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          _buildSearchBox(),
          if (_cities.length > 1) _buildCityTabs(),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8ECF0)),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.close, color: Color(0xFF666666), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(21),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFFAABBCC), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
                decoration: const InputDecoration(
                  hintText: '搜尋站名...',
                  hintStyle: TextStyle(
                    color: Color(0xFFAABBCC),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTabs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _cities.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final city = _cities[index];
            final isSelected = city == _selectedCity;
            return GestureDetector(
              onTap: () => setState(() => _selectedCity = city),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4A90D9)
                      : const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
      );
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFE74C3C), size: 48),
              const SizedBox(height: 12),
              Text(
                widget.errorMessage!,
                style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.onRetry != null)
                TextButton(
                  onPressed: widget.onRetry,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  child: const Text('重試'),
                ),
            ],
          ),
        ),
      );
    }

    final stations = _filteredStations;
    if (stations.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty ? '找不到「$_searchQuery」相關站名' : '此城市暫無站點資料',
          style: const TextStyle(color: Color(0xFFAABBCC), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        final isSelected = station.stationId == widget.selectedStationId;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(station),
              child: Container(
                color: isSelected
                    ? const Color(0xFF4A90D9).withValues(alpha: 0.031)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4A90D9)
                            : const Color(0xFFCCCCCC),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        station.stationName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF4A90D9)
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check,
                          color: Color(0xFF4A90D9), size: 18),
                  ],
                ),
              ),
            ),
            if (index < stations.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF0F2F5),
              ),
          ],
        );
      },
    );
  }
}

/// 顯示車站選擇 Modal，回傳使用者選擇的 [Station]，取消則回傳 null
Future<Station?> showStationPickerModal(
  BuildContext context, {
  required String title,
  required List<Station> stations,
  String? selectedStationId,
  bool isLoading = false,
  String? errorMessage,
  VoidCallback? onRetry,
}) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => StationPickerModal(
        title: title,
        stations: stations,
        selectedStationId: selectedStationId,
        isLoading: isLoading,
        errorMessage: errorMessage,
        onRetry: onRetry,
      ),
    ),
  );
}
