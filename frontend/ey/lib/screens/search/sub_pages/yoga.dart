import 'package:ey/home_page.dart';
import 'package:ey/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}

class YogaPage extends StatefulWidget {
  @override
  _YogaPageState createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  final List<String> featuredImages = [
    'assets/images/yoga6.jpg',
    'assets/images/yoga.jpg',
    'assets/images/yoga6.jpg',
  ];
  final List<String> featuredImages2 = [
    'assets/images/yoga1.jpg',
    'assets/images/yoga3.jpg',
    'assets/images/yoga5.jpg',
    'assets/images/yoga3.jpg',
    'assets/images/yoga1.jpg',
    'assets/images/yoga5.jpg',
  ];

  // progress state
  int _sessionsCompleted = 0;
  int get _totalSessions => featuredImages.length;
  double get _progress => _sessionsCompleted / _totalSessions;

  // badge state
  DateTime? _firstLaunchDate;
  int _daysUsed = 0;
  final List<_Badge> _badges = [
    _Badge(name: 'Day 1', icon: Icons.looks_one, thresholdDays: 1),
    _Badge(name: '7 Days', icon: Icons.looks_two, thresholdDays: 7),
    _Badge(name: '30 Days', icon: Icons.star, thresholdDays: 30),
    _Badge(name: '365 Days', icon: Icons.celebration, thresholdDays: 365),
  ];

  final int initialPage = 996;
  late PageController _loopingController;
  late PageController _featuredController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initFirstLaunch();
    _loopingController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.7,
    );
    _featuredController = PageController(viewportFraction: 0.8)
      ..addListener(() {
        setState(() {
          _currentPage = _featuredController.page?.round() ?? 0;
        });
      });
  }

  Future<void> _initFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('firstLaunch');
    if (stored == null) {
      _firstLaunchDate = DateTime.now();
      await prefs.setString('firstLaunch', _firstLaunchDate!.toIso8601String());
    } else {
      _firstLaunchDate = DateTime.parse(stored);
    }
    final now = DateTime.now();
    setState(() {
      _daysUsed = now.difference(_firstLaunchDate!).inDays + 1;
    });
  }

  @override
  void dispose() {
    _loopingController.dispose();
    _featuredController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Moment de détente' ,style: TextStyle(fontFamily: 'Poppins'),),
          backgroundColor: Colors.pink[100],
          elevation: 0,
        ),
        body:
        Stack(children: [Container(color: Colors.white,),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Featured Sessions Carousel
                Container(

                  height: 200,
                  color: Colors.pink[100],
                  child: PageView.builder(
                    controller: _featuredController,
                    itemCount: featuredImages.length,
                    itemBuilder:
                        (context, index) => Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              featuredImages[index],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                  Container(color: Colors.grey[300]),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Text(
                            'Session ${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(blurRadius: 6, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    featuredImages.length,
                        (i) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        i == _currentPage ? Colors.pink[700] : Colors.pink[200],
                      ),
                    ),
                  ),
                ),

                // Tutorials Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meilleurs tutoriels',
                        style: TextStyle(fontFamily: 'Poppins',fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: PageView.builder(
                          controller: _loopingController,
                          itemCount: featuredImages2.length,
                          itemBuilder:
                              (context, index) => Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    featuredImages2[index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                        Container(color: Colors.grey[300]),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: Text(
                                  'Tutorial ${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Start Button
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _sessionsCompleted = (_sessionsCompleted + 1).clamp(
                                0,
                                _totalSessions,
                              );
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MainNavigationWrapper()),
                            );
                          },
                          icon: Icon(Icons.spa, color: Colors.white),
                          label: Text(
                            'Commencer une session de détente',
                            style: TextStyle(color: Colors.white ,fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Quote Card
                      Card(
                        color: Colors.pink[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '"Respire profondément. Même la plus petite pause peut réinitialiser ta journée."',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      // Categories
                      SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                          [
                            'Étirements',
                            'Meditation',
                            'Respiration',
                            'Sleep Aid',
                          ]
                              .map(
                                (cat) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.pink[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),

                      // Recommended
                      SizedBox(height: 20),
                      Text(
                        'Recommandé pour vous',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder:
                              (context, index) => Container(
                            width: 120,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.pink[50],
                              image: DecorationImage(
                                image: AssetImage(featuredImages2[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [Colors.black26, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: Text(
                                'Mini ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins'
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Progress
                      SizedBox(height: 20),
                      Text(
                        'Progrès de la semaine',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.pink[100],
                        valueColor: AlwaysStoppedAnimation(Colors.pink[400]!),
                      ),

                      // Sounds
                      SizedBox(height: 20),
                      Text(
                        'Sons relaxants',
                        style: TextStyle(fontFamily: 'Poppins',fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                          ['rain', 'ocean', 'forest', 'fireplace'].map((sound) {
                            final isPlaying = _currentlyPlaying == sound;
                            return GestureDetector(
                              onTap: () async {
                                if (isPlaying) {
                                  await _audioPlayer.stop();
                                  setState(() => _currentlyPlaying = null);
                                } else {
                                  await _audioPlayer.play(
                                    AssetSource('sounds/$sound.mp3'),
                                  );
                                  setState(() => _currentlyPlaying = sound);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  isPlaying
                                      ? Colors.pink[400]
                                      : Colors.pink[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.music_note,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      sound.capitalize(),
                                      style: TextStyle(color: Colors.white,fontFamily: 'Poppins'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Achievements Badges
                      SizedBox(height: 20),
                      Text(
                        '🏆 Tes réussites ',
                        style: TextStyle(fontFamily: 'Poppins',fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          itemCount: _badges.length,
                          itemBuilder: (context, i) {
                            final badge = _badges[i];
                            final unlocked = _daysUsed >= badge.thresholdDays;
                            return Container(
                              width: 100,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color:
                                unlocked ? Colors.pink[100] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    unlocked ? badge.icon : Icons.lock,
                                    size: 32,
                                    color:
                                    unlocked
                                        ? Colors.pink[400]
                                        : Colors.grey[600],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    badge.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                      unlocked
                                          ? Colors.black87
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  if (unlocked)
                                    Text(
                                      '${badge.thresholdDays}d',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.pink[400],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]
        )
    );
  }
}

class _Badge {
  final String name;
  final IconData icon;
  final int thresholdDays;
  _Badge({required this.name, required this.icon, required this.thresholdDays});
}
