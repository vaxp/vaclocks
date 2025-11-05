import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/repositories/world_clock_repository_impl.dart';
import '../../domain/entities/city_clock.dart';

part 'world_clock_event.dart';
part 'world_clock_state.dart';

class WorldClockBloc extends Bloc<WorldClockEvent, WorldClockState> {
  WorldClockBloc(this._repository) : super(WorldClockState.initial()) {
    on<WorldClockStarted>(_onStarted);
    on<WorldClockTicked>(_onTicked);
    on<WorldClockRemoveRequested>(_onRemove);
    on<WorldClockAddRequested>(_onAddRequested);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => add(WorldClockTicked()));
  }

  final WorldClockRepository _repository;
  Timer? _ticker;

  Future<void> _onStarted(WorldClockStarted event, Emitter<WorldClockState> emit) async {
    final items = _repository.loadInitial();
    emit(state.copyWith(cities: items));
  }

  void _onTicked(WorldClockTicked event, Emitter<WorldClockState> emit) {
    emit(state.copyWith(now: DateTime.now()));
  }

  void _onRemove(WorldClockRemoveRequested event, Emitter<WorldClockState> emit) {
    _repository.remove(event.city);
    emit(state.copyWith(cities: _repository.list()));
  }

  Future<void> _onAddRequested(WorldClockAddRequested event, Emitter<WorldClockState> emit) async {
    final context = event.context;
    final result = await showDialog<CityClock>(
      context: context,
      builder: (ctx) => _AddCityDialog(now: state.now),
    );
    if (result != null) {
      _repository.add(result);
      emit(state.copyWith(cities: _repository.list()));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  static String formatTimeFor(String timeZoneId, DateTime now) {
    final location = tz.getLocation(timeZoneId);
    final local = tz.TZDateTime.from(now, location);
    return DateFormat('HH:mm').format(local);
  }

  static String relativeDescription(String timeZoneId, DateTime now, {bool showTomorrow = true}) {
    final here = now.toUtc();
    final there = tz.TZDateTime.from(now, tz.getLocation(timeZoneId)).toUtc();
    final diff = there.difference(here);
    final hours = diff.inHours;
    final sign = hours == 0 ? '' : (hours > 0 ? 'ahead' : 'behind');
    final abs = hours.abs();
    final tomorrow = tz.TZDateTime.from(now, tz.getLocation(timeZoneId)).day != tz.TZDateTime.from(now, tz.local).day;
    if (hours == 0) return 'Current location';
    final base = '$abs hour${abs == 1 ? '' : 's'} $sign';
    if (showTomorrow && tomorrow && hours > 0) {
      return 'Tomorrow • $base';
    }
    return base;
  }
}

class _AddCityDialog extends StatefulWidget {
  const _AddCityDialog({required this.now});
  final DateTime now;
  @override
  State<_AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<_AddCityDialog> {
  final List<CityClock> _known = const [
    CityClock(city: 'Washington', timeZoneId: 'America/New_York'),
    CityClock(city: 'Budapest', timeZoneId: 'Europe/Budapest'),
    CityClock(city: 'Akita', timeZoneId: 'Asia/Tokyo'),
    CityClock(city: 'Auckland', timeZoneId: 'Pacific/Auckland'),
    CityClock(city: 'London', timeZoneId: 'Europe/London'),
    CityClock(city: 'Cairo', timeZoneId: 'Africa/Cairo'),
    CityClock(city: 'Sydney', timeZoneId: 'Australia/Sydney'),
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _known.where((c) => c.city.toLowerCase().contains(_query.toLowerCase())).toList();
    return AlertDialog(
      title: const Text('Add city'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search city'),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final city = filtered[i];
                  final time = WorldClockBloc.formatTimeFor(city.timeZoneId, widget.now);
                  return ListTile(
                    title: Text(city.city),
                    trailing: Text(time, style: Theme.of(context).textTheme.titleMedium),
                    onTap: () => Navigator.of(context).pop(city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}


