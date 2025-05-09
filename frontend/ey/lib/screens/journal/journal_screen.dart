import 'package:flutter/material.dart';
import 'journal_view.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const JournalView(),

    );
  }
}