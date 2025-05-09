import 'package:flutter/material.dart';
import 'package:ey/StressService.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _stressLevel = 0;
  List<FlSpot> _stressData = [];

  @override
  void initState() {
    super.initState();

    // Point initial à l'heure actuelle avec stress = 0
    final now = DateTime.now();
    final initialHour = now.hour + now.minute / 60;
    _stressData.add(FlSpot(initialHour, 0));

    StressService.init(onStressDetected: (stressValue) {
      setState(() {
        _stressLevel = stressValue;
        final current = DateTime.now();
        final hour = current.hour + current.minute / 60;
        double stressYValue = stressValue.toDouble();

        _stressData.add(FlSpot(hour, stressYValue));

        if (_stressData.length > 12) {  // Limite à 12 heures (12 PM à 12 AM)
          _stressData.removeAt(0);
        }
      });
    });
  }

  Widget buildLegendCircle(Color color, String label,TextStyle textStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(backgroundColor: color, radius: 6),
        const SizedBox(width: 4),
        Text(label, style: textStyle),
        const SizedBox(width: 12),
      ],
    );
  }

  String formatHour(double hourValue) {
    int hour = hourValue.toInt() % 12;  // Limite l'affichage de l'heure entre 12 et 11
    final suffix = hourValue >= 12 ? 'PM' : 'AM';  // PM si l'heure est après midi
    if (hour == 0) hour = 12;  // Pour afficher "12 PM" et "12 AM"
    return '$hour $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(600.0), // Larger height for the app bar
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFc3cde6),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [

                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //ajout pour appbar
              Container(
                height: 130,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFc3cde6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bienvenue,',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Zaineb',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),

              ),

        
            // Padding pour les autres éléments
           Padding(
              padding: const EdgeInsets.all(16.0),  // Padding ici pour les autres éléments
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
              //baad bienvenu
               const SizedBox(height: 20),

                   const Text(
                     'Humeur du jour',
                     style: TextStyle(
                       fontFamily: 'Poppins',
                       fontSize: 16,  // Augmenter la taille du texte ici
                       fontWeight: FontWeight.bold,
                     ),
                   ),


                   const SizedBox(height: 20),
              // yebda hna
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LineChart(
                    LineChartData(
                      minX: 12,  // Début de l'échelle à 12 PM
                      maxX: 24,  // Fin de l'échelle à 12 AM
                      minY: 0,
                      maxY: 3.5,
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(),
                          bottom: BorderSide(),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,  // Interval de 1 heure entre les titres
                            getTitlesWidget: (value, meta) {
                              return Text(
                                formatHour(value),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _stressData,
                          isCurved: true,
                          color: Colors.grey,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              Color dotColor;
                              switch (spot.y.toInt()) {
                                case 0:
                                  dotColor = const Color(0xFF84a98c);
                                  break;
                                case 1: //stress
                                  dotColor = const Color(0xffb9baa3);
                                  break;
                                case 2:   //colere
                                  dotColor = const Color(0xfff27059);
                                  break;
                                case 3:  //joie
                                  dotColor = const Color(0xFFf4acb7);
                                  break;
                                case 4:  //triste
                                  dotColor = const Color(0xFF6d6875);
                                  break;
                                case 5:  //fear
                                  dotColor = const Color(0xFF2b2d42);
                                  break;
                                default:
                                  dotColor = Colors.grey;
                              }
          
                              return FlDotCirclePainter(
                                radius: 5,
                                color: dotColor,
                                strokeWidth: 2,
                                strokeColor: Colors.black,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Répartir les éléments de manière égale
                           children: [
                             // Colonne de gauche
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   buildLegendCircle(const Color(0xFF84a98c), "Calm",TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
                                   buildLegendCircle(const Color(0xffb9baa3), "Stress",TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
                                   buildLegendCircle(const Color(0xFF6d6875), "Triste",TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
                                 ],
                               ),
                             ),
                             // Colonne de droite
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   buildLegendCircle(const Color(0xfff27059), "Colère",TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
                                   buildLegendCircle(const Color(0xFFf4acb7), "Joie",TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
                                   buildLegendCircle(const Color(0xFF2b2d42), "Peur",TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   const SizedBox(height: 25),
                   const Text(
                     'Vos objectifs pour cette semaine',
                     style: TextStyle(
                       fontFamily: 'Poppins',
                       fontSize: 18,  // Augmenter la taille du texte ici
                       fontWeight: FontWeight.bold,
                     ),
                   ),

                   const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),  // Coins arrondis
                ),
                elevation: 5,  // Ombre de la card
                child: Container(
                  width: double.infinity,  // Prendre toute la largeur
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/3776499s-01.jpg'), //
                      fit: BoxFit.cover,  // L'image couvre tout l'espace du container
                    ),
                    borderRadius: BorderRadius.circular(20), // Coins arrondis
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),  // Coins arrondis
                ),
                elevation: 5,  // Ombre de la card
                child: Container(
                  width: double.infinity,  // Prendre toute la largeur
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/3776499s-02.jpg'), //  image de fond
                      fit: BoxFit.cover,  // L'image couvre tout l'espace du container
                    ),
                    borderRadius: BorderRadius.circular(20), // Coins arrondis
                  ),
                ),
              ),
            ],
              ),
           )],
        
          ),
      ),


    );
  }
}
