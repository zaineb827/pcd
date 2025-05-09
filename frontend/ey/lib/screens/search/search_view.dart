import 'package:flutter/material.dart';
import 'sub_pages/sports_page.dart';
import 'sub_pages/meditation_page.dart';
import 'sub_pages/breath_page.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Sports',
      'icon': Icons.sports_soccer,
      'page': SportsPage(),
      'isModal': true,
    },
    {
      'title': 'Méditation',
      'icon': Icons.self_improvement,
      'page': MeditationPage(),
      'isModal': true,
    },
    {
      'title': 'Respiration',
      'icon': Icons.air,
      'page': BreathPage(),
      'isModal': false,
    },
    {
      'title': 'Musique',
      'icon': Icons.music_note,
      'page': BreathPage(),
      'isModal': false,
    },
    {
      'title': 'Livres et Podcats',
      'icon': Icons.library_books,
      'page': BreathPage(),
      'isModal': false,
    },
    {
      'title': 'Filmes et series',
      'icon': Icons.movie,
      'page': BreathPage(),
      'isModal': false,
    },
  ];

  void _navigateToPage(BuildContext context, Widget page, bool isModal) {
    if (isModal) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(
        PageRouteBuilder(
          fullscreenDialog: true,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16), // + espacement haut/bas
      itemCount: categories.length,
      itemBuilder: (ctx, index) => Card(
        margin: const EdgeInsets.only(bottom: 20), // ↑ espace entre les cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              categories[index]['icon'],
              color: const Color(0xFF9fc2c0),
            ),
          ),
          title: Text(
            categories[index]['title'],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
          onTap: () => _navigateToPage(
            context,
            categories[index]['page'],
            categories[index]['isModal'],
          ),
        ),
      ),
    );
  }
}
