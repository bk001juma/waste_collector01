import 'dart:async';
import 'package:RecycleHub/services/educational_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class EducationalCarouselPage extends StatefulWidget {
  const EducationalCarouselPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EducationalCarouselPageState createState() =>
      _EducationalCarouselPageState();
}

class _EducationalCarouselPageState extends State<EducationalCarouselPage> {
  final EducationalService _educationalService = EducationalService();
  int _currentIndex = 0;
  late Timer _timer;
  late List<Map<String, dynamic>> _educationalContent = [];

  @override
  void initState() {
    super.initState();
    _fetchEducationalContent();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        if (_currentIndex < _educationalContent.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
      });
    });
  }

  _fetchEducationalContent() {
    _educationalService.getEducationalContent().listen((snapshot) {
      setState(() {
        _educationalContent =
            snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educational Carousel')),
      body:
          _educationalContent.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300.0,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      initialPage: _currentIndex,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items:
                        _educationalContent.map((content) {
                          String contentPreview = content['content'] ?? '';
                          if (content['type'] == 'text' &&
                              contentPreview.length > 100) {
                            contentPreview =
                                '${contentPreview.substring(0, 100)}...';
                          }

                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text(
                                            content['title'] ?? 'No Title',
                                          ),
                                          content: Text(
                                            content['content'] ??
                                                'No content available',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Background image
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/r-tip.jpg',
                                            ), // Your background image
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      // Content overlay with text
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(16.0),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          // ignore: deprecated_member_use
                                          color: Colors.black.withOpacity(
                                            0.5,
                                          ), // Semi-transparent overlay
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              content['title'] ?? 'No Title',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Colors
                                                        .white, // White text color
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              contentPreview,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ), // White text color
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
    );
  }
}
