import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/components/menu_app.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';

class ThemePage extends StatefulWidget {
  final List<Widget> children;
  final void Function() onLogout;
  const ThemePage({super.key, required this.children, required this.onLogout});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useDrawer = screenWidth < Globals.mediumWidth;

    return Scaffold(
      backgroundColor: Cores.principalBackground,
      appBar: MenuApp(),
      drawer: useDrawer
          ? Drawer(
              child: MenuDrawer(onLogout: widget.onLogout),
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!useDrawer)
              SizedBox(
                width: 280,
                child: MenuDrawer(onLogout: widget.onLogout),
              ),
            if (!useDrawer)
            const SizedBox(width: 10),
            Expanded(
              child: ListView(
                children: widget.children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
