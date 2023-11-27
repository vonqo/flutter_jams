import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jams/app_types.dart';
import 'package:flutter_jams/screens/transparent_text_screen.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const FlutterJams());
}

class FlutterJams extends StatelessWidget {
  const FlutterJams({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vonqo\'s Flutter Jams',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppTypes.SCREEN_TRANSPARENT_TEXT_SCREEN,
      routes: {
        AppTypes.SCREEN_TRANSPARENT_TEXT_SCREEN: (context) => const TransparentTextScreen(),
      },
    );
  }
}