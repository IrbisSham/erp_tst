import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import 'report_details_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildReportCard(
              context,
              'Sales Report',
              Icons.trending_up,
              Colors.green,
              () => _showReport(context, 'Sales Report'),
            ),
            _buildReportCard(
              context,
              'Inventory Report',
              Icons.inventory,
              Colors.blue,
              () => _showReport(context, 'Inventory Report'),
            ),
            _buildReportCard(
              context,
              'Customer Report',
              Icons.people,
              Colors.orange,
              () => _showReport(context, 'Customer Report'),
            ),
            _buildReportCard(
              context,
              'Financial Report',
              Icons.account_balance,
              Colors.purple,
              () => _showReport(context, 'Financial Report'),
            ),
            _buildReportCard(
              context,
              'Product Performance',
              Icons.bar_chart,
              Colors.teal,
              () => _showReport(context, 'Product Performance'),
            ),
            _buildReportCard(
              context,
              'Monthly Summary',
              Icons.calendar_month,
              Colors.indigo,
              () => _showReport(context, 'Monthly Summary'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReport(BuildContext context, String reportType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsScreen(reportType: reportType),
      ),
    );
  }
}
