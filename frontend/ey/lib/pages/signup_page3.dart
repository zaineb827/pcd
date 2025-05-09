import 'package:ey/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:ey/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:ey/appcolor.dart';

Future<void> requestMicPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    await Permission.microphone.request();
  }
}

final audioPlayer = AudioPlayer();

class SignUpPage3 extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage3> {
  final AudioRecorder _audioRecorder = AudioRecorder(); // ✅ New instance
  bool isRecording = false;
  Timer? _timer;
  String? lastRecordingPath;

  @override
  void initState() {
    super.initState();
    requestMicPermission();
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/my_voice_note.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: path,
      );

      setState(() {
        isRecording = true;
        lastRecordingPath = path;
      });

      print('Recording started at $path');

      _timer = Timer(Duration(seconds: 15), () async {
        await stopRecording();
      });
    }
  }

  Future<void> stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      isRecording = false;
    });
    _timer?.cancel();
    print('Recording stopped: $path');
  }

  Future<void> playLastRecording() async {
    if (lastRecordingPath != null) {
      await audioPlayer.stop();
      await audioPlayer.play(DeviceFileSource(lastRecordingPath!));
      print('Playing: $lastRecordingPath');
    } else {
      print('No recording to play.');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color appcolor = AppColors.getBackground(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: appcolor,
        title: Text('S\'inscrire', textAlign: TextAlign.center),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.gettextcolor(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppColors.getBackgroundImage(context)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 100),
                  Text(
                    'Étape 3 de votre inscription !',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.gettextcolor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'C\'est la dernière étape pour vous configurer avec notre application ! il vous suffit d\'enregistrer votre voix pendant 15 secondes pour que notre modèle d\'IA l\'utilise, vous pouvez entendre ce que vous avez enregistré avec le bouton ci-dessous, pour de meilleurs résultats, assurez-vous que votre voix est claire et audible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.gettextcolor(context)),
                  ),
                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await startRecording();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Démarrer'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await stopRecording();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Arrêter'),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    isRecording ? 'Enregistrement en cours...' : 'Pas en coure d\'enregistrement',
                    style: TextStyle(
                      fontSize: 16,
                      color: isRecording ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: lastRecordingPath != null
                        ? () async {
                      await playLastRecording();
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('Lire le dernier enregistrement'),
                  ),
                  SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage(),)
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Inscription terminée',
                      style: TextStyle(fontSize: 18, color: AppColors.gettextcolor(context)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
