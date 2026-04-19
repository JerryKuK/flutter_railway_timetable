import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/railway_type.dart';

class RailwayTypeCubit extends Cubit<RailwayType> {
  RailwayTypeCubit() : super(RailwayType.tra);

  void switchTo(RailwayType type) => emit(type);
}
