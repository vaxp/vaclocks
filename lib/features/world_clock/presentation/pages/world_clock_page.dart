import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vaclocks/core/l10n/app_localizations.dart';

import '../../domain/entities/city_clock.dart';
import '../bloc/world_clock_bloc.dart';

class WorldClockPage extends StatelessWidget {
  const WorldClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldClockBloc, WorldClockState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: state.cities.length,
          itemBuilder: (context, i) {
            final item = state.cities[i];
            return _ClockCard(city: item, now: state.now);
          },
        );
      },
    );
  }
}

class _ClockCard extends StatelessWidget {
  const _ClockCard({required this.city, required this.now});
  final CityClock city;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final time = WorldClockBloc.formatTimeFor(city.timeZoneId, now);
    String desc;
    if (city.isLocal) {
      desc = l10n.currentLocation;
    } else {
      final here = now.toUtc();
      final there = tz.TZDateTime.from(now, tz.getLocation(city.timeZoneId)).toUtc();
      final diff = there.difference(here);
      final hours = diff.inHours;
      if (hours == 0) {
        desc = l10n.currentLocation;
      } else {
        final abs = hours.abs();
        final tomorrow = tz.TZDateTime.from(now, tz.getLocation(city.timeZoneId)).day != tz.TZDateTime.from(now, tz.local).day;
        final isAhead = hours > 0;
        final hourLabel = abs == 1 
            ? (isAhead ? l10n.hourAhead : l10n.hourBehind)
            : (isAhead ? l10n.hoursAhead : l10n.hoursBehind);
        desc = '$abs $hourLabel';
        if (tomorrow && isAhead) {
          desc = '${l10n.tomorrow} • $desc';
        }
      }
    }
    final isAhead = !desc.contains(l10n.hoursBehind) && !desc.contains(l10n.hourBehind) && !desc.contains(l10n.currentLocation);
    final color = isAhead ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer;
    final textColor = isAhead ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSecondaryContainer;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(city.city, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(desc),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(time, style: theme.textTheme.titleMedium?.copyWith(color: textColor)),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => context.read<WorldClockBloc>().add(WorldClockRemoveRequested(city)),
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, size: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}


