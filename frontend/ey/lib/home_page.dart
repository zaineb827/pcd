import 'package:flutter/material.dart';
import 'sensor_service.dart';
import 'package:ey/appcolor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sensorService = SensorService();

  @override
  Widget build(BuildContext context) {
    Color appcolor = AppColors.getBackground(context);

    return Scaffold(
      body: Stack(
        children: [
          // Fond de la page
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppColors.getBackgroundImage(context)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Phrase avant le bouton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Pour optimiser votre expérience et nous permettre de mieux comprendre vos émotions afin de vous offrir un accompagnement personnalisé, veuillez activer ce paramètre dans les services installés > EmoCare",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),  // Espacement entre la phrase et le bouton
                // Bouton pour lancer le service
                ElevatedButton(
                  child: const Text('Activer',style: TextStyle( fontFamily: 'Poppins'),)
                  ,
                  onPressed: _sensorService.startService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
