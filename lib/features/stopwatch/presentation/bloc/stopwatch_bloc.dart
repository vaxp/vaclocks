import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StopwatchState extends Equatable {
  const StopwatchState({required this.running, required this.elapsedMs, required this.lapsMs});
  final bool running;
  final int elapsedMs;
  final List<int> lapsMs;
  StopwatchState copyWith({bool? running, int? elapsedMs, List<int>? lapsMs}) =>
      StopwatchState(running: running ?? this.running, elapsedMs: elapsedMs ?? this.elapsedMs, lapsMs: lapsMs ?? this.lapsMs);
  @override
  List<Object?> get props => [running, elapsedMs, lapsMs];
}

abstract class StopwatchEvent {}
class StopwatchStarted extends StopwatchEvent {}
class StopwatchStopped extends StopwatchEvent {}
class StopwatchReset extends StopwatchEvent {}
class StopwatchLapped extends StopwatchEvent {}
class StopwatchTicked extends StopwatchEvent { StopwatchTicked(this.ms); final int ms; }

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  StopwatchBloc() : super(const StopwatchState(running: false, elapsedMs: 0, lapsMs: [])) {
    on<StopwatchStarted>(_onStart);
    on<StopwatchStopped>(_onStop);
    on<StopwatchReset>(_onReset);
    on<StopwatchLapped>(_onLap);
    on<StopwatchTicked>((e, emit) => emit(state.copyWith(elapsedMs: e.ms)));
  }

  Timer? _timer;
  int _baseMs = 0;
  DateTime? _startTime;

  void _onStart(StopwatchStarted event, Emitter<StopwatchState> emit) {
    if (state.running) return;
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      final ms = _baseMs + DateTime.now().difference(_startTime!).inMilliseconds;
      add(StopwatchTicked(ms));
    });
    emit(state.copyWith(running: true));
  }

  void _onStop(StopwatchStopped event, Emitter<StopwatchState> emit) {
    if (!state.running) return;
    _baseMs = state.elapsedMs;
    _timer?.cancel();
    emit(state.copyWith(running: false));
  }

  void _onReset(StopwatchReset event, Emitter<StopwatchState> emit) {
    _timer?.cancel();
    _baseMs = 0;
    _startTime = null;
    emit(const StopwatchState(running: false, elapsedMs: 0, lapsMs: []));
  }

  void _onLap(StopwatchLapped event, Emitter<StopwatchState> emit) {
    if (!state.running) return;
    final laps = [...state.lapsMs, state.elapsedMs];
    emit(state.copyWith(lapsMs: laps));
  }
}

String formatMs(int ms) {
  final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
  final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
  final hundredths = (((ms % 1000) ~/ 10)).toString().padLeft(2, '0');
  return '$minutes:$seconds.$hundredths';
}


