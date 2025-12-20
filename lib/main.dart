import 'package:flutter/material.dart';

import 'layout/main_layout.dart';
//import 'package:marrany3/screens/bookings.dart';
//import 'package:marrany3/screens/home/home_tab.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: MainLayout(),
      

    );
  }
}