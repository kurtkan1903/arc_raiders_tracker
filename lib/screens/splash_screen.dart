import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserSelectionScreen())
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset('assets/images/logo.webp', width: 180, 
                    errorBuilder: (c, e, s) => const Icon(Icons.radar, color: Colors.blueAccent, size: 80)),
                ),
                const SizedBox(height: 50),
                Text("ARC RAIDERS", style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8)),
                const SizedBox(height: 8),
                Text("TRACKING SYSTEM v2.0", style: GoogleFonts.inter(color: Colors.white12, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 60),
                SizedBox(
                  width: 150,
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: Colors.blueAccent.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text("ESTABLISHING SPERANZA UPLINK...", 
                style: GoogleFonts.inter(color: Colors.white10, fontSize: 9, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
