import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEETOX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF282828)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<void> _imageLoadingFuture;

  @override
  void initState() {
    super.initState();
    _imageLoadingFuture = _preloadImage('assets/moon_surface.jpg');
  }

  Future<void> _preloadImage(String imagePath) async {
    final assetImage = AssetImage(imagePath);
    final completer = Completer<void>();

    assetImage.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          completer.complete();
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          completer.completeError(error, stackTrace);
        },
      ),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateFormat('MMM').format(now).toUpperCase();
    final nextMonth = DateFormat('MMM').format(
      DateTime(now.year, now.month + 1),
    ).toUpperCase();
    final day = now.day.toString();

    final screenWidth = MediaQuery.of(context).size.width;
    final barsPosition = screenWidth * 0.80; // 10% offset from right edge

    return FutureBuilder<void>(
      future: _imageLoadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the image to load
          return const Scaffold(
            backgroundColor: Color(0xFFF9F6EF),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle image loading error
          return Scaffold(
            backgroundColor: const Color(0xFFF9F6EF),
            body: const Center(
              child: Text(
                'Failed to load image.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // Once the image is loaded, show the main content
        return Scaffold(
          backgroundColor: const Color(0xFFF9F6EF),
          body: Stack(
            children: [
              // Leftmost Black Bar (positioned under the image)
              Positioned(
                top: 80,
                left: barsPosition - 140,
                child: Container(
                  width: 15,
                  height: 400,
                  color: Color(0xFF282828),
                ),
              ),

              // Main Image Container
              Positioned(
                top: 100,
                left: 50,
                right: 50,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: const DecorationImage(
                        image: AssetImage('assets/moon_surface.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Vertical Black Bars
              Positioned(
                top: 80,
                left: barsPosition - 125,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) => Container(
                        margin: const EdgeInsets.only(left: 12),
                        width: 15,
                        height: 450,
                        color: Color(0xFF282828),
                      )),
                ),
              ),

              // DEETOX Text
              Positioned(
                left: 50,
                top: 420,
                child: Text(
                  'DEETOX.',
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // Date Section
              Positioned(
                right: 50,
                top: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentMonth,
                      style: const TextStyle(letterSpacing: 8, fontSize: 14),
                    ),
                    Text(
                      nextMonth,
                      style: const TextStyle(letterSpacing: 8, fontSize: 14),
                    ),
                    Text(
                      "'$day",
                      style: const TextStyle(letterSpacing: 8, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Buttons at bottom
              Positioned(
                left: 40,
                right: 40,
                bottom: 40,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF282828)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        child: const Text(
                          'GET STARTED',
                          style: TextStyle(
                            color: Color(0xFF282828),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 48,
                      color: Color(0xFF282828),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'LOG IN',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
