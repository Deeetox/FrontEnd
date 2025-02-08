import 'dart:math';
import 'package:flutter/material.dart';
import 'home_page.dart';

class TimeSelectionPage extends StatefulWidget {
  const TimeSelectionPage({Key? key}) : super(key: key);

  @override
  _TimeSelectionPageState createState() => _TimeSelectionPageState();
}

class _TimeSelectionPageState extends State<TimeSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  DateTime _selectedTime = DateTime.now();
  double _hourRotation = 0.0;
  double _minuteRotation = 0.0;
  bool _isAM = true;
  bool _isInteractingWithHour = false;
  bool _isInteractingWithMinute = false;
  Color? _currentBackgroundColor;
  bool _isNightTime = false;

  late Color _textColor;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final now = DateTime.now();
    _selectedTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _hourRotation = _calculateHourRotation(_selectedTime.hour, _selectedTime.minute);
    _minuteRotation = _calculateMinuteRotation(_selectedTime.minute);

    _isNightTime = _checkIsNightTime(_selectedTime.hour);
    _currentBackgroundColor = _isNightTime ? Colors.black : Colors.white;
    _textColor = _currentBackgroundColor == Colors.black ? Colors.white : Colors.black;

    _colorAnimation = AlwaysStoppedAnimation<Color?>(_currentBackgroundColor);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _checkIsNightTime(int hour) {
    return hour >= 18 || hour < 6;
  }

  void _updateColorAnimation({bool animate = true}) {
    final isNightTime = _checkIsNightTime(_selectedTime.hour);

    if (isNightTime != _isNightTime) {
      _isNightTime = isNightTime;
      final beginColor = _currentBackgroundColor;
      final endColor = isNightTime ? Colors.black : Colors.white;

      _colorAnimation = ColorTween(begin: beginColor, end: endColor).animate(_animationController)
        ..addListener(() {
          setState(() {
            // Update background color during animation
            _currentBackgroundColor = _colorAnimation.value;
          });
        });

      if (animate) {
        _animationController.forward(from: 0.0); // Always start from the beginning
      }

      _textColor = endColor == Colors.black ? Colors.white : Colors.black;

    } else {
      _colorAnimation = AlwaysStoppedAnimation<Color?>(_currentBackgroundColor);
    }
  }

  double _calculateHourRotation(int hour, int minute) {
    return pi * (((hour % 12) + (minute / 60)) / 6);
  }

  double _calculateMinuteRotation(int minute) {
    return pi * (minute / 30);
  }

  void _updateSelectedTime() {
    int hour = ((_hourRotation / (2 * pi) * 12 + 3) % 12).round();
    if (hour == 0) hour = 12;
    int minute = ((_minuteRotation / (2 * pi) * 60 + 15) % 60).round();

    if (!_isAM && hour != 12) {
      hour += 12;
    } else if (_isAM && hour == 12) {
      hour = 0;
    }

    // Check if the hour has changed before updating the state
    if (_selectedTime.hour != hour) {
      _selectedTime = DateTime(_selectedTime.year, _selectedTime.month, _selectedTime.day, hour, minute);
      _updateColorAnimation();
    } else {
      _selectedTime = DateTime(_selectedTime.year, _selectedTime.month, _selectedTime.day, hour, minute);
    }
  }


  String get _selectedTimeString {
    final hour = _selectedTime.hour % 12 == 0 ? 12 : _selectedTime.hour % 12;
    final minute = _selectedTime.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${_selectedTime.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        final backgroundColor = _currentBackgroundColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.arrow_back_ios, color: _textColor, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            title: Text(
              "TIME SELECTION",
              style: TextStyle(fontSize: 16, color: _textColor),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text(
                  "GO",
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Drag the hands to set the time:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                        fontFamily: 'PixelifySans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final clockSize = min(constraints.maxWidth, constraints.maxHeight);
                        final center = Offset(clockSize / 2, clockSize / 2);
                        final hourHandLength = clockSize * 0.3;
                        final minuteHandLength = clockSize * 0.45;

                        return GestureDetector(
                          onPanStart: (details) {
                            RenderBox box = context.findRenderObject() as RenderBox;
                            Offset position = details.localPosition;

                            double distance = (position - center).distance;

                            _isInteractingWithHour = distance <= hourHandLength;
                            _isInteractingWithMinute = distance > hourHandLength;
                          },
                          onPanUpdate: (details) {
                            RenderBox box = context.findRenderObject() as RenderBox;
                            Offset position = details.localPosition;

                            double angle = atan2(position.dy - center.dy, position.dx - center.dx);

                            setState(() {
                              if (_isInteractingWithHour) {
                                _hourRotation = angle;
                              } else if (_isInteractingWithMinute) {
                                _minuteRotation = angle;
                              }
                              _updateSelectedTime();
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _isInteractingWithHour = false;
                              _isInteractingWithMinute = false;
                            });
                          },
                          child: CustomPaint(
                            painter: ClockPainter(
                              hourRotation: _hourRotation,
                              minuteRotation: _minuteRotation,
                              color: _textColor,
                              backgroundColor: backgroundColor!,
                              emptyCenterRadius: clockSize * 0.07,
                            ),
                            size: Size(clockSize, clockSize),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedTimeString.substring(0, 5),
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 32,
                            fontFamily: 'PixelifySans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAM = !_isAM;
                              _updateSelectedTime();
                            });
                          },
                          child: Text(
                            _selectedTimeString.substring(5),
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 24,
                              fontFamily: 'PixelifySans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ClockPainter extends CustomPainter {
  final double hourRotation;
  final double minuteRotation;
  final Color color;
  final Color backgroundColor;
  final double emptyCenterRadius;

  ClockPainter({
    required this.hourRotation,
    required this.minuteRotation,
    required this.color,
    required this.backgroundColor,
    required this.emptyCenterRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.2;

    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final offset = Offset(
        center.dx + radius * 0.9 * cos(angle),
        center.dy + radius * 0.9 * sin(angle),
      );
      canvas.drawCircle(offset, 2, Paint()..color = color);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(hourRotation);
    canvas.drawLine(
      Offset(0, 0),
      Offset(radius * 0.5, 0),
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(minuteRotation);
    canvas.drawLine(
      Offset(0, 0),
      Offset(radius * 0.7, 0),
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.drawCircle(center, emptyCenterRadius, Paint()..color = backgroundColor);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.hourRotation != hourRotation ||
        oldDelegate.minuteRotation != minuteRotation ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.emptyCenterRadius != emptyCenterRadius;
  }
}
