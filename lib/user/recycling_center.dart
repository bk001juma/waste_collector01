import 'package:flutter/material.dart';

class RecyclingCenterPage extends StatelessWidget {
  const RecyclingCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Center'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Company Logo and Name
            Column(
              children: [
                Image.asset('assets/images/logo11.png', height: 80),
                const SizedBox(height: 10),
                const Text(
                  'WIB CO LTD',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],
            ),

            // About Section
            const Text(
              'WIB CO LTD is committed to keeping our streets clean and promoting environmental sustainability. We work across 7 key streets to collect, sort, and recycle waste efficiently.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Mission & Vision
            const Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Our Mission',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text(
                      'To create a clean and green environment through efficient waste collection and recycling.',
                    ),
                    SizedBox(height: 16),
                    Text('Our Vision',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text(
                      'To be Tanzania\'s leading force in environmental sustainability and urban cleanliness.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CEO
            _buildProfileCard(
              title: 'Chief Executive Officer (CEO)',
              name: 'LAMECK SETH LAMECK',
              imagePath: 'assets/images/ceo.jpg',
            ),

            const SizedBox(height: 20),

            // Manager
            _buildProfileCard(
              title: 'Operations Manager',
              name: 'BARAKA MASHIMBE',
              imagePath: 'assets/images/1000001104[1].jpg',
            ),

            const SizedBox(height: 20),

            // Operating Days & Streets
            const Card(
              color: Color.fromARGB(255, 239, 255, 239),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Operating Schedule',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('🕘 Monday - Sunday: 7:00 AM to 4:00 PM'),
                    SizedBox(height: 10),
                    Text('📍 Streets Covered:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('• Sangasanga Street'),
                    Text('• J4 Street'),
                    Text('• Mahakamani Street'),
                    Text('• Osterbay Street'),
                    Text('• Mkubege Street'),
                    Text('• Paradise Street'),
                    Text('• Changarawe Street'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Info
            const Card(
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text('Contact Us'),
                subtitle: Text('Email: info@wibcoltd.co.tz\nPhone: +255 758 703 792'),
              ),
            ),

            const SizedBox(height: 10),

            // Call to Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Join us in keeping our streets clean! Together, we build a healthier Tanzania.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      {required String title, required String name, required String imagePath}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: 30,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(name),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
