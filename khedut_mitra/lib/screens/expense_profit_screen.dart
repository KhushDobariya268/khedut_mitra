import 'package:flutter/material.dart';
import '../data/app_state.dart';

class ExpenseProfitScreen extends StatefulWidget {
  const ExpenseProfitScreen({super.key});

  @override
  State<ExpenseProfitScreen> createState() => _ExpenseProfitScreenState();
}

class _ExpenseProfitScreenState extends State<ExpenseProfitScreen> {
  final _seeds = TextEditingController();
  final _fertilizer = TextEditingController();
  final _labor = TextEditingController();
  final _irrigation = TextEditingController();
  final _other = TextEditingController();
  final _revenue = TextEditingController();

  double _totalExpense = 0;
  double _profit = 0;
  bool _calculated = false;

  void _calculate() {
    double parse(TextEditingController c) => double.tryParse(c.text) ?? 0;
    final expense = parse(_seeds) +
        parse(_fertilizer) +
        parse(_labor) +
        parse(_irrigation) +
        parse(_other);
    final revenue = parse(_revenue);
    setState(() {
      _totalExpense = expense;
      _profit = revenue - expense;
      _calculated = true;
    });
  }

  @override
  void dispose() {
    _seeds.dispose();
    _fertilizer.dispose();
    _labor.dispose();
    _irrigation.dispose();
    _other.dispose();
    _revenue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(app.t('expenseProfit'))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(app.t('totalExpense'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _amountField(app.t('seeds'), _seeds),
              _amountField(app.t('fertilizer'), _fertilizer),
              _amountField(app.t('labor'), _labor),
              _amountField(app.t('irrigation'), _irrigation),
              _amountField(app.t('otherExpense'), _other),
              const SizedBox(height: 16),
              Text(app.t('totalRevenue'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _amountField(app.t('revenue'), _revenue),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _calculate,
                  child: Text(app.t('calculate'),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              if (_calculated) ...[
                const SizedBox(height: 20),
                Card(
                  color: _profit >= 0
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(app.t('totalExpense')),
                            Text('₹${_totalExpense.toStringAsFixed(0)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app.t('netProfit'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${_profit.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _profit >= 0
                                    ? const Color(0xFF2E7D32)
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _amountField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}