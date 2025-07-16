import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';
import '../widgets/offline_banner.dart';

class BulkOperationsScreen extends StatefulWidget {
  const BulkOperationsScreen({super.key});

  @override
  State<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends State<BulkOperationsScreen> {
  final ExportService _exportService = ExportService();
  final ImportService _importService = ImportService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Operations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_statusMessage.isNotEmpty) ...[
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _statusMessage,
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Export Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Data',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Export your data to CSV or Excel format for backup or analysis.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Products Export
                          _buildExportSection(
                            'Products',
                            Icons.inventory,
                            Colors.blue,
                            () => _exportProducts(),
                          ),
                          const SizedBox(height: 12),
                          
                          // Customers Export
                          _buildExportSection(
                            'Customers',
                            Icons.people,
                            Colors.green,
                            () => _exportCustomers(),
                          ),
                          const SizedBox(height: 12),
                          
                          // Orders Export
                          _buildExportSection(
                            'Orders',
                            Icons.shopping_cart,
                            Colors.orange,
                            () => _exportOrders(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Import Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Import Data',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Import data from CSV or Excel files. Download templates to ensure proper formatting.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Products Import
                          _buildImportSection(
                            'Products',
                            Icons.inventory,
                            Colors.blue,
                            () => _importProducts(),
                            () => _downloadProductTemplate(),
                          ),
                          const SizedBox(height: 12),
                          
                          // Customers Import
                          _buildImportSection(
                            'Customers',
                            Icons.people,
                            Colors.green,
                            () => _importCustomers(),
                            () => _downloadCustomerTemplate(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bulk Update Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bulk Updates',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Perform bulk operations on your data.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : () => _showBulkPriceUpdateDialog(),
                                  icon: const Icon(Icons.price_change),
                                  label: const Text('Update Prices'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : () => _showBulkStockUpdateDialog(),
                                  icon: const Icon(Icons.inventory_2),
                                  label: const Text('Update Stock'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Processing...'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection(String title, IconData icon, Color color, VoidCallback onExport) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => _exportData(title, 'csv'),
                child: const Text('CSV'),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => _exportData(title, 'excel'),
                child: const Text('Excel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection(
    String title,
    IconData icon,
    Color color,
    VoidCallback onImport,
    VoidCallback onDownloadTemplate,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : onDownloadTemplate,
                child: const Text('Template'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : onImport,
                child: const Text('Import'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String type, String format) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Exporting $type to $format...';
    });

    try {
      String filePath;
      
      switch (type.toLowerCase()) {
        case 'products':
          filePath = format == 'csv' 
              ? await _exportService.exportProductsToCSV()
              : await _exportService.exportProductsToExcel();
          break;
        case 'customers':
          filePath = format == 'csv'
              ? await _exportService.exportCustomersToCSV()
              : await _exportService.exportCustomersToExcel();
          break;
        case 'orders':
          filePath = format == 'csv'
              ? await _exportService.exportOrdersToCSV()
              : await _exportService.exportOrdersToExcel();
          break;
        default:
          throw Exception('Unknown export type: $type');
      }

      await _exportService.shareFile(filePath);
      
      setState(() {
        _statusMessage = '$type exported successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Export failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportProducts() async {
    // This method is kept for backward compatibility
  }

  Future<void> _exportCustomers() async {
    // This method is kept for backward compatibility
  }

  Future<void> _exportOrders() async {
    // This method is kept for backward compatibility
  }

  Future<void> _importProducts() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Importing products...';
      });

      try {
        final filePath = result.files.single.path!;
        final extension = filePath.split('.').last.toLowerCase();
        
        ImportResult importResult;
        if (extension == 'csv') {
          importResult = await _importService.importProductsFromCSV(filePath);
        } else {
          importResult = await _importService.importProductsFromExcel(filePath);
        }

        _showImportResultDialog('Products', importResult);
      } catch (e) {
        setState(() {
          _statusMessage = 'Import failed: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importCustomers() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Importing customers...';
      });

      try {
        final filePath = result.files.single.path!;
        final extension = filePath.split('.').last.toLowerCase();
        
        ImportResult importResult;
        if (extension == 'csv') {
          importResult = await _importService.importCustomersFromCSV(filePath);
        } else {
          importResult = await _importService.importCustomersFromExcel(filePath);
        }

        _showImportResultDialog('Customers', importResult);
      } catch (e) {
        setState(() {
          _statusMessage = 'Import failed: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadProductTemplate() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating product template...';
    });

    try {
      final filePath = await _exportService.generateProductTemplate();
      await _exportService.shareFile(filePath);
      
      setState(() {
        _statusMessage = 'Product template generated successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Template generation failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadCustomerTemplate() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating customer template...';
    });

    try {
      final filePath = await _exportService.generateCustomerTemplate();
      await _exportService.shareFile(filePath);
      
      setState(() {
        _statusMessage = 'Customer template generated successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Template generation failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImportResultDialog(String type, ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type Import Result'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(result.message),
              const SizedBox(height: 8),
              Text('Success: ${result.successCount}'),
              Text('Errors: ${result.errorCount}'),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...result.errors.take(10).map((error) => Text('• $error')),
                if (result.errors.length > 10)
                  Text('... and ${result.errors.length - 10} more errors'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    setState(() {
      _statusMessage = result.message;
    });
  }

  void _showBulkPriceUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkPriceUpdateDialog(
        onUpdate: (skuPriceMap) async {
          setState(() {
            _isLoading = true;
            _statusMessage = 'Updating prices...';
          });

          try {
            final result = await _importService.bulkUpdateProductPrices(skuPriceMap);
            setState(() {
              _statusMessage = 'Updated ${result.successCount} products. ${result.errorCount} errors.';
            });
          } catch (e) {
            setState(() {
              _statusMessage = 'Bulk update failed: ${e.toString()}';
            });
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
      ),
    );
  }

  void _showBulkStockUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkStockUpdateDialog(
        onUpdate: (skuStockMap) async {
          setState(() {
            _isLoading = true;
            _statusMessage = 'Updating stock...';
          });

          try {
            final result = await _importService.bulkUpdateProductStock(skuStockMap);
            setState(() {
              _statusMessage = 'Updated ${result.successCount} products. ${result.errorCount} errors.';
            });
          } catch (e) {
            setState(() {
              _statusMessage = 'Bulk update failed: ${e.toString()}';
            });
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
      ),
    );
  }
}

class BulkPriceUpdateDialog extends StatefulWidget {
  final Function(Map<String, double>) onUpdate;

  const BulkPriceUpdateDialog({super.key, required this.onUpdate});

  @override
  State<BulkPriceUpdateDialog> createState() => _BulkPriceUpdateDialogState();
}

class _BulkPriceUpdateDialogState extends State<BulkPriceUpdateDialog> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Price Update'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter SKU and price pairs (one per line):'),
            const Text('Format: SKU,Price'),
            const Text('Example: PROD-001,299.99'),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'PROD-001,299.99\nPROD-002,199.99',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final lines = _textController.text.split('\n');
            final skuPriceMap = <String, double>{};
            
            for (var line in lines) {
              final parts = line.split(',');
              if (parts.length == 2) {
                final sku = parts[0].trim();
                final price = double.tryParse(parts[1].trim());
                if (price != null) {
                  skuPriceMap[sku] = price;
                }
              }
            }
            
            Navigator.pop(context);
            widget.onUpdate(skuPriceMap);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class BulkStockUpdateDialog extends StatefulWidget {
  final Function(Map<String, int>) onUpdate;

  const BulkStockUpdateDialog({super.key, required this.onUpdate});

  @override
  State<BulkStockUpdateDialog> createState() => _BulkStockUpdateDialogState();
}

class _BulkStockUpdateDialogState extends State<BulkStockUpdateDialog> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Stock Update'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter SKU and stock pairs (one per line):'),
            const Text('Format: SKU,Stock'),
            const Text('Example: PROD-001,100'),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'PROD-001,100\nPROD-002,50',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final lines = _textController.text.split('\n');
            final skuStockMap = <String, int>{};
            
            for (var line in lines) {
              final parts = line.split(',');
              if (parts.length == 2) {
                final sku = parts[0].trim();
                final stock = int.tryParse(parts[1].trim());
                if (stock != null) {
                  skuStockMap[sku] = stock;
                }
              }
            }
            
            Navigator.pop(context);
            widget.onUpdate(skuStockMap);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
