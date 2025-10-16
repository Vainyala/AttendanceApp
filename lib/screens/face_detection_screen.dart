// Modified version of your existing face detection screen
// with callback support for the verification flow

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


import '../services/upload_service.dart';

class FaceDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final VoidCallback? onVerificationComplete; // NEW: Callback for completion

  const FaceDetectionScreen({
    Key? key,
    required this.cameras,
    this.onVerificationComplete,
  }) : super(key: key);

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _debugMode = false;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  int _currentCameraIndex = 0;

  bool _faceDetected = false;
  bool _faceFittedInFrame = false;
  int _blinkCount = 0;
  bool _livenessVerified = false;
  String _instructionText = "Position your face in the frame";

  List<Face> _faces = [];
  bool _previousEyesOpen = true;

  bool _isProcessing = false;
  int _frameSkipCounter = 0;
  static const int FRAME_SKIP = 5;

  XFile? _capturedImage;
  bool _isCapturingImage = false;

  @override
  void initState() {
    super.initState();
    _currentCameraIndex = _getFrontCameraIndex();
    _initializeFaceDetector();
    _initializeCamera();
  }

  void _initializeFaceDetector() {
    try {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableClassification: true,
          enableLandmarks: false,
          enableTracking: false,
          minFaceSize: 0.3,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      debugPrint("✅ Fast face detector initialized");
    } catch (e) {
      debugPrint('❌ Face detector init error: $e');
    }
  }
