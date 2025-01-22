import 'dart:io'; // Import for File handling
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';

class JournalPost {
  final String id;
  final String text;
  final String? imagePath; // File path of the image (can be null)
  final Offset position;
  final double rotation;

  JournalPost({
    required this.id,
    required this.text,
    this.imagePath,
    required this.position,
    required this.rotation,
  });
}

class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});

  @override
  State<JournalingPage> createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> {
  bool isEditMode = false;
  List<JournalPost> posts = [
    JournalPost(
      id: '1',
      text: 'Do more of what you love. :)',
      position: const Offset(100, 100),
      rotation: 0.1,
    ),
    JournalPost(
      id: '2',
      text: 'Live in the moment.',
      position: const Offset(200, 300),
      rotation: -0.05,
    ),
  ];

  double _scale = 1.0;
  late Offset _lastFocalPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vision Board'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (details) {
          _lastFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_scale * details.scale).clamp(0.5, 3.0);
          });
        },
        child: Stack(
          children: [
            Transform.scale(
              scale: _scale,
              child: Stack(
                children: [
                  ...posts.map((post) => _buildDraggablePost(post)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDraggablePost(JournalPost post) {
    return isEditMode
        ? Positioned(
            left: post.position.dx * _scale,
            top: post.position.dy * _scale,
            child: Draggable(
              feedback: _buildPostCard(post),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  final index = posts.indexWhere((p) => p.id == post.id);
                  posts[index] = JournalPost(
                    id: post.id,
                    text: post.text,
                    imagePath: post.imagePath,
                    position: details.offset / _scale,
                    rotation: post.rotation,
                  );
                });
              },
              child: _buildPostCard(post),
            ),
          )
        : Positioned(
            left: post.position.dx * _scale,
            top: post.position.dy * _scale,
            child: _buildPostCard(post),
          );
  }

  // Updated _buildPostCard to check for Image.file or Image.asset
  Widget _buildPostCard(JournalPost post) {
    return Transform.rotate(
      angle: post.rotation,
      child: Card(
        elevation: 4,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (post.imagePath != null)
                // Check if it's a file path or an asset path
                post.imagePath!.startsWith('http') || post.imagePath!.startsWith('assets')
                    ? Image.asset(
                        post.imagePath!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(post.imagePath!),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  post.text,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPostDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Enter your text',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        posts.add(JournalPost(
                          id: DateTime.now().toString(),
                          text: textController.text,
                          position: Offset(
                            math.Random().nextDouble() * 200 + 50,
                            math.Random().nextDouble() * 400 + 50,
                          ),
                          rotation: (math.Random().nextDouble() - 0.5) * 0.2,
                          imagePath: pickedFile.path, // Store file path
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        posts.add(JournalPost(
                          id: DateTime.now().toString(),
                          text: textController.text,
                          position: Offset(
                            math.Random().nextDouble() * 200 + 50,
                            math.Random().nextDouble() * 400 + 50,
                          ),
                          rotation: (math.Random().nextDouble() - 0.5) * 0.2,
                          imagePath: pickedFile.path, // Store file path
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  posts.add(JournalPost(
                    id: DateTime.now().toString(),
                    text: textController.text,
                    position: Offset(
                      math.Random().nextDouble() * 200 + 50,
                      math.Random().nextDouble() * 400 + 50,
                    ),
                    rotation: (math.Random().nextDouble() - 0.5) * 0.2,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
