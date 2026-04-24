import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../bookings/domain/models/booking_session_model.dart';
import '../../../bookings/domain/models/coach_data_model.dart';
import '../../../bookings/presentation/screens/coach_details_screen.dart';
import '../../../home/presentation/screens/client_search_screen.dart';

class CoachesForYouSection extends StatelessWidget {
  const CoachesForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Coaches for you",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientSearchScreen()),
              ),
              child: Text("see more →",
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
                price: 500,
                image: "assets/images/coach_ahmed_mohamed.png",
              ),
              CoachCard(
                name: 'Sara Ahmed',
                sport: 'Swimming',
                rating: 4.7,
                reviews: 77,
                price: 400,
                image: "assets/images/coach_sarah_Ahmed.jpeg",
              ),
              CoachCard(
                name: 'Ziad Marwan',
                sport: 'Padel',
                rating: 4.7,
                reviews: 16,
                price: 600,
                image: "assets/images/ZiadMarwanPADEL.jpeg",
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
  final String image;

  const CoachCard({
    super.key,
    required this.name,
    required this.sport,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
  });

  int _coachUserIdByName(String coachName) {
    switch (coachName) {
      case 'Ahmed Mohamed':
        return 2;
      case 'Sara Ahmed':
      case 'Sarah Ahmed':
        return 3;
      case 'Nancy Ali':
        return 4;
      case 'Ziad Marwan':
        return 5;
      case 'Omar Khaled':
        return 6;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final session = BookingSessionModel(
          id: DateTime.now().toString(),
          coachUserId: _coachUserIdByName(name),
          coachName: name,
          sport: sport,
          location: 'Cairo, Egypt',
          date: DateTime.now(),
          isPast: false,
        );

        final coachData = allCoachesData.firstWhere(
              (c) => c.name == name || c.name.contains(name.split(' ')[0]),
          orElse: () => allCoachesData.first,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDetailsScreen(
              session: session,
              image: image,
              coachData: coachData,
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
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
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
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(sport,
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('$rating ($reviews reviews)',
                        style: const TextStyle(fontSize: 12)),
                  ]),
                  const SizedBox(height: 6),
                  Text('$price LE/hr',
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600)),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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