import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'meditation_timer_page.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({Key? key}) : super(key: key);

  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int _selectedMinutes = 02;
  bool _startingBell = true;
  bool _backgroundNoise = true;
  bool _endingBell = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCFDBD5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Méditation du jour',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prolongez votre session en ajoutant une ambiance et des éléments personnalisés à vos paramètres de pratique.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),

              // Sélecteur de temps modifié
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Durée',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFCE8F8A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        NumberPicker(
                          minValue: 1,
                          maxValue: 60,
                          value: _selectedMinutes,
                          zeroPad: true,
                          infiniteLoop: true,
                          itemWidth: 100,
                          itemHeight: 50,
                          selectedTextStyle: const TextStyle(
                            color: Color(0xFFCE6A6B),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                          textMapper: (value) => '$value min', // Affiche "X min"
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[600]!, width: 1),
                              bottom: BorderSide(color: Colors.grey[600]!, width: 1),
                            ),
                          ),
                          onChanged: (value) => setState(() => _selectedMinutes = value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildMeditationOption('Décompte & cloche de départ ', _startingBell, (value) {
                setState(() => _startingBell = value);
              }),
              const SizedBox(height: 12),
              _buildMeditationOption('Sons d’ambiance	 ', _backgroundNoise, (value) {
                setState(() => _backgroundNoise = value);
              }),
              const SizedBox(height: 12),
              _buildMeditationOption('Cloche de clôture ', _endingBell, (value) {
                setState(() => _endingBell = value);
              }),
              const SizedBox(height: 24),

              //start //
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCE8F8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _startMeditation(context),
                  child: const Text(
                    'Lancer la session',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationOption(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      width: double.infinity, // Même largeur que le time picker
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF97999B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFFEBACA2),

          ),
        ],
      ),
    );
  }

  void _startMeditation(BuildContext context) async {
    // Vérifie si le compte à rebours est activé
    if (_startingBell) {
      await _showVisualCountdown(context);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeditationTimerPage(
          duration: _selectedMinutes,
          shouldPlayEndBell: _endingBell, // Renommé pour plus de clarté
          backgroundSound: _backgroundNoise,
        ),
      ),
    );
  }

  Future<void> _showVisualCountdown(BuildContext context) async {
    // Compte à rebours visuel seulement (3, 2, 1)
    for (int i = 3; i > 0; i--) {
      // Affiche le chiffre en plein écran
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.7),
        barrierDismissible: false,
        builder: (_) => Center(
          child: Text(
            '$i',
            style: const TextStyle(
              fontSize: 120,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop(); // Ferme le dialog
    }

    // Message "Start!" (optionnel)
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Text(
          'Start',
          style: TextStyle(
            fontSize: 80,
            color: Colors.blueGrey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context).pop();
  }


}