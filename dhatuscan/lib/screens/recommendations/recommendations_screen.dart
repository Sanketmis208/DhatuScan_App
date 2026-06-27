import 'package:flutter/material.dart';

/// Placeholder for RecommendationsScreen.
/// Full implementation is in task 13.3.
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: const Center(child: Text('Recommendations — coming soon')),
    );
  }
}
