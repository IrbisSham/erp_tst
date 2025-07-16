class SearchFilter {
  final String? query;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> categories;
  final List<String> statuses;
  final double? minPrice;
  final double? maxPrice;
  final int? minStock;
  final int? maxStock;
  final String? sortBy;
  final bool sortAscending;
  final Map<String, dynamic> customFilters;

  SearchFilter({
    this.query,
    this.startDate,
    this.endDate,
    this.categories = const [],
    this.statuses = const [],
    this.minPrice,
    this.maxPrice,
    this.minStock,
    this.maxStock,
    this.sortBy,
    this.sortAscending = true,
    this.customFilters = const {},
  });

  SearchFilter copyWith({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    List<String>? statuses,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
    String? sortBy,
    bool? sortAscending,
    Map<String, dynamic>? customFilters,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categories: categories ?? this.categories,
      statuses: statuses ?? this.statuses,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      customFilters: customFilters ?? this.customFilters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'categories': categories,
      'statuses': statuses,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minStock': minStock,
      'maxStock': maxStock,
      'sortBy': sortBy,
      'sortAscending': sortAscending,
      'customFilters': customFilters,
    };
  }

  factory SearchFilter.fromMap(Map<String, dynamic> map) {
    return SearchFilter(
      query: map['query'],
      startDate: map['startDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate'])
          : null,
      endDate: map['endDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      categories: List<String>.from(map['categories'] ?? []),
      statuses: List<String>.from(map['statuses'] ?? []),
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      minStock: map['minStock']?.toInt(),
      maxStock: map['maxStock']?.toInt(),
      sortBy: map['sortBy'],
      sortAscending: map['sortAscending'] ?? true,
      customFilters: Map<String, dynamic>.from(map['customFilters'] ?? {}),
    );
  }

  bool get hasActiveFilters {
    return query?.isNotEmpty == true ||
        startDate != null ||
        endDate != null ||
        categories.isNotEmpty ||
        statuses.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        minStock != null ||
        maxStock != null ||
        customFilters.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (query?.isNotEmpty == true) count++;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (categories.isNotEmpty) count++;
    if (statuses.isNotEmpty) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (minStock != null) count++;
    if (maxStock != null) count++;
    count += customFilters.length;
    return count;
  }
}

class SavedSearch {
  final String id;
  final String name;
  final String entityType; // 'products', 'customers', 'orders'
  final SearchFilter filter;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedSearch({
    required this.id,
    required this.name,
    required this.entityType,
    required this.filter,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'entity_type': entityType,
      'filter': filter.toMap(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SavedSearch.fromMap(Map<String, dynamic> map) {
    return SavedSearch(
      id: map['id'],
      name: map['name'],
      entityType: map['entity_type'],
      filter: SearchFilter.fromMap(map['filter']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}
