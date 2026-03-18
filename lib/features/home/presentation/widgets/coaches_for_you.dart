import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../bookings/domain/models/booking_session_model.dart';
import '../../../bookings/presentation/screens/coach_details_screen.dart';

class CoachesForYouSection extends StatelessWidget {
  const CoachesForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// title
        Row(
          children: const [
            Text(
              "Coaches for you",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              "see more →",
              style: TextStyle(color: Colors.blue),
            )
          ],
        ),

        const SizedBox(height: 14),

        /// coaches list
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [

              CoachCard(
                name: 'Ahmed Mohamed',
                sport: 'Football',
                rating: 4.9,
                reviews: 80,
                price: 25,
                image: "assets/images/coach_ahmed_mohamed.png",
              ),

              CoachCard(
                name: 'Sara Ahmed',
                sport: 'Swimming',
                rating: 4.7,
                reviews: 77,
                price: 25,
                image: "assets/images/coach_sarah_Ahmed.jpeg",
              ),

              CoachCard(
                name: 'Ziad Marwan',
                sport: 'Padel',
                rating: 4.7,
                reviews: 16,
                price: 25,
                image: "assets/images/coach_ziad_marwan.png",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class CoachCard extends StatelessWidget {
  final String name;
  final String sport;
  final double rating;
  final int reviews;
  final int price;
  final String image;   // ← ضفنا الصورة

  const CoachCard({
    super.key,
    required this.name,
    required this.sport,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image, // ← هنا
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final session = BookingSessionModel(
          id: DateTime.now().toString(),
          coachName: name,
          sport: sport,
          location: "Cairo", // رجّعناها مدينة
          date: DateTime.now(),
          isPast: false,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDetailsScreen(
              session: session,
              image: image, // نبعث الصورة هنا
            ),
          ),
        );
      },
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imagePlaceholder(),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    sport,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviews reviews)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '\$ $price/hr',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
        color: AppColors.primaryBlue.withOpacity(.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
        child: Image.asset(
          image,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}