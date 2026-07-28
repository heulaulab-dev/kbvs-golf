import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KbVsGolfApp());
}

class KbVsGolfApp extends StatelessWidget {
  const KbVsGolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'KBVS Golf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'SFPro',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
