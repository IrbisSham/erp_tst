class Order {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final String status;
  final String priority;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.expectedDelivery,
    required this.status,
    required this.priority,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_date': orderDate.millisecondsSinceEpoch,
      'expected_delivery': expectedDelivery.millisecondsSinceEpoch,
      'status': status,
      'priority': priority,
      'subtotal': subtotal,
      'discount': discount,
      'shipping': shipping,
      'total': total,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, {List<OrderItem>? items}) {
    return Order(
      id: map['id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['order_date']),
      expectedDelivery: DateTime.fromMillisecondsSinceEpoch(map['expected_delivery']),
      status: map['status'],
      priority: map['priority'],
      subtotal: map['subtotal'].toDouble(),
      discount: map['discount'].toDouble(),
      shipping: map['shipping'].toDouble(),
      total: map['total'].toDouble(),
      notes: map['notes'],
      items: items ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isSynced: map['is_synced'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    DateTime? orderDate,
    DateTime? expectedDelivery,
    String? status,
    String? priority,
    double? subtotal,
    double? discount,
    double? shipping,
    double? total,
    String? notes,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      total: map['total'].toDouble(),
    );
  }
}
