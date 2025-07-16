import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [products, filteredProducts, searchQuery];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationSuccess extends ProductState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductDetailsLoaded extends ProductState {
  final Product product;

  const ProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class LowStockProductsLoaded extends ProductState {
  final List<Product> lowStockProducts;

  const LowStockProductsLoaded(this.lowStockProducts);

  @override
  List<Object?> get props => [lowStockProducts];
}

class InventoryStatsLoaded extends ProductState {
  final Map<String, dynamic> stats;

  const InventoryStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}
