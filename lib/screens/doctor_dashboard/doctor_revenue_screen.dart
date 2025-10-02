import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:healup/models/revenue_model.dart';
import 'package:healup/services/utility_service.dart';

class DoctorRevenueScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorRevenueScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorRevenueScreen> createState() => _DoctorRevenueScreenState();
}

class _DoctorRevenueScreenState extends State<DoctorRevenueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Revenue> _revenues = [];
  bool _isLoading = true;

  // Summary data
  double _totalEarnings = 0.0;
  double _monthlyEarnings = 0.0;
  double _weeklyEarnings = 0.0;
  int _totalTransactions = 0;
  int _pendingTransactions = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRevenueData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRevenueData() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('revenues')
          .where('doctorId', isEqualTo: widget.doctor.id)
          .orderBy('paymentDate', descending: true)
          .get();

      final revenues = querySnapshot.docs
          .map((doc) => Revenue.fromMap(doc.data(), doc.id))
          .toList();

      _calculateSummary(revenues);

      setState(() {
        _revenues = revenues;
      });
    } catch (e) {
      print('Error loading revenue data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateSummary(List<Revenue> revenues) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    _totalEarnings = revenues
        .where((r) => r.status == PaymentStatus.completed)
        .fold(0.0, (sum, r) => sum + r.doctorEarnings);

    _monthlyEarnings = revenues
        .where(
          (r) =>
              r.status == PaymentStatus.completed &&
              r.paymentDate.isAfter(startOfMonth),
        )
        .fold(0.0, (sum, r) => sum + r.doctorEarnings);

    _weeklyEarnings = revenues
        .where(
          (r) =>
              r.status == PaymentStatus.completed &&
              r.paymentDate.isAfter(startOfWeek),
        )
        .fold(0.0, (sum, r) => sum + r.doctorEarnings);

    _totalTransactions = revenues.length;
    _pendingTransactions = revenues
        .where((r) => r.status == PaymentStatus.pending)
        .length;
  }

  List<Revenue> _getFilteredRevenues(PaymentStatus? status) {
    if (status == null) return _revenues;
    return _revenues.where((revenue) => revenue.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Revenue Dashboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTransactionsTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(),
          const SizedBox(height: 24),
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),
          // Recent Transactions
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Earnings',
                UtilityService.formatCurrency(_totalEarnings),
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'This Month',
                UtilityService.formatCurrency(_monthlyEarnings),
                Icons.calendar_month,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'This Week',
                UtilityService.formatCurrency(_weeklyEarnings),
                Icons.date_range,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Transactions',
                _totalTransactions.toString(),
                Icons.receipt_long,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final completedTransactions = _revenues
        .where((r) => r.status == PaymentStatus.completed)
        .length;
    final avgTransactionAmount = completedTransactions > 0
        ? _totalEarnings / completedTransactions
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  completedTransactions.toString(),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pending',
                  _pendingTransactions.toString(),
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Average',
                  UtilityService.formatCurrency(avgTransactionAmount),
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _revenues.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: recentTransactions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: recentTransactions.map((revenue) {
                    final isLast = recentTransactions.last == revenue;
                    return Column(
                      children: [
                        _buildTransactionItem(revenue),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Filter Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: TabController(length: 4, vsync: this),
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Pending'),
              Tab(text: 'Failed'),
            ],
          ),
        ),
        Expanded(
          child: _revenues.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRevenueData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _revenues.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(_revenues[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Revenue revenue) {
    Color statusColor = _getStatusColor(revenue.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        revenue.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transaction ID: ${revenue.transactionId ?? 'N/A'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      UtilityService.formatCurrency(revenue.doctorEarnings),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        revenue.status.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  UtilityService.formatDate(revenue.paymentDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  revenue.method.toString().split('.').last.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total: ${UtilityService.formatCurrency(revenue.amount)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  'Platform Fee: ${UtilityService.formatCurrency(revenue.platformFee)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Revenue revenue) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getStatusColor(revenue.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.attach_money,
          color: _getStatusColor(revenue.status),
          size: 20,
        ),
      ),
      title: Text(
        revenue.patientName,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        UtilityService.formatDate(revenue.paymentDate),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Text(
        UtilityService.formatCurrency(revenue.doctorEarnings),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(revenue.status),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthlyChart(),
          const SizedBox(height: 24),
          _buildPaymentMethodChart(),
          const SizedBox(height: 24),
          _buildInsights(),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Revenue Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for chart - you can integrate a charting library here
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Chart will be displayed here\n(Integration with charts_flutter or fl_chart)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChart() {
    final methodCounts = <PaymentMethod, int>{};
    for (var revenue in _revenues) {
      methodCounts[revenue.method] = (methodCounts[revenue.method] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...methodCounts.entries.map((entry) {
            final percentage = _revenues.isNotEmpty
                ? (entry.value / _revenues.length * 100).toStringAsFixed(1)
                : '0.0';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPaymentMethodColor(entry.key),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '$percentage% (${entry.value})',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    final avgDailyEarnings = _totalEarnings / 30; // Rough estimate
    final topEarningDay = _revenues.isNotEmpty
        ? _revenues
              .where((r) => r.status == PaymentStatus.completed)
              .fold<Revenue?>(
                null,
                (prev, curr) =>
                    prev == null || curr.doctorEarnings > prev.doctorEarnings
                    ? curr
                    : prev,
              )
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            'Average Daily Earnings',
            UtilityService.formatCurrency(avgDailyEarnings),
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          if (topEarningDay != null)
            _buildInsightItem(
              'Highest Single Transaction',
              UtilityService.formatCurrency(topEarningDay.doctorEarnings),
              Icons.star,
              Colors.amber,
            ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Success Rate',
            '${((_revenues.where((r) => r.status == PaymentStatus.completed).length / (_revenues.isNotEmpty ? _revenues.length : 1)) * 100).toStringAsFixed(1)}%',
            Icons.check_circle,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.bank_transfer:
        return Colors.green;
      case PaymentMethod.wallet:
        return Colors.purple;
      case PaymentMethod.cash:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
