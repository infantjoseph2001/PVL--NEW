import 'package:flutter/material.dart';
import 'package:pvl_master/screens/init_screen.dart';
import 'package:pvl_master/services/data_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataService>(
      create: (_) => DataService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pearson Vision Limousine',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,  // Enable Material 3 support
        ),
        home: InitScreen(),
      ),
    );
  }
}
