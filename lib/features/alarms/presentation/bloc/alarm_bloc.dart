import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaclocks/core/notifications/notification_service.dart';
import 'package:vaclocks/core/audio/ringer.dart';
import 'package:vaclocks/core/l10n/app_localizations.dart';

enum AlarmRepeat { none, daily, weekly, monthly }

class Alarm extends Equatable {
  const Alarm({required this.timeOfDay, this.enabled = true, this.repeat = AlarmRepeat.none});
  final TimeOfDay timeOfDay;
  final bool enabled;
  final AlarmRepeat repeat;
  Alarm copyWith({TimeOfDay? timeOfDay, bool? enabled, AlarmRepeat? repeat}) =>
      Alarm(timeOfDay: timeOfDay ?? this.timeOfDay, enabled: enabled ?? this.enabled, repeat: repeat ?? this.repeat);
  @override
  List<Object?> get props => [timeOfDay.hour, timeOfDay.minute, enabled, repeat];
}

abstract class AlarmEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AlarmAddRequested extends AlarmEvent {}
class AlarmAdded extends AlarmEvent { AlarmAdded(this.alarm); final Alarm alarm; @override List<Object?> get props => [alarm]; }
class AlarmToggled extends AlarmEvent { AlarmToggled(this.index); final int index; @override List<Object?> get props => [index]; }
class AlarmDeleted extends AlarmEvent { AlarmDeleted(this.index); final int index; @override List<Object?> get props => [index]; }
class _AlarmReschedule extends AlarmEvent { _AlarmReschedule(this.index); final int index; }
class AlarmSnoozed extends AlarmEvent { AlarmSnoozed(this.index, this.timeOfDay); final int index; final TimeOfDay timeOfDay; }

