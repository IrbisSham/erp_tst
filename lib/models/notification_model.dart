import 'package:equatable/equatable.dart';

enum NotificationType {
  lowStock,
  newOrder,
  orderStatusUpdate,
  customerUpdate,
  syncComplete,
  syncError,
  systemAlert,
  reminder,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final bool isRead;
  final bool isActionable;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isCancelled;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.data = const {},
    this.isRead = false,
    this.isActionable = false,
    this.actionUrl,
    required this.createdAt,
    this.scheduledAt,
    this.isCancelled = false,
  });

  factory AppNotification.create({
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic> data = const {},
    bool isActionable = false,
    String? actionUrl,
    DateTime? scheduledAt,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      priority: priority,
      data: data,
      isActionable: isActionable,
      actionUrl: actionUrl,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: (map['is_read'] as int) == 1,
      isActionable: (map['is_actionable'] as int) == 1,
      actionUrl: map['action_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      scheduledAt: map['scheduled_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduled_at'] as int)
          : null,
      isCancelled: (map['is_cancelled'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'data': data,
      'is_read': isRead ? 1 : 0,
      'is_actionable': isActionable ? 1 : 0,
      'action_url': actionUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'scheduled_at': scheduledAt?.millisecondsSinceEpoch,
      'is_cancelled': isCancelled ? 1 : 0,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isActionable,
    String? actionUrl,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isCancelled,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        priority,
        data,
        isRead,
        isActionable,
        actionUrl,
        createdAt,
        scheduledAt,
        isCancelled,
      ];
}

class NotificationSettings extends Equatable {
  final bool enableNotifications;
  final bool enablePushNotifications;
  final bool enableSound;
  final bool enableVibration;
  final bool enableLowStockAlerts;
  final bool enableOrderAlerts;
  final bool enableSyncAlerts;
  final bool enableSystemAlerts;
  final int lowStockThreshold;
  final List<String> quietHoursStart;
  final List<String> quietHoursEnd;

  const NotificationSettings({
    this.enableNotifications = true,
    this.enablePushNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableLowStockAlerts = true,
    this.enableOrderAlerts = true,
    this.enableSyncAlerts = true,
    this.enableSystemAlerts = true,
    this.lowStockThreshold = 10,
    this.quietHoursStart = const ['22', '00'],
    this.quietHoursEnd = const ['07', '00'],
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enableNotifications: map['enableNotifications'] as bool? ?? true,
      enablePushNotifications: map['enablePushNotifications'] as bool? ?? true,
      enableSound: map['enableSound'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      enableLowStockAlerts: map['enableLowStockAlerts'] as bool? ?? true,
      enableOrderAlerts: map['enableOrderAlerts'] as bool? ?? true,
      enableSyncAlerts: map['enableSyncAlerts'] as bool? ?? true,
      enableSystemAlerts: map['enableSystemAlerts'] as bool? ?? true,
      lowStockThreshold: map['lowStockThreshold'] as int? ?? 10,
      quietHoursStart: List<String>.from(map['quietHoursStart'] ?? ['22', '00']),
      quietHoursEnd: List<String>.from(map['quietHoursEnd'] ?? ['07', '00']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableNotifications': enableNotifications,
      'enablePushNotifications': enablePushNotifications,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'enableLowStockAlerts': enableLowStockAlerts,
      'enableOrderAlerts': enableOrderAlerts,
      'enableSyncAlerts': enableSyncAlerts,
      'enableSystemAlerts': enableSystemAlerts,
      'lowStockThreshold': lowStockThreshold,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  NotificationSettings copyWith({
    bool? enableNotifications,
    bool? enablePushNotifications,
    bool? enableSound,
    bool? enableVibration,
    bool? enableLowStockAlerts,
    bool? enableOrderAlerts,
    bool? enableSyncAlerts,
    bool? enableSystemAlerts,
    int? lowStockThreshold,
    List<String>? quietHoursStart,
    List<String>? quietHoursEnd,
  }) {
    return NotificationSettings(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableLowStockAlerts: enableLowStockAlerts ?? this.enableLowStockAlerts,
      enableOrderAlerts: enableOrderAlerts ?? this.enableOrderAlerts,
      enableSyncAlerts: enableSyncAlerts ?? this.enableSyncAlerts,
      enableSystemAlerts: enableSystemAlerts ?? this.enableSystemAlerts,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  @override
  List<Object?> get props => [
        enableNotifications,
        enablePushNotifications,
        enableSound,
        enableVibration,
        enableLowStockAlerts,
        enableOrderAlerts,
        enableSyncAlerts,
        enableSystemAlerts,
        lowStockThreshold,
        quietHoursStart,
        quietHoursEnd,
      ];
}
