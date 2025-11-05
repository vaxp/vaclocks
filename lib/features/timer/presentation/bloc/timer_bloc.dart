import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaclocks/core/notifications/notification_service.dart' as core show NotificationService;

class TimerState extends Equatable {
  const TimerState({required this.totalMs, required this.remainingMs, required this.running});
  final int totalMs;
  final int remainingMs;
  final bool running;
  TimerState copyWith({int? totalMs, int? remainingMs, bool? running}) =>
      TimerState(totalMs: totalMs ?? this.totalMs, remainingMs: remainingMs ?? this.remainingMs, running: running ?? this.running);
  @override
  List<Object?> get props => [totalMs, remainingMs, running];
}

abstract class TimerEvent {}
class TimerStarted extends TimerEvent { TimerStarted(this.ms); final int ms; }
class TimerPaused extends TimerEvent {}
class TimerResumed extends TimerEvent {}
class TimerReset extends TimerEvent {}
class TimerTicked extends TimerEvent {}

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(const TimerState(totalMs: 0, remainingMs: 0, running: false)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
  }

  Timer? _timer;
  DateTime? _lastTick;

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(TimerState(totalMs: event.ms, remainingMs: event.ms, running: true));
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => add(TimerTicked()));
    // Notify: timer set and schedule finish notification
    core.NotificationService().showInstant(id: 1001, title: 'Timer set', body: 'Ends in ${event.ms ~/ 1000} seconds');
    core.NotificationService().scheduleAfter(
      id: 1002,
      delay: Duration(milliseconds: event.ms),
      title: 'Timer finished',
      body: 'Your timer has ended',
    );
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(state.copyWith(running: false));
    core.NotificationService().cancel(1002); // cancel scheduled finish
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state.remainingMs <= 0 || state.running) return;
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => add(TimerTicked()));
    emit(state.copyWith(running: true));
    core.NotificationService().scheduleAfter(
      id: 1002,
      delay: Duration(milliseconds: state.remainingMs),
      title: 'Timer finished',
      body: 'Your timer has ended',
    );
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(const TimerState(totalMs: 0, remainingMs: 0, running: false));
    core.NotificationService().cancel(1002);
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastTick ?? now).inMilliseconds;
    _lastTick = now;
    final remaining = (state.remainingMs - elapsed).clamp(0, state.totalMs);
    if (remaining == 0) {
      _timer?.cancel();
      emit(state.copyWith(remainingMs: 0, running: false));
      core.NotificationService().showInstant(id: 1003, title: 'Timer finished', body: 'Time is up');
    } else {
      emit(state.copyWith(remainingMs: remaining));
    }
  }
}

String formatCountdown(int ms) {
  final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
  final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}


