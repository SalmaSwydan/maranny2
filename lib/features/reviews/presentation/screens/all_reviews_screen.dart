import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/review_card.dart';

class AllReviewsScreen extends StatelessWidget {
  const AllReviewsScreen({super.key});

  // All reviews data
  final List<Map<String, dynamic>> _allReviews = const [
    {
      'name': 'Ahmed Yasser',
      'review': 'Excellent coaching! Really improved My skills',
      'timestamp': '2 days ago',
      'rating': 5,
    },
    {
      'name': 'Maria K.',
      'review': 'Very patient and professional!',
      'timestamp': '2 days ago',
      'rating': 5,
    },
    {
      'name': 'Zeyad Hamdi',
      'review': 'Learned alot about footwork and positioning',
      'timestamp': '4 days ago',
      'rating': 5,
    },
    {
      'name': 'Marwan Nagy',
      'review': 'Very knowledgeable and experienced.',
      'timestamp': '5 days ago',
      'rating': 5,
    },
    {
      'name': 'Ali Naser',
      'review': 'Amazing coach! my serve has improved completely',
      'timestamp': '5 days ago',
      'rating': 5,
    },
  ];

  // Star rating breakdown
  final Map<int, int> _ratingBreakdown = const {
    5: 4, // 4 reviews with 5 stars
    4: 1, // 1 review with 4 stars
    3: 0,
    2: 0,
    1: 0,
  };

  double _calculateAverageRating() {
    int totalRating = 0;
    int totalReviews = 0;
    _ratingBreakdown.forEach((stars, count) {
      totalRating += stars * count;
      totalReviews += count;
    });
    return totalReviews > 0 ? totalRating / totalReviews : 0.0;
  }

  double _getRatingPercentage(int stars) {
    int totalReviews = _ratingBreakdown.values.reduce((a, b) => a + b);
    if (totalReviews == 0) return 0.0;
    return _ratingBreakdown[stars]! / totalReviews;
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = _calculateAverageRating();
    final totalReviews = _ratingBreakdown.values.reduce((a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF6FD3F5), // light blue
                  Color(0xFF1F3A93), // deep blue
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'All Reviews',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating summary card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left side - Overall rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalReviews reviews',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Inter',
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Right side - Star breakdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(5, (index) {
                              final stars = 5 - index;
                              final percentage = _getRatingPercentage(stars);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      '$stars',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: percentage,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reviews list
                  ..._allReviews.map((review) {
                    return ReviewCard(
                      name: review['name'] as String,
                      review: review['review'] as String,
                      timestamp: review['timestamp'] as String,
                      rating: review['rating'] as int,
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



