import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../../domain/entities/city_clock.dart';

abstract class WorldClockRepository {
  List<CityClock> loadInitial();
  List<CityClock> list();
  void add(CityClock city);
  void remove(CityClock city);
}

class WorldClockRepositoryImpl implements WorldClockRepository {
  WorldClockRepositoryImpl() {
    _ensureTimeZones();
  }

  final List<CityClock> _cities = [];

  @override
  List<CityClock> loadInitial() {
    if (_cities.isEmpty) {
      _cities.addAll(const [
        CityClock(city: 'Washington', timeZoneId: 'America/New_York'),
        CityClock(city: 'Budapest', timeZoneId: 'Europe/Budapest', isLocal: true),
        CityClock(city: 'Akita', timeZoneId: 'Asia/Tokyo'),
        CityClock(city: 'Auckland', timeZoneId: 'Pacific/Auckland'),
      ]);
    }
    return List.unmodifiable(_cities);
  }

  @override
  List<CityClock> list() => List.unmodifiable(_cities);

  @override
  void add(CityClock city) {
    if (_cities.any((c) => c.timeZoneId == city.timeZoneId)) return;
    _cities.add(city);
  }

  @override
  void remove(CityClock city) {
    _cities.removeWhere((c) => c.timeZoneId == city.timeZoneId);
  }

  void _ensureTimeZones() {
    if (!tz.timeZoneDatabase.locations.containsKey('UTC')) {
      tzdata.initializeTimeZones();
    }
  }
}


