import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaclocks/core/l10n/app_localizations.dart';

import '../bloc/alarm_bloc.dart';

class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: state.alarms.length,
          itemBuilder: (context, i) {
            final alarm = state.alarms[i];
            final l10n = AppLocalizations.of(context);
            final time = alarm.timeOfDay.format(context);
            final repeatText = switch (alarm.repeat) {
              AlarmRepeat.none => l10n.oneTime,
              AlarmRepeat.daily => l10n.daily,
              AlarmRepeat.weekly => l10n.weekly,
              AlarmRepeat.monthly => l10n.monthly,
            };
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(time, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(repeatText, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Switch(value: alarm.enabled, onChanged: (_) => context.read<AlarmBloc>().add(AlarmToggled(i))),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => context.read<AlarmBloc>().add(AlarmDeleted(i))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


