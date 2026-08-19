/* =================================================================================
   TRUCK LOGISTICS - DRIVER MOBILE APP (FLUTTER / ANDROID)
   =================================================================================
   
   HOW TO SETUP AND RUN:

   1. CHANGING THE BACKEND BASE URL:
      - Open `lib/config/api_config.dart`
      - For Android Emulator: Set `baseUrl = 'http://10.0.2.2:8000'`
      - For Physical Android Phone on local Wi-Fi: Set `baseUrl = 'http://192.168.X.X:8000'`
        (Replace 192.168.X.X with your laptop's IPv4 address from `ipconfig`).

   2. RUNNING ON CONNECTED ANDROID DEVICE OR EMULATOR:
      - Open terminal in `c:\Users\User\Downloads\Project_NEO\Truck_Logistics\driver_app`
      - List devices: `flutter devices`
      - Run app: `flutter run -d android` (or specify device ID: `flutter run -d <device_id>`)
      - Build APK for direct phone installation: `flutter build apk --release`
        (Generates standalone APK at build/app/outputs/flutter-apk/app-release.apk)

   ================================================================================= */

import 'package:flutter/material.dart';
import 'screens/truck_select_screen.dart';

void main() {
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truck Driver App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const TruckSelectScreen(),
    );
  }
}
