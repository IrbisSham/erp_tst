import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/main_drawer.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/offline_banner.dart';
import '../bloc/dashboard/dashboard_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.error != null) {
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
                          state.error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DashboardCubit>().loadDashboardData();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DashboardCubit>().refreshDashboard();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            DashboardCard(
                              title: 'Total Sales',
                              value: '\$${(state.dashboardData['totalSales'] ?? 0.0).toStringAsFixed(0)}',
                              icon: Icons.trending_up,
                              color: Colors.green,
                            ),
                            DashboardCard(
                              title: 'Orders',
                              value: '${state.dashboardData['totalOrders'] ?? 0}',
                              icon: Icons.shopping_cart,
                              color: Colors.blue,
                            ),
                            DashboardCard(
                              title: 'Customers',
                              value: '${state.dashboardData['totalCustomers'] ?? 0}',
                              icon: Icons.people,
                              color: Colors.orange,
                            ),
                            DashboardCard(
                              title: 'Products',
                              value: '${state.dashboardData['totalProducts'] ?? 0}',
                              icon: Icons.inventory,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Sales Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ChartWidget(),
                        const SizedBox(height: 24),
                        Text(
                          'Recent Activities',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              ListTile(
                                leading: Icon(Icons.add_shopping_cart, color: Colors.green),
                                title: Text('New order received'),
                                subtitle: Text('Order #1234 - \$450.00'),
                                trailing: Text('2 min ago'),
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.person_add, color: Colors.blue),
                                title: Text('New customer registered'),
                                subtitle: Text('John Doe'),
                                trailing: Text('15 min ago'),
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.inventory, color: Colors.orange),
                                title: Text('Low stock alert'),
                                subtitle: Text('Product ABC - 5 items left'),
                                trailing: Text('1 hour ago'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
