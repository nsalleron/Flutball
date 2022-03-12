import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutball/core/utils/constants.dart';
import 'package:flutball/data/datasources/remote/football_api_service.dart';
import 'package:flutball/data/repositories/football_repository.dart';
import 'package:flutball/data/repositories/football_repository_impl.dart';
import 'package:flutball/domain/usecases/get_competitions_usecase.dart';
import 'package:flutball/domain/usecases/get_match_usecase.dart';
import 'package:flutball/domain/usecases/get_team_usecase.dart';
import 'package:flutball/presentation/competition/logic/competition_cubit.dart';
import 'package:flutball/presentation/competition/logic/team_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt injector = GetIt.instance
  ..registerLazySingleton<Dio>(
    () => Dio()
      ..options.headers['X-Auth-Token'] = kApiKey
      ..interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: kBaseUrl)).interceptor
            as Interceptor,
      )
      ..interceptors.add(LogInterceptor(responseBody: true)),
  )
  ..registerLazySingleton<FootballApiService>(
    () => FootballApiService(injector()),
  )
  ..registerLazySingleton<FootballRepository>(
    () => FootballRepositoryImpl(footballApiService: injector()),
  )
  ..registerLazySingleton<GetMatchesUseCase>(
    () => GetMatchesUseCase(injector()),
  )
  ..registerLazySingleton<GetTeamUseCase>(() => GetTeamUseCase(injector()))
  ..registerLazySingleton<GetCompetitionUseCase>(
    () => GetCompetitionUseCase(injector()),
  )
  ..registerLazySingleton<CompetitionCubit>(
    () => CompetitionCubit(getCompetitionUseCase: injector()),
  )
  ..registerLazySingleton(
    () => TeamCubit(getTeamUseCase: injector(), getMatchesUseCase: injector()),
  );
