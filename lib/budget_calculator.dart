import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BudgetCalculator extends StatefulWidget {
  const BudgetCalculator({super.key});

  @override
  _BudgetCalculatorState createState() => _BudgetCalculatorState();
}

class _BudgetCalculatorState extends State<BudgetCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  double _income = 0;
  double _needs = 0;
  double _wants = 0;
  double _savings = 0;
  bool _isLoading = false;

  final _firestore = FirebaseFirestore.instance;
  final _formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  void _calculateBudget() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _income = double.parse(_incomeController.text);
        _needs = _income * 0.5;
        _wants = _income * 0.3;
        _savings = _income * 0.2;
      });
    }
  }

  Future<void> _saveToFirebase() async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('budgets').add({
        'income': _income,
        'needs': _needs,
        'wants': _wants,
        'savings': _savings,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
    setState(() => _isLoading = false);
  }

  Widget _buildCategoryCard(String title, double amount, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.circle, color: color, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              _formatter.format(amount),
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly After-Tax Income',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateBudget,
                child: const Text('Calculate Budget'),
              ),
              const SizedBox(height: 30),
              if (_income > 0) ...[
                _buildCategoryCard('Needs (50%)', _needs, Colors.teal),
                const SizedBox(height: 15),
                _buildCategoryCard('Wants (30%)', _wants, Colors.orange[300]!),
                const SizedBox(height: 15),
                _buildCategoryCard(
                  'Savings (20%)',
                  _savings,
                  Colors.green[300]!,
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save to Cloud'),
                      onPressed: _saveToFirebase,
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
