import 'package:flutter/material.dart';

class CoachesTitle extends StatelessWidget {
  const CoachesTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Featured Coaches",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {

                    },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            children: [
              Text(
                "See all",
                style: TextStyle(
                  color: Color(0xFF2563EB), // لون الثيم
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ),
      ],
    );
  }
}