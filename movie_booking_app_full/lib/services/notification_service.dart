import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

/// NotificationService - Quản lý thông báo trong app
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );
  }

  /// Hiển thị thông báo ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'movie_booking_channel',
      'Movie Booking Notifications',
      channelDescription: 'Thông báo đặt vé xem phim',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Lên lịch thông báo cho booking reminder
  Future<void> scheduleBookingReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Schedule 1 hour before showtime
    final reminderTime = scheduledDate.subtract(const Duration(hours: 1));

    if (reminderTime.isBefore(DateTime.now())) {
      // If reminder time is in the past, don't schedule
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'movie_booking_reminders',
      'Movie Booking Reminders',
      channelDescription: 'Nhắc nhở lịch chiếu phim',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: null,
      payload: payload,
    );
  }

  /// Hủy thông báo đã lên lịch
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Thông báo đặt vé thành công
  Future<void> showBookingSuccessNotification(String movieTitle, String showTime) async {
    await showNotification(
      id: Random().nextInt(2147483647),
      title: 'Đặt vé thành công!',
      body: 'Vé xem phim "$movieTitle" vào $showTime đã được xác nhận.',
    );
  }

  /// Thông báo nhắc nhở lịch chiếu
  Future<void> scheduleShowReminder(String movieTitle, DateTime showTime, int bookingId) async {
    await scheduleBookingReminder(
      id: bookingId,
      title: 'Nhắc nhở: Phim sắp chiếu!',
      body: 'Phim "$movieTitle" sẽ chiếu trong 1 giờ nữa.',
      scheduledDate: showTime,
      payload: 'booking_$bookingId',
    );
  }

  /// Thông báo hủy vé
  Future<void> showBookingCancelledNotification(String movieTitle) async {
    await showNotification(
      id: Random().nextInt(2147483647),
      title: 'Vé đã được hủy',
      body: 'Vé xem phim "$movieTitle" đã được hủy thành công.',
    );
  }
}
