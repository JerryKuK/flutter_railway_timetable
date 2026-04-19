enum RailwayType {
  tra,
  hsr;

  String get label => this == RailwayType.hsr ? '高鐵' : '台鐵';
  String get instanceName => this == RailwayType.hsr ? 'thsr' : '';
}
