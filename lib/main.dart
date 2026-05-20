import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/crisis_provider.dart';
import 'screens/signal_input_screen.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      try {
        mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
      } catch (e) {
        // Handle initialization error safely
      }
    }
  }

  runApp(const CiroApp());
}

class CiroApp extends StatelessWidget {
  const CiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CrisisProvider()),
      ],
      child: MaterialApp(
        title: 'CIRO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SignalInputScreen(),
      ),
    );
  }
}
