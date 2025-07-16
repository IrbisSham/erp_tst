import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerBloc({required CustomerRepository customerRepository})
      : _customerRepository = customerRepository,
        super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<LoadCustomerById>(_onLoadCustomerById);
    on<LoadCustomerStats>(_onLoadCustomerStats);
    on<RefreshCustomers>(_onRefreshCustomers);
  }

  Future<void> _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await _customerRepository.getAllCustomers(
        includeDeleted: event.includeDeleted,
      );
      emit(CustomerLoaded(
        customers: customers,
        filteredCustomers: customers,
      ));
    } catch (e) {
      emit(CustomerError('Failed to load customers: $e'));
    }
  }

  Future<void> _onSearchCustomers(SearchCustomers event, Emitter<CustomerState> emit) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      
      if (event.query.isEmpty) {
        emit(CustomerLoaded(
          customers: currentState.customers,
          filteredCustomers: currentState.customers,
          searchQuery: event.query,
        ));
      } else {
        try {
          final searchResults = await _customerRepository.searchCustomers(event.query);
          emit(CustomerLoaded(
            customers: currentState.customers,
            filteredCustomers: searchResults,
            searchQuery: event.query,
          ));
        } catch (e) {
          emit(CustomerError('Search failed: $e'));
        }
      }
    }
  }

  Future<void> _onCreateCustomer(CreateCustomer event, Emitter<CustomerState> emit) async {
    try {
      await _customerRepository.createCustomer(event.customer);
      emit(const CustomerOperationSuccess('Customer created successfully'));
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError('Failed to create customer: $e'));
    }
  }

  Future<void> _onUpdateCustomer(UpdateCustomer event, Emitter<CustomerState> emit) async {
    try {
      await _customerRepository.updateCustomer(event.customer);
      emit(const CustomerOperationSuccess('Customer updated successfully'));
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError('Failed to update customer: $e'));
    }
  }

  Future<void> _onDeleteCustomer(DeleteCustomer event, Emitter<CustomerState> emit) async {
    try {
      await _customerRepository.deleteCustomer(event.customerId);
      emit(const CustomerOperationSuccess('Customer deleted successfully'));
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError('Failed to delete customer: $e'));
    }
  }

  Future<void> _onLoadCustomerById(LoadCustomerById event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customer = await _customerRepository.getCustomerById(event.customerId);
      if (customer != null) {
        emit(CustomerDetailsLoaded(customer));
      } else {
        emit(const CustomerError('Customer not found'));
      }
    } catch (e) {
      emit(CustomerError('Failed to load customer: $e'));
    }
  }

  Future<void> _onLoadCustomerStats(LoadCustomerStats event, Emitter<CustomerState> emit) async {
    try {
      final stats = await _customerRepository.getCustomerStats();
      emit(CustomerStatsLoaded(stats));
    } catch (e) {
      emit(CustomerError('Failed to load customer stats: $e'));
    }
  }

  Future<void> _onRefreshCustomers(RefreshCustomers event, Emitter<CustomerState> emit) async {
    add(const LoadCustomers());
  }
}
