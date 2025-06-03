import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'interest_selection.dart' show getSavedLesson;
import 'challenge_page.dart';
import 'journaling_page.dart';
import 'profile_page.dart';

const String APPWRITE_ENDPOINT = 'https://fra.cloud.appwrite.io/v1';
const String APPWRITE_PROJECT_ID = '68311c8b000a47b14944';
const String BUCKET_ID = '68311d94003c6f0af2e6';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userName;
  String? _selectedTopic;
  DateTime? _lessonStartDate;

  final ScrollController _scrollController = ScrollController();
  late PageController _calendarController;
  late DateTime _baseMonth;
  final int _initialPage = 1;

  DateTime displayedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String? selectedTopic;
  int streak = 5;

  late PageController _lessonController;
  List<Map<String, dynamic>> _availableLessons = [];
  int _currentLessonIndex = 0;

  List<dynamic> _lessonJsonList = []; // Loaded from Appwrite

  @override
  void initState() {
    super.initState();
    _lessonController = PageController(initialPage: 0);
    _loadUserData();
    _loadLessonData();
    _baseMonth = DateTime.now();
    displayedMonth = _baseMonth;
    _calendarController = PageController(initialPage: _initialPage);
  }

  Future<void> _loadUserData() async {
    // Replace with your Appwrite user fetch if needed
    setState(() {
      _userName = 'Guest';
    });
  }

  Future<void> _loadLessonData() async {
    final savedData = await getSavedLesson();
    if (savedData.isNotEmpty) {
      setState(() {
        _selectedTopic = savedData['lesson'];
        try {
          _lessonStartDate = DateTime.parse(savedData['startDate']!);
        } catch (e) {
          _lessonStartDate = DateTime.now();
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final selectedLesson = prefs.getString('selectedLesson') ?? 'lesson1';
      final lessonFileName = '$selectedLesson.json';

      try {
        final lessonJson = await _fetchAndCacheLessonJson(lessonFileName);
        setState(() {
          if (lessonJson is List) {
            _lessonJsonList = lessonJson;
          } else if (lessonJson is Map && lessonJson['lessons'] is List) {
            _lessonJsonList = lessonJson['lessons'];
          } else {
            _lessonJsonList = [lessonJson];
          }
        });
        _calculateAvailableLessons();
      } catch (e) {
        // Handle error (show dialog, etc)
        setState(() {
          _lessonJsonList = [];
        });
      }
    }
  }

  Future<dynamic> _fetchAndCacheLessonJson(String lessonFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$lessonFileName';
    final file = File(filePath);

    if (await file.exists()) {
      final contents = await file.readAsString();
      return json.decode(contents);
    }

    final client = Client()
      ..setEndpoint(APPWRITE_ENDPOINT)
      ..setProject(APPWRITE_PROJECT_ID);
    final storage = Storage(client);

    try {
      final result = await storage.getFileDownload(
        bucketId: BUCKET_ID,
        fileId: lessonFileName,
      );
      await file.writeAsBytes(result);
      final contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      throw Exception('Failed to fetch lesson JSON: $e');
    }
  }

  void _calculateAvailableLessons() {
    List<Map<String, dynamic>> lessons = [];

    if (_lessonStartDate != null && _lessonJsonList.isNotEmpty) {
      final difference = selectedDate.difference(_lessonStartDate!).inDays;
      if (difference >= 0 && difference < _lessonJsonList.length) {
        final lesson = _lessonJsonList[difference];
        if (lesson is Map<String, dynamic>) {
          lessons.add(lesson);
        } else if (lesson is Map) {
          lessons.add(Map<String, dynamic>.from(lesson));
        }
      }
    }

    bool hasJournaling = lessons.any((l) => (l['topic']?.toString().toLowerCase() ?? '') == 'journaling');
    if (!hasJournaling) {
      lessons.add({
        "lesson_id": "journaling",
        "topic": "Journaling",
        "lesson_title": "Reflective Writing",
        "type": "journal",
        "description": "Explore the benefits of journaling and how it can enhance self-awareness and mental health.",
        "lesson_content": [
          "assets/reflective_writing_page1.png",
          "assets/reflective_writing_page2.png"
        ],
        "quiz": {}
      });
    }

    setState(() {
      _availableLessons = lessons;
      _currentLessonIndex = 0;
      _updateTopicTitle();
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _scrollController.dispose();
    _lessonController.dispose();
    super.dispose();
  }

  String _getStreakMessage() {
    if (streak > 0) {
      return "You're on a $streak day streak!\nKeep up the great work!";
    }
    return "Start your journey today!\nBegin with your first lesson!";
  }

  Widget _buildWelcomePage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFFF9F6EF),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Good Morning, ${_userName ?? 'Guest'}!",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: Color(0xFF282828),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getStreakMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF282828).withOpacity(0.6),
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  MediaQuery.of(context).size.height,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Column(
                children: [
                  Text(
                    'Scroll Down',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF282828).withOpacity(0.3),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF282828).withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      color: const Color(0xFFF9F6EF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${displayedMonth.year}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF282828),
                  height: 1.5,
                ),
              ),
              Text(
                DateFormat('MMMM').format(displayedMonth).toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF282828),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF282828)),
                bottom: BorderSide(color: Color(0xFF282828)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                  .map((day) => Text(
                        day,
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: Color(0xFF282828),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _calendarController,
              onPageChanged: (index) {
                setState(() {
                  displayedMonth = DateTime(
                    _baseMonth.year,
                    _baseMonth.month + (index - _initialPage),
                  );
                });
              },
              itemBuilder: (context, index) {
                DateTime monthToShow = DateTime(
                  _baseMonth.year,
                  _baseMonth.month + (index - _initialPage),
                );
                return _buildCalendarGrid(monthToShow);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleDateSelection(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      _calculateAvailableLessons();
    });
  }

  Widget _buildCalendarGrid(DateTime month) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.5,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final firstDay = DateTime(month.year, month.month, 1);
        final firstDayOffset = firstDay.weekday % 7;
        final day = index - firstDayOffset + 1;

        if (day < 1 || day > DateTime(month.year, month.month + 1, 0).day) {
          return const SizedBox();
        }

        final currentDate = DateTime(month.year, month.month, day);
        final isSelected = currentDate.year == selectedDate.year &&
            currentDate.month == selectedDate.month &&
            currentDate.day == selectedDate.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _handleDateSelection(currentDate);
            });
            _scrollController.animateTo(
              MediaQuery.of(context).size.height * 2,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF282828) : Colors.transparent,
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF282828),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonSelection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(40),
      color: const Color(0xFFF9F6EF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDate.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF282828),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    _availableLessons.isNotEmpty
                        ? _availableLessons[_currentLessonIndex]['topic']
                            .toString()
                            .toUpperCase()
                        : '',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _availableLessons.isNotEmpty && _currentLessonIndex > 0
                    ? () {
                        _lessonController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              Expanded(
                child: SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: _lessonController,
                    itemCount: _availableLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = _availableLessons[index];
                      return Column(
                        children: [
                          Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              image: const DecorationImage(
                                image: AssetImage('assets/lesson_placeholder.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            lesson['description'] ?? '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF282828).withOpacity(0.6),
                              height: 1.8,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    },
                    onPageChanged: (index) {
                      setState(() {
                        _currentLessonIndex = index;
                        _updateTopicTitle();
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _availableLessons.isNotEmpty && _currentLessonIndex < _availableLessons.length - 1
                    ? () {
                        _lessonController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 48,
            color: const Color(0xFF282828),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _availableLessons.isNotEmpty &&
                            _availableLessons[_currentLessonIndex]['topic'] == 'Journaling'
                        ? const JournalingPage()
                        : ChallengePage(jsonData: _availableLessons[_currentLessonIndex]),
                  ),
                );
              },
              child: const Text(
                'START LESSON',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTopicTitle() {
    if (_availableLessons.isNotEmpty &&
        _currentLessonIndex >= 0 &&
        _currentLessonIndex < _availableLessons.length) {
      setState(() {
        selectedTopic = _availableLessons[_currentLessonIndex]['topic'];
      });
    } else {
      setState(() {
        selectedTopic = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const PageScrollPhysics(),
        child: Column(
          children: [
            _buildWelcomePage(),
            _buildCalendar(),
            _buildLessonSelection(),
          ],
        ),
      ),
    );
  }
}
