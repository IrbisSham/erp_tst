import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncService _syncService = SyncService();
  bool _isOnline = true;
  SyncStatus _syncStatus = SyncStatus.idle;
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivity.isOnline;
    _loadPendingSyncCount();

    // Listen for connectivity changes
    _connectivity.connectionStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });

    // Listen for sync status changes
    _syncService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _syncStatus = status;
        });
        if (status == SyncStatus.completed) {
          _loadPendingSyncCount();
        }
      }
    });
  }

  Future<void> _loadPendingSyncCount() async {
    final count = await _syncService.getPendingSyncCount();
    if (mounted) {
      setState(() {
        _pendingSyncCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline && _pendingSyncCount == 0 && _syncStatus != SyncStatus.syncing) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    IconData icon;
    String message;

    if (!_isOnline) {
      backgroundColor = Colors.red;
      icon = Icons.wifi_off;
      message = 'Offline - Changes saved locally';
    } else if (_syncStatus == SyncStatus.syncing) {
      backgroundColor = Colors.orange;
      icon = Icons.sync;
      message = 'Syncing data...';
    } else if (_pendingSyncCount > 0) {
      backgroundColor = Colors.blue;
      icon = Icons.cloud_upload;
      message = '$_pendingSyncCount changes pending sync';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_pendingSyncCount > 0 && _isOnline && _syncStatus != SyncStatus.syncing)
            GestureDetector(
              onTap: () async {
                try {
                  await _syncService.forceSyncAll();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data synced successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sync failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'SYNC NOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_syncStatus == SyncStatus.syncing)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
