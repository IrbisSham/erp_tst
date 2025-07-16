import 'package:flutter/material.dart';
import '../models/search_filter.dart';
import '../services/search_service.dart';
import '../widgets/advanced_search_widget.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import 'edit_customer_screen.dart';
import 'edit_order_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  final String entityType;
  final SearchFilter? initialFilter;

  const AdvancedSearchScreen({
    super.key,
    required this.entityType,
    this.initialFilter,
  });

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final SearchService _searchService = SearchService();
  SearchFilter _currentFilter = SearchFilter();
  List<dynamic> _searchResults = [];
  List<SavedSearch> _savedSearches = [];
  bool _isLoading = false;
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? SearchFilter();
    _loadSavedSearches();
    if (_currentFilter.hasActiveFilters) {
      _performSearch();
    }
  }

  Future<void> _loadSavedSearches() async {
    final savedSearches = await _searchService.getSavedSearches(widget.entityType);
    setState(() {
      _savedSearches = savedSearches;
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> results;
      switch (widget.entityType) {
        case 'products':
          results = await _searchService.searchProducts(_currentFilter);
          break;
        case 'customers':
          results = await _searchService.searchCustomers(_currentFilter);
          break;
        case 'orders':
          results = await _searchService.searchOrders(_currentFilter);
          break;
        default:
          results = [];
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _onFilterChanged(SearchFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
    _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _currentFilter = SearchFilter();
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search ${widget.entityType.toUpperCase()}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'save_search':
                  _showSaveSearchDialog();
                  break;
                case 'saved_searches':
                  _showSavedSearchesDialog();
                  break;
                case 'clear_history':
                  _clearSearchHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (_currentFilter.hasActiveFilters)
                const PopupMenuItem(
                  value: 'save_search',
                  child: Row(
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text('Save Search'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'saved_searches',
                child: Row(
                  children: [
                    Icon(Icons.bookmark),
                    SizedBox(width: 8),
                    Text('Saved Searches'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_history',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            AdvancedSearchWidget(
              entityType: widget.entityType,
              initialFilter: _currentFilter,
              onFilterChanged: _onFilterChanged,
              onClearFilters: _clearFilters,
            ),
          
          // Results Summary
          if (_searchResults.isNotEmpty || _isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isLoading 
                        ? 'Searching...' 
                        : 'Found ${_searchResults.length} results',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_searchResults.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showSortDialog(),
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort'),
                    ),
                ],
              ),
            ),
          
          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (!_currentFilter.hasActiveFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Use the search filters above to find ${widget.entityType}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.entityType} found matching your criteria',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildResultItem(item);
      },
    );
  }

  Widget _buildResultItem(dynamic item) {
    switch (widget.entityType) {
      case 'products':
        return _buildProductItem(item as Product);
      case 'customers':
        return _buildCustomerItem(item as Customer);
      case 'orders':
        return _buildOrderItem(item as Order);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getProductStatusColor(product.status),
          child: Text(
            product.stock.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${product.sku}'),
            Text('Category: ${product.category}'),
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Chip(
          label: Text(product.status),
          backgroundColor: _getProductStatusColor(product.status).withOpacity(0.2),
        ),
        onTap: () {

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => EditProductScreen(product: product.toMap()),
          //   ),
          // );

        },
      ),
    );
  }

  Widget _buildCustomerItem(Customer customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: customer.status == 'Active' ? Colors.green : Colors.grey,
          child: Text(
            customer.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.email),
            if (customer.company != null) Text('Company: ${customer.company}'),
            Text('Orders: ${customer.totalOrders} | Spent: \$${customer.totalSpent.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Chip(
          label: Text(customer.status),
          backgroundColor: customer.status == 'Active' 
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCustomerScreen(customer: customer.toMap()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getOrderStatusColor(order.status),
          child: Text(
            order.items.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Order ${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName}'),
            Text('Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Chip(
          label: Text(order.status),
          backgroundColor: _getOrderStatusColor(order.status).withOpacity(0.2),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditOrderScreen(order: order.toMap()),
            ),
          );
        },
      ),
    );
  }

  Color _getProductStatusColor(String status) {
    switch (status) {
      case 'In Stock':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.orange;
      case 'Pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showSaveSearchDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Search'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Search Name',
            hintText: 'Enter a name for this search',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await _searchService.saveSearch(
                    nameController.text,
                    widget.entityType,
                    _currentFilter,
                  );
                  Navigator.pop(context);
                  _loadSavedSearches();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Search saved successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save search: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSavedSearchesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Searches'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _savedSearches.isEmpty
              ? const Center(child: Text('No saved searches'))
              : ListView.builder(
                  itemCount: _savedSearches.length,
                  itemBuilder: (context, index) {
                    final savedSearch = _savedSearches[index];
                    return ListTile(
                      title: Text(savedSearch.name),
                      subtitle: Text(
                        'Saved ${savedSearch.createdAt.day}/${savedSearch.createdAt.month}/${savedSearch.createdAt.year}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _searchService.deleteSavedSearch(savedSearch.id);
                          _loadSavedSearches();
                          setState(() {});
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentFilter = savedSearch.filter;
                        });
                        _performSearch();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _currentFilter.sortBy,
              decoration: const InputDecoration(labelText: 'Sort By'),
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
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Order: '),
                Radio<bool>(
                  value: true,
                  groupValue: _currentFilter.sortAscending,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(sortAscending: value);
                    });
                  },
                ),
                const Text('Ascending'),
                Radio<bool>(
                  value: false,
                  groupValue: _currentFilter.sortAscending,
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(sortAscending: value);
                    });
                  },
                ),
                const Text('Descending'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearSearchHistory() async {
    await _searchService.clearSearchHistory(widget.entityType);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search history cleared')),
      );
    }
  }
}
