import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaclocks/core/l10n/app_localizations.dart';

import '../bloc/stopwatch_bloc.dart';

class StopwatchPage extends StatelessWidget {
  const StopwatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StopwatchBloc, StopwatchState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Column(
          children: [
            const SizedBox(height: 24),
            Text(formatMs(state.elapsedMs), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: state.running
                      ? () => context.read<StopwatchBloc>().add(StopwatchStopped())
                      : () => context.read<StopwatchBloc>().add(StopwatchStarted()),
                  child: Text(state.running ? l10n.stop : l10n.start),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: state.running
                      ? () => context.read<StopwatchBloc>().add(StopwatchLapped())
                      : () => context.read<StopwatchBloc>().add(StopwatchReset()),
                  child: Text(state.running ? l10n.lap : l10n.reset),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.lapsMs.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Text('#${i + 1}'),
                  title: Text(formatMs(state.lapsMs[i])),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}


