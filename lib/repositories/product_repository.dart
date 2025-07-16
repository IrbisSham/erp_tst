import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';

class ProductRepository {
  final DatabaseService _db = DatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final Uuid _uuid = const Uuid();

  Future<List<Product>> getAllProducts({bool includeDeleted = false}) async {
    final whereClause = includeDeleted ? null : 'is_deleted = 0';
    final maps = await _db.query(
      'products',
      where: whereClause,
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final maps = await _db.query(
      'products',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> searchProducts(String query) async {
    final maps = await _db.query(
      'products',
      where: 'is_deleted = 0 AND (name LIKE ? OR sku LIKE ? OR category LIKE ?)',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<String> createProduct(Product product) async {
    final id = product.id.isEmpty ? _uuid.v4() : product.id;
    final now = DateTime.now();
    
    final productToSave = product.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    await _db.insert('products', productToSave.toMap(), ConflictAlgorithm.replace);
    
    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('products', id, 'CREATE', data: productToSave.toMap());
    }

    // Trigger notification for new product
    NotificationService().notifySystemAlert(
      'Product Added',
      'New product "${productToSave.name}" has been added to inventory',
      priority: NotificationPriority.low,
    );

    return id;
  }

  Future<void> updateProduct(Product product) async {
    final updatedProduct = product.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _db.update(
      'products',
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    // Add to sync queue if online
    if (_connectivity.isOnline) {
      await _db.addToSyncQueue('products', product.id, 'UPDATE', data: updatedProduct.toMap());
    }

    // Check for low stock and trigger notification if needed
    if (updatedProduct.stock <= 10) {
      NotificationService().checkLowStockAndNotify();
    }
  }

  Future<void> deleteProduct(String id) async {
    // Soft delete
    await _db.update(
      'products',
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
      await _db.addToSyncQueue('products', id, 'DELETE');
    }
  }

  Future<List<Product>> getUnsyncedProducts() async {
    final maps = await _db.query(
      'products',
      where: 'is_synced = 0',
      orderBy: 'updated_at ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> markAsSynced(String id) async {
    await _db.update(
      'products',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    final maps = await _db.query(
      'products',
      where: 'is_deleted = 0 AND stock <= ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getInventoryStats() async {
    final allProducts = await getAllProducts();
    final lowStockProducts = await getLowStockProducts();
    final outOfStockProducts = allProducts.where((p) => p.stock == 0).toList();
    
    final totalValue = allProducts.fold<double>(
      0.0, 
      (sum, product) => sum + (product.price * product.stock),
    );

    return {
      'totalProducts': allProducts.length,
      'lowStockCount': lowStockProducts.length,
      'outOfStockCount': outOfStockProducts.length,
      'totalValue': totalValue,
    };
  }
}
