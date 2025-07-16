import 'package:equatable/equatable.dart';
import '../../models/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;

  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderOperationSuccess extends OrderState {
  final String message;

  const OrderOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderDetailsLoaded extends OrderState {
  final Order order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class CustomerOrdersLoaded extends OrderState {
  final List<Order> orders;
  final String customerId;

  const CustomerOrdersLoaded(this.orders, this.customerId);

  @override
  List<Object?> get props => [orders, customerId];
}

class SalesStatsLoaded extends OrderState {
  final Map<String, dynamic> stats;

  const SalesStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}
