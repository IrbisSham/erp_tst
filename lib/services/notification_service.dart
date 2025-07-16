import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';
import '../services/database_service.dart';
import '../repositories/product_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final DatabaseService _db = DatabaseService();
  final ProductRepository _productRepo = ProductRepository();

  StreamController<AppNotification> notificationStreamController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notificationStream => notificationStreamController.stream;

  NotificationSettings _settings = NotificationSettings();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _loadSettings();
    await _setupBackgroundTasks();
    
    _isInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {

    // Request permissions
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS

    // Get FCM token

    // Handle foreground messages

    // Handle background messages

    // Handle notification taps when app is in background

    // Handle notification tap when app is terminated
  }

  Future<void> _setupBackgroundTasks() async {

  }

  // Local Notification Methods
  Future<void> showNotification(AppNotification notification) async {
    if (!_settings.enableNotifications) return;
    if (!_shouldShowNotification(notification)) return;

    await _saveNotificationToDatabase(notification);

    notificationStreamController.add(notification);
  }

  Future<void> scheduleNotification(AppNotification notification) async {
    if (!_settings.enableNotifications) return;
    if (notification.scheduledAt == null) return;

    await _saveNotificationToDatabase(notification);

  }

  Future<void> cancelNotification(String notificationId) async {
    await _db.update(
      'notifications',
      {'is_cancelled': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> cancelAllNotifications() async {
  }

  // Firebase Messaging Methods




  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    return NotificationType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => NotificationType.systemAlert,
    );
  }

  // Event-based Notification Triggers
  Future<void> checkLowStockAndNotify() async {
    if (!_settings.enableLowStockAlerts) return;

    final lowStockProducts = await _productRepo.getLowStockProducts(
      threshold: _settings.lowStockThreshold,
    );

    for (final product in lowStockProducts) {
      // Check if we already sent a notification for this product recently
      final recentNotifications = await _getRecentNotifications(
        type: NotificationType.lowStock,
        hours: 24,
      );

      final alreadyNotified = recentNotifications.any(
        (n) => n.data['product_id'] == product.id,
      );

      if (!alreadyNotified) {
        final notification = AppNotification.create(
          title: 'Low Stock Alert',
          body: '${product.name} is running low (${product.stock} remaining)',
          type: NotificationType.lowStock,
          priority: product.stock == 0 
              ? NotificationPriority.urgent 
              : NotificationPriority.high,
          data: {
            'product_id': product.id,
            'product_name': product.name,
            'stock_level': product.stock,
          },
          isActionable: true,
          actionUrl: '/inventory/${product.id}',
        );

        await showNotification(notification);
      }
    }
  }

  Future<void> notifyNewOrder(Map<String, dynamic> orderData) async {
    if (!_settings.enableOrderAlerts) return;

    final notification = AppNotification.create(
      title: 'New Order Received',
      body: 'Order #${orderData['id']} from ${orderData['customer_name']}',
      type: NotificationType.newOrder,
      priority: NotificationPriority.high,
      data: orderData,
      isActionable: true,
      actionUrl: '/orders/${orderData['id']}',
    );

    await showNotification(notification);
  }

  Future<void> notifyOrderStatusUpdate(Map<String, dynamic> orderData) async {
    if (!_settings.enableOrderAlerts) return;

    final notification = AppNotification.create(
      title: 'Order Status Updated',
      body: 'Order #${orderData['id']} is now ${orderData['status']}',
      type: NotificationType.orderStatusUpdate,
      priority: NotificationPriority.normal,
      data: orderData,
      isActionable: true,
      actionUrl: '/orders/${orderData['id']}',
    );

    await showNotification(notification);
  }

  Future<void> notifyCustomerUpdate(Map<String, dynamic> customerData) async {
    final notification = AppNotification.create(
      title: 'Customer Updated',
      body: '${customerData['name']} information has been updated',
      type: NotificationType.customerUpdate,
      priority: NotificationPriority.low,
      data: customerData,
      isActionable: true,
      actionUrl: '/customers/${customerData['id']}',
    );

    await showNotification(notification);
  }

  Future<void> notifySyncComplete(int itemCount) async {
    if (!_settings.enableSyncAlerts) return;

    final notification = AppNotification.create(
      title: 'Sync Complete',
      body: 'Successfully synced $itemCount items',
      type: NotificationType.syncComplete,
      priority: NotificationPriority.low,
      data: {'item_count': itemCount},
    );

    await showNotification(notification);
  }

  Future<void> notifySyncError(String error) async {
    if (!_settings.enableSyncAlerts) return;

    final notification = AppNotification.create(
      title: 'Sync Failed',
      body: 'Failed to sync data: $error',
      type: NotificationType.syncError,
      priority: NotificationPriority.high,
      data: {'error': error},
    );

    await showNotification(notification);
  }

  Future<void> notifySystemAlert(String title, String message, {NotificationPriority priority = NotificationPriority.normal}) async {
    if (!_settings.enableSystemAlerts) return;

    final notification = AppNotification.create(
      title: title,
      body: message,
      type: NotificationType.systemAlert,
      priority: priority,
    );

    await showNotification(notification);
  }

  Future<void> scheduleReminder(String title, String message, DateTime scheduledTime, {Map<String, dynamic>? data}) async {
    final notification = AppNotification.create(
      title: title,
      body: message,
      type: NotificationType.reminder,
      priority: NotificationPriority.normal,
      scheduledAt: scheduledTime,
      data: data ?? {},
    );

    await scheduleNotification(notification);
  }

  // Database Methods
  Future<void> _saveNotificationToDatabase(AppNotification notification) async {
    await _db.insert('notifications', notification.toMap(), ConflictAlgorithm.replace);
  }

  Future<List<AppNotification>> getNotifications({int limit = 50, int offset = 0}) async {
    final maps = await _db.query(
      'notifications',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => AppNotification.fromMap(map)).toList();
  }

  Future<List<AppNotification>> getUnreadNotifications() async {
    final maps = await _db.query(
      'notifications',
      where: 'is_read = 0',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => AppNotification.fromMap(map)).toList();
  }

  Future<int> getUnreadCount() async {
    final result = await _db.query(
      'notifications',
      columns: ['COUNT(*) as count'],
      where: 'is_read = 0',
    );

    return result.first['count'] as int;
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllAsRead() async {
    await _db.update(
      'notifications',
      {'is_read': 1},
      where: 'is_read = 0',
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> deleteOldNotifications({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    await _db.delete(
      'notifications',
      where: 'created_at < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  Future<List<AppNotification>> _getRecentNotifications({
    required NotificationType type,
    required int hours,
  }) async {
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
    final maps = await _db.query(
      'notifications',
      where: 'type = ? AND created_at > ?',
      whereArgs: [type.name, cutoffTime.millisecondsSinceEpoch],
    );

    return maps.map((map) => AppNotification.fromMap(map)).toList();
  }

  // Settings Methods
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('notification_settings');
    
    if (settingsJson != null) {
      final settingsMap = jsonDecode(settingsJson);
      _settings = NotificationSettings.fromMap(settingsMap);
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_settings', jsonEncode(settings.toMap()));
  }

  NotificationSettings get settings => _settings;

  // Helper Methods
  bool _shouldShowNotification(AppNotification notification) {
    // Check quiet hours
    final now = DateTime.now();
    final quietStart = TimeOfDay(
      hour: int.parse(_settings.quietHoursStart[0]),
      minute: int.parse(_settings.quietHoursStart[1]),
    );
    final quietEnd = TimeOfDay(
      hour: int.parse(_settings.quietHoursEnd[0]),
      minute: int.parse(_settings.quietHoursEnd[1]),
    );

    final currentTime = TimeOfDay.fromDateTime(now);
    
    if (_isInQuietHours(currentTime, quietStart, quietEnd)) {
      return notification.priority == NotificationPriority.urgent;
    }

    // Check type-specific settings
    switch (notification.type) {
      case NotificationType.lowStock:
        return _settings.enableLowStockAlerts;
      case NotificationType.newOrder:
      case NotificationType.orderStatusUpdate:
        return _settings.enableOrderAlerts;
      case NotificationType.syncComplete:
      case NotificationType.syncError:
        return _settings.enableSyncAlerts;
      case NotificationType.systemAlert:
        return _settings.enableSystemAlerts;
      default:
        return true;
    }
  }

  bool _isInQuietHours(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }


  void _navigateToNotificationTarget(AppNotification notification) {
    // This would be implemented with your navigation system
    // For now, we'll just mark it as read
    markAsRead(notification.id);
  }

  void dispose() {
    notificationStreamController.close();
  }
}

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {

}
