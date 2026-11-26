import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/employee_dashboard/data/datasources/employee_remote_datasource.dart';
import '../../features/employee_dashboard/data/repositories/employee_repository_impl.dart';
import '../../features/employee_dashboard/domain/repositories/employee_repository.dart';
import '../../features/employee_dashboard/presentation/cubit/employee_cubit.dart';
import '../../features/owner_home/data/datasources/owner_remote_datasource.dart';
import '../../features/owner_home/data/repositories/owner_repository_impl.dart';
import '../../features/owner_home/domain/repositories/owner_repository.dart';
import '../../features/owner_home/presentation/cubit/owner_cubit.dart';
import '../../features/settings/presentation/locale_cubit.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Core Storage & Network
  final tokenStorage = TokenStorage(secureStorage: sl(), prefs: sl());
  AppConfig.init(tokenStorage.getSavedBaseUrl());
  sl.registerSingleton<TokenStorage>(tokenStorage);

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenStorage: sl()),
  );

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl()),
  );

  // Owner Home Feature
  sl.registerLazySingleton<OwnerRemoteDataSource>(
    () => OwnerRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OwnerRepository>(
    () => OwnerRepositoryImpl(sl()),
  );
  sl.registerFactory<OwnerCubit>(
    () => OwnerCubit(sl()),
  );

  // Employee Dashboard Feature
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );
  sl.registerFactory<EmployeeCubit>(
    () => EmployeeCubit(sl()),
  );

  // Settings
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl()),
  );
}
