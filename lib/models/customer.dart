class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String type;
  final String status;
  final String? notes;
  final int totalOrders;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    this.address,
    this.city,
    this.state,
    this.zip,
    required this.type,
    required this.status,
    this.notes,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'type': type,
      'status': status,
      'notes': notes,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      company: map['company'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      zip: map['zip'],
      type: map['type'],
      status: map['status'],
      notes: map['notes'],
      totalOrders: map['total_orders'] ?? 0,
      totalSpent: (map['total_spent'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isSynced: map['is_synced'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? type,
    String? status,
    String? notes,
    int? totalOrders,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
