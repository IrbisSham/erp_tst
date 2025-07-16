import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../repositories/product_repository.dart';
import '../repositories/customer_repository.dart';

class ImportService {
  static final ImportService _instance = ImportService._internal();
  factory ImportService() => _instance;
  ImportService._internal();

  final ProductRepository _productRepo = ProductRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final Uuid _uuid = const Uuid();

  // Import Products
  Future<ImportResult> importProductsFromCSV(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);

      if (rows.isEmpty) {
        return ImportResult(success: false, message: 'File is empty');
      }

      final headers = rows.first.map((e) => e.toString().toLowerCase()).toList();
      final dataRows = rows.skip(1).toList();

      List<String> errors = [];
      List<Product> validProducts = [];
      int successCount = 0;

      for (int i = 0; i < dataRows.length; i++) {
        try {
          final row = dataRows[i];
          final product = _parseProductFromRow(headers, row);
          
          if (product != null) {
            validProducts.add(product);
          } else {
            errors.add('Row ${i + 2}: Invalid product data');
          }
        } catch (e) {
          errors.add('Row ${i + 2}: ${e.toString()}');
        }
      }

      // Save valid products
      for (var product in validProducts) {
        try {
          await _productRepo.createProduct(product);
          successCount++;
        } catch (e) {
          errors.add('Failed to save product ${product.name}: ${e.toString()}');
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        message: 'Imported $successCount products successfully',
        successCount: successCount,
        errorCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Error reading file: ${e.toString()}');
    }
  }

  Future<ImportResult> importProductsFromExcel(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        return ImportResult(success: false, message: 'No sheets found in Excel file');
      }

      final sheet = excel.tables.values.first;
      if (sheet == null || sheet.rows.isEmpty) {
        return ImportResult(success: false, message: 'Sheet is empty');
      }

      final headers = sheet.rows.first?.map((cell) => 
          cell?.value?.toString().toLowerCase() ?? '').toList() ?? [];
      final dataRows = sheet.rows.skip(1).toList();

      List<String> errors = [];
      List<Product> validProducts = [];
      int successCount = 0;

      for (int i = 0; i < dataRows.length; i++) {
        try {
          final row = dataRows[i]?.map((cell) => cell?.value?.toString() ?? '').toList() ?? [];
          final product = _parseProductFromRow(headers, row);
          
          if (product != null) {
            validProducts.add(product);
          } else {
            errors.add('Row ${i + 2}: Invalid product data');
          }
        } catch (e) {
          errors.add('Row ${i + 2}: ${e.toString()}');
        }
      }

      // Save valid products
      for (var product in validProducts) {
        try {
          await _productRepo.createProduct(product);
          successCount++;
        } catch (e) {
          errors.add('Failed to save product ${product.name}: ${e.toString()}');
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        message: 'Imported $successCount products successfully',
        successCount: successCount,
        errorCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Error reading Excel file: ${e.toString()}');
    }
  }

  // Import Customers
  Future<ImportResult> importCustomersFromCSV(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);

      if (rows.isEmpty) {
        return ImportResult(success: false, message: 'File is empty');
      }

      final headers = rows.first.map((e) => e.toString().toLowerCase()).toList();
      final dataRows = rows.skip(1).toList();

      List<String> errors = [];
      List<Customer> validCustomers = [];
      int successCount = 0;

      for (int i = 0; i < dataRows.length; i++) {
        try {
          final row = dataRows[i];
          final customer = _parseCustomerFromRow(headers, row);
          
          if (customer != null) {
            validCustomers.add(customer);
          } else {
            errors.add('Row ${i + 2}: Invalid customer data');
          }
        } catch (e) {
          errors.add('Row ${i + 2}: ${e.toString()}');
        }
      }

      // Save valid customers
      for (var customer in validCustomers) {
        try {
          await _customerRepo.createCustomer(customer);
          successCount++;
        } catch (e) {
          errors.add('Failed to save customer ${customer.name}: ${e.toString()}');
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        message: 'Imported $successCount customers successfully',
        successCount: successCount,
        errorCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Error reading file: ${e.toString()}');
    }
  }

  Future<ImportResult> importCustomersFromExcel(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        return ImportResult(success: false, message: 'No sheets found in Excel file');
      }

      final sheet = excel.tables.values.first;
      if (sheet == null || sheet.rows.isEmpty) {
        return ImportResult(success: false, message: 'Sheet is empty');
      }

      final headers = sheet.rows.first?.map((cell) => 
          cell?.value?.toString().toLowerCase() ?? '').toList() ?? [];
      final dataRows = sheet.rows.skip(1).toList();

      List<String> errors = [];
      List<Customer> validCustomers = [];
      int successCount = 0;

