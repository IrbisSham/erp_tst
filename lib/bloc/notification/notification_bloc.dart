import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc({required NotificationService notificationService})
      : _notificationService = notificationService,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadNotifications>(_onLoadUnreadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<FilterNotifications>(_onFilterNotifications);
    on<SendTestNotification>(_onSendTestNotification);
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationService.getNotifications(
        limit: event.limit,
        offset: event.offset,
      );
      final unreadCount = await _notificationService.getUnreadCount();
      
      emit(NotificationLoaded(
        notifications: notifications,
        filteredNotifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  Future<void> _onLoadUnreadNotifications(LoadUnreadNotifications event, Emitter<NotificationState> emit) async {
    try {
      final unreadNotifications = await _notificationService.getUnreadNotifications();
      final unreadCount = unreadNotifications.length;
      
      emit(NotificationLoaded(
        notifications: unreadNotifications,
        filteredNotifications: unreadNotifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError('Failed to load unread notifications: $e'));
    }
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    try {
      await _notificationService.markAsRead(event.notificationId);
      emit(const NotificationOperationSuccess('Notification marked as read'));
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: $e'));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsRead event, Emitter<NotificationState> emit) async {
    try {
      await _notificationService.markAllAsRead();
      emit(const NotificationOperationSuccess('All notifications marked as read'));
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: $e'));
    }
  }

  Future<void> _onDeleteNotification(DeleteNotification event, Emitter<NotificationState> emit) async {
    try {
      await _notificationService.deleteNotification(event.notificationId);
      emit(const NotificationOperationSuccess('Notification deleted'));
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationError('Failed to delete notification: $e'));
    }
  }

  Future<void> _onFilterNotifications(FilterNotifications event, Emitter<NotificationState> emit) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      List<AppNotification> filtered = currentState.notifications;

      if (event.type != null) {
        filtered = filtered.where((n) => n.type == event.type).toList();
      }

      if (event.unreadOnly == true) {
        filtered = filtered.where((n) => !n.isRead).toList();
      }

      emit(NotificationLoaded(
        notifications: currentState.notifications,
        filteredNotifications: filtered,
        unreadCount: currentState.unreadCount,
        activeFilter: event.type,
      ));
    }
  }

  Future<void> _onSendTestNotification(SendTestNotification event, Emitter<NotificationState> emit) async {
    try {
      await _notificationService.notifySystemAlert(
        'Test Notification',
        'This is a test notification to verify the system is working correctly.',
        priority: NotificationPriority.normal,
      );
      emit(const NotificationOperationSuccess('Test notification sent'));
    } catch (e) {
      emit(NotificationError('Failed to send test notification: $e'));
    }
  }

  Future<void> _onLoadNotificationSettings(LoadNotificationSettings event, Emitter<NotificationState> emit) async {
    try {
      final settings = _notificationService.settings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationError('Failed to load notification settings: $e'));
    }
  }

  Future<void> _onUpdateNotificationSettings(UpdateNotificationSettings event, Emitter<NotificationState> emit) async {
    try {
      await _notificationService.updateSettings(event.settings);
      emit(NotificationSettingsUpdated(event.settings));
    } catch (e) {
      emit(NotificationError('Failed to update notification settings: $e'));
    }
  }

  Future<void> _onRefreshNotifications(RefreshNotifications event, Emitter<NotificationState> emit) async {
    add(const LoadNotifications());
  }
}
