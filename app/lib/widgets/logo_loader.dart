import 'package:flutter/material.dart';

class ClyroLogoLoader extends StatelessWidget {
  final double size;

  const ClyroLogoLoader({
    super.key, 
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png', // The path to your file
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}