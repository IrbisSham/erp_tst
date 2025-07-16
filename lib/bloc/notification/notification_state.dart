import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final List<AppNotification> filteredNotifications;
  final int unreadCount;
  final NotificationType? activeFilter;

  const NotificationLoaded({
    required this.notifications,
    required this.filteredNotifications,
    required this.unreadCount,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [notifications, filteredNotifications, unreadCount, activeFilter];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationOperationSuccess extends NotificationState {
  final String message;

  const NotificationOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationSettingsLoaded extends NotificationState {
  final NotificationSettings settings;

  const NotificationSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsUpdated extends NotificationState {
  final NotificationSettings settings;

  const NotificationSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}
