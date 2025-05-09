import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late CameraController _cameraController;
  final AudioRecorder _audioRecorder = AudioRecorder(); // ✅ NEW for v6.0.0
  late String audioPath;
  late String imagePath;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(camera, ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {});
  }

  Future<void> startRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      print("Pas de permission pour le microphone.");
      return;
    }

    final tempDir = await getTemporaryDirectory();
    audioPath = p.join(tempDir.path, 'recording.m4a');
    imagePath = p.join(tempDir.path, 'photo.jpg');

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: audioPath,
    );

    setState(() {
      isRecording = true;
    });

    // Capture photo après 10 secondes
    Timer(const Duration(seconds: 10), () async {
      if (!_cameraController.value.isInitialized) return;
      final image = await _cameraController.takePicture();
      await image.saveTo(imagePath);
    });

    // Arrêter l'enregistrement après 60 secondes et envoyer les fichiers
    Timer(const Duration(seconds: 60), () async {
      await _audioRecorder.stop();
      setState(() {
        isRecording = false;
      });
      await sendFiles();
    });
  }

  Future<void> sendFiles() async {
    var uri = Uri.parse("http://<YOUR_PC_IP>:5000/predict");

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('audio', audioPath))
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      print('Réponse: $respStr');
    } else {
      print('Échec du téléchargement');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    const appcolor = Colors.blue;  // You can replace Colors.blue with your preferred color.

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50), // Specify the height of the AppBar
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), // Apply corner radius to the bottom of the AppBar
            child: AppBar(
              toolbarHeight: 50,
              backgroundColor: appcolor,
              title: const Text(
                "Capture",
                style: TextStyle(
                  fontFamily: 'Poppins', // Custom font
                ),
              ),
            ),
          ),
        ),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_cameraController)),
          ElevatedButton(
            onPressed: isRecording ? null : startRecording,
            child: const Text("Commencer la capture 60s", style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}