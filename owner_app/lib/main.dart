/* =================================================================================
   TRUCK LOGISTICS - FLEET OWNER PROGRAM (FLUTTER / WINDOWS DESKTOP)
   =================================================================================
   
   HOW TO SETUP AND BUILD FOR WINDOWS DESKTOP:

   1. ENABLE FLUTTER DESKTOP SUPPORT (ONCE):
      - Open terminal and run: `flutter config --enable-windows-desktop`

   2. CHANGING THE BACKEND BASE URL:
      - Open `lib/config/api_config.dart`
      - For backend running on same Windows machine: Use `baseUrl = 'http://localhost:8000'`
      - For backend hosted on another laptop on local network: Set `baseUrl = 'http://192.168.X.X:8000'`

   3. RUNNING AS A NATIVE WINDOWS APP:
      - Open terminal in `c:\Users\User\Downloads\Project_NEO\Truck_Logistics\owner_app`
      - Run app live: `flutter run -d windows`
      - Build standalone executable (.exe): `flutter build windows`
        (Executable output generated at `build/windows/runner/Release/owner_app.exe`)

   ================================================================================= */

import 'package:flutter/material.dart';
import 'screens/owner_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OwnerApp());
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet Owner Dashboard - Truck Logistics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        appBarTheme: const AppBarTheme(
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
      ),
      home: const OwnerDashboardScreen(),
    );
  }
}
