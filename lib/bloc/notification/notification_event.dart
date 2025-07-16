import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int limit;
  final int offset;

  const LoadNotifications({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

class LoadUnreadNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class FilterNotifications extends NotificationEvent {
  final NotificationType? type;
  final bool? unreadOnly;

  const FilterNotifications({this.type, this.unreadOnly});

  @override
  List<Object?> get props => [type, unreadOnly];
}

class SendTestNotification extends NotificationEvent {}

class LoadNotificationSettings extends NotificationEvent {}

class UpdateNotificationSettings extends NotificationEvent {
  final NotificationSettings settings;

  const UpdateNotificationSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class RefreshNotifications extends NotificationEvent {}
