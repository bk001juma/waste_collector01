// ignore_for_file: deprecated_member_use

import 'package:RecycleHub/user/educational_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/educational_service.dart';

class RecyclingTips extends StatelessWidget {
  const RecyclingTips({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final EducationalService educationalService = EducationalService();

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/tips.jpg',
                ), // 🔁 Use your own image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // A semi-transparent overlay to improve readability
          Container(color: Colors.black.withOpacity(0.3)),
          // Educational content list
          Column(
            children: [
              // Header message
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recycling Tips!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.6),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: educationalService.getEducationalContent(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final contentList = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: contentList.length,
                      itemBuilder: (context, index) {
                        final content =
                            contentList[index].data() as Map<String, dynamic>;

                        String contentPreview = content['content'] ?? '';
                        if (content['type'] == 'text' &&
                            contentPreview.length > 100) {
                          contentPreview =
                              '${contentPreview.substring(0, 100)}...';
                        }

                        return Card(
                          color: Colors.white.withOpacity(
                            0.9,
                          ), // Slight transparency for background blend
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: Icon(
                              content['type'] == 'text'
                                  ? Icons.article
                                  : Icons.video_library,
                              color: Colors.green,
                            ),
                            title: Text(
                              content['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                content['type'] == 'text'
                                    ? contentPreview
                                    : 'Tap to open video',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            trailing:
                                content['type'] == 'video'
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        if (content['content'] != null) {
                                          _launchURL(content['content']);
                                        }
                                      },
                                    )
                                    : null,
                            onTap: () {
                              if (content['type'] == 'text') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EducationalDetailPage(
                                          content: content,
                                        ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
