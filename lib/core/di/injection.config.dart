// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_railway_timetable/core/di/app_module.dart' as _i580;
import 'package:flutter_railway_timetable/features/home/data/repository/recent_search_repository_impl.dart'
    as _i159;
import 'package:flutter_railway_timetable/features/home/domain/repository/recent_search_repository.dart'
    as _i433;
import 'package:flutter_railway_timetable/features/timetable/data/datasource/tdx_tra_api_service.dart'
    as _i317;
import 'package:flutter_railway_timetable/features/timetable/data/repository/timetable_repository_impl.dart'
    as _i692;
import 'package:flutter_railway_timetable/features/timetable/domain/repository/timetable_repository.dart'
    as _i275;
import 'package:flutter_railway_timetable/features/timetable/domain/usecase/get_daily_timetable_use_case.dart'
    as _i520;
import 'package:flutter_railway_timetable/features/timetable/presentation/bloc/timetable_bloc.dart'
    as _i6;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i317.TdxTraApiService>(
      () => appModule.tdxTraApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i433.RecentSearchRepository>(
      () => _i159.SharedPreferencesRecentSearchRepository(),
    );
    gh.lazySingleton<_i275.TimetableRepository>(
      () => _i692.TimetableRepositoryImpl(gh<_i317.TdxTraApiService>()),
    );
    gh.factory<_i520.GetDailyTimetableUseCase>(
      () => _i520.GetDailyTimetableUseCase(gh<_i275.TimetableRepository>()),
    );
    gh.factory<_i6.TimetableBloc>(
      () => _i6.TimetableBloc(gh<_i520.GetDailyTimetableUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i580.AppModule {}
