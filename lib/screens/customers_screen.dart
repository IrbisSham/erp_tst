import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/main_drawer.dart';
import '../widgets/offline_banner.dart';
import '../bloc/customer/customer_bloc.dart';
import '../bloc/customer/customer_event.dart';
import '../bloc/customer/customer_state.dart';
import '../models/customer.dart';
import 'edit_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export_csv':
                  _exportCustomers('csv');
                  break;
                case 'export_excel':
                  _exportCustomers('excel');
                  break;
                case 'import':
                  _importCustomers();
                  break;
                case 'bulk_ops':
                  Navigator.pushNamed(context, '/bulk-operations');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_excel',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_ops',
                child: Row(
                  children: [
                    Icon(Icons.import_export),
                    SizedBox(width: 8),
                    Text('Bulk Operations'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomerDialog(context);
        },
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context.read<CustomerBloc>().add(SearchCustomers(query));
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<CustomerBloc, CustomerState>(
              listener: (context, state) {
                if (state is CustomerError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is CustomerOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomerLoaded) {
                  final customers = state.filteredCustomers;
                  
                  if (customers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No customers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CustomerBloc>().add(RefreshCustomers());
                    },
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: customer.status == 'Active' 
                                  ? Colors.green 
                                  : Colors.grey,
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    customer.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (!customer.isSynced)
                                  const Icon(
                                    Icons.sync_disabled,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.email),
                                Text(customer.company ?? 'No company'),
                                Text('Orders: ${customer.totalOrders} | Spent: \$${customer.totalSpent.toStringAsFixed(2)}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                customer.status,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: customer.status == 'Active' 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                            onTap: () {
                              _showCustomerDetails(context, customer);
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is CustomerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CustomerBloc>().add(const LoadCustomers());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(customer: customer.toMap()),
      ),
    ).then((result) {
      if (result == true || result == 'deleted') {
        context.read<CustomerBloc>().add(const LoadCustomers());
      }
    });
  }

  void _showAddCustomerDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditCustomerScreen(),
      ),
    ).then((result) {
      if (result == true) {
        context.read<CustomerBloc>().add(const LoadCustomers());
      }
    });
  }

  Future<void> _exportCustomers(String format) async {
    // TODO: Implement export functionality
    print('Exporting customers to $format');
  }

  Future<void> _importCustomers() async {
    // TODO: Implement import functionality
    print('Importing customers');
  }
}
