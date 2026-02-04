import 'package:flutter/material.dart';

class SellFabricScreen extends StatelessWidget {
  const SellFabricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: const Text('Sell Fabric'),
        backgroundColor: const Color(0xFF1E2D33),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Sell Fabric Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Form to list new fabric goes here.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
