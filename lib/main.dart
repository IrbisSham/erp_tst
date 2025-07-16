import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/edit_order_screen.dart';
import 'screens/edit_customer_screen.dart';
import 'screens/report_details_screen.dart';
import 'screens/bulk_operations_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'repositories/product_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/order_repository.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/customer/customer_bloc.dart';
import 'bloc/order/order_bloc.dart';
import 'bloc/notification/notification_bloc.dart';
import 'bloc/dashboard/dashboard_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Initialize services
  await ConnectivityService().initialize();
  SyncService().initialize();
  await NotificationService().initialize();
  
  runApp(const ERPApp());
}

class ERPApp extends StatelessWidget {
  const ERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepository(),
        ),
        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepository(),
        ),
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepository(),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => NotificationService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider<CustomerBloc>(
            create: (context) => CustomerBloc(
              customerRepository: context.read<CustomerRepository>(),
            ),
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(
              orderRepository: context.read<OrderRepository>(),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationService: context.read<NotificationService>(),
            ),
          ),
          BlocProvider<DashboardCubit>(
            create: (context) => DashboardCubit(
              productRepository: context.read<ProductRepository>(),
              customerRepository: context.read<CustomerRepository>(),
              orderRepository: context.read<OrderRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Mobile ERP',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/inventory': (context) => const InventoryScreen(),
            '/sales': (context) => const SalesScreen(),
            '/customers': (context) => const CustomersScreen(),
            '/reports': (context) => const ReportsScreen(),
            '/profile': (context) => const ProfileScreen(),
            // '/edit-product': (context) => const EditProductScreen(),
            '/edit-order': (context) => const EditOrderScreen(),
            '/edit-customer': (context) => const EditCustomerScreen(),
            '/report-details': (context) => const ReportDetailsScreen(reportType: 'General Report'),
            '/bulk-operations': (context) => const BulkOperationsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/notification-settings': (context) => const NotificationSettingsScreen(),
          },
        ),
      ),
    );
  }
}
