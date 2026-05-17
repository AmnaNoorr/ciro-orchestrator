import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/crisis_provider.dart';
import 'screens/signal_input_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
