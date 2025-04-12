import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  final User user;
  const AccountScreen({super.key, required this.user});

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Account")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(child: Text("Failed to load profile"));
          }

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text("${data['firstName']} ${data['lastName']}"),
                subtitle: const Text("Name"),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(data['email'] ?? user.email ?? ''),
                subtitle: const Text("Email"),
              ),
              ListTile(
                leading: const Icon(Icons.cake),
                title: Text(data['dob'] ?? 'N/A'),
                subtitle: const Text("Date of Birth"),
              ),
              ListTile(
                leading: const Icon(Icons.perm_identity),
                title: Text(user.uid),
                subtitle: const Text("User ID"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