      for (int i = 0; i < dataRows.length; i++) {
        try {
          final row = dataRows[i]?.map((cell) => cell?.value?.toString() ?? '').toList() ?? [];
          final customer = _parseCustomerFromRow(headers, row);
          
          if (customer != null) {
            validCustomers.add(customer);
          } else {
            errors.add('Row ${i + 2}: Invalid customer data');
          }
        } catch (e) {
          errors.add('Row ${i + 2}: ${e.toString()}');
        }
      }

      // Save valid customers
      for (var customer in validCustomers) {
        try {
          await _customerRepo.createCustomer(customer);
          successCount++;
        } catch (e) {
          errors.add('Failed to save customer ${customer.name}: ${e.toString()}');
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        message: 'Imported $successCount customers successfully',
        successCount: successCount,
        errorCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Error reading Excel file: ${e.toString()}');
    }
  }

  // Bulk operations
  Future<BulkOperationResult> bulkUpdateProductPrices(Map<String, double> skuPriceMap) async {
    List<String> errors = [];
    int successCount = 0;

    for (var entry in skuPriceMap.entries) {
      try {
        final products = await _productRepo.searchProducts(entry.key);
        final product = products.firstWhere((p) => p.sku == entry.key);
        
        final updatedProduct = product.copyWith(
          price: entry.value,
          updatedAt: DateTime.now(),
        );
        
        await _productRepo.updateProduct(updatedProduct);
        successCount++;
      } catch (e) {
        errors.add('Failed to update product ${entry.key}: ${e.toString()}');
      }
    }

    return BulkOperationResult(
      successCount: successCount,
      errorCount: errors.length,
      errors: errors,
    );
  }

  Future<BulkOperationResult> bulkUpdateProductStock(Map<String, int> skuStockMap) async {
    List<String> errors = [];
    int successCount = 0;

    for (var entry in skuStockMap.entries) {
      try {
        final products = await _productRepo.searchProducts(entry.key);
        final product = products.firstWhere((p) => p.sku == entry.key);
        
        final updatedProduct = product.copyWith(
          stock: entry.value,
          updatedAt: DateTime.now(),
        );
        
        await _productRepo.updateProduct(updatedProduct);
        successCount++;
      } catch (e) {
        errors.add('Failed to update stock for ${entry.key}: ${e.toString()}');
      }
    }

    return BulkOperationResult(
      successCount: successCount,
      errorCount: errors.length,
      errors: errors,
    );
  }

  // Helper methods
  Product? _parseProductFromRow(List<String> headers, List<dynamic> row) {
    try {
      final data = <String, dynamic>{};
      for (int i = 0; i < headers.length && i < row.length; i++) {
        data[headers[i]] = row[i];
      }

      final name = data['name']?.toString();
      final sku = data['sku']?.toString();
      final category = data['category']?.toString();
      final stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
      final price = double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;
      final status = data['status']?.toString() ?? 'Active';

      if (name == null || name.isEmpty || sku == null || sku.isEmpty) {
        return null;
      }

      final now = DateTime.now();
      return Product(
        id: _uuid.v4(),
        name: name,
        sku: sku,
        category: category ?? 'General',
        stock: stock,
        price: price,
        status: status,
        description: data['description']?.toString(),
        supplier: data['supplier']?.toString(),
        location: data['location']?.toString(),
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      return null;
    }
  }

  Customer? _parseCustomerFromRow(List<String> headers, List<dynamic> row) {
    try {
      final data = <String, dynamic>{};
      for (int i = 0; i < headers.length && i < row.length; i++) {
        data[headers[i]] = row[i];
      }

      final name = data['name']?.toString();
      final email = data['email']?.toString();
      final phone = data['phone']?.toString();

      if (name == null || name.isEmpty || email == null || email.isEmpty) {
        return null;
      }

      final now = DateTime.now();
      return Customer(
        id: _uuid.v4(),
        name: name,
        email: email,
        phone: phone ?? '',
        company: data['company']?.toString(),
        address: data['address']?.toString(),
        city: data['city']?.toString(),
        state: data['state']?.toString(),
        zip: data['zip']?.toString(),
        type: data['type']?.toString() ?? 'Individual',
        status: data['status']?.toString() ?? 'Active',
        notes: data['notes']?.toString(),
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      return null;
    }
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int successCount;
  final int errorCount;
  final List<String> errors;

  ImportResult({
    required this.success,
    required this.message,
    this.successCount = 0,
    this.errorCount = 0,
    this.errors = const [],
  });
}

class BulkOperationResult {
  final int successCount;
  final int errorCount;
  final List<String> errors;

  BulkOperationResult({
    required this.successCount,
    required this.errorCount,
    this.errors = const [],
  });
}
