import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaclocks/venom_layout.dart';

import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/alarms/presentation/bloc/alarm_bloc.dart';
import 'features/alarms/presentation/pages/alarms_page.dart';
import 'features/stopwatch/presentation/bloc/stopwatch_bloc.dart';
import 'features/stopwatch/presentation/pages/stopwatch_page.dart';
import 'features/timer/presentation/bloc/timer_bloc.dart';
import 'features/timer/presentation/pages/timer_page.dart';
import 'features/world_clock/data/repositories/world_clock_repository_impl.dart';
import 'features/world_clock/presentation/bloc/world_clock_bloc.dart';
import 'features/world_clock/presentation/pages/world_clock_page.dart';

class VaclocksApp extends StatefulWidget {
  const VaclocksApp({super.key});

  @override
  State<VaclocksApp> createState() => _VaclocksAppState();
}

class _VaclocksAppState extends State<VaclocksApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              WorldClockBloc(WorldClockRepositoryImpl())
                ..add(WorldClockStarted()),
        ),
        BlocProvider(create: (_) => AlarmBloc()),
        BlocProvider(create: (_) => StopwatchBloc()),
        BlocProvider(create: (_) => TimerBloc()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Vaclocks',
            theme: buildAppTheme(context),
            navigatorKey: navigatorKey,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: VenomScaffold(
              body: IndexedStack(
                index: _index,
                children: const [
                  WorldClockPage(),
                  AlarmsPage(),
                  StopwatchPage(),
                  TimerPage(),
                ],
              ),
              index: _index,
              onIndexChanged: (i) => setState(() => _index = i),
            ),
          );
        },
      ),
    );
  }
}

// Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 child: Header(
//                   index: _index,onChanged: (i) => setState(() => _index = i),
//                 ),
//               ),









