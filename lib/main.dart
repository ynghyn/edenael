import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EdeNaelApp());
}

class EdeNaelApp extends StatelessWidget {
  const EdeNaelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdeNael - 찬양 플레이리스트',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern color scheme matching your web app
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Primary indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFFF59E0B), // Amber
          background: const Color(0xFFF8FAFC),
          surface: Colors.white,
        ),
        
        // Korean font support with error handling
        textTheme: GoogleFonts.notoSansKrTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF1E293B),
          displayColor: const Color(0xFF1E293B),
        ),
        
        // Modern elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Card theme
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.all(8),
        ),
        
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.notoSansKr(
            color: const Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      
      home: const HomeScreen(),
    );
  }
}