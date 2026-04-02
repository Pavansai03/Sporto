import 'package:flutter/material.dart';

class SportoTitle extends StatelessWidget {
  const SportoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min, // Keeps the row tight around its children
      crossAxisAlignment: CrossAxisAlignment.center, // Aligns icon with text middle
      children: [
        Text(
            'Sp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 26, // Slightly larger base text
              letterSpacing: 1.0, // Gives a little breathing room
            )
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.0), // Nudges the icon down slightly to act as a lowercase 'o'
          child: Icon(
            Icons.sports_soccer,
            color: Colors.white,
            size: 22, // Sized to match the lowercase text
          ),
        ),
        Text(
            'rto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 26, // Slightly larger base text
              letterSpacing: 1.0, // Gives a little breathing room
            )
        ),
      ],
    );
  }
}
