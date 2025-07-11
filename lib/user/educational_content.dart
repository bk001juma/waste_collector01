import 'package:flutter/material.dart';

class EducationalDetailPage extends StatelessWidget {
  final Map<String, dynamic> content;

  const EducationalDetailPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content['title']),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content['content'] ?? 'No content available',
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
