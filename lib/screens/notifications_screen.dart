import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../widgets/notification_item.dart';
import 'notification_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  List<AppNotification> _filteredNotifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  late TabController _tabController;

  final List<String> _filterOptions = [
    'all',
    'unread',
    'lowStock',
    'orders',
    'sync',
    'system',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterOptions.length, vsync: this);
    _loadNotifications();
    
    // Listen for new notifications
    _notificationService.notificationStream.listen((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _filterNotifications();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  void _filterNotifications() {
    switch (_selectedFilter) {
      case 'all':
        _filteredNotifications = _notifications;
        break;
      case 'unread':
        _filteredNotifications = _notifications.where((n) => !n.isRead).toList();
        break;
      case 'lowStock':
        _filteredNotifications = _notifications
            .where((n) => n.type == NotificationType.lowStock)
            .toList();
        break;
      case 'orders':
        _filteredNotifications = _notifications
            .where((n) => 
                n.type == NotificationType.newOrder ||
                n.type == NotificationType.orderStatusUpdate)
            .toList();
        break;
      case 'sync':
        _filteredNotifications = _notifications
            .where((n) => 
                n.type == NotificationType.syncComplete ||
                n.type == NotificationType.syncError)
            .toList();
        break;
      case 'system':
        _filteredNotifications = _notifications
            .where((n) => 
                n.type == NotificationType.systemAlert ||
                n.type == NotificationType.reminder)
            .toList();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'test_notification':
                  _sendTestNotification();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark All Read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_notification',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active),
                    SizedBox(width: 8),
                    Text('Test Notification'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            setState(() {
              _selectedFilter = _filterOptions[index];
              _filterNotifications();
            });
          },
          tabs: [
            Tab(text: 'All (${_notifications.length})'),
            Tab(text: 'Unread (${_notifications.where((n) => !n.isRead).length})'),
            Tab(text: 'Stock (${_notifications.where((n) => n.type == NotificationType.lowStock).length})'),
            Tab(text: 'Orders (${_notifications.where((n) => n.type == NotificationType.newOrder || n.type == NotificationType.orderStatusUpdate).length})'),
            Tab(text: 'Sync (${_notifications.where((n) => n.type == NotificationType.syncComplete || n.type == NotificationType.syncError).length})'),
            Tab(text: 'System (${_notifications.where((n) => n.type == NotificationType.systemAlert || n.type == NotificationType.reminder).length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return NotificationItem(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () => _deleteNotification(notification),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'unread':
        message = 'No unread notifications';
        icon = Icons.mark_email_read;
        break;
      case 'lowStock':
        message = 'No stock alerts';
        icon = Icons.inventory_2;
        break;
      case 'orders':
        message = 'No order notifications';
        icon = Icons.shopping_cart;
        break;
      case 'sync':
        message = 'No sync notifications';
        icon = Icons.sync;
        break;
      case 'system':
        message = 'No system notifications';
        icon = Icons.settings;
        break;
      default:
        message = 'No notifications yet';
        icon = Icons.notifications_none;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (notification.isActionable && notification.actionUrl != null) {
      // Navigate to the specific screen based on action URL
      // This would be implemented with your navigation system
      print('Navigate to: ${notification.actionUrl}');
    }
    
    // Show notification details
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.body),
              const SizedBox(height: 16),
              Text(
                'Type: ${notification.type.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Priority: ${notification.priority.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Created: ${notification.createdAt}',
                style: const TextStyle(fontSize: 12),
              ),
              if (notification.data.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...notification.data.entries.map(
                  (entry) => Text('${entry.key}: ${entry.value}'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (notification.isActionable && notification.actionUrl != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to action URL
                print('Navigate to: ${notification.actionUrl}');
              },
              child: const Text('Open'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    await _notificationService.deleteNotification(notification.id);
    _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _loadNotifications();
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete all notifications
              for (final notification in _notifications) {
                await _notificationService.deleteNotification(notification.id);
              }
              _loadNotifications();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    _notificationService.notifySystemAlert(
      'Test Notification',
      'This is a test notification to verify the system is working correctly.',
      priority: NotificationPriority.normal,
    );
  }
}
