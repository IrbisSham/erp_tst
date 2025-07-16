import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../repositories/product_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final ProductRepository _productRepo = ProductRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final OrderRepository _orderRepo = OrderRepository();

  // Export Products
  Future<String> exportProductsToCSV() async {
    final products = await _productRepo.getAllProducts();
    
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'ID',
      'Name',
      'SKU',
      'Category',
      'Stock',
      'Price',
      'Status',
      'Description',
      'Supplier',
      'Location',
      'Created At',
      'Updated At'
    ]);

    // Data rows
    for (var product in products) {
      rows.add([
        product.id,
        product.name,
        product.sku,
        product.category,
        product.stock,
        product.price,
        product.status,
        product.description ?? '',
        product.supplier ?? '',
        product.location ?? '',
        product.createdAt.toIso8601String(),
        product.updatedAt.toIso8601String(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveToFile('products_export.csv', csv);
  }

  Future<String> exportProductsToExcel() async {
    final products = await _productRepo.getAllProducts();
    var excel = Excel.createExcel();
    Sheet sheet = excel['Products'];

    // Header row
    List<String> headers = [
      'ID', 'Name', 'SKU', 'Category', 'Stock', 'Price', 'Status',
      'Description', 'Supplier', 'Location', 'Created At', 'Updated At'
    ];
    
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Data rows
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      List<dynamic> row = [
        product.id,
        product.name,
        product.sku,
        product.category,
        product.stock,
        product.price,
        product.status,
        product.description ?? '',
        product.supplier ?? '',
        product.location ?? '',
        product.createdAt.toIso8601String(),
        product.updatedAt.toIso8601String(),
      ];

      for (int j = 0; j < row.length; j++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
        if (row[j] is String) {
          cell.value = TextCellValue(row[j]);
        } else if (row[j] is int) {
          cell.value = IntCellValue(row[j]);
        } else if (row[j] is double) {
          cell.value = DoubleCellValue(row[j]);
        } else {
          cell.value = TextCellValue(row[j].toString());
        }
      }
    }

    var bytes = excel.encode();
    return await _saveBytesToFile('products_export.xlsx', Uint8List.fromList(bytes!));
  }

  // Export Customers
  Future<String> exportCustomersToCSV() async {
    final customers = await _customerRepo.getAllCustomers();
    
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'ID',
      'Name',
      'Email',
      'Phone',
      'Company',
      'Address',
      'City',
      'State',
      'ZIP',
      'Type',
      'Status',
      'Total Orders',
      'Total Spent',
      'Notes',
      'Created At',
      'Updated At'
    ]);

    // Data rows
    for (var customer in customers) {
      rows.add([
        customer.id,
        customer.name,
        customer.email,
        customer.phone,
        customer.company ?? '',
        customer.address ?? '',
        customer.city ?? '',
        customer.state ?? '',
        customer.zip ?? '',
        customer.type,
        customer.status,
        customer.totalOrders,
        customer.totalSpent,
        customer.notes ?? '',
        customer.createdAt.toIso8601String(),
        customer.updatedAt.toIso8601String(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveToFile('customers_export.csv', csv);
  }

  Future<String> exportCustomersToExcel() async {
    final customers = await _customerRepo.getAllCustomers();
    var excel = Excel.createExcel();
    Sheet sheet = excel['Customers'];

    // Header row
    List<String> headers = [
      'ID', 'Name', 'Email', 'Phone', 'Company', 'Address', 'City', 'State',
      'ZIP', 'Type', 'Status', 'Total Orders', 'Total Spent', 'Notes',
      'Created At', 'Updated At'
    ];
    
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Data rows
    for (int i = 0; i < customers.length; i++) {
      final customer = customers[i];
      List<dynamic> row = [
        customer.id,
        customer.name,
        customer.email,
        customer.phone,
        customer.company ?? '',
        customer.address ?? '',
        customer.city ?? '',
        customer.state ?? '',
        customer.zip ?? '',
        customer.type,
        customer.status,
        customer.totalOrders,
        customer.totalSpent,
        customer.notes ?? '',
        customer.createdAt.toIso8601String(),
        customer.updatedAt.toIso8601String(),
      ];

      for (int j = 0; j < row.length; j++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
        if (row[j] is String) {
          cell.value = TextCellValue(row[j]);
        } else if (row[j] is int) {
          cell.value = IntCellValue(row[j]);
        } else if (row[j] is double) {
          cell.value = DoubleCellValue(row[j]);
        } else {
          cell.value = TextCellValue(row[j].toString());
        }
      }
    }

    var bytes = excel.encode();
    return await _saveBytesToFile('customers_export.xlsx', Uint8List.fromList(bytes!));
  }

  // Export Orders
  Future<String> exportOrdersToCSV() async {
    final orders = await _orderRepo.getAllOrders();
    
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'Order ID',
      'Customer ID',
      'Customer Name',
      'Order Date',
      'Expected Delivery',
      'Status',
      'Priority',
      'Subtotal',
      'Discount',
      'Shipping',
      'Total',
      'Notes',
      'Items Count',
      'Created At',
      'Updated At'
    ]);

    // Data rows
    for (var order in orders) {
      rows.add([
        order.id,
        order.customerId,
        order.customerName,
        order.orderDate.toIso8601String(),
        order.expectedDelivery.toIso8601String(),
        order.status,
        order.priority,
        order.subtotal,
        order.discount,
        order.shipping,
        order.total,
        order.notes ?? '',
        order.items.length,
        order.createdAt.toIso8601String(),
        order.updatedAt.toIso8601String(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveToFile('orders_export.csv', csv);
  }

  Future<String> exportOrdersToExcel() async {
    final orders = await _orderRepo.getAllOrders();
    var excel = Excel.createExcel();
    
    // Orders sheet
    Sheet ordersSheet = excel['Orders'];
    List<String> orderHeaders = [
      'Order ID', 'Customer ID', 'Customer Name', 'Order Date', 'Expected Delivery',
      'Status', 'Priority', 'Subtotal', 'Discount', 'Shipping', 'Total',
      'Notes', 'Items Count', 'Created At', 'Updated At'
    ];
    
    for (int i = 0; i < orderHeaders.length; i++) {
      ordersSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(orderHeaders[i]);
    }

    // Order Items sheet
    Sheet itemsSheet = excel['Order Items'];
    List<String> itemHeaders = [
      'Item ID', 'Order ID', 'Product ID', 'Product Name', 'Quantity', 'Price', 'Total'
    ];
    
    for (int i = 0; i < itemHeaders.length; i++) {
      itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(itemHeaders[i]);
    }

    int orderRowIndex = 1;
    int itemRowIndex = 1;

    for (var order in orders) {
      // Add order data
      List<dynamic> orderRow = [
        order.id,
        order.customerId,
        order.customerName,
        order.orderDate.toIso8601String(),
        order.expectedDelivery.toIso8601String(),
        order.status,
        order.priority,
        order.subtotal,
        order.discount,
        order.shipping,
        order.total,
        order.notes ?? '',
        order.items.length,
        order.createdAt.toIso8601String(),
        order.updatedAt.toIso8601String(),
      ];

      for (int j = 0; j < orderRow.length; j++) {
        var cell = ordersSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: orderRowIndex));
        if (orderRow[j] is String) {
          cell.value = TextCellValue(orderRow[j]);
        } else if (orderRow[j] is int) {
          cell.value = IntCellValue(orderRow[j]);
        } else if (orderRow[j] is double) {
          cell.value = DoubleCellValue(orderRow[j]);
        } else {
          cell.value = TextCellValue(orderRow[j].toString());
        }
      }
      orderRowIndex++;

      // Add order items
      for (var item in order.items) {
        List<dynamic> itemRow = [
          item.id,
          item.orderId,
          item.productId,
          item.productName,
          item.quantity,
          item.price,
          item.total,
        ];

        for (int j = 0; j < itemRow.length; j++) {
          var cell = itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: itemRowIndex));
          if (itemRow[j] is String) {
            cell.value = TextCellValue(itemRow[j]);
          } else if (itemRow[j] is int) {
            cell.value = IntCellValue(itemRow[j]);
          } else if (itemRow[j] is double) {
            cell.value = DoubleCellValue(itemRow[j]);
          } else {
            cell.value = TextCellValue(itemRow[j].toString());
          }
        }
        itemRowIndex++;
      }
    }

    var bytes = excel.encode();
    return await _saveBytesToFile('orders_export.xlsx', Uint8List.fromList(bytes!));
  }

  // Generate import templates
  Future<String> generateProductTemplate() async {
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'Name',
      'SKU',
      'Category',
      'Stock',
      'Price',
      'Status',
      'Description',
      'Supplier',
      'Location'
    ]);

    // Sample data row
    rows.add([
      'Sample Product',
      'SAMPLE-001',
      'Electronics',
      100,
      299.99,
      'Active',
      'Sample product description',
      'Sample Supplier',
      'Warehouse A'
    ]);

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveToFile('product_import_template.csv', csv);
  }

  Future<String> generateCustomerTemplate() async {
    List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'Name',
      'Email',
      'Phone',
      'Company',
      'Address',
      'City',
      'State',
      'ZIP',
      'Type',
      'Status',
      'Notes'
    ]);

    // Sample data row
    rows.add([
      'John Doe',
      'john.doe@example.com',
      '+1234567890',
      'Sample Company',
      '123 Main St',
      'Anytown',
      'CA',
      '12345',
      'Business',
      'Active',
      'Sample customer notes'
    ]);

    String csv = const ListToCsvConverter().convert(rows);
    return await _saveToFile('customer_import_template.csv', csv);
  }

  // Helper methods
  Future<String> _saveToFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> _saveBytesToFile(String fileName, Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}
