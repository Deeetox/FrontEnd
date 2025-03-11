import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<SharedPreferences> _prefsFuture;
  String? _selectedQuestion;
  String? _userName;
  String _answer = '';

  // Updated menu options for app settings
  final Map<String, List<String>> menuOptions = {
    'SOUND': ['ON', 'OFF', 'VIBRATE'],
    'BRIGHTNESS': ['AUTO', 'LIGHT', 'DARK'],
  };

  // Profile customization questions
  final List<String> questions = [
    'FAVORITE BINGE SHOW',
    'YOU CAN ALWAYS FIND ME...',
    'FAVORITE THING ABOUT WORK IS...',
    'DREAM VACATION SPOT',
    'MORNING ROUTINE INCLUDES',
    'BEST PART OF MY DAY IS',
  ];

  final Map<String, String> _selectedOptions = {};
  final Map<String, String> _answers = {};

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
    _loadPreferences();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'Guest';
      });
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefsFuture;
    setState(() {
      for (var category in menuOptions.keys) {
        _selectedOptions[category] = prefs.getString(category) ?? menuOptions[category]!.first;
      }
      _selectedQuestion = prefs.getString('selectedQuestion');
      _answer = prefs.getString('answer') ?? '';
    });
  }

  Widget _buildHorizontalOptions(String category, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: GoogleFonts.spaceMono(
            fontSize: 14,
            color: const Color(0xFF282828),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((option) {
            bool isSelected = _selectedOptions[category] == option;
            return GestureDetector(
              onTap: () async {
                final prefs = await _prefsFuture;
                await prefs.setString(category, option);
                setState(() => _selectedOptions[category] = option);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    option,
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      color: const Color(0xFF282828),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    CustomPaint(
                      painter: CircleIndicatorPainter(),
                      size: const Size(80, 40),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const Divider(color: Color(0xFF282828)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'vol. 02',
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        color: const Color(0xFF282828),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout_rounded, color: Color(0xFF282828)),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'HELLO my name is',
                  style: GoogleFonts.spaceMono(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF282828),
                    height: 1.2,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF282828)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ' ${_userName ?? 'Guest'} ',
                        style: GoogleFonts.spaceMono(
                          color: const Color(0xFF282828),
                          fontSize: 18,
                        ),
                      ),
                      
                    ],
                  ),
                ),
                ...menuOptions.entries.map((entry) => 
                  _buildHorizontalOptions(entry.key, entry.value)),
                const SizedBox(height: 30),
                DropdownButton<String>(
                  value: _selectedQuestion,
                  hint: Text(
                    'SELECT A QUESTION',
                    style: GoogleFonts.spaceMono(
                      color: const Color(0xFF282828),
                    ),
                  ),
                  isExpanded: true,
                  underline: Container(
                    height: 1,
                    color: const Color(0xFF282828),
                  ),
                  items: questions.map((String question) {
                    return DropdownMenuItem<String>(
                      value: question,
                      child: Text(
                        question,
                        style: GoogleFonts.spaceMono(
                          color: const Color(0xFF282828),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      final prefs = await _prefsFuture;
                      await prefs.setString('selectedQuestion', newValue);
                      setState(() => _selectedQuestion = newValue);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  child: TextField(
                    controller: TextEditingController(text: _answer),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dancingScript(
                      fontSize: 24,
                      color: const Color(0xFF282828),
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF282828)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF282828)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF282828)),
                      ),
                    ),
                    onChanged: (value) async {
                      final prefs = await _prefsFuture;
                      await prefs.setString('answer', value);
                      setState(() => _answer = value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF282828)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * 3.14159,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
