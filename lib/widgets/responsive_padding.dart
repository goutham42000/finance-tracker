class ResponsivePadding extends StatelessWidget {
  final Widget child;
  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal = width > 600 ? 64.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 16),
      child: child,
    );
  }
}
