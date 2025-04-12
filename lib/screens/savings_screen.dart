import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import '../widgets/app_scaffold.dart';

class SavingsScreen extends StatelessWidget {
  final User user;
  const SavingsScreen({super.key, required this.user});

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _exportCSV(BuildContext context) async {
    try {
      final transactions = await _fetchTransactions();

      final rows = <List<dynamic>>[
        ["Date", "Paid By", "Paid To", "Category", "Price (€)", "Comment"]
      ];

      for (var tx in transactions) {
        rows.add([
          tx['date'] ?? '',
          tx['paidBy'] ?? '',
          tx['paidTo'] ?? '',
          tx['category'] ?? '',
          tx['price']?.toStringAsFixed(2) ?? '0.00',
          tx['comment'] ?? '',
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "savings_export.csv")
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CSV download started")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to export CSV: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Savings Breakdown",
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Export CSV',
          onPressed: () => _exportCSV(context),
        ),
      ],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                      Expanded(flex: 3, child: Text("Comment", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
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
                            Expanded(flex: 3, child: Text(tx['comment'] ?? '')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
