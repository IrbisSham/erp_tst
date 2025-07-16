import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  late NotificationSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _settings = _notificationService.settings;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _notificationService.updateSettings(_settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notification Settings'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Turn on/off all notifications'),
                      value: _settings.enableNotifications,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(enableNotifications: value);
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Receive notifications when app is closed'),
                      value: _settings.enablePushNotifications,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enablePushNotifications: value);
                              });
                            }
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Sound'),
                      subtitle: const Text('Play sound for notifications'),
                      value: _settings.enableSound,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enableSound: value);
                              });
                            }
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Vibration'),
                      subtitle: const Text('Vibrate for notifications'),
                      value: _settings.enableVibration,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enableVibration: value);
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notification Types
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Types',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Low Stock Alerts'),
                      subtitle: const Text('Get notified when products are running low'),
                      value: _settings.enableLowStockAlerts,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enableLowStockAlerts: value);
                              });
                            }
                          : null,
                    ),
                    if (_settings.enableLowStockAlerts)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Row(
                          children: [
                            const Text('Stock threshold: '),
                            Expanded(
                              child: Slider(
                                value: _settings.lowStockThreshold.toDouble(),
                                min: 1,
                                max: 50,
                                divisions: 49,
                                label: _settings.lowStockThreshold.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _settings = _settings.copyWith(lowStockThreshold: value.round());
                                  });
                                },
                              ),
                            ),
                            Text(_settings.lowStockThreshold.toString()),
                          ],
                        ),
                      ),
                    SwitchListTile(
                      title: const Text('Order Alerts'),
                      subtitle: const Text('Get notified about new orders and status updates'),
                      value: _settings.enableOrderAlerts,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enableOrderAlerts: value);
                              });
                            }
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Sync Alerts'),
                      subtitle: const Text('Get notified about data synchronization'),
                      value: _settings.enableSyncAlerts,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enableSyncAlerts: value);
                              });
                            }
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('System Alerts'),
                      subtitle: const Text('Get notified about system messages and updates'),
                      value: _settings.enableSystemAlerts,
                      onChanged: _settings.enableNotifications
                          ? (value) {
                              setState(() {
                                _settings = _settings.copyWith(enableSystemAlerts: value);
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quiet Hours
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiet Hours',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'During quiet hours, only urgent notifications will be shown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${_settings.quietHoursStart[0]}:${_settings.quietHoursStart[1]}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${_settings.quietHoursEnd[0]}:${_settings.quietHoursEnd[1]}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sendTestNotification,
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Send Test Notification'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllNotifications,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Notifications'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final currentTime = isStartTime
        ? TimeOfDay(
            hour: int.parse(_settings.quietHoursStart[0]),
            minute: int.parse(_settings.quietHoursStart[1]),
          )
        : TimeOfDay(
            hour: int.parse(_settings.quietHoursEnd[0]),
            minute: int.parse(_settings.quietHoursEnd[1]),
          );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _settings = _settings.copyWith(
            quietHoursStart: [
              picked.hour.toString().padLeft(2, '0'),
              picked.minute.toString().padLeft(2, '0'),
            ],
          );
        } else {
          _settings = _settings.copyWith(
            quietHoursEnd: [
              picked.hour.toString().padLeft(2, '0'),
              picked.minute.toString().padLeft(2, '0'),
            ],
          );
        }
      });
    }
  }

  void _sendTestNotification() {
    _notificationService.notifySystemAlert(
      'Test Notification',
      'This is a test notification. If you can see this, notifications are working correctly!',
      priority: NotificationPriority.normal,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification sent')),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _notificationService.cancelAllNotifications();
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
