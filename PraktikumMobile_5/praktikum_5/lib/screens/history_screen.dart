import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/session_service.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Semua';
  Future<List<TransactionModel>>? _future;

  @override
  void initState() {
    super.initState();

    _future = _loadTransactions();

    DatabaseService.instance.addListener(_onTransactionsChanged);
  }

  // Memuat ulang riwayat ketika transaksi berubah.
  void _onTransactionsChanged() {
    if (!mounted) return;
    _refresh();
  }

  Future<List<TransactionModel>> _loadTransactions() async {
    final userId = await SessionService.getUserId();

    if (userId == null) return [];

    return DatabaseService.instance.getTransactions(userId);
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    final future = _loadTransactions();

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
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _filter,
              decoration: const InputDecoration(
                labelText: 'Filter transaksi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Semua',
                  child: Text('Semua Transaksi'),
                ),
                DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(
                  value: 'Pengeluaran',
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filter = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat riwayat: ${snapshot.error}'),
                  );
                }

                final all = snapshot.data ?? [];

                final filtered = _filter == 'Semua'
                    ? all
                    : all.where((transaction) {
                        return transaction.type == _filter;
                      }).toList();

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.history, size: 54, color: Colors.blue),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Belum ada transaksi untuk ditampilkan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final transaction = filtered[index];

                      return TransactionTile(
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
                      );
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
}
