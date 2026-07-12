import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/league.dart';
import '../models/stadium.dart';
import 'sports_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const int _reminderId = 100;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // If the device timezone can't be determined, fall back to default.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings: settings);
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedules a reminder ~3 hours before the favorite team's next home
  /// game. Replaces any previously scheduled reminder.
  static Future<void> scheduleGameDayReminder(String? favoriteTeam) async {
    await _plugin.cancel(id: _reminderId);
    if (favoriteTeam == null || favoriteTeam.isEmpty) return;

    Stadium? stadium;
    for (final s in kStadiums) {
      if (s.team == favoriteTeam) {
        stadium = s;
        break;
      }
    }
    if (stadium == null) return;

    final nextGame = await SportsService.fetchNextGame(stadium);
    if (nextGame == null) return;

    final reminderTime = nextGame.dateTime.subtract(const Duration(hours: 3));
    if (reminderTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Game day! ${stadium.league.emoji}',
      body: '${nextGame.title} today \u2014 don\'t forget to sign your seat!',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'game_day_channel',
          'Game Day Reminders',
          channelDescription: "Reminders for your favorite team's game days",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}