class AlarmState extends Equatable {
  const AlarmState(this.alarms);
  final List<Alarm> alarms;
  @override
  List<Object?> get props => [alarms];
}

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  AlarmBloc() : super(const AlarmState([])) {
    on<AlarmAddRequested>(_onAddRequested);
    on<AlarmAdded>(_onAdded);
    on<AlarmToggled>((e, emit) {
      final next = [...state.alarms];
      next[e.index] = next[e.index].copyWith(enabled: !next[e.index].enabled);
      emit(AlarmState(next));
      _scheduleOrCancel(e.index, next[e.index]);
    });
    on<AlarmDeleted>((e, emit) {
      _cancelTimer(e.index);
      final next = [...state.alarms]..removeAt(e.index);
      emit(AlarmState(next));
    });
    on<_AlarmReschedule>((e, emit) => _scheduleIndex(e.index));
    on<AlarmSnoozed>((e, emit) {
      final list = [...state.alarms];
      if (e.index >= 0 && e.index < list.length) {
        list[e.index] = list[e.index].copyWith(timeOfDay: e.timeOfDay, enabled: true);
        emit(AlarmState(list));
        add(_AlarmReschedule(e.index));
      }
    });
  }

  Future<void> _onAddRequested(AlarmAddRequested event, Emitter<AlarmState> emit) async {
    final context = navigatorKey.currentContext!;
    final result = await showDialog<Alarm>(context: context, builder: (_) => const _AddAlarmDialog());
    if (result != null) add(AlarmAdded(result));
  }

  void _onAdded(AlarmAdded e, Emitter<AlarmState> emit) {
    final list = [...state.alarms, e.alarm];
    emit(AlarmState(list));
    _scheduleIndex(list.length - 1);
  }

  final Map<int, Timer> _timers = {};

  void _cancelTimer(int index) {
    _timers.remove(index)?.cancel();
  }

  void _scheduleOrCancel(int index, Alarm alarm) {
    _cancelTimer(index);
    if (alarm.enabled) _scheduleIndex(index);
  }

  void _scheduleIndex(int index) {
    if (index < 0 || index >= state.alarms.length) return;
    final alarm = state.alarms[index];
    if (!alarm.enabled) return;
    final now = DateTime.now();
    final next = _nextOccurrence(now, alarm);
    final delay = next.difference(now);
    _timers[index] = Timer(delay, () async {
      await NotificationService().showInstant(id: 2000 + index, title: 'Alarm', body: _labelFor(alarm));
      await Ringer().start();
      final context = navigatorKey.currentContext;
      if (context != null) {
        // ignore: use_build_context_synchronously
        await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (_) => _RingingDialog(index: index, label: _labelFor(alarm)),
        );
      }
      // Note: further scheduling happens in user action handlers (stop/snooze)
    });
  }

  static String _labelFor(Alarm alarm) {
    final hh = alarm.timeOfDay.hour.toString().padLeft(2, '0');
    final mm = alarm.timeOfDay.minute.toString().padLeft(2, '0');
    final rep = switch (alarm.repeat) {
      AlarmRepeat.none => 'once',
      AlarmRepeat.daily => 'daily',
      AlarmRepeat.weekly => 'weekly',
      AlarmRepeat.monthly => 'monthly',
    };
    return '$hh:$mm ($rep)';
  }

  static DateTime _nextOccurrence(DateTime from, Alarm alarm) {
    DateTime candidate = DateTime(from.year, from.month, from.day, alarm.timeOfDay.hour, alarm.timeOfDay.minute);
    if (!candidate.isAfter(from)) {
      switch (alarm.repeat) {
        case AlarmRepeat.none:
        case AlarmRepeat.daily:
          candidate = candidate.add(const Duration(days: 1));
          break;
        case AlarmRepeat.weekly:
          candidate = candidate.add(const Duration(days: 7));
          break;
        case AlarmRepeat.monthly:
          candidate = DateTime(candidate.year, candidate.month + 1, candidate.day, candidate.hour, candidate.minute);
          break;
      }
    }
    return candidate;
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AddAlarmDialog extends StatefulWidget {
  const _AddAlarmDialog();
  @override
  State<_AddAlarmDialog> createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<_AddAlarmDialog> {
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  AlarmRepeat _repeat = AlarmRepeat.none;
  bool _isPm = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newAlarm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              ActionChip(label: Text('${l10n.morning} (08:00)'), onPressed: () => setState(() => _time = const TimeOfDay(hour: 8, minute: 0))),
              ActionChip(label: Text('${l10n.evening} (20:00)'), onPressed: () => setState(() => _time = const TimeOfDay(hour: 20, minute: 0))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.tonal(
            onPressed: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
                child: Text('${l10n.pickTime}: ${_time.format(context)}'),
              ),
              const SizedBox(width: 12),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(value: false, label: Text(l10n.am)),
                  ButtonSegment<bool>(value: true, label: Text(l10n.pm)),
                ],
                selected: {_isPm},
                onSelectionChanged: (s) {
                  final pm = s.first;
                  setState(() {
                    _isPm = pm;
                    var h = _time.hour % 12;
                    if (pm) h += 12;
                    _time = TimeOfDay(hour: h, minute: _time.minute);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(l10n.oneTime),
                selected: _repeat == AlarmRepeat.none,
                onSelected: (_) => setState(() => _repeat = AlarmRepeat.none),
              ),
              FilterChip(
                label: Text(l10n.daily),
                selected: _repeat == AlarmRepeat.daily,
                onSelected: (_) => setState(() => _repeat = AlarmRepeat.daily),
              ),
              FilterChip(
                label: Text(l10n.weekly),
                selected: _repeat == AlarmRepeat.weekly,
                onSelected: (_) => setState(() => _repeat = AlarmRepeat.weekly),
              ),
              FilterChip(
                label: Text(l10n.monthly),
                selected: _repeat == AlarmRepeat.monthly,
                onSelected: (_) => setState(() => _repeat = AlarmRepeat.monthly),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, Alarm(timeOfDay: _time, enabled: true, repeat: _repeat)), child: Text(l10n.add)),
      ],
    );
  }
}

class _RingingDialog extends StatelessWidget {
  const _RingingDialog({required this.index, required this.label});
  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.alarmRinging),
      content: Text(label),
      actions: [
        TextButton(
          onPressed: () async {
            await Ringer().stop();
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.stop),
        ),
        FilledButton(
          onPressed: () async {
            await Ringer().stop();
            // Snooze 10 minutes
            // ignore: use_build_context_synchronously
            final bloc = context.read<AlarmBloc>();
            final now = DateTime.now();
            final future = now.add(const Duration(minutes: 10));
            final td = TimeOfDay(hour: future.hour, minute: future.minute);
            bloc.add(AlarmSnoozed(index, td));
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.snooze10Min),
        ),
      ],
    );
  }
}


