import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Use the first camera, typically the back camera. If not available, use empty logic or handle error.
    // In a real app we'd pass available cameras from main or load them here.
    // For now assuming the list passed is valid.
    if (widget.cameras.isNotEmpty) {
        _controller = CameraController(
          widget.cameras.first,
          ResolutionPreset.medium, // Lower resolution for better web compatibility
        );
        _initializeControllerFuture = _controller.initialize().catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                print('User denied camera access.');
                break;
              default:
                print('Handle other errors.');
                break;
            }
          }
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
        return const Scaffold(
            body: Center(child: Text('No camera found')),
        );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Camera is initialized, display preview.
            return Stack(
              children: [
                // Full screen camera preview
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),
                
                // Back button
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 30)
                    ),
                  ),
                ),

                // Capture button area
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      GestureDetector(


                        onTap: () async {
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller.takePicture();

                            if (!mounted) return;

                            // Navigate to preview screen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewScreen(imageFile: image),
                              ),
                            );

                            // If result is not null, it means user pressed OK.
                            // We pass the result back to the previous screen (e.g. AddNewItem).
                            if (result != null && mounted) {
                              Navigator.pop(context, result);
                            }
                            // If result is null (Retake), we just stay here and can take another photo.

                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD9D9D9), // Light grey like the design
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "PHOTO",
                        style: TextStyle(
                          color: Color(0xFFEAA900), // Yellow color from design
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
