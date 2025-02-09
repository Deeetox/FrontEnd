import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your HomePage

class ChallengePage extends StatefulWidget {
  final Map<String, dynamic> jsonData;

  const ChallengePage({required this.jsonData});

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  late PageController _pageController;
  int currentIndex = 0;
  Map<int, bool> answeredQuestions = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Build lesson content as full-screen images
  Widget buildLessonContent(String imagePath) {
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.localPosition.dx < screenWidth / 2) {
          // Tap left
          if (currentIndex > 0) {
            _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // Tap right
          if (currentIndex < widget.jsonData['lesson_content'].length + widget.jsonData['quiz'].length - 1) {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  // Build quiz content with immediate feedback
  Widget buildQuizContent(String question, List<String> choices, int correctAnswerIndex, int questionIndex) {
    return Container(
      color: Color(0xFFF9F6EF), // Beige or light gray background
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0), // Margins for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spacer to position question at ~40% of the screen height
          Spacer(flex: 5),

          // Question Text
          Text(
            question,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w700, // Increased weight
              height: 0.9, // Reduced line spacing further
              color: Color(0xFF222021),
            ),
            textAlign: TextAlign.left,
          ),

          // Horizontal Line Under Question
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
              height: 3, // Thickness of the line
              color: Color(0xFF222021),
            ),
          ),

          // Spacer between question and answers
          SizedBox(height: 24),

          // Answer Choices
          ...choices.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;

            return GestureDetector(
              onTap: () {
                setState(() {
                  answeredQuestions[questionIndex] = true;
                });

                final isCorrect = index == correctAnswerIndex;

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Color(0xFFF9F6EF),
                    title: Text(
                      isCorrect ? "Correct!" : "Incorrect",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    content: Text(
                      isCorrect
                          ? "You selected the correct answer."
                          : "The correct answer is ${choices[correctAnswerIndex]}.",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          if (currentIndex < widget.jsonData['lesson_content'].length + widget.jsonData['quiz'].length - 1) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else if (answeredQuestions.length == widget.jsonData['quiz'].length) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                            );
                          }
                        },
                        child: Text("Next", style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numbering for each choice
                    Text(
                      "${index + 1}. ",
                      style: TextStyle(fontSize: 18, color: Color(0xFF222021)),
                    ),
                    Expanded(
                      child: Text(
                        choice,
                        style: TextStyle(fontSize: 18, color: Color(0xFF222021)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Spacer to push content upwards
          Spacer(flex: 6),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final lessonContent = widget.jsonData['lesson_content'] as List<String>;
    final quiz = widget.jsonData['quiz'] as Map<String, dynamic>;

    // Combine lesson pages and quiz pages into one list
    final pages = [
      ...lessonContent.map((imagePath) => buildLessonContent(imagePath)).toList(),
      ...quiz.entries.map((entry) {
        int questionIndex = lessonContent.length + quiz.keys.toList().indexOf(entry.key);
        return buildQuizContent(entry.key, entry.value[0], entry.value[1], questionIndex);
      }).toList(),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        physics:
            currentIndex >= lessonContent.length ? NeverScrollableScrollPhysics() : null,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) => pages[index],
      ),
    );
  }
}
