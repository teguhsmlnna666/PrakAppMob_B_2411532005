import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<_DashboardData>? _future;

  @override
  void initState() {
    super.initState();

    _future = _loadData();

    DatabaseService.instance.addListener(_onTransactionsChanged);
  }

  void _onTransactionsChanged() {
    if (!mounted) return;
    _refresh();
  }

  Future<_DashboardData> _loadData() async {
    final userId = await SessionService.getUserId();
    final name = await SessionService.getUserName();

    if (userId == null) {
      return _DashboardData(
        name: name,
        balance: 0,
        income: 0,
        expense: 0,
        transactions: [],
      );
    }

    final summary = await DatabaseService.instance.getBalanceSummary(userId);

    final transactions = await DatabaseService.instance.getTransactions(userId);

    return _DashboardData(
      name: name,
      balance: summary['balance'] ?? 0,
      income: summary['income'] ?? 0,
      expense: summary['expense'] ?? 0,
      transactions: transactions,
    );
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    final future = _loadData();

    setState(() {
      _future = future;
    });

    await future;
  }

  @override
  void dispose() {
    DatabaseService.instance.removeListener(_onTransactionsChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final data =
              snapshot.data ??
              _DashboardData(
                name: 'Pengguna',
                balance: 0,
                income: 0,
                expense: 0,
                transactions: [],
              );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${data.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Selamat datang kembali!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                BalanceCardWidget(
                  balance: data.balance,
                  income: data.income,
                  expense: data.expense,
                ),

                const SizedBox(height: 24),
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.arrow_downward,
                        label: 'Pemasukan',
                        color: Colors.green,
                        onTap: () => _openAdd(context, 'Pemasukan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.arrow_upward,
                        label: 'Pengeluaran',
                        color: Colors.red,
                        onTap: () => _openAdd(context, 'Pengeluaran'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Transaksi Terakhir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );

                        if (mounted) {
                          _refresh();
                        }
                      },
                      child: const Text('Lihat semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (data.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada transaksi.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Tekan tombol + untuk menambahkan transaksi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...data.transactions
                      .take(5)
                      .map(
                        (transaction) => TransactionTile(
                          transaction: transaction,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailScreen(
                                  transaction: transaction,
                                ),
                              ),
                            );

                            if (mounted) {
                              _refresh();
                            }
                          },
                        ),
                      ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAdd(BuildContext context, String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialType: type),
      ),
    );

    if (mounted) {
      _refresh();
    }
  }
}

class _DashboardData {
  final String name;
  final int balance;
  final int income;
  final int expense;
  final List<TransactionModel> transactions;

  const _DashboardData({
    required this.name,
    required this.balance,
    required this.income,
    required this.expense,
    required this.transactions,
  });
}