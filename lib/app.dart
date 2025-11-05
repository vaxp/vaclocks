import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
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
          create: (_) => WorldClockBloc(WorldClockRepositoryImpl())..add(WorldClockStarted()),
        ),
        BlocProvider(create: (_) => AlarmBloc()),
        BlocProvider(create: (_) => StopwatchBloc()),
        BlocProvider(create: (_) => TimerBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vaclocks',
        theme: buildAppTheme(context),
        navigatorKey: navigatorKey,
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: _Header(
                  index: _index,
                  onChanged: (i) => setState(() => _index = i),
                ),
              ),
            ),
          ),
          body: IndexedStack(
            index: _index,
            children: const [
              WorldClockPage(),
              AlarmsPage(),
              StopwatchPage(),
              TimerPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        _IconButton(
          icon: Icons.add,
          onPressed: () {
            if (index == 0) {
              context.read<WorldClockBloc>().add(WorldClockAddRequested(context: context));
            } else if (index == 1) {
              context.read<AlarmBloc>().add(AlarmAddRequested());
            }
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Segmented(
            current: index,
            onChanged: onChanged,
            items: const [
              (Icons.public, 'World'),
              (Icons.alarm, 'Alarms'),
              (Icons.timer_outlined, 'Stopwatch'),
              (Icons.hourglass_bottom, 'Timer'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _IconButton(icon: Icons.menu, onPressed: () {}),
        const SizedBox(width: 8),
        _IconButton(icon: Icons.close, onPressed: () {}),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.current, required this.onChanged, required this.items});
  final int current;
  final ValueChanged<int> onChanged;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: i == current ? theme.colorScheme.surfaceContainerHighest : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].$1, size: 18),
                      const SizedBox(width: 6),
                      Text(items[i].$2, style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


