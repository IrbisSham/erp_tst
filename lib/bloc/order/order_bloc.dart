import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<DeleteOrder>(_onDeleteOrder);
    on<LoadOrderById>(_onLoadOrderById);
    on<LoadOrdersByCustomer>(_onLoadOrdersByCustomer);
    on<LoadSalesStats>(_onLoadSalesStats);
    on<RefreshOrders>(_onRefreshOrders);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getAllOrders(
        includeDeleted: event.includeDeleted,
      );
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError('Failed to load orders: $e'));
    }
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.createOrder(event.order);
      emit(const OrderOperationSuccess('Order created successfully'));
      add(const LoadOrders());
    } catch (e) {
      emit(OrderError('Failed to create order: $e'));
    }
  }

  Future<void> _onUpdateOrder(UpdateOrder event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.updateOrder(event.order);
      emit(const OrderOperationSuccess('Order updated successfully'));
      add(const LoadOrders());
    } catch (e) {
      emit(OrderError('Failed to update order: $e'));
    }
  }

  Future<void> _onDeleteOrder(DeleteOrder event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.deleteOrder(event.orderId);
      emit(const OrderOperationSuccess('Order deleted successfully'));
      add(const LoadOrders());
    } catch (e) {
      emit(OrderError('Failed to delete order: $e'));
    }
  }

  Future<void> _onLoadOrderById(LoadOrderById event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      if (order != null) {
        emit(OrderDetailsLoaded(order));
      } else {
        emit(const OrderError('Order not found'));
      }
    } catch (e) {
      emit(OrderError('Failed to load order: $e'));
    }
  }

  Future<void> _onLoadOrdersByCustomer(LoadOrdersByCustomer event, Emitter<OrderState> emit) async {
    try {
      final orders = await _orderRepository.getOrdersByCustomer(event.customerId);
      emit(CustomerOrdersLoaded(orders, event.customerId));
    } catch (e) {
      emit(OrderError('Failed to load customer orders: $e'));
    }
  }

  Future<void> _onLoadSalesStats(LoadSalesStats event, Emitter<OrderState> emit) async {
    try {
      final stats = await _orderRepository.getSalesStats();
      emit(SalesStatsLoaded(stats));
    } catch (e) {
      emit(OrderError('Failed to load sales stats: $e'));
    }
  }

  Future<void> _onRefreshOrders(RefreshOrders event, Emitter<OrderState> emit) async {
    add(const LoadOrders());
  }
}
