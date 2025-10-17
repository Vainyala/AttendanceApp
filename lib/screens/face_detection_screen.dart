// Modified version with FIXED UI
// Logic remains unchanged - only UI improvements

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/upload_service.dart';

class FaceDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final VoidCallback? onVerificationComplete;

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
  static const int FRAME_SKIP = 3;

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
          minFaceSize: 0.2,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      debugPrint("✅ Fast face detector initialized");
    } catch (e) {
      debugPrint('❌ Face detector init error: $e');
    }
  }

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

      try {
        await _cameraController!.stopImageStream();
        await Future.delayed(Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('⚠️ Stream already stopped: $e');
      }

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
    debugPrint("🎉 Starting verification completion...");

    setState(() {
      _livenessVerified = true;
      _instructionText = "Verification Complete!";
    });

    try {
      debugPrint("⏹️ Stopping image stream...");
      await _cameraController?.stopImageStream();
    } catch (e) {
      debugPrint('⚠️ Stream stop error: $e');
    }

    await Future.delayed(Duration(milliseconds: 500));

    debugPrint("📸 Attempting to capture image...");
    await _captureImage();

    if (_capturedImage != null) {
      debugPrint("✅ Image captured: ${_capturedImage!.path}");
      debugPrint("📤 File size: ${await File(_capturedImage!.path).length()} bytes");
      debugPrint("🌐 Starting upload...");

      final success = await UploadService.uploadImage(
        File(_capturedImage!.path),
        "user123",
      );

      if (success) {
        debugPrint("✅ Image uploaded successfully");
      } else {
        debugPrint("❌ Image upload failed");
      }
    } else {
      debugPrint("❌ ERROR: No image was captured!");
    }

    debugPrint("✅ Showing success dialog...");
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();

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
      if (camera.sensorOrientation == 90) rotation = InputImageRotation.rotation90deg;
      else if (camera.sensorOrientation == 180) rotation = InputImageRotation.rotation180deg;
      else if (camera.sensorOrientation == 270) rotation = InputImageRotation.rotation270deg;

      InputImageFormat? format;
      Uint8List bytes;

      if (Platform.isAndroid) {
        format = InputImageFormat.nv21;
        if (image.planes.length >= 2) {
          final yPlane = image.planes[0];
          final uvPlane = image.planes[1];
          bytes = Uint8List(yPlane.bytes.length + uvPlane.bytes.length);
          bytes.setRange(0, yPlane.bytes.length, yPlane.bytes);
          bytes.setRange(yPlane.bytes.length, bytes.length, uvPlane.bytes);
        } else {
          return null;
        }
      } else {
        format = InputImageFormat.bgra8888;
        bytes = Uint8List.fromList(image.planes[0].bytes);
      }

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Face Verification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_debugMode)
            IconButton(
              icon: Icon(Icons.info, color: Colors.white),
              onPressed: _showDebugInfo,
            ),
        ],
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          // Camera Preview - Full Screen
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // REMOVED: CustomPaint for face detection boxes
          // This was causing the green squares

          // Face Oval Guide - Centered
          Center(
            child: Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _faceFittedInFrame
                      ? Colors.green
                      : Colors.white.withOpacity(0.8),
                  width: 3,
                ),
              ),
            ),
          ),

          // Green Overlay when face fitted
          if (_faceFittedInFrame)
            Center(
              child: Container(
                width: 260,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.15),
                ),
              ),
            ),

          // Status Indicators at Top
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _buildStatusRow(),
          ),

          // Instruction Box at Bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _buildInstructionBox(),
          ),

          // Capturing Overlay
          if (_isCapturingImage)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Capturing Image...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Initializing Camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        _instructionText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatusIndicator(
            label: "Face",
            isCompleted: _faceDetected,
          ),
          _StatusIndicator(
            label: "Fitted",
            isCompleted: _faceFittedInFrame,
          ),
          _StatusIndicator(
            label: "Blink $_blinkCount/3",
            isCompleted: _blinkCount >= 3,
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool isCompleted;

  const _StatusIndicator({
    required this.label,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.9)
            : Colors.grey.shade800.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? Colors.green.shade300
              : Colors.grey.shade600,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 16,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}