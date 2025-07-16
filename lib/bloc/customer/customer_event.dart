import 'package:equatable/equatable.dart';
import '../../models/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final bool includeDeleted;

  const LoadCustomers({this.includeDeleted = false});

  @override
  List<Object?> get props => [includeDeleted];
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateCustomer extends CustomerEvent {
  final Customer customer;

  const CreateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadCustomerById extends CustomerEvent {
  final String customerId;

  const LoadCustomerById(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadCustomerStats extends CustomerEvent {}

class RefreshCustomers extends CustomerEvent {}
