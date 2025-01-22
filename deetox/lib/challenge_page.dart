import 'package:flutter/material.dart';

class ChallengePage extends StatefulWidget {
  final Map<String, dynamic> jsonData;

  const ChallengePage({required this.jsonData});

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  int currentQuestionIndex = 0;
  Map<int, String> userAnswers = {};

  @override
  Widget build(BuildContext context) {
    final jsonData = widget.jsonData;
    final lessonType = jsonData['type'];
    final lesson = jsonData['lesson'];
    final questions = lesson['questions'];
    final questionData = questions[currentQuestionIndex];

    // Progress bar at the top
    Widget buildProgressBar() {
      double progress = (currentQuestionIndex + 1) / questions.length;
      return Container(
        width: double.infinity,
        height: 3.0,
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange, Colors.yellow]),
          borderRadius: BorderRadius.circular(1.5),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(color: Colors.orange),
        ),
      );
    }

    // Introductory lesson content
    Widget buildLessonContent() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          lesson['content'],
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF363B44),
          ),
        ),
      );
    }

    // Quiz type questions (multiple choice)
    Widget buildQuizContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionData['question'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF363B44),
            ),
          ),
          SizedBox(height: 16.0),
          ...questionData['options'].map<Widget>((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  userAnswers[currentQuestionIndex] = option;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: userAnswers[currentQuestionIndex] == option
                      ? Colors.orangeAccent.withAlpha(150)
                      : Color(0xFFF1EAE0),
                  border: Border.all(
                    color: userAnswers[currentQuestionIndex] == option
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF363B44),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      );
    }

    // Open-ended questions
    Widget buildOpenEndedContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionData['question'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF363B44),
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            onChanged: (value) {
              userAnswers[currentQuestionIndex] = value;
            },
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Color(0xFFF1EAE0),
            ),
            maxLines: 5,
          ),
        ],
      );
    }

    // Determine the type of question to render
    Widget buildQuestionContent() {
      return lessonType == "quiz" ? buildQuizContent() : buildOpenEndedContent();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF1EAE0),
      appBar: AppBar(
        title: Text(jsonData['title']),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildProgressBar(),
              SizedBox(height: 20.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLessonContent(),
                      buildQuestionContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: currentQuestionIndex > 0
                  ? () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    }
                  : null,
              child: Text("Back"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: currentQuestionIndex < questions.length - 1
                  ? () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                  : () {
                      // Submit answers logic
                      print(userAnswers); // Example: Output user's answers
                    },
              child: Text(
                  currentQuestionIndex < questions.length - 1 ? "Next" : "Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
