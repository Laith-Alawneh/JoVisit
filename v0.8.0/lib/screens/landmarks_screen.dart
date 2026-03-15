import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../data/landmarks_data.dart';

class LandmarksScreen extends StatelessWidget {
  const LandmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final landmarks = LandmarksData.getLandmarks();

    return Scaffold(
      appBar: AppBar(
        // ❌ BUG: التدرج اللوني خاطئ
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green], // ❌ ألوان خاطئة
            ),
          ),
        ),
        title: const Text('Jordan\'s Landmarks'),
      ),
      drawer: Drawer(
        // ❌ BUG: درج التنقل لا يُغلق بشكل صحيح
        child: ListView(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () {
                // ❌ BUG: لا يوجد Navigator.pop() قبل التنقل
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('Landmarks'),
              onTap: () {
                // ❌ BUG: لا يوجد Navigator.pop()
                Navigator.pushNamed(context, '/landmarks');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: landmarks.length,
        itemBuilder: (context, index) {
          final landmark = landmarks[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              // ❌ BUG: لا توجد محاذاة صحيحة
              children: [
                Image.asset(
                  landmark.primaryImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ❌ BUG: النص قد يتجاوز الحدود
                      Text(
                        landmark.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        // ❌ لا يوجد overflow handling
                      ),
                      const SizedBox(height: 8),
                      Text(
                        landmark.nameArabic,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        // ❌ لا يوجد overflow handling
                      ),
                      const SizedBox(height: 8),
                      // ❌ BUG: الوصف قد يكون طويل جداً
                      Text(
                        landmark.description,
                        style: const TextStyle(fontSize: 16),
                        // ❌ لا يوجد maxLines أو overflow
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 4),
                          // ❌ BUG: النص قد يتجاوز
                          Text(
                            landmark.location,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
