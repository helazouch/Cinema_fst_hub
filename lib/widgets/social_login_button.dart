import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const SocialLoginButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Container(width: 24, height: 24, child: _buildIcon()),
      ),
    );
  }

  Widget _buildIcon() {
    // Utiliser des icônes intégrées pour Google, Apple, et Facebook
    if (assetPath.contains('google')) {
      return const Icon(Icons.g_mobiledata, size: 24, color: Colors.red);
    } else if (assetPath.contains('apple')) {
      return const Icon(Icons.apple, size: 24, color: Colors.black);
    } else if (assetPath.contains('facebook')) {
      return const Icon(Icons.facebook, size: 24, color: Colors.blue);
    }
    return const Icon(Icons.login, size: 24);
  }
}
