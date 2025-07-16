import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'edit_order_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-001',
      'customer': 'John Doe',
      'date': '2024-01-15',
      'amount': 1299.99,
      'status': 'Completed',
      'items': 3,
    },
    {
      'id': 'ORD-002',
      'customer': 'Jane Smith',
      'date': '2024-01-14',
      'amount': 599.50,
      'status': 'Processing',
      'items': 2,
    },
    {
      'id': 'ORD-003',
      'customer': 'Bob Johnson',
      'date': '2024-01-13',
      'amount': 299.99,
      'status': 'Shipped',
      'items': 1,
    },
    {
      'id': 'ORD-004',
      'customer': 'Alice Brown',
      'date': '2024-01-12',
      'amount': 899.99,
      'status': 'Pending',
      'items': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Orders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOrderDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.attach_money, size: 32, color: Colors.green),
                          const SizedBox(height: 8),
                          const Text('Total Sales'),
                          Text(
                            '\$125,430',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_cart, size: 32, color: Colors.blue),
                          const SizedBox(height: 8),
                          const Text('Total Orders'),
                          Text(
                            '1,234',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order['status']),
                      child: Text(
                        order['items'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'Order ${order['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${order['customer']}'),
                        Text('Date: ${order['date']}'),
                        Text(
                          'Amount: \$${order['amount'].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        order['status'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _getStatusColor(order['status']).withOpacity(0.2),
                    ),
                    onTap: () {
                      _showOrderDetails(context, order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.orange;
      case 'Pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderScreen(order: order),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the orders list
        setState(() {
          // In a real app, you would reload data from the API
        });
      } else if (result == 'deleted') {
        // Remove the order from the list
        setState(() {
          _orders.removeWhere((o) => o['id'] == order['id']);
        });
      }
    });
  }

  void _showCreateOrderDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditOrderScreen(),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the orders list
        setState(() {
          // In a real app, you would reload data from the API
        });
      }
    });
  }
}
