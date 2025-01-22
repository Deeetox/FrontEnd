import 'package:flutter/material.dart';
import 'home_page.dart';

class TimeSelectionPage extends StatefulWidget {
  const TimeSelectionPage({super.key});

  @override
  _TimeSelectionPageState createState() => _TimeSelectionPageState();
}

class _TimeSelectionPageState extends State<TimeSelectionPage> {
  late int selectedHour;
  late int selectedMinute;
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;

  @override
  void initState() {
    super.initState();
    selectedHour = DateTime.now().hour;
    selectedMinute = DateTime.now().minute;

    // Initialize controllers
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    hourController?.dispose();
    minuteController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized before building the widget
    if (hourController == null || minuteController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6EF),
        body: Stack(
          children: [
            // Header
            Positioned(
              top: 40,
              left: 40,
              child: const Text(
                '00.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF282828),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'TIME SELECTION',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF282828),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
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
            ),
            // Main content
            Positioned(
              bottom: 90,
              right: 40,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: Color(0xFF282828),
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Text(
                      '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTimeWheel(
                              controller: hourController!,
                              value: selectedHour,
                              maxValue: 23,
                              onChanged: (value) => setState(() => selectedHour = value),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTimeWheel(
                              controller: minuteController!,
                              value: selectedMinute,
                              maxValue: 59,
                              onChanged: (value) => setState(() => selectedMinute = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page number
            Positioned(
              bottom: 40,
              right: 40,
              child: const Text(
                '02',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF282828),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWheel({
    required FixedExtentScrollController controller,
    required int value,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: maxValue + 1,
        builder: (context, index) {
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 16,
                color: value == index ? Color(0xFF282828) : Color(0xFF282828),
              ),
            ),
          );
        },
      ),
    );
  }
}
