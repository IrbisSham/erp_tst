import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/main_drawer.dart';
import '../widgets/offline_banner.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../models/product.dart';
import '../models/search_filter.dart';
import '../services/search_service.dart';
import 'edit_product_screen.dart';
import 'advanced_search_screen.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final SearchService _searchService = SearchService();
  SearchFilter _currentFilter = SearchFilter();
  bool _isAdvancedSearch = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
  }

  void _onAdvancedSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedSearchScreen(
          entityType: 'products',
          initialFilter: _currentFilter,
        ),
      ),
    ).then((result) {
      if (result != null && result is SearchFilter) {
        setState(() {
          _currentFilter = result;
          _isAdvancedSearch = result.hasActiveFilters;
        });
        // Apply advanced search filter
        // This would need to be implemented in the ProductBloc
      }
    });
  }

  void _clearAdvancedFilters() {
    setState(() {
      _currentFilter = SearchFilter();
      _isAdvancedSearch = false;
    });
    context.read<ProductBloc>().add(const LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Inventory'),
            if (_isAdvancedSearch) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text('${_currentFilter.activeFilterCount} filters'),
                backgroundColor: Colors.blue.withOpacity(0.2),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: _clearAdvancedFilters,
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onAdvancedSearch,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export_csv':
                  _exportProducts('csv');
                  break;
                case 'export_excel':
                  _exportProducts('excel');
                  break;
                case 'import':
                  _importProducts();
                  break;
                case 'bulk_ops':
                  Navigator.pushNamed(context, '/bulk-operations');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_excel',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_ops',
                child: Row(
                  children: [
                    Icon(Icons.import_export),
                    SizedBox(width: 8),
                    Text('Bulk Operations'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          if (!_isAdvancedSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: _onAdvancedSearch,
                          tooltip: 'Advanced Search',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (query) {
                        context.read<ProductBloc>().add(SearchProducts(query));
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state is ProductError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is ProductOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  final products = state.filteredProducts;
                  
                  if (products.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      // Results summary
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${products.length} products found',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_isAdvancedSearch)
                              TextButton.icon(
                                onPressed: _onAdvancedSearch,
                                icon: const Icon(Icons.tune),
                                label: const Text('Modify Search'),
                              ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<ProductBloc>().add(RefreshProducts());
                          },
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(product.status),
                                    child: Text(
                                      product.stock.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (!product.isSynced)
                                        const Icon(
                                          Icons.sync_disabled,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('SKU: ${product.sku}'),
                                      Text('Category: ${product.category}'),
                                      Text(
                                        'Price: \$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      product.status,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _getStatusColor(product.status).withOpacity(0.2),
                                  ),
                                  onTap: () {
                                    _showProductDetails(context, product);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductBloc>().add(const LoadProducts());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_isAdvancedSearch) {
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
              'No products found matching your search criteria',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearAdvancedFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
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

  void _showProductDetails(BuildContext context, Product product) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditProductScreen(product: product.toMap()),
    //   ),
    // ).then((result) {
    //   if (result == true || result == 'deleted') {
    //     context.read<ProductBloc>().add(const LoadProducts());
    //   }
    // });
  }

  void _showAddProductDialog(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const EditProductScreen(),
    //   ),
    // ).then((result) {
    //   if (result == true) {
    //     context.read<ProductBloc>().add(const LoadProducts());
    //   }
    // });
  }

  Future<void> _exportProducts(String format) async {
    try {
      final exportService = ExportService();
      String filePath;

      if (format == 'csv') {
        filePath = await exportService.exportProductsToCSV();
      } else {
        filePath = await exportService.exportProductsToExcel();
      }

      await exportService.shareFile(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Products exported to $format successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importProducts() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final importService = ImportService();
        final filePath = result.files.single.path!;
        final extension = filePath.split('.').last.toLowerCase();

        ImportResult importResult;
        if (extension == 'csv') {
          importResult = await importService.importProductsFromCSV(filePath);
        } else {
          importResult = await importService.importProductsFromExcel(filePath);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(importResult.message)),
          );

          if (importResult.success || importResult.successCount > 0) {
            context.read<ProductBloc>().add(const LoadProducts());
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')),
          );
        }
      }
    }
  }
}
