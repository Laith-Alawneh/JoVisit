import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../core/theme/app_theme.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _submitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Our App'),
      ),
      body: _submitted ? _buildThankYouScreen() : _buildRatingForm(),
    );
  }

  Widget _buildRatingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        // ❌ BUG: لا توجد محاذاة صحيحة
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                // ❌ BUG: لا توجد crossAxisAlignment أو mainAxisAlignment
                children: [
                  const Icon(
                    Icons.star,
                    size: 60,
                    color: AppTheme.goldColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How would you rate your experience?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // ❌ BUG: RatingBar بدون Center
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 50,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: AppTheme.goldColor,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Your feedback (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitRating,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Rating'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'Thank You!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text('We appreciate your feedback.'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _submitted = false;
                _rating = 0;
                _feedbackController.clear();
              });
            },
            child: const Text('Submit Another Rating'),
          ),
        ],
      ),
    );
  }
}
