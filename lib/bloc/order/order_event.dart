import 'package:equatable/equatable.dart';
import '../../models/order.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  final bool includeDeleted;

  const LoadOrders({this.includeDeleted = false});

  @override
  List<Object?> get props => [includeDeleted];
}

class CreateOrder extends OrderEvent {
  final Order order;

  const CreateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrder extends OrderEvent {
  final Order order;

  const UpdateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class DeleteOrder extends OrderEvent {
  final String orderId;

  const DeleteOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadOrderById extends OrderEvent {
  final String orderId;

  const LoadOrderById(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadOrdersByCustomer extends OrderEvent {
  final String customerId;

  const LoadOrdersByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadSalesStats extends OrderEvent {}

class RefreshOrders extends OrderEvent {}
