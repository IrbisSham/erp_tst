import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final bool includeDeleted;

  const LoadProducts({this.includeDeleted = false});

  @override
  List<Object?> get props => [includeDeleted];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateProduct extends ProductEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class LoadProductById extends ProductEvent {
  final String productId;

  const LoadProductById(this.productId);

  @override
  List<Object?> get props => [productId];
}

class LoadLowStockProducts extends ProductEvent {
  final int threshold;

  const LoadLowStockProducts({this.threshold = 10});

  @override
  List<Object?> get props => [threshold];
}

class LoadInventoryStats extends ProductEvent {}

class RefreshProducts extends ProductEvent {}
