import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget_Buddy',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.light(
          primary: Colors.indigo,
          secondary: Colors.teal,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.rubikTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// Authentication Screen
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogin = true;
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Check user auth state once when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BudgetCalculator()),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BudgetCalculator()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage =
            e.toString().contains('firebase_auth')
                ? 'Authentication failed. Please check your credentials.'
                : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  isLogin ? 'Welcome Back' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin
                      ? 'Sign in to access your budget calculator'
                      : 'Sign up to start managing your budget',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  obscureText: true,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _authenticate,
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(isLogin ? 'Sign In' : 'Sign Up'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Sign In',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Budget Calculator Screen
class BudgetCalculator extends StatefulWidget {
  const BudgetCalculator({super.key});

  @override
  _BudgetCalculatorState createState() => _BudgetCalculatorState();
}

class _BudgetCalculatorState extends State<BudgetCalculator> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _incomeController = TextEditingController();
  bool isLoading = true;
  double income = 0;
  double needsAmount = 0;
  double wantsAmount = 0;
  double savingsAmount = 0;
  List<BudgetEntry> entries = [];

  // Categories for budget entries
  final Map<String, BudgetCategory> categories = {
    'Housing': BudgetCategory('Housing', Icons.home, BudgetType.needs),
    'Utilities': BudgetCategory('Utilities', Icons.power, BudgetType.needs),
    'Groceries': BudgetCategory(
      'Groceries',
      Icons.shopping_basket,
      BudgetType.needs,
    ),
    'Transportation': BudgetCategory(
      'Transportation',
      Icons.directions_car,
      BudgetType.needs,
    ),
    'Healthcare': BudgetCategory(
      'Healthcare',
      Icons.local_hospital,
      BudgetType.needs,
    ),
    'Dining Out': BudgetCategory(
      'Dining Out',
      Icons.restaurant,
      BudgetType.wants,
    ),
    'Entertainment': BudgetCategory(
      'Entertainment',
      Icons.movie,
      BudgetType.wants,
    ),
    'Shopping': BudgetCategory(
      'Shopping',
      Icons.shopping_bag,
      BudgetType.wants,
    ),
    'Subscriptions': BudgetCategory(
      'Subscriptions',
      Icons.subscriptions,
      BudgetType.wants,
    ),
    'Travel': BudgetCategory('Travel', Icons.flight, BudgetType.wants),
    'Savings': BudgetCategory('Savings', Icons.savings, BudgetType.savings),
    'Investments': BudgetCategory(
      'Investments',
      Icons.trending_up,
      BudgetType.savings,
    ),
    'Debt Repayment': BudgetCategory(
      'Debt Repayment',
      Icons.money_off,
      BudgetType.savings,
    ),
    'Other': BudgetCategory('Other', Icons.category, BudgetType.needs),
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        // If no user is found, redirect to auth screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        }
        return;
      }

      // Get user income
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          income = (userDoc.data()?['income'] ?? 0).toDouble();
          _calculateBudget();
        });
        _incomeController.text = income.toString();
      }

      // Get budget entries
      final entriesSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('entries')
              .orderBy('date', descending: true)
              .get();

      final loadedEntries =
          entriesSnapshot.docs.map((doc) {
            final data = doc.data();
            return BudgetEntry(
              id: doc.id,
              category: categories[data['category']] ?? categories['Other']!,
              amount: (data['amount'] ?? 0).toDouble(),
              description: data['description'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
            );
          }).toList();

      setState(() {
        entries = loadedEntries;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateBudget() {
    setState(() {
      needsAmount = income * 0.5;
      wantsAmount = income * 0.3;
      savingsAmount = income * 0.2;
    });
  }

  Future<void> _saveIncome() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      final newIncome = double.tryParse(_incomeController.text) ?? 0;

      await _firestore.collection('users').doc(userId).set({
        'income': newIncome,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        income = newIncome;
        _calculateBudget();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _addEntry(BudgetEntry entry) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('entries')
          .add({
            'category': entry.category.name,
            'amount': entry.amount,
            'description': entry.description,
            'date': Timestamp.fromDate(entry.date),
            'type': entry.category.type.toString().split('.').last,
          });

      final newEntry = entry.copyWith(id: docRef.id);

      setState(() {
        entries.insert(0, newEntry);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _deleteEntry(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('entries')
          .doc(id)
          .delete();

      setState(() {
        entries.removeWhere((entry) => entry.id == id);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _showAddEntryDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    BudgetCategory selectedCategory = categories['Housing']!;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<BudgetCategory>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: selectedCategory,
                      items:
                          categories.values.map((category) {
                            return DropdownMenuItem<BudgetCategory>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(category.icon, size: 20),
                                  const SizedBox(width: 8),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount'),
                        ),
                      );
                      return;
                    }
                    final entry = BudgetEntry(
                      id: '',
                      category: selectedCategory,
                      amount: amount,
                      description: descriptionController.text,
                      date: DateTime.now(),
                    );
                    _addEntry(entry);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false, // This removes all previous routes from the stack
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Widget _buildBudgetSummary() {
    // Calculate spent amounts by category
    double spentNeeds = entries
        .where((entry) => entry.category.type == BudgetType.needs)
        .fold(0, (sum, entry) => sum + entry.amount);

    double spentWants = entries
        .where((entry) => entry.category.type == BudgetType.wants)
        .fold(0, (sum, entry) => sum + entry.amount);

    double spentSavings = entries
        .where((entry) => entry.category.type == BudgetType.savings)
        .fold(0, (sum, entry) => sum + entry.amount);

    // Format currency
    final formatter = NumberFormat.currency(symbol: '₹');

    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monthly Income',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      formatter.format(income),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Update Income'),
                          content: TextField(
                            controller: _incomeController,
                            decoration: const InputDecoration(
                              labelText: 'Monthly Income',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('CANCEL'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _saveIncome();
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('UPDATE'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Update Income'),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCategoryBar(
                  'Needs (50%)',
                  needsAmount,
                  spentNeeds,
                  Colors.indigo,
                ),
                const SizedBox(height: 16),
                _buildCategoryBar(
                  'Wants (30%)',
                  wantsAmount,
                  spentWants,
                  Colors.teal,
                ),
                const SizedBox(height: 16),
                _buildCategoryBar(
                  'Savings (20%)',
                  savingsAmount,
                  spentSavings,
                  Colors.amber[700]!,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar(
    String title,
    double total,
    double spent,
    Color color,
  ) {
    final percentage = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final formatter = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              '${formatter.format(spent)} / ${formatter.format(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          color: percentage >= 0.9 ? Colors.red : color,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No transactions yet.\nTap the + button to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final formatter = NumberFormat.currency(symbol: '₹');

        Color typeColor;
        switch (entry.category.type) {
          case BudgetType.needs:
            typeColor = Colors.indigo;
            break;
          case BudgetType.wants:
            typeColor = Colors.teal;
            break;
          case BudgetType.savings:
            typeColor = Colors.amber[700]!;
            break;
        }

        return Dismissible(
          key: Key(entry.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text(
                      'Are you sure you want to delete this entry?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (direction) => _deleteEntry(entry.id),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: typeColor.withOpacity(0.2),
                child: Icon(entry.category.icon, color: typeColor, size: 20),
              ),
              title: Text(entry.category.name),
              subtitle: Text(
                entry.description.isNotEmpty
                    ? entry.description
                    : DateFormat('MMM dd, yyyy').format(entry.date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                formatter.format(entry.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget_Buddy :)'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBudgetSummary(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Filter'),
                            onPressed: () {
                              // Implement filtering functionality
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTransactionsList(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Data Classes
enum BudgetType { needs, wants, savings }

class BudgetCategory {
  final String name;
  final IconData icon;
  final BudgetType type;

  BudgetCategory(this.name, this.icon, this.type);
}

class BudgetEntry {
  final String id;
  final BudgetCategory category;
  final double amount;
  final String description;
  final DateTime date;

  BudgetEntry({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  BudgetEntry copyWith({
    String? id,
    BudgetCategory? category,
    double? amount,
    String? description,
    DateTime? date,
  }) {
    return BudgetEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
