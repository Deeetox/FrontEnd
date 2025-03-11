// interest_selection.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'time_selection.dart';
import 'package:intl/intl.dart';

// Top-level function to get saved lesson data
Future<Map<String, String>> getSavedLesson() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lesson = prefs.getString('selectedLesson');
  String? startDate = prefs.getString('lessonStartDate');

  if (lesson != null && startDate != null) {
    return {'lesson': lesson, 'startDate': startDate};
  }
  return {};
}

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({Key? key}) : super(key: key);

  @override
  _InterestSelectionPageState createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage>
    with SingleTickerProviderStateMixin {
  String? selectedTopic;
  String? selectedLesson;
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<String, List<Map<String, String>>> lessons = {
    'Music (Coming Soon!)': [
      {'title': 'Intro to Music', 'days': '5', 'description': 'Learn the basics of music theory and history.'},
      {'title': 'Classical Composers', 'days': '7', 'description': 'Explore the lives of famous composers.'},
    ],
    'Literature (Coming Soon!)': [
      {'title': 'Shakespearean Drama', 'days': '6', 'description': "A dive into Shakespeare's works and themes."},
      {'title': 'Modern Poetry', 'days': '4', 'description': 'Analyzing contemporary poetry styles.'},
    ],
    'Philosophy (Coming Soon!)': [
      {'title': 'Existentialism', 'days': '7', 'description': 'An overview of existentialist philosophy.'},
      {'title': 'Ethics & Morality', 'days': '5', 'description': 'Discuss key ethical theories and applications.'},
    ],
    'Art': [
      {'title': 'What is Art?', 'days': '5', 'description': 'Define art, its forms, and its subjective nature.'},
      {'title': 'Elements of Art', 'days': '5', 'description': 'Study the foundational elements like line, shape, color, texture, and space.'},
      {'title': 'Principles of Design', 'days': '5', 'description': 'Understand balance, contrast, rhythm, unity, and variety in design.'},
      {'title': 'Prehistoric to Ancient Art', 'days': '5', 'description': 'Explore art from prehistoric times to ancient civilizations like Egypt, Greece, and Rome.'},
      {'title': 'Medieval to Renaissance Art', 'days': '5', 'description': 'Study Byzantine mosaics, Gothic cathedrals, and Renaissance masters like da Vinci and Michelangelo.'},
      {'title': 'Baroque to Romanticism', 'days': '5', 'description': 'Analyze Baroque drama, Rococo elegance, Neoclassicism’s order, and Romanticism’s emotion.'},
      {'title': 'Impressionism to Post-Impressionism', 'days': '5', 'description': 'Study Impressionist techniques and Post-Impressionism’s emotional depth.'},
      {'title': 'Early Modernism', 'days': '5', 'description': "Explore Cubism's abstraction and Fauvism's bold colors."},
      {'title': 'Surrealism and Abstract Expressionism', 'days': '5', 'description': "Analyze Surrealism's dreamscapes and Abstract Expressionism's spontaneity."},
      {'title': 'African & Islamic Art', 'days': '5', 'description': "Study African sculpture and textiles alongside Islamic geometric patterns and calligraphy."},
      {'title': 'Asian & Indigenous American Art', 'days': '5', 'description': "Explore Asian ink painting and Indigenous American pottery traditions."},
      {'title': 'Art Criticism & Interpretation', 'days': '5', 'description': "Learn to describe, analyze, interpret, and critique artworks effectively."}
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTopic(String topic) {
    setState(() {
      if (selectedTopic == topic) {
        selectedTopic = null;
        selectedLesson = null;
        _controller.reverse();
      } else {
        selectedTopic = topic;
        selectedLesson = null;
        _controller.forward(from: 0.0);
      }
    });
  }

  void _selectLesson(String lesson) async {
    setState(() {
      selectedLesson = (selectedLesson == lesson) ? null : lesson;
    });

    if (selectedLesson != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('selectedLesson', selectedLesson!);
      await prefs.setString('lessonStartDate', currentDate);
       // Debugging line
    }
    print('Selected Lesson: $selectedLesson');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      '00.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF282828),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 100),
                    Text(
                      'CONTENTS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF282828),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: selectedLesson != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TimeSelectionPage()),
                          );
                        }
                      : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'GO',
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedLesson != null ? Color(0xFF282828) : Colors.grey,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 90,
            right: 40,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMainSection('01', 'MINDFULNESS', ['Music (Coming Soon!)', 'Literature (Coming Soon!)', 'Philosophy (Coming Soon!)']),
                  const SizedBox(height: 40),
                  _buildMainSection('02', 'CREATIVITY', ['Art']),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: Text(
              '01',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF282828),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSection(String number, String title, List<String> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...topics.asMap().entries.map((entry) => _buildTopic(number, entry.key + 1, entry.value)),
      ],
    );
  }

  Widget _buildTopic(String chapterNumber, int topicIndex, String topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectTopic(topic),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 60),
                SizedBox(
                  width: 60,
                  child: Text(
                    '$chapterNumber.$topicIndex',
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '/',
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight, // Align topic to the right
                    child: Text(
                      topic.toUpperCase(),
                      textAlign: TextAlign.right, // Also align text within the widget
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: selectedTopic == topic ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: selectedTopic == topic ? 200.0 : 0.0,
            ),
            child: ClipRect(
              child: SingleChildScrollView(
                child: Column(
                  children: (selectedTopic == topic && lessons[topic] != null)
                      ? lessons[topic]!
                          .map((lesson) => _buildLesson(lesson))
                          .toList()
                      : [],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLesson(Map<String, String> lesson) {
    bool isSelected = selectedLesson == lesson['title'];

    return TweenAnimationBuilder(
      tween: ColorTween(
        begin: Colors.transparent,
        end: isSelected ? const Color(0xFF282828).withOpacity(0.1) : Colors.transparent,
      ),
      duration: const Duration(milliseconds: 300),
      builder: (context, Color? color, child) {
        return GestureDetector(
          onTap: () => _selectLesson(lesson['title']!),
          child: Container(
            color: color,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lesson['days']} days',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson['description']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, letterSpacing: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
