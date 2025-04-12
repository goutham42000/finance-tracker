import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account_screen.dart';
import 'savings_screen.dart';
import 'login_screen.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _paidByController = TextEditingController();
  final _paidToController = TextEditingController();
  final _commentController = TextEditingController();

  void _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = {
      'date': _dateController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'category': _categoryController.text.trim(),
      'paidBy': _paidByController.text.trim(),
      'paidTo': _paidToController.text.trim(),
      'comment': _commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('transactions')
          .add(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction saved")),
      );

      _formKey.currentState!.reset();
      _dateController.clear();
      _priceController.clear();
      _categoryController.clear();
      _paidByController.clear();
      _paidToController.clear();
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    }
  }

  Stream<QuerySnapshot> _getTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Finance Tracker",
      actions: [
        IconButton(
          icon: const Icon(Icons.savings),
          tooltip: "View Savings",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SavingsScreen(user: widget.user),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: "My Account",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountScreen(user: widget.user),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _dateController.text = picked.toIso8601String().split("T").first;
                    }
                  },
                  validator: (val) => val!.isEmpty ? 'Enter date' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (€)',
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Enter price' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (val) => val!.isEmpty ? 'Enter category' : null,
                ),
                TextFormField(
                  controller: _paidByController,
                  decoration: const InputDecoration(labelText: 'Paid By'),
                  validator: (val) => val!.isEmpty ? 'Enter payer' : null,
                ),
                TextFormField(
                  controller: _paidToController,
                  decoration: const InputDecoration(labelText: 'Paid To'),
                  validator: (val) => val!.isEmpty ? 'Enter payee' : null,
                ),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Comment'),
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTransaction,
                  child: const Text("Add Transaction"),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              color: Colors.blue.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("Paid By", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("Paid To", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text("€", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getTransactionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No transactions found."));
                  }

                  final transactions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index].data() as Map<String, dynamic>;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(tx['date'] ?? '')),
                            Expanded(flex: 2, child: Text(tx['paidBy'] ?? '')),
                            Expanded(flex: 2, child: Text(tx['paidTo'] ?? '')),
                            Expanded(flex: 2, child: Text(tx['category'] ?? '')),
                            Expanded(flex: 1, child: Text("€${(tx['price'] ?? 0).toStringAsFixed(2)}")),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
