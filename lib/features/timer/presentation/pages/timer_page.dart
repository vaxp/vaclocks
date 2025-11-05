import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaclocks/core/l10n/app_localizations.dart';

import '../bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimerBloc, TimerState>(
      listenWhen: (p, c) => p.running != c.running || (p.remainingMs > 0 && c.remainingMs == 0),
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        final messenger = ScaffoldMessenger.of(context);
        if (state.running) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.timerStarted)));
        } else if (state.remainingMs == 0) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.timerFinished)));
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(formatCountdown(state.remainingMs), style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final m in [1, 3, 5, 10])
                    ActionChip(
                      label: Text('${m}m'),
                      onPressed: () => context.read<TimerBloc>().add(TimerStarted(m * 60000)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: state.running
                        ? () => context.read<TimerBloc>().add(TimerPaused())
                        : () => context.read<TimerBloc>().add(TimerResumed()),
                    child: Text(state.running ? l10n.pause : l10n.resume),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => context.read<TimerBloc>().add(TimerReset()),
                    child: Text(l10n.reset),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


