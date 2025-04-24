import 'dart:io';
import 'dart:ui';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_assist/Controllers/database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  // static final onClickNotification = BehaviorSubject<String>();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // void onNotificationTap(NotificationResponse notificationResponse) {
  //   onClickNotification.add(notificationResponse.payload!);
  // }

  //INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return;

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationPlugin.initialize(
      initSettings,
      // onDidReceiveNotificationResponse: onNotificationTap,
      // onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    _isInitialized = true;
  }

  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'med_assist_channel',
        'Alarme Médicale',
        channelDescription: 'Notification pour les rappels de médicaments',
        importance: Importance.max,
        priority: Priority.high,
        // icon: 'notification_icon',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // NotificationDetails notificationDetails() {
  //   return const NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       'channel 0',
  //       'Treat Notification',
  //       channelDescription: 'Treat Notification Channel',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       ticker: 'ticker',
  //       // actions: <AndroidNotificationAction>[
  //       //   AndroidNotificationAction(
  //       //     'id_1',
  //       //     'Action 1',
  //       //     icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  //       //     contextual: true,
  //       //   ),
  //       //   AndroidNotificationAction(
  //       //     'id_2',
  //       //     'Action 2',
  //       //     titleColor: Color.fromARGB(255, 255, 0, 0),
  //       //     icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  //       //   ),
  //       // ],
  //     ),
  //     iOS: DarwinNotificationDetails(),
  //   );
  // }

  Future<void> addAlarm({
    required int id,
    required String title1,
    required String title2,
    required String body1,
    required String body2,
    required String payload,
    required DateTime time,
    required String userUid,
  }) async {
    bool isAllow = await DatabaseService(
      userUid,
    ).getUserSetting("allowNotification");
    if (!isAllow) return;

    String alarmMusic = await DatabaseService(
      userUid,
    ).getUserSetting("alarmMusic");

    const Map<String, String> alarmSounds = {
      "music1": "alarm.wav",
      "music2": "alarm_clock.mp3",
      "music3": "natural_alarm.mp3",
      "music4": "sehun.mp3",
    };

    String? song = alarmSounds[alarmMusic];
    if (song == null) return;

    if (time.isBefore(DateTime.now())) return;

    tz.initializeTimeZones();
    final location = tz.getLocation('Africa/Tunis');

    final scheduledTime = tz.TZDateTime(
      location,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute - 5,
      time.second,
    );

    if (scheduledTime.isBefore(tz.TZDateTime.now(location))) {
      print("⛔ Notification skipped: scheduled time is in the past.");
      return;
    }

    final alarmSettings = AlarmSettings(
      id: id,
      payload: payload,
      dateTime: time,
      assetAudioPath: 'assets/alarms/$song',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 1,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: false,
      ),
      notificationSettings: NotificationSettings(
        title: title2,
        body: body2,
        stopButton: 'Stop the alarm',
        icon: 'notification_icon',
        iconColor: const Color(0xff862778),
      ),
    );

    try {
      await notificationPlugin.zonedSchedule(
        id,
        title1,
        body1,
        scheduledTime,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: payload,
        matchDateTimeComponents: null,
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e, stack) {
      print("⚠️ zonedSchedule error: $e");
      print(stack);
    }
  }

  Future<void> cancelAlarm({required int id}) async {
    await notificationPlugin.cancel(id);
    await Alarm.stop(id);
  }

  Future<void> cancelAllAlarm() async {
    await notificationPlugin.cancelAll();
    await Alarm.stopAll();
  }

  Future<bool> isNotificationPlanned(int id) async {
    final List<ActiveNotification>? activeNotifications =
        await notificationPlugin.getActiveNotifications();

    if (activeNotifications == null) return false;

    return activeNotifications.any((notification) => notification.id == id);
  }
}
