import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  String _formatRupiah(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  IconData _categoryIcon() {
    switch (transaction.category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Hiburan':
        return Icons.movie;
      case 'Gaji':
        return Icons.work;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.receipt_long;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? Colors.green : Colors.red;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withValues(alpha: 0.10),
            child: Icon(
              _categoryIcon(),
              color: Colors.blue,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${transaction.category} • ${_formatDate(transaction.date)}',
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'} ${_formatRupiah(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}