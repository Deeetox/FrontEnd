import 'package:flutter/material.dart';
import 'time_selection.dart';

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({super.key});

  @override
  _InterestSelectionPageState createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> with SingleTickerProviderStateMixin {
  final Map<String, bool> selectedInterests = {
    'Music': false,
    'Literature': false,
    'Art': false,
    'Philosophy': false,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),
      body: Stack(
        children: [
          // Header at top
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TimeSelectionPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'GO',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF282828),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content at bottom right
          Positioned(
            bottom: 90,
            right: 40,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMainSection('01', 'MINDFULNESS', [
                    _buildSubsection('01.1', 'Music', '01'),
                    _buildSubsection('01.2', 'Literature', '04'),
                    _buildSubsection('01.3', 'Philosophy', '14'),
                  ]),
                  
                  const SizedBox(height: 40),
                  
                  _buildMainSection('02', 'CREATIVITY', [
                    _buildSubsection('02.1', 'Art', '16'),
                  ]),
                ],
              ),
            ),
          ),
          
          // Page number at bottom right
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

  Widget _buildMainSection(String number, String title, List<Widget> subsections) {
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
        ...subsections,
      ],
    );
  }

  Widget _buildSubsection(String number, String title, String page) {
    bool isSelected = selectedInterests[title] ?? false;
    
    return TweenAnimationBuilder(
      tween: ColorTween(
        begin: Colors.transparent,
        end: isSelected ? Color(0xFF282828).withOpacity(0.1) : Colors.transparent,
      ),
      duration: const Duration(milliseconds: 300),
      builder: (context, Color? color, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedInterests[title] = !isSelected;
            });
          },
          child: Container(
            color: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 60),
                SizedBox(
                  width: 60,
                  child: Text(
                    number,
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
                    alignment: Alignment.centerRight,  // Right align the text
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        );
      },
    );
  }
}
