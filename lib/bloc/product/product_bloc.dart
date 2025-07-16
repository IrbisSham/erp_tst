import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<LoadProductById>(_onLoadProductById);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
    on<LoadInventoryStats>(_onLoadInventoryStats);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getAllProducts(
        includeDeleted: event.includeDeleted,
      );
      emit(ProductLoaded(
        products: products,
        filteredProducts: products,
      ));
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      
      if (event.query.isEmpty) {
        emit(ProductLoaded(
          products: currentState.products,
          filteredProducts: currentState.products,
          searchQuery: event.query,
        ));
      } else {
        try {
          final searchResults = await _productRepository.searchProducts(event.query);
          emit(ProductLoaded(
            products: currentState.products,
            filteredProducts: searchResults,
            searchQuery: event.query,
          ));
        } catch (e) {
          emit(ProductError('Search failed: $e'));
        }
      }
    }
  }

  Future<void> _onCreateProduct(CreateProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.createProduct(event.product);
      emit(const ProductOperationSuccess('Product created successfully'));
      add(const LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to create product: $e'));
    }
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.updateProduct(event.product);
      emit(const ProductOperationSuccess('Product updated successfully'));
      add(const LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to update product: $e'));
    }
  }

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.deleteProduct(event.productId);
      emit(const ProductOperationSuccess('Product deleted successfully'));
      add(const LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to delete product: $e'));
    }
  }

  Future<void> _onLoadProductById(LoadProductById event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _productRepository.getProductById(event.productId);
      if (product != null) {
        emit(ProductDetailsLoaded(product));
      } else {
        emit(const ProductError('Product not found'));
      }
    } catch (e) {
      emit(ProductError('Failed to load product: $e'));
    }
  }

  Future<void> _onLoadLowStockProducts(LoadLowStockProducts event, Emitter<ProductState> emit) async {
    try {
      final lowStockProducts = await _productRepository.getLowStockProducts(
        threshold: event.threshold,
      );
      emit(LowStockProductsLoaded(lowStockProducts));
    } catch (e) {
      emit(ProductError('Failed to load low stock products: $e'));
    }
  }

  Future<void> _onLoadInventoryStats(LoadInventoryStats event, Emitter<ProductState> emit) async {
    try {
      final stats = await _productRepository.getInventoryStats();
      emit(InventoryStatsLoaded(stats));
    } catch (e) {
      emit(ProductError('Failed to load inventory stats: $e'));
    }
  }

  Future<void> _onRefreshProducts(RefreshProducts event, Emitter<ProductState> emit) async {
    add(const LoadProducts());
  }
}
