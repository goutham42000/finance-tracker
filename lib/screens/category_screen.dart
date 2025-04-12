import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final User user;
  const CategoryScreen({super.key, required this.user});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final categoryController = TextEditingController();

  Future<void> _addCategory() async {
    final text = categoryController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('categories')
        .add({'name': text});

    categoryController.clear();
    setState(() {}); // refresh
  }

  Stream<QuerySnapshot> _getCategoryStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('categories')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "New Category"),
            ),
            ElevatedButton(
              onPressed: _addCategory,
              child: const Text("Add Category"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCategoryStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final category = docs[index]['name'];
                      return ListTile(
                        title: Text(category),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