// In FaceDetectionScreen, ensure front camera is used
  int _getFrontCameraIndex() {
    for (int i = 0; i < widget.cameras.length; i++) {
      if (widget.cameras[i].lensDirection == CameraLensDirection.front) {
        print("✅ Front camera found at index $i");
        return i;
      }
    }
    print("⚠️ No front camera, using camera 0");
    return 0;
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    try {
      _cameraController = CameraController(
        widget.cameras[_currentCameraIndex],
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startImageStream();
      }
    } catch (e) {
      debugPrint('❌ Camera init failed: $e');
      if (mounted) {
        setState(() => _instructionText = "Failed to initialize camera");
      }
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _cameraController!.startImageStream((CameraImage image) {
      _frameSkipCounter++;
      if (_frameSkipCounter < FRAME_SKIP) return;
      _frameSkipCounter = 0;

      if (_isProcessing || _livenessVerified || !mounted) return;

      _isProcessing = true;

      _detectFaces(image).then((_) {
        _isProcessing = false;
      }).catchError((e) {
        debugPrint('Detection error: $e');
        _isProcessing = false;
      });
    });
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final detectedFaces = await _faceDetector!.processImage(inputImage);

      if (mounted) {
        setState(() {
          _faces = detectedFaces;
        });
        _processFaceDetection(detectedFaces);
      }
    } catch (e) {
      debugPrint('❌ Face detection error: $e');
    }
  }

  void _processFaceDetection(List<Face> detectedFaces) {
    if (detectedFaces.isEmpty) {
      setState(() {
        _faceDetected = false;
        _faceFittedInFrame = false;
        _instructionText = "Position your face in the frame";
      });
      return;
    }

    final face = detectedFaces.first;
    setState(() {
      _faceDetected = true;
    });

    final faceRect = face.boundingBox;

    if (_isFaceInFrame(faceRect)) {
      if (!_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = true;
          _instructionText = "Great! Now blink 3 times";
        });
      }

      if (_faceFittedInFrame && !_livenessVerified) {
        if (_blinkCount == 0) {
          setState(() {
            _instructionText = "Blink now (0/3)";
          });
        } else if (_blinkCount < 3) {
          setState(() {
            _instructionText = "Keep blinking ($_blinkCount/3)";
          });
        }

        _detectBlinking(face);
      }
    } else {
      setState(() {
        _faceFittedInFrame = false;
        _instructionText = "Move face closer to center";
      });
    }
  }

  bool _isFaceInFrame(Rect faceRect) {
    final w = faceRect.width;
    final h = faceRect.height;
    final cx = faceRect.center.dx;
    final cy = faceRect.center.dy;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool inFrame = w > 30 && h > 30 &&
        cx > 0 && cx < screenWidth &&
        cy > 50 && cy < (screenHeight - 80);

    return inFrame;
  }

  void _detectBlinking(Face face) {
    final leftProb = face.leftEyeOpenProbability;
    final rightProb = face.rightEyeOpenProbability;

    if (leftProb == null || rightProb == null) return;

    const double openThreshold = 0.4;
    final eyesOpen = (leftProb > openThreshold) && (rightProb > openThreshold);

    if (_previousEyesOpen && !eyesOpen) {
      debugPrint("👁️ Eyes closed detected");
    } else if (!_previousEyesOpen && eyesOpen) {
      setState(() {
        _blinkCount++;
      });

      debugPrint("✅ BLINK detected! Count: $_blinkCount");

      if (mounted && _blinkCount >= 3) {
        _completeVerification();
      }
    }

    _previousEyesOpen = eyesOpen;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturingImage) {
      return;
    }

    try {
      setState(() {
        _isCapturingImage = true;
      });

      final XFile image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
        _isCapturingImage = false;
      });

      debugPrint("✅ Image captured successfully: ${image.path}");

    } catch (e) {
      debugPrint('❌ Error capturing image: $e');
      setState(() {
        _isCapturingImage = false;
      });
    }
  }

  void _completeVerification() async {
    setState(() {
      _livenessVerified = true;
      _instructionText = "Verification Complete!";
    });

    try {
      _cameraController?.stopImageStream();
    } catch (_) {}

    await _captureImage();

    if (_capturedImage != null) {
      final success = await UploadService.uploadImage(
        File(_capturedImage!.path),
        "user123",
      );

      if (success) {
        print("✅ Image uploaded successfully");
      } else {
        print("❌ Image upload failed");
      }
    }

    Timer(Duration(milliseconds: 500), () => _showSuccessDialog());
  }

  void _showSuccessDialog() {
    debugPrint("🔵 Showing success dialog");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Success!')
            ]
        ),
        content: Text('Face liveness verified successfully!'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close face detection screen

                // NEW: Call the completion callback
                if (widget.onVerificationComplete != null) {
                  widget.onVerificationComplete!();
                }
              },
              child: Text('OK')
          )
        ],
      ),
    );
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = widget.cameras[_currentCameraIndex];

      InputImageRotation rotation = InputImageRotation.rotation0deg;
      switch (camera.sensorOrientation) {
        case 90:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation270deg;
          break;
      }

      final format = InputImageFormat.bgra8888;
      final bytes = Uint8List.fromList(image.planes[0].bytes);

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint('❌ Conversion error: $e');
      return null;
    }
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cameras: ${widget.cameras.length}'),
            Text('Current camera: $_currentCameraIndex'),
            Text('Camera initialized: $_isCameraInitialized'),
            Text('Face detected: $_faceDetected'),
            Text('Face fitted: $_faceFittedInFrame'),
            Text('Blinks: $_blinkCount/3'),
            Text('Processing: $_isProcessing'),
            Text('Faces found: ${_faces.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  void _switchCamera() {
    if (widget.cameras.length > 1) {
      _currentCameraIndex = _currentCameraIndex == 0 ? 1 : 0;

      try {
        _cameraController?.dispose();
      } catch (_) {}

      _initializeCamera();

      setState(() {
        _faceDetected = false;
        _faceFittedInFrame = false;
        _blinkCount = 0;
        _livenessVerified = false;
        _instructionText = "Position your face in the frame";
        _previousEyesOpen = true;
        _capturedImage = null;
      });
    }
  }

  @override
  void dispose() {
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Verification'),
        actions: [
          if (_debugMode)
            IconButton(
              icon: Icon(Icons.info),
              onPressed: _showDebugInfo,
            ),
        ],
      ),
      body: _isCameraInitialized
          ? Stack(
          children: [
            CameraPreview(_cameraController!),

            CustomPaint(
              painter: SimpleFaceDetectionPainter(
                faces: _faces,
                imageSize: Size(
                    _cameraController!.value.previewSize?.width ?? 1,
                    _cameraController!.value.previewSize?.height ?? 1
                ),
              ),
              size: Size.infinite,
            ),

            Center(
              child: Container(
                width: 280,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _faceFittedInFrame ? Colors.green : Colors.white,
                      width: 3
                  ),
                  borderRadius: BorderRadius.circular(140),
                ),
                child: _faceFittedInFrame
                    ? Container(
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(140)
                    )
                )
                    : null,
              ),
            ),

            Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: _buildInstructionBox()
            ),

            Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: _buildStatusRow()
            ),

            if (_isCapturingImage)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Capturing Image...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ]
      )
          : Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                    'Initializing Camera...',
                    style: TextStyle(color: Colors.white, fontSize: 16)
                )
              ]
          )
      ),
    );
  }

  Widget _buildInstructionBox() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Text(
          _instructionText,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
          )
      )
  );

  Widget _buildStatusRow() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatusIndicator(label: "Face", isCompleted: _faceDetected),
        _StatusIndicator(label: "Fitted", isCompleted: _faceFittedInFrame),
        _StatusIndicator(label: "Blink: $_blinkCount/3", isCompleted: _blinkCount >= 3),
      ]
  );
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool isCompleted;
  const _StatusIndicator({required this.label, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: isCompleted ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold
          )
      ),
    );
  }
}

class SimpleFaceDetectionPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  SimpleFaceDetectionPainter({
    required this.faces,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    final Paint facePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double scaleX = imageSize.width > 0 ? size.width / imageSize.width : 1.0;
    final double scaleY = imageSize.height > 0 ? size.height / imageSize.height : 1.0;

    for (final face in faces) {
      final Rect rect = Rect.fromLTRB(
          face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY
      );
      canvas.drawRect(rect, facePaint);
    }
  }

  @override
  bool shouldRepaint(SimpleFaceDetectionPainter oldDelegate) =>
      oldDelegate.faces != faces;
}