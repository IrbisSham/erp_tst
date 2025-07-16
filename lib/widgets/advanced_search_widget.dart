import 'package:flutter/material.dart';
import '../models/search_filter.dart';
import '../services/search_service.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final String entityType;
  final SearchFilter initialFilter;
  final Function(SearchFilter) onFilterChanged;
  final VoidCallback? onClearFilters;

  const AdvancedSearchWidget({
    super.key,
    required this.entityType,
    required this.initialFilter,
    required this.onFilterChanged,
    this.onClearFilters,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final SearchService _searchService = SearchService();
  late SearchFilter _currentFilter;
  
  final _queryController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();

  List<String> _availableCategories = [];
  List<String> _availableStatuses = [];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _initializeControllers();
    _loadFilterOptions();
    _loadSearchHistory();
  }

  void _initializeControllers() {
    _queryController.text = _currentFilter.query ?? '';
    _minPriceController.text = _currentFilter.minPrice?.toString() ?? '';
    _maxPriceController.text = _currentFilter.maxPrice?.toString() ?? '';
    _minStockController.text = _currentFilter.minStock?.toString() ?? '';
    _maxStockController.text = _currentFilter.maxStock?.toString() ?? '';
  }

  Future<void> _loadFilterOptions() async {
    switch (widget.entityType) {
      case 'products':
        _availableCategories = await _searchService.getProductCategories();
        _availableStatuses = await _searchService.getProductStatuses();
        break;
      case 'customers':
        _availableCategories = await _searchService.getCustomerTypes();
        _availableStatuses = await _searchService.getCustomerStatuses();
        break;
      case 'orders':
        _availableCategories = await _searchService.getOrderPriorities();
        _availableStatuses = await _searchService.getOrderStatuses();
        break;
    }
    setState(() {});
  }

  Future<void> _loadSearchHistory() async {
    _searchHistory = await _searchService.getSearchHistory(widget.entityType);
    setState(() {});
  }

  void _updateFilter() {
    final newFilter = _currentFilter.copyWith(
      query: _queryController.text.isEmpty ? null : _queryController.text,
      minPrice: _minPriceController.text.isEmpty 
          ? null 
          : double.tryParse(_minPriceController.text),
      maxPrice: _maxPriceController.text.isEmpty 
          ? null 
          : double.tryParse(_maxPriceController.text),
      minStock: _minStockController.text.isEmpty 
          ? null 
          : int.tryParse(_minStockController.text),
      maxStock: _maxStockController.text.isEmpty 
          ? null 
          : int.tryParse(_maxStockController.text),
    );
    
    setState(() {
      _currentFilter = newFilter;
    });
    
    widget.onFilterChanged(newFilter);
  }

  void _clearFilters() {
    setState(() {
      _currentFilter = SearchFilter();
      _queryController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minStockController.clear();
      _maxStockController.clear();
    });
    
    widget.onClearFilters?.call();
    widget.onFilterChanged(SearchFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Search',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_currentFilter.hasActiveFilters)
                      Chip(
                        label: Text('${_currentFilter.activeFilterCount} filters'),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _currentFilter.hasActiveFilters ? _clearFilters : null,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Query with History
            _buildSearchField(),
            const SizedBox(height: 16),
            
            // Date Range
            _buildDateRangeSection(),
            const SizedBox(height: 16),
            
            // Categories/Types and Statuses
            _buildCategoryAndStatusSection(),
            const SizedBox(height: 16),
            
            // Price/Amount Range
            _buildPriceRangeSection(),
            const SizedBox(height: 16),
            
            // Stock/Orders Range (for products/customers)
            if (widget.entityType != 'orders')
              _buildStockRangeSection(),
            
            // Sorting Options
            const SizedBox(height: 16),
            _buildSortingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _queryController,
          decoration: InputDecoration(
            labelText: 'Search ${widget.entityType}',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _queryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _queryController.clear();
                      _updateFilter();
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _updateFilter(),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              _searchService.addToSearchHistory(widget.entityType, query);
              _loadSearchHistory();
            }
          },
        ),
        if (_searchHistory.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _searchHistory.take(5).map((query) {
              return ActionChip(
                label: Text(query),
                onPressed: () {
                  _queryController.text = query;
                  _updateFilter();
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _currentFilter.startDate != null
                        ? '${_currentFilter.startDate!.day}/${_currentFilter.startDate!.month}/${_currentFilter.startDate!.year}'
                        : 'Select start date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _currentFilter.endDate != null
                        ? '${_currentFilter.endDate!.day}/${_currentFilter.endDate!.month}/${_currentFilter.endDate!.year}'
                        : 'Select end date',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryAndStatusSection() {
    String categoryLabel;
    switch (widget.entityType) {
      case 'products':
        categoryLabel = 'Categories';
        break;
      case 'customers':
        categoryLabel = 'Customer Types';
        break;
      case 'orders':
        categoryLabel = 'Priorities';
        break;
      default:
        categoryLabel = 'Categories';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMultiSelectChips(
                    _availableCategories,
                    _currentFilter.categories,
                    (selected) {
                      setState(() {
                        _currentFilter = _currentFilter.copyWith(categories: selected);
                      });
                      widget.onFilterChanged(_currentFilter);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMultiSelectChips(
                    _availableStatuses,
                    _currentFilter.statuses,
                    (selected) {
                      setState(() {
                        _currentFilter = _currentFilter.copyWith(statuses: selected);
                      });
                      widget.onFilterChanged(_currentFilter);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    String label;
    switch (widget.entityType) {
      case 'products':
        label = 'Price Range';
        break;
      case 'customers':
        label = 'Total Spent Range';
        break;
      case 'orders':
        label = 'Order Amount Range';
        break;
      default:
        label = 'Price Range';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateFilter(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                decoration: const InputDecoration(
                  labelText: 'Max',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateFilter(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockRangeSection() {
    String label = widget.entityType == 'products' ? 'Stock Range' : 'Orders Range';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minStockController,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateFilter(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxStockController,
                decoration: const InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateFilter(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortingSection() {
    List<String> sortOptions;
    switch (widget.entityType) {
      case 'products':
        sortOptions = ['name', 'price', 'stock', 'created', 'updated'];
        break;
      case 'customers':
        sortOptions = ['name', 'email', 'company', 'total_spent', 'total_orders', 'created', 'updated'];
        break;
      case 'orders':
        sortOptions = ['customer', 'total', 'status', 'priority', 'order_date', 'expected_delivery', 'created', 'updated'];
        break;
      default:
        sortOptions = ['created', 'updated'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _currentFilter.sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: sortOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(sortBy: value);
                  });
                  widget.onFilterChanged(_currentFilter);
                },
              ),
            ),
            const SizedBox(width: 16),
            ToggleButtons(
              isSelected: [_currentFilter.sortAscending, !_currentFilter.sortAscending],
              onPressed: (index) {
                setState(() {
                  _currentFilter = _currentFilter.copyWith(sortAscending: index == 0);
                });
                widget.onFilterChanged(_currentFilter);
              },
              children: const [
                Icon(Icons.arrow_upward),
                Icon(Icons.arrow_downward),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips(
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    if (options.isEmpty) {
      return const Text('No options available');
    }

    return Wrap(
      spacing: 8,
      children: options.map((option) {
        final bool isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            List<String> newSelected = [selected.toString()];
            if (selected) {
              newSelected.add(option);
            } else {
              newSelected.remove(option);
            }
            onChanged(newSelected);
          },
        );
      }).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_currentFilter.startDate ?? DateTime.now())
          : (_currentFilter.endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _currentFilter = _currentFilter.copyWith(startDate: picked);
        } else {
          _currentFilter = _currentFilter.copyWith(endDate: picked);
        }
      });
      widget.onFilterChanged(_currentFilter);
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }
}
