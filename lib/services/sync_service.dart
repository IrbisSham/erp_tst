import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../repositories/product_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';
import 'notification_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ProductRepository _productRepo = ProductRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final OrderRepository _orderRepo = OrderRepository();

  static const String baseUrl = 'https://your-api-server.com/api';
  Timer? _syncTimer;
  bool _isSyncing = false;

  StreamController<SyncStatus> syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => syncStatusController.stream;

  void initialize() {
    // Listen for connectivity changes
    _connectivity.connectionStream.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        syncData();
      }
    });

    // Start periodic sync when online
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_connectivity.isOnline && !_isSyncing) {
        syncData();
      }
    });
  }

  Future<void> syncData() async {
    if (!_connectivity.isOnline || _isSyncing) return;

    _isSyncing = true;
    syncStatusController.add(SyncStatus.syncing);

    try {
      // Sync pending changes to server
      await _syncPendingChanges();
      
      // Pull latest data from server
      await _pullLatestData();

      syncStatusController.add(SyncStatus.completed);
      NotificationService().notifySyncComplete(0); // Placeholder for pendingItems.length
    } catch (e) {
      syncStatusController.add(SyncStatus.error);
      NotificationService().notifySyncError(e.toString());
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncPendingChanges() async {
    final pendingItems = await _db.getPendingSyncItems();
    
    for (var item in pendingItems) {
      try {
        await _syncItem(item);
        await _db.removeSyncItem(item['id']);
      } catch (e) {
        // Increment retry count
        await _db.update(
          'sync_queue',
          {'retry_count': item['retry_count'] + 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
        
        // Remove item if retry count exceeds limit
        if (item['retry_count'] >= 3) {
          await _db.removeSyncItem(item['id']);
        }
      }
    }
  }

  Future<void> _syncItem(Map<String, dynamic> item) async {
    final tableName = item['table_name'];
    final recordId = item['record_id'];
    final operation = item['operation'];
    
    String endpoint = '$baseUrl/${tableName.toLowerCase()}';
    
    switch (operation) {
      case 'CREATE':
        await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: item['data'],
        );
        break;
      case 'UPDATE':
        await http.put(
          Uri.parse('$endpoint/$recordId'),
          headers: {'Content-Type': 'application/json'},
          body: item['data'],
        );
        break;
      case 'DELETE':
        await http.delete(Uri.parse('$endpoint/$recordId'));
        break;
    }

    // Mark as synced in local database
    await _markRecordAsSynced(tableName, recordId);
  }

  Future<void> _markRecordAsSynced(String tableName, String recordId) async {
    switch (tableName) {
      case 'products':
        await _productRepo.markAsSynced(recordId);
        break;
      case 'customers':
        await _customerRepo.markAsSynced(recordId);
        break;
      case 'orders':
        await _orderRepo.markAsSynced(recordId);
        break;
    }
  }

  Future<void> _pullLatestData() async {
    // This would typically pull data from server and update local database
    // For now, we'll just mark it as a placeholder
    
    try {
      // Pull products
      final productsResponse = await http.get(Uri.parse('$baseUrl/products'));
      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        // Process and update local products
      }

      // Pull customers
      final customersResponse = await http.get(Uri.parse('$baseUrl/customers'));
      if (customersResponse.statusCode == 200) {
        final customersData = json.decode(customersResponse.body);
        // Process and update local customers
      }

      // Pull orders
      final ordersResponse = await http.get(Uri.parse('$baseUrl/orders'));
      if (ordersResponse.statusCode == 200) {
        final ordersData = json.decode(ordersResponse.body);
        // Process and update local orders
      }
    } catch (e) {
      print('Error pulling data: $e');
    }
  }

  Future<void> forceSyncAll() async {
    if (!_connectivity.isOnline) {
      throw Exception('No internet connection');
    }

    _isSyncing = true;
    syncStatusController.add(SyncStatus.syncing);

    try {
      // Get all unsynced data
      final unsyncedProducts = await _productRepo.getUnsyncedProducts();
      final unsyncedCustomers = await _customerRepo.getUnsyncedCustomers();
      final unsyncedOrders = await _orderRepo.getUnsyncedOrders();

      // Sync products
      for (var product in unsyncedProducts) {
        await _syncProductToServer(product);
      }

      // Sync customers
      for (var customer in unsyncedCustomers) {
        await _syncCustomerToServer(customer);
      }

      // Sync orders
      for (var order in unsyncedOrders) {
        await _syncOrderToServer(order);
      }

      syncStatusController.add(SyncStatus.completed);
    } catch (e) {
      syncStatusController.add(SyncStatus.error);
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncProductToServer(dynamic product) async {
    // Implement actual API call to sync product
    // This is a placeholder
    await Future.delayed(const Duration(milliseconds: 100));
    await _productRepo.markAsSynced(product.id);
  }

  Future<void> _syncCustomerToServer(dynamic customer) async {
    // Implement actual API call to sync customer
    // This is a placeholder
    await Future.delayed(const Duration(milliseconds: 100));
    await _customerRepo.markAsSynced(customer.id);
  }

  Future<void> _syncOrderToServer(dynamic order) async {
    // Implement actual API call to sync order
    // This is a placeholder
    await Future.delayed(const Duration(milliseconds: 100));
    await _orderRepo.markAsSynced(order.id);
  }

  Future<int> getPendingSyncCount() async {
    final pendingItems = await _db.getPendingSyncItems();
    return pendingItems.length;
  }

  void dispose() {
    _syncTimer?.cancel();
    syncStatusController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
}
