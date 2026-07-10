import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/components/menu_app.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';

class ThemePage extends StatefulWidget {
  final List<Widget> children;
  final List<Widget>? bottomAppBarItems;
  final String? title;
  final Widget? floatingActionButton;
  const ThemePage({
    super.key,
    required this.children,
    this.bottomAppBarItems,
    this.title,
    this.floatingActionButton,
  });

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useDrawer = screenWidth < Globals.mediumWidth;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Cores.principalBackground,
      appBar: MenuApp(),
      drawer: useDrawer ? Drawer(child: MenuDrawer()) : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!useDrawer) SizedBox(width: 280, child: MenuDrawer()),
                    if (!useDrawer) const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TituloH1(
                                text: widget.title!,
                                color: Cores.colorLogo,
                              ),
                            ),
                          Expanded(child: ListView(children: widget.children)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if ((widget.bottomAppBarItems ?? []).isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  if (!useDrawer) SizedBox(width: 280),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.bottomAppBarItems!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: null,
    );
  }
}

class BottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? color;
  const BottomButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: () => onPressed(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), Text(label)],
      ),
    );
  }
}
