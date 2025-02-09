import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'challenge_page.dart';
import 'journaling_page.dart';
import 'profile_page.dart';

final List<String> lessonTopics = ['Music', 'Literature', 'Art', 'Philosophy', 'Journaling'];
final List<Map<String, dynamic>> jsonData = [
  {
    "lesson_id": "lesson1",
    "topic": "Art",
    "lesson_title": "Understanding Colors",
    "type": "lesson_quiz",
    "description": "Learn more about the psychology of colors and how they can influence emotions.",
    "lesson_content": [
      "assets/understanding_colors_page1.png",
      "assets/understanding_colors_page2.png"
    ],
    "quiz": {
      "What color is a mix of blue and yellow?": [["Green", "Purple", "Orange", "Pink"], 0],
      "What does red often symbolize?": [["Peace", "Urgency", "Sadness", "Happiness"], 1]
    }
  },
  {
    "lesson_id": "lesson2",
    "topic": "Music",
    "lesson_title": "The Evolution of Sound",
    "type": "lesson_quiz",
    "description": "Explore the history of music and its impact on culture and society.",
    "lesson_content": [
      "assets/evolution_of_sound_page1.png",
      "assets/evolution_of_sound_page2.png"
    ],
    "quiz": {
      "Who is considered the father of modern classical music?": [["Beethoven", "Mozart", "Bach", "Chopin"], 0],
      "Which of these is a modern genre?": [["Classical", "Jazz", "Rock", "Opera"], 2]
    }
  },
  {
    "lesson_id": "lesson3",
    "topic": "Literature",
    "lesson_title": "The Art of Storytelling",
    "type": "lesson_quiz",
    "description": "Discover the elements of storytelling and how narratives shape our understanding of the world.",
    "lesson_content": [
      "assets/art_of_storytelling_page1.png",
      "assets/art_of_storytelling_page2.png"
    ],
    "quiz": {
      "What is the central element of any story?": [["Plot", "Characters", "Theme", "Setting"], 0],
      "Which of these is a common storytelling technique?": [["Flashbacks", "Foreshadowing", "Monologue", "All of the above"], 3]
    }
  },
  {
    "lesson_id": "lesson4",
    "topic": "Philosophy",
    "lesson_title": "Introduction to Ethics",
    "type": "lesson_quiz",
    "description": 
        "Explore ethical theories and principles that guide human behavior and decision-making.",
    "lesson_content": [
      "assets/introduction_to_ethics_page1.png",
      "assets/introduction_to_ethics_page2.png"
    ],
    "quiz": {
      "Which ethical theory focuses on the greatest good for the greatest number?": [["Utilitarianism", "Deontology", "Virtue Ethics", "Relativism"], 0],
      "Which ethical theory emphasizes duty and rules?": [["Utilitarianism", "Deontology", "Virtue Ethics", "Relativism"], 1]
    }
  },
  {
    "lesson_id": "lesson5",
    "topic": "Journaling",
    "lesson_title": "Reflective Writing",
    "type": "journal",
    "description": 
        "Explore the benefits of journaling and how it can enhance self-awareness and mental health.",
    "lesson_content": [
      // Journaling lessons are represented as infographic pages for consistency
      // No quiz content for journaling lessons
      "assets/reflective_writing_page1.png",
      "assets/reflective_writing_page2.png"
    ],
    // Journaling lessons do not include quizzes
    // Keeping quiz empty for this type
    "quiz": {}
  }
];


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  late PageController _calendarController;
  late DateTime _baseMonth;
  final int _initialPage = 1;

  DateTime displayedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String? selectedTopic;
  int currentTopicIndex = 0;
  int streak = 5;

  @override
  void initState() {
    super.initState();
    _baseMonth = DateTime.now();
    displayedMonth = _baseMonth;
    _calendarController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _scrollController.dispose();
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
              const Text(
                "Good Morning, [Name]!",
                style: TextStyle(
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
          // Display the current year and month.
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
          // Weekdays row.
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
              selectedDate = currentDate;
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
    final currentLesson = jsonData[currentTopicIndex];

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
              Text(
                currentLesson['topic'].toString().toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    currentTopicIndex = (currentTopicIndex - 1) % jsonData.length;
                    selectedTopic = jsonData[currentTopicIndex]['topic'];
                  });
                },
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey<int>(currentTopicIndex),
                    children: [
                      Container(
                        height: 400,
                        width: 400,
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
                        currentLesson['description'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF282828).withOpacity(0.6),
                          height: 1.8,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    currentTopicIndex = (currentTopicIndex + 1) % jsonData.length;
                    selectedTopic = jsonData[currentTopicIndex]['topic'];
                  });
                },
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
                    builder: (context) => selectedTopic == 'Journaling'
                        ? const JournalingPage()
                        : ChallengePage(jsonData: jsonData[currentTopicIndex]),
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
