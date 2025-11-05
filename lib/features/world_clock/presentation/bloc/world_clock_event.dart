part of 'world_clock_bloc.dart';

abstract class WorldClockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorldClockStarted extends WorldClockEvent {}

class WorldClockTicked extends WorldClockEvent {}

class WorldClockRemoveRequested extends WorldClockEvent {
  WorldClockRemoveRequested(this.city);
  final CityClock city;
  @override
  List<Object?> get props => [city];
}

class WorldClockAddRequested extends WorldClockEvent {
  WorldClockAddRequested({required this.context});
  final BuildContext context;
}


