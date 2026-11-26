import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/employee_dashboard/presentation/cubit/employee_cubit.dart';
import 'features/owner_home/presentation/cubit/owner_cubit.dart';
import 'features/settings/presentation/locale_cubit.dart';

void main() {
  bootstrap(() => const XGarageApp());
}

class XGarageApp extends StatefulWidget {
  const XGarageApp({super.key});

  @override
  State<XGarageApp> createState() => _XGarageAppState();
}

class _XGarageAppState extends State<XGarageApp> {
  late final AuthCubit _authCubit;
  late final LocaleCubit _localeCubit;
  late final OwnerCubit _ownerCubit;
  late final EmployeeCubit _employeeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>()..checkAuthStatus();
    _localeCubit = sl<LocaleCubit>();
    _ownerCubit = sl<OwnerCubit>();
    _employeeCubit = sl<EmployeeCubit>();
    _router = createRouter(_authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<LocaleCubit>.value(value: _localeCubit),
        BlocProvider<OwnerCubit>.value(value: _ownerCubit),
        BlocProvider<EmployeeCubit>.value(value: _employeeCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'XGarage',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
