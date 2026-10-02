import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_state.dart';
import '../services/firestore_service.dart';

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
  bool _isSaving = false;

  Future<void> _calculate() async {
    double parse(TextEditingController c) => double.tryParse(c.text) ?? 0;
    final seedVal = parse(_seeds);
    final fertVal = parse(_fertilizer);
    final laborVal = parse(_labor);
    final irrigVal = parse(_irrigation);
    final otherVal = parse(_other);
    final revVal = parse(_revenue);

    final expense = seedVal + fertVal + laborVal + irrigVal + otherVal;
    final profit = revVal - expense;

    setState(() {
      _totalExpense = expense;
      _profit = profit;
      _calculated = true;
      _isSaving = true;
    });

    try {
      await FirestoreService().saveExpenseCalculation(
        seeds: seedVal,
        fertilizer: fertVal,
        labor: laborVal,
        irrigation: irrigVal,
        other: otherVal,
        totalExpense: expense,
        revenue: revVal,
        netProfit: profit,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calculation saved to Firebase Firestore!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Firestore save error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                  onPressed: _isSaving ? null : _calculate,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(app.t('calculate'),
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
              const SizedBox(height: 24),
              const Text(
                'History in Firestore',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirestoreService().getExpensesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No previous calculations saved in Firestore.',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data();
                      final totalExp = (data['totalExpense'] as num?)?.toDouble() ?? 0.0;
                      final netProf = (data['netProfit'] as num?)?.toDouble() ?? 0.0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('Expense: ₹${totalExp.toStringAsFixed(0)} | Profit: ₹${netProf.toStringAsFixed(0)}'),
                          subtitle: Text('Revenue: ₹${((data['revenue'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}'),
                          trailing: Icon(
                            netProf >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: netProf >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
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
