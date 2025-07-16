import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';

class OrderRepository {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final Uuid _uuid = const Uuid();

  Future<List<Order>> getAllOrders({bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final orderMaps = await _db.query(
      'orders',
      where: whereClause,
      orderBy: 'order_date DESC',
    );

    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      final items = await getOrderItems(orderMap['id']);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<Order?> getOrderById(String id) async {
    final maps = await _db.query(
      'orders',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final items = await getOrderItems(id);
      return Order.fromMap(maps.first, items: items);
    }
    return null;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final maps = await _db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return maps.map((map) => OrderItem.fromMap(map)).toList();
  }

  Future<List<Order>> getOrdersByCustomer(String customerId) async {
    final orderMaps = await _db.query(
      'orders',
      where: 'customer_id = ? AND is_deleted = 0',
      whereArgs: [customerId],
      orderBy: 'order_date DESC',
    );

    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      final items = await getOrderItems(orderMap['id']);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<String> createOrder(Order order) async {
    final id = order.id.isEmpty ? _uuid.v4() : order.id;
    final now = DateTime.now();
    
    final orderToSave = order.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    // Insert order
    await _db.insert('orders', orderToSave.toMap(), ConflictAlgorithm.replace);

    // Insert order items
    for (var item in order.items) {
      final itemToSave = OrderItem(
        id: item.id.isEmpty ? _uuid.v4() : item.id,
        orderId: id,
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        price: item.price,
        total: item.total,
      );
      await _db.insert('order_items', itemToSave.toMap(), ConflictAlgorithm.replace);
    }

    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('orders', id, 'CREATE', data: orderToSave.toMap());
    }

    // Trigger notification for new order
    NotificationService().notifyNewOrder({
      'id': id,
      'customer_name': order.customerName,
      'total': order.total,
      'status': order.status,
    });

    return id;
  }

  Future<void> updateOrder(Order order) async {
    final updatedOrder = order.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _db.update(
      'orders',
      updatedOrder.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );

    // Delete existing order items
    await _db.delete('order_items', where: 'order_id = ?', whereArgs: [order.id]);

    // Insert updated order items
    for (var item in order.items) {
      final itemToSave = OrderItem(
        id: item.id.isEmpty ? _uuid.v4() : item.id,
        orderId: order.id,
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        price: item.price,
        total: item.total,
      );
      await _db.insert('order_items', itemToSave.toMap(), ConflictAlgorithm.replace);
    }

    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('orders', order.id, 'UPDATE', data: updatedOrder.toMap());
    }

    // Trigger notification for order status update
    NotificationService().notifyOrderStatusUpdate({
      'id': order.id,
      'customer_name': order.customerName,
      'status': updatedOrder.status,
      'total': order.total,
    });
  }

  Future<void> deleteOrder(String id) async {
    // Soft delete
    await _db.update(
      'orders',
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
      await _db.addToSyncQueue('orders', id, 'DELETE');
    }
  }

  Future<List<Order>> getUnsyncedOrders() async {
    final orderMaps = await _db.query(
      'orders',
      where: 'is_synced = 0',
      orderBy: 'updated_at ASC',
    );

    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      final items = await getOrderItems(orderMap['id']);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<void> markAsSynced(String id) async {
    await _db.update(
      'orders',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    final allOrders = await getAllOrders();
    
    final totalSales = allOrders.fold<double>(
      0.0, 
      (sum, order) => sum + order.total,
    );

    final completedOrders = allOrders.where((o) => o.status == 'Completed').toList();
    final pendingOrders = allOrders.where((o) => o.status == 'Pending').toList();

    final averageOrderValue = allOrders.isNotEmpty ? totalSales / allOrders.length : 0.0;

    return {
      'totalOrders': allOrders.length,
      'totalSales': totalSales,
      'completedOrders': completedOrders.length,
      'pendingOrders': pendingOrders.length,
      'averageOrderValue': averageOrderValue,
    };
  }
}
