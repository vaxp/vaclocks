part of 'world_clock_bloc.dart';

class WorldClockState extends Equatable {
  const WorldClockState({required this.cities, required this.now});

  factory WorldClockState.initial() => WorldClockState(cities: const [], now: DateTime.now());

  final List<CityClock> cities;
  final DateTime now;

  WorldClockState copyWith({List<CityClock>? cities, DateTime? now}) =>
      WorldClockState(cities: cities ?? this.cities, now: now ?? this.now);

  @override
  List<Object?> get props => [cities, now];
}


