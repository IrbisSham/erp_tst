import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';

class CustomerRepository {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final Uuid _uuid = const Uuid();

  Future<List<Customer>> getAllCustomers({bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      'customers',
      where: whereClause,
      orderBy: 'name ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(String id) async {
    final maps = await _db.query(
      'customers',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final maps = await _db.query(
      'customers',
      where: 'is_deleted = 0 AND (name LIKE ? OR email LIKE ? OR company LIKE ?)',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<String> createCustomer(Customer customer) async {
    final id = customer.id.isEmpty ? _uuid.v4() : customer.id;
    final now = DateTime.now();
    
    final customerToSave = customer.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    await _db.insert('customers', customerToSave.toMap(), ConflictAlgorithm.replace);
    
    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('customers', id, 'CREATE', data: customerToSave.toMap());
    }

    return id;
  }

  Future<void> updateCustomer(Customer customer) async {
    final updatedCustomer = customer.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _db.update(
      'customers',
      updatedCustomer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );

    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('customers', customer.id, 'UPDATE', data: updatedCustomer.toMap());
    }
  }

  Future<void> deleteCustomer(String id) async {
    // Soft delete
    await _db.update(
      'customers',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('customers', id, 'DELETE');
    }
  }

  Future<void> updateCustomerStats(String customerId, int orderCount, double totalSpent) async {
    await _db.update(
      'customers',
      {
        'total_orders': orderCount,
        'total_spent': totalSpent,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<List<Customer>> getUnsyncedCustomers() async {
    final maps = await _db.query(
      'customers',
      where: 'is_synced = 0',
      orderBy: 'updated_at ASC',
    );
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<void> markAsSynced(String id) async {
    await _db.update(
      'customers',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getCustomerStats() async {
    final allCustomers = await getAllCustomers();
    final activeCustomers = allCustomers.where((c) => c.status == 'Active').toList();
    
    final totalSpent = allCustomers.fold<double>(
      0.0, 
      (sum, customer) => sum + customer.totalSpent,
    );

    final totalOrders = allCustomers.fold<int>(
      0, 
      (sum, customer) => sum + customer.totalOrders,
    );

    return {
      'totalCustomers': allCustomers.length,
      'activeCustomers': activeCustomers.length,
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
      'averageOrderValue': totalOrders > 0 ? totalSpent / totalOrders : 0.0,
    };
  }
}
