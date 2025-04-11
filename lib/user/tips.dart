import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecyclingTips extends StatelessWidget {
  // Example data for recycling tips
  final List<Map<String, String>> tips = [
    {
      'title': 'How to Recycle Plastic',
      'description': 'Learn how to properly recycle plastic waste.',
      'type': 'note',
    },
    {
      'title': 'Recycling Paper at Home',
      'description': 'A step-by-step guide to recycling paper.',
      'type': 'note',
    },
    {
      'title': 'The Importance of Recycling Metal',
      'description': 'Why recycling metal is crucial for the environment.',
      'type': 'note',
    },
    {
      'title': 'Recycling Glass: Dos and Don\'ts',
      'description': 'Best practices for recycling glass.',
      'type': 'note',
    },
    {
      'title': 'How Recycling Works',
      'description': 'Watch this video to understand the recycling process.',
      'type': 'video',
      'url':
          'https://www.youtube.com/watch?v=example1', // Replace with actual video URL
    },
    {
      'title': 'Creative Ways to Reuse Plastic',
      'description': 'Discover innovative ways to reuse plastic items.',
      'type': 'video',
      'url':
          'https://www.youtube.com/watch?v=example2', // Replace with actual video URL
    },
  ];

  RecyclingTips({super.key});
  // Function to open video links
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Tips'),
        backgroundColor: Colors.green, // Theme color for sustainability
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Icon(
                tip['type'] == 'note' ? Icons.article : Icons.video_library,
                color: Colors.green,
              ),
              title: Text(
                tip['title']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(tip['description']!),
              trailing:
                  tip['type'] == 'video'
                      ? IconButton(
                        icon: const Icon(
                          Icons.play_circle_filled,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (tip['url'] != null) {
                            _launchURL(tip['url']!);
                          }
                        },
                      )
                      : null,
              onTap: () {
                if (tip['type'] == 'note') {
                  // Navigate to a detailed note page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecyclingTipDetail(tip: tip),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// Detailed Page for Recycling Tips
class RecyclingTipDetail extends StatelessWidget {
  final Map<String, String> tip;

  const RecyclingTipDetail({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tip['title']!), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip['title']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(tip['description']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (tip['type'] == 'note')
              Text(
                'Detailed content about ${tip['title']} goes here. '
                'This section can include step-by-step instructions, '
                'best practices, and more.',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
