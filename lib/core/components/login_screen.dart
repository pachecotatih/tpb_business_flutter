import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Widget child;
  const LoginScreen({super.key, required this.child});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          image: AssetImage('assets/img/background_login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: const EdgeInsets.all(30),
              constraints: const BoxConstraints(maxWidth: 350, maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
