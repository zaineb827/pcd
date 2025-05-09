import 'package:flutter/material.dart';
import 'search_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // Hauteur de l'AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), // Coin inférieur gauche
            bottomRight: Radius.circular(20), // Coin inférieur droit
          ),
          child: AppBar(
            backgroundColor: Color(0xFFc3cde6), // Couleur personnalisée
            title: const Text(
              'Explorer',

              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body:  SearchView(),
    );
  }
}