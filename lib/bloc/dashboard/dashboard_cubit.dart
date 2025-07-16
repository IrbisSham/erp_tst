import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/order_repository.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic> dashboardData;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.dashboardData = const {},
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    Map<String, dynamic>? dashboardData,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      dashboardData: dashboardData ?? this.dashboardData,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, dashboardData, error];
}

class DashboardCubit extends Cubit<DashboardState> {
  final ProductRepository _productRepository;
  final CustomerRepository _customerRepository;
  final OrderRepository _orderRepository;

  DashboardCubit({
    required ProductRepository productRepository,
    required CustomerRepository customerRepository,
    required OrderRepository orderRepository,
  })  : _productRepository = productRepository,
        _customerRepository = customerRepository,
        _orderRepository = orderRepository,
        super(const DashboardState());

  Future<void> loadDashboardData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final inventoryStats = await _productRepository.getInventoryStats();
      final customerStats = await _customerRepository.getCustomerStats();
      final salesStats = await _orderRepository.getSalesStats();

      final dashboardData = {
        'totalSales': salesStats['totalSales'] ?? 0.0,
        'totalOrders': salesStats['totalOrders'] ?? 0,
        'totalCustomers': customerStats['totalCustomers'] ?? 0,
        'totalProducts': inventoryStats['totalProducts'] ?? 0,
        'lowStockCount': inventoryStats['lowStockCount'] ?? 0,
        'outOfStockCount': inventoryStats['outOfStockCount'] ?? 0,
        'inventoryValue': inventoryStats['totalValue'] ?? 0.0,
        'averageOrderValue': salesStats['averageOrderValue'] ?? 0.0,
        'activeCustomers': customerStats['activeCustomers'] ?? 0,
        'completedOrders': salesStats['completedOrders'] ?? 0,
        'pendingOrders': salesStats['pendingOrders'] ?? 0,
      };

      emit(state.copyWith(
        isLoading: false,
        dashboardData: dashboardData,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data: $e',
      ));
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }
}
