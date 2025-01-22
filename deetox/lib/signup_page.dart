import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'interest_selection.dart';


class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Header Text
            Text(
              'Sign Up',
              style: GoogleFonts.openSans(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 40),
            
            // Full Name Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: TextStyle(color: Color(0xFF282828).withOpacity(0.6)),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF282828), width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF282828), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Email Field
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Color(0xFF282828).withOpacity(0.6)),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF282828), width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF282828), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Password Field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Color(0xFF282828).withOpacity(0.6)),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF282828), width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF282828), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const Spacer(),
            
            // Sign Up Button
            Container(
              width: double.infinity,
              height: 48,
              color: Color(0xFF282828),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InterestSelectionPage()),
                  );
                },
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Login Link
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Color(0xFF282828),
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
