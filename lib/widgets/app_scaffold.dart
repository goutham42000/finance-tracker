import 'package:flutter/material.dart';
import 'footer_bar.dart';
import 'header_bar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showFooter;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Column(
        children: [
          HeaderBar(title: title, actions: actions),
          Expanded(child: body),
          if (showFooter) const TrademarkFooter(),
        ],
      ),
    );
  }
}
