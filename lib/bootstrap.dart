import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/bloc_observer.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    developer.log(details.exceptionAsString(), stackTrace: details.stack, name: 'FLUTTER_ERROR');
  };

  Bloc.observer = AppBlocObserver();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initDependencies();
      runApp(await builder());
    },
    (error, stackTrace) => developer.log(error.toString(), stackTrace: stackTrace, name: 'UNCAUGHT_ERROR'),
  );
}
