import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../transactions/add_transaction_screen.dart';
import '../../services/notification_service.dart';
import 'package:flutter/foundation.dart';
import '../transactions/contacts_screen.dart';
import '../../services/theme_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.yellow
                  : const Color(0xFF1E3A8A),
            ),
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              final isCurrentlyDark =
                  Theme.of(context).brightness == Brightness.dark;
              themeProvider.toggleTheme(!isCurrentlyDark);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.people_alt_outlined,
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () async {
              if (!kIsWeb) {
                await NotificationService().showTestNotification();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Push notifications are for mobile only!'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: DatabaseService().getUserTransactions(
          context.read<AuthService>().getCurrentUser()!.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          double totalEarned = 0;
          double totalPaid = 0;

          for (var tx in transactions) {
            double interestForOneMonth =
                (tx.amount * tx.interestRate * 1) / 100;
            if (tx.type == 'Given') {
              totalEarned += interestForOneMonth;
            } else if (tx.type == 'Taken') {
              totalPaid += interestForOneMonth;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Est. Monthly Earned',
                        amount: '₹${totalEarned.toStringAsFixed(2)}',
                        color: Colors.green.shade700,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Est. Monthly Paid',
                        amount: '₹${totalPaid.toStringAsFixed(2)}',
                        color: Colors.red.shade700,
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  'Monthly Flow',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildMonthlyFlowChart(transactions),

                const SizedBox(height: 32),

                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                transactions.isEmpty
                    ? const Center(
                        child: Text(
                          "No transactions yet. Click '+' to add one!",
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUrgentAlert(transactions),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length > 5
                                ? 5
                                : transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return Card(
                                color: Theme.of(context).cardColor,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: tx.type == 'Given'
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    child: Icon(
                                      tx.type == 'Given'
                                          ? Icons.arrow_outward
                                          : Icons.call_received,
                                      color: tx.type == 'Given'
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                  title: Text(
                                    "Principal: ₹${tx.amount}",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${tx.interestRate}% Interest",
                                  ),
                                  trailing: Text(
                                    tx.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tx.type == 'Given'
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Loan', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildUrgentAlert(List<TransactionModel> transactions) {
    final now = DateTime.now();

    final urgentLoans = transactions.where((t) {
      final daysLeft = t.dueDate?.difference(now).inDays ?? -1;
      return daysLeft >= 0 && daysLeft <= 3;
    }).toList();

    if (urgentLoans.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Priority Action",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  "${urgentLoans.length} loan(s) are reaching their due date!",
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyFlowChart(List<TransactionModel> transactions) {
    double totalGiven = 0;
    double totalTaken = 0;

    for (var tx in transactions) {
      if (tx.type == 'Given') totalGiven += tx.amount;
      if (tx.type == 'Taken') totalTaken += tx.amount;
    }

    double maxY = (totalGiven > totalTaken ? totalGiven : totalTaken) * 1.2;
    if (maxY == 0) maxY = 10000;

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value == 0 ? 'Given (Lent)' : 'Taken (Borrowed)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalGiven,
                  color: Colors.green.shade500,
                  width: 45,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: totalTaken,
                  color: Colors.red.shade500,
                  width: 45,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
