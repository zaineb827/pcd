import 'package:flutter/material.dart';
import 'yoga.dart';

class SportsPage extends StatelessWidget {
  SportsPage({super.key});

  //  sports data
  final List<Map<String, dynamic>> sportsCategories = [
    {
      'title': 'Yoga',
      'image': 'assets/images/yoga.jpg',
      'color': Colors.orange,
      'exercises': ['Sun Salutation', 'Warrior Pose', 'Tree Pose',"okhr", 'Tree Pose'],
      'page' : YogaPage(),

    },
    {
      'title': 'Course',
      'image': 'assets/images/run.jpg',
      'color': Colors.blue,
      'exercises': ['Interval Training', 'Endurance Run', 'Tree Pose'],
      //'page': Runnin(),
    },
    {
      'title': 'Fitness',
      'image': 'assets/images/strength.jpg',
      'color': Colors.red,
      'exercises': ['Push-ups', 'Squats', 'Deadlifts'],
    },
    {
      'title': 'Natation',
      'image': 'assets/images/swim.jpg',
      'color': Colors.teal,
      'exercises': ['Freestyle', 'Breaststroke', 'Butterfly'],
    },
    {
      'title': 'Marche',
      'image': 'assets/images/walk.jpg',
      'color': Colors.grey,
      'exercises': ['Freestyle', 'Tree Pose'],
    },
    {
      'title': 'Dance',
      'image': 'assets/images/dance.jpg',
      'color': Colors.teal,
      'exercises': ['Freestyle', 'Breaststroke', 'Butterfly', 'Tree Pose'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(style: TextStyle(
          fontSize: 24,
          fontFamily: 'Poppins',
        ), 'Sports & Exercises'),
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: sportsCategories.length,
          itemBuilder: (context, index) {
            final category = sportsCategories[index];
            return _buildSportCard(context, category);
          },
        ),
      ),
    );
  }

  Widget _buildSportCard(BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, category),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with gradient overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
                child: Image.asset(
                  category['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: category['color'].withOpacity(0.7),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category['exercises'].length} exercises',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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
  void _navigateToPage(BuildContext context, Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => category['page'], // Utilisation de la page dynamique
      ),
    );
  }


}