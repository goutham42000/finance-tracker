import 'package:flutter/material.dart';

class TrademarkFooter extends StatelessWidget {
  const TrademarkFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "© 2025 Finance Tracker™ • All rights reserved",
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
