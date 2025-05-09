import 'package:flutter/material.dart';

class BreathPage extends StatelessWidget {
  const BreathPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text('Exercices de respiration...'),
      ),
    );
  }
}