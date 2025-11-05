import 'package:equatable/equatable.dart';

class CityClock extends Equatable {
  const CityClock({required this.city, required this.timeZoneId, this.isLocal = false});

  final String city;
  final String timeZoneId; // e.g. 'America/New_York'
  final bool isLocal;

  @override
  List<Object?> get props => [city, timeZoneId, isLocal];
}


