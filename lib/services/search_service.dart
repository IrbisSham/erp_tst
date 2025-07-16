import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';
import '../models/search_filter.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../repositories/product_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';
import 'package:uuid/uuid.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final DatabaseService _db = DatabaseService();
  final ProductRepository _productRepo = ProductRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final OrderRepository _orderRepo = OrderRepository();
  final Uuid _uuid = const Uuid();

  // Advanced Product Search
  Future<List<Product>> searchProducts(SearchFilter filter) async {
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    // Text search
    if (filter.query?.isNotEmpty == true) {
      whereClause += ' AND (name LIKE ? OR sku LIKE ? OR description LIKE ? OR supplier LIKE ?)';
      final searchTerm = '%${filter.query}%';
      whereArgs.addAll([searchTerm, searchTerm, searchTerm, searchTerm]);
    }

    // Date range
    if (filter.startDate != null) {
      whereClause += ' AND created_at >= ?';
      whereArgs.add(filter.startDate!.millisecondsSinceEpoch);
    }
    if (filter.endDate != null) {
      whereClause += ' AND created_at <= ?';
      whereArgs.add(filter.endDate!.millisecondsSinceEpoch);
    }

    // Categories
    if (filter.categories.isNotEmpty) {
      final categoryPlaceholders = filter.categories.map((_) => '?').join(',');
      whereClause += ' AND category IN ($categoryPlaceholders)';
      whereArgs.addAll(filter.categories);
    }

    // Statuses
    if (filter.statuses.isNotEmpty) {
      final statusPlaceholders = filter.statuses.map((_) => '?').join(',');
      whereClause += ' AND status IN ($statusPlaceholders)';
      whereArgs.addAll(filter.statuses);
    }

    // Price range
    if (filter.minPrice != null) {
      whereClause += ' AND price >= ?';
      whereArgs.add(filter.minPrice);
    }
    if (filter.maxPrice != null) {
      whereClause += ' AND price <= ?';
      whereArgs.add(filter.maxPrice);
    }

    // Stock range
    if (filter.minStock != null) {
      whereClause += ' AND stock >= ?';
      whereArgs.add(filter.minStock);
    }
    if (filter.maxStock != null) {
      whereClause += ' AND stock <= ?';
      whereArgs.add(filter.maxStock);
    }

    // Sorting
    String orderBy = 'updated_at DESC';
    if (filter.sortBy != null) {
      final direction = filter.sortAscending ? 'ASC' : 'DESC';
      switch (filter.sortBy) {
        case 'name':
          orderBy = 'name $direction';
          break;
        case 'price':
          orderBy = 'price $direction';
          break;
        case 'stock':
          orderBy = 'stock $direction';
          break;
        case 'created':
          orderBy = 'created_at $direction';
          break;
        case 'updated':
          orderBy = 'updated_at $direction';
          break;
      }
    }

    final maps = await _db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // Advanced Customer Search
  Future<List<Customer>> searchCustomers(SearchFilter filter) async {
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    // Text search
    if (filter.query?.isNotEmpty == true) {
      whereClause += ' AND (name LIKE ? OR email LIKE ? OR company LIKE ? OR phone LIKE ?)';
      final searchTerm = '%${filter.query}%';
      whereArgs.addAll([searchTerm, searchTerm, searchTerm, searchTerm]);
    }

    // Date range
    if (filter.startDate != null) {
      whereClause += ' AND created_at >= ?';
      whereArgs.add(filter.startDate!.millisecondsSinceEpoch);
    }
    if (filter.endDate != null) {
      whereClause += ' AND created_at <= ?';
      whereArgs.add(filter.endDate!.millisecondsSinceEpoch);
    }

    // Customer types (using categories field)
    if (filter.categories.isNotEmpty) {
      final typePlaceholders = filter.categories.map((_) => '?').join(',');
      whereClause += ' AND type IN ($typePlaceholders)';
      whereArgs.addAll(filter.categories);
    }

    // Statuses
    if (filter.statuses.isNotEmpty) {
      final statusPlaceholders = filter.statuses.map((_) => '?').join(',');
      whereClause += ' AND status IN ($statusPlaceholders)';
      whereArgs.addAll(filter.statuses);
    }

    // Total spent range (using price fields)
    if (filter.minPrice != null) {
      whereClause += ' AND total_spent >= ?';
      whereArgs.add(filter.minPrice);
    }
    if (filter.maxPrice != null) {
      whereClause += ' AND total_spent <= ?';
      whereArgs.add(filter.maxPrice);
    }

    // Total orders range (using stock fields)
    if (filter.minStock != null) {
      whereClause += ' AND total_orders >= ?';
      whereArgs.add(filter.minStock);
    }
    if (filter.maxStock != null) {
      whereClause += ' AND total_orders <= ?';
      whereArgs.add(filter.maxStock);
    }

    // Sorting
    String orderBy = 'updated_at DESC';
    if (filter.sortBy != null) {
      final direction = filter.sortAscending ? 'ASC' : 'DESC';
      switch (filter.sortBy) {
        case 'name':
          orderBy = 'name $direction';
          break;
        case 'email':
          orderBy = 'email $direction';
          break;
        case 'company':
          orderBy = 'company $direction';
          break;
        case 'total_spent':
          orderBy = 'total_spent $direction';
          break;
        case 'total_orders':
          orderBy = 'total_orders $direction';
          break;
        case 'created':
          orderBy = 'created_at $direction';
          break;
        case 'updated':
          orderBy = 'updated_at $direction';
          break;
      }
    }

    final maps = await _db.query(
      'customers',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  // Advanced Order Search
  Future<List<Order>> searchOrders(SearchFilter filter) async {
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    // Text search
    if (filter.query?.isNotEmpty == true) {
      whereClause += ' AND (customer_name LIKE ? OR notes LIKE ?)';
      final searchTerm = '%${filter.query}%';
      whereArgs.addAll([searchTerm, searchTerm]);
    }

    // Date range (order date)
    if (filter.startDate != null) {
      whereClause += ' AND order_date >= ?';
      whereArgs.add(filter.startDate!.millisecondsSinceEpoch);
    }
    if (filter.endDate != null) {
      whereClause += ' AND order_date <= ?';
      whereArgs.add(filter.endDate!.millisecondsSinceEpoch);
    }

    // Priority (using categories field)
    if (filter.categories.isNotEmpty) {
      final priorityPlaceholders = filter.categories.map((_) => '?').join(',');
      whereClause += ' AND priority IN ($priorityPlaceholders)';
      whereArgs.addAll(filter.categories);
    }

    // Statuses
    if (filter.statuses.isNotEmpty) {
      final statusPlaceholders = filter.statuses.map((_) => '?').join(',');
      whereClause += ' AND status IN ($statusPlaceholders)';
      whereArgs.addAll(filter.statuses);
    }

    // Total amount range
    if (filter.minPrice != null) {
      whereClause += ' AND total >= ?';
      whereArgs.add(filter.minPrice);
    }
    if (filter.maxPrice != null) {
      whereClause += ' AND total <= ?';
      whereArgs.add(filter.maxPrice);
    }

    // Sorting
    String orderBy = 'order_date DESC';
    if (filter.sortBy != null) {
      final direction = filter.sortAscending ? 'ASC' : 'DESC';
      switch (filter.sortBy) {
        case 'customer':
          orderBy = 'customer_name $direction';
          break;
        case 'total':
          orderBy = 'total $direction';
          break;
        case 'status':
          orderBy = 'status $direction';
          break;
        case 'priority':
          orderBy = 'priority $direction';
          break;
        case 'order_date':
          orderBy = 'order_date $direction';
          break;
        case 'expected_delivery':
          orderBy = 'expected_delivery $direction';
          break;
        case 'created':
          orderBy = 'created_at $direction';
          break;
        case 'updated':
          orderBy = 'updated_at $direction';
          break;
      }
    }

    final orderMaps = await _db.query(
      'orders',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      final items = await _orderRepo.getOrderItems(orderMap['id']);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  // Saved Searches
  Future<void> saveSearch(String name, String entityType, SearchFilter filter) async {
    final savedSearch = SavedSearch(
      id: _uuid.v4(),
      name: name,
      entityType: entityType,
      filter: filter,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _db.insert('saved_searches', {
      'id': savedSearch.id,
      'name': savedSearch.name,
      'entity_type': savedSearch.entityType,
      'filter_json': jsonEncode(savedSearch.filter.toMap()),
      'created_at': savedSearch.createdAt.millisecondsSinceEpoch,
      'updated_at': savedSearch.updatedAt.millisecondsSinceEpoch,
    }, ConflictAlgorithm.replace);
  }

  Future<List<SavedSearch>> getSavedSearches(String entityType) async {
    final maps = await _db.query(
      'saved_searches',
      where: 'entity_type = ?',
      whereArgs: [entityType],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) {
      final filterMap = jsonDecode(map['filter_json']);
      return SavedSearch(
        id: map['id'],
        name: map['name'],
        entityType: map['entity_type'],
        filter: SearchFilter.fromMap(filterMap),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      );
    }).toList();
  }

  Future<void> deleteSavedSearch(String id) async {
    await _db.delete('saved_searches', where: 'id = ?', whereArgs: [id]);
  }

  // Search History
  Future<void> addToSearchHistory(String entityType, String query) async {
    if (query.trim().isEmpty) return;

    await _db.insert('search_history', {
      'id': _uuid.v4(),
      'entity_type': entityType,
      'query': query.trim(),
      'search_count': 1,
      'last_searched': DateTime.now().millisecondsSinceEpoch,
    }, ConflictAlgorithm.replace);
  }

  Future<List<String>> getSearchHistory(String entityType, {int limit = 10}) async {
    final maps = await _db.query(
      'search_history',
      where: 'entity_type = ?',
      whereArgs: [entityType],
      orderBy: 'last_searched DESC',
      limit: limit,
    );

    return maps.map((map) => map['query'] as String).toList();
  }

  Future<void> clearSearchHistory(String entityType) async {
    await _db.delete('search_history', where: 'entity_type = ?', whereArgs: [entityType]);
  }

  // Filter Options
  Future<List<String>> getProductCategories() async {
    final maps = await _db.query(
      'products',
      columns: ['DISTINCT category'],
      where: 'is_deleted = 0 AND category IS NOT NULL',
      orderBy: 'category ASC',
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<List<String>> getProductStatuses() async {
    final maps = await _db.query(
      'products',
      columns: ['DISTINCT status'],
      where: 'is_deleted = 0 AND status IS NOT NULL',
      orderBy: 'status ASC',
    );
    return maps.map((map) => map['status'] as String).toList();
  }

  Future<List<String>> getCustomerTypes() async {
    final maps = await _db.query(
      'customers',
      columns: ['DISTINCT type'],
      where: 'is_deleted = 0 AND type IS NOT NULL',
      orderBy: 'type ASC',
    );
    return maps.map((map) => map['type'] as String).toList();
  }

  Future<List<String>> getCustomerStatuses() async {
    final maps = await _db.query(
      'customers',
      columns: ['DISTINCT status'],
      where: 'is_deleted = 0 AND status IS NOT NULL',
      orderBy: 'status ASC',
    );
    return maps.map((map) => map['status'] as String).toList();
  }

  Future<List<String>> getOrderStatuses() async {
    final maps = await _db.query(
      'orders',
      columns: ['DISTINCT status'],
      where: 'is_deleted = 0 AND status IS NOT NULL',
      orderBy: 'status ASC',
    );
    return maps.map((map) => map['status'] as String).toList();
  }

  Future<List<String>> getOrderPriorities() async {
    final maps = await _db.query(
      'orders',
      columns: ['DISTINCT priority'],
      where: 'is_deleted = 0 AND priority IS NOT NULL',
      orderBy: 'priority ASC',
    );
    return maps.map((map) => map['priority'] as String).toList();
  }
}
