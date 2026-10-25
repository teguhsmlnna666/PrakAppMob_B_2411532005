import 'package:flutter/material.dart';

class BalanceCardWidget extends StatefulWidget {
  final int balance;
  final int income;
  final int expense;

  const BalanceCardWidget({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  State<BalanceCardWidget> createState() =>
      _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceVisible = true;

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

    final prefix = value < 0 ? '-Rp ' : 'Rp ';
    return '$prefix${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Saldo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                tooltip: _isBalanceVisible
                    ? 'Sembunyikan saldo'
                    : 'Tampilkan saldo',
                onPressed: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isBalanceVisible
                ? _formatRupiah(widget.balance)
                : 'Rp •••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  icon: Icons.arrow_downward,
                  label: 'Pemasukan',
                  amount: widget.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryItem(
                  icon: Icons.arrow_upward,
                  label: 'Pengeluaran',
                  amount: widget.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required int amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _isBalanceVisible
                    ? _formatRupiah(amount)
                    : '••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}