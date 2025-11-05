import 'package:flutter/material.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  NotificationService().init();
  runApp(const VaclocksApp());
}
