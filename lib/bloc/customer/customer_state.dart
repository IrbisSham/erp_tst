import 'package:equatable/equatable.dart';
import '../../models/customer.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String searchQuery;

  const CustomerLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [customers, filteredCustomers, searchQuery];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;

  const CustomerOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerDetailsLoaded extends CustomerState {
  final Customer customer;

  const CustomerDetailsLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerStatsLoaded extends CustomerState {
  final Map<String, dynamic> stats;

  const CustomerStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}
