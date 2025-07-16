import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = "";
    String dbName = 'erp_database.db';
    Future<Database> db;
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      path = dbName;
      db = factory.openDatabase(dbName);
    } else {
      path = join(await getDatabasesPath(), dbName);
      db = openDatabase(
        path,
        version: 3, // Incremented version for notifications table
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
    return await db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        supplier TEXT,
        location TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        company TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        zip TEXT,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        total_orders INTEGER NOT NULL DEFAULT 0,
        total_spent REAL NOT NULL DEFAULT 0.0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        order_date INTEGER NOT NULL,
        expected_delivery INTEGER NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0.0,
        shipping REAL NOT NULL DEFAULT 0.0,
        total REAL NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Sync queue table for tracking changes
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        created_at INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Saved searches table
    await db.execute('''
      CREATE TABLE saved_searches (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        filter_json TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        query TEXT NOT NULL,
        search_count INTEGER NOT NULL DEFAULT 1,
        last_searched INTEGER NOT NULL,
        UNIQUE(entity_type, query)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        priority TEXT NOT NULL,
        data TEXT,
        created_at INTEGER NOT NULL,
        scheduled_at INTEGER,
        is_read INTEGER NOT NULL DEFAULT 0,
        is_actionable INTEGER NOT NULL DEFAULT 0,
        is_cancelled INTEGER NOT NULL DEFAULT 0,
        action_url TEXT,
        icon_path TEXT,
        sound_path TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_products_sku ON products(sku)');
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_status ON products(status)');
    await db.execute('CREATE INDEX idx_products_price ON products(price)');
    await db.execute('CREATE INDEX idx_products_stock ON products(stock)');
    await db.execute('CREATE INDEX idx_products_created_at ON products(created_at)');
    
    await db.execute('CREATE INDEX idx_customers_email ON customers(email)');
    await db.execute('CREATE INDEX idx_customers_type ON customers(type)');
    await db.execute('CREATE INDEX idx_customers_status ON customers(status)');
    await db.execute('CREATE INDEX idx_customers_created_at ON customers(created_at)');
    
    await db.execute('CREATE INDEX idx_orders_customer_id ON orders(customer_id)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db.execute('CREATE INDEX idx_orders_priority ON orders(priority)');
    await db.execute('CREATE INDEX idx_orders_order_date ON orders(order_date)');
    await db.execute('CREATE INDEX idx_orders_total ON orders(total)');
    
    await db.execute('CREATE INDEX idx_order_items_order_id ON order_items(order_id)');
    await db.execute('CREATE INDEX idx_sync_queue_table_record ON sync_queue(table_name, record_id)');
    await db.execute('CREATE INDEX idx_saved_searches_entity_type ON saved_searches(entity_type)');
    await db.execute('CREATE INDEX idx_search_history_entity_type ON search_history(entity_type)');
    
    // Notification indexes
    await db.execute('CREATE INDEX idx_notifications_type ON notifications(type)');
    await db.execute('CREATE INDEX idx_notifications_created_at ON notifications(created_at)');
    await db.execute('CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
    await db.execute('CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      await db.execute('''
        CREATE TABLE saved_searches (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          filter_json TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE search_history (
          id TEXT PRIMARY KEY,
          entity_type TEXT NOT NULL,
          query TEXT NOT NULL,
          search_count INTEGER NOT NULL DEFAULT 1,
          last_searched INTEGER NOT NULL,
          UNIQUE(entity_type, query)
        )
      ''');

      // Add new indexes
      await db.execute('CREATE INDEX idx_products_category ON products(category)');
      await db.execute('CREATE INDEX idx_products_status ON products(status)');
      await db.execute('CREATE INDEX idx_products_price ON products(price)');
      await db.execute('CREATE INDEX idx_products_stock ON products(stock)');
      await db.execute('CREATE INDEX idx_products_created_at ON products(created_at)');
      
      await db.execute('CREATE INDEX idx_customers_type ON customers(type)');
      await db.execute('CREATE INDEX idx_customers_status ON customers(status)');
      await db.execute('CREATE INDEX idx_customers_created_at ON customers(created_at)');
      
      await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
      await db.execute('CREATE INDEX idx_orders_priority ON orders(priority)');
      await db.execute('CREATE INDEX idx_orders_order_date ON orders(order_date)');
      await db.execute('CREATE INDEX idx_orders_total ON orders(total)');
      
      await db.execute('CREATE INDEX idx_saved_searches_entity_type ON saved_searches(entity_type)');
      await db.execute('CREATE INDEX idx_search_history_entity_type ON search_history(entity_type)');
    }

    if (oldVersion < 3) {
      // Add notifications table for version 3
      await db.execute('''
        CREATE TABLE notifications (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          type TEXT NOT NULL,
          priority TEXT NOT NULL,
          data TEXT,
          created_at INTEGER NOT NULL,
          scheduled_at INTEGER,
          is_read INTEGER NOT NULL DEFAULT 0,
          is_actionable INTEGER NOT NULL DEFAULT 0,
          is_cancelled INTEGER NOT NULL DEFAULT 0,
          action_url TEXT,
          icon_path TEXT,
          sound_path TEXT
        )
      ''');

      // Add notification indexes
      await db.execute('CREATE INDEX idx_notifications_type ON notifications(type)');
      await db.execute('CREATE INDEX idx_notifications_created_at ON notifications(created_at)');
      await db.execute('CREATE INDEX idx_notifications_is_read ON notifications(is_read)');
      await db.execute('CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at)');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'erp_database.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data, ConflictAlgorithm conflictAlgorithm) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> addToSyncQueue(String tableName, String recordId, String operation, {Map<String, dynamic>? data}) async {
    final db = await database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data != null ? data.toString() : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeSyncItem(int syncId) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [syncId]);
  }
}
