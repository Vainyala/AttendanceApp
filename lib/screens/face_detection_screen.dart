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

class _FaceDetectionScreenState extends State<FaceDetectionScreen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
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

  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _currentCameraIndex = _getFrontCameraIndex();
    _initializeFaceDetector();
    _initializeCamera();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
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
      debugPrint("✅ Face detector initialized");
    } catch (e) {
      debugPrint('❌ Face detector init error: $e');
    }
  }

  int _getFrontCameraIndex() {
    for (int i = 0; i < widget.cameras.length; i++) {
      if (widget.cameras[i].lensDirection == CameraLensDirection.front) {
        return i;
      }
    }
    return 0;
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    try {
      _cameraController = CameraController(
        widget.cameras[_currentCameraIndex],
        ResolutionPreset.medium,
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
        setState(() => _instructionText = "Camera initialization failed");
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

    if (!_faceDetected) {
      setState(() {
        _faceDetected = true;
      });
    }

    final faceRect = face.boundingBox;

    if (_isFaceInFrame(faceRect)) {
      if (!_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = true;
          _instructionText = "Perfect! Now blink 3 times";
        });
      }

      if (_faceFittedInFrame && !_livenessVerified) {
        _detectBlinking(face);
      }
    } else {
      if (_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = false;
          _instructionText = "Move closer to center";
        });
      }
    }
  }

  bool _isFaceInFrame(Rect faceRect) {
    final w = faceRect.width;
    final h = faceRect.height;
    final cx = faceRect.center.dx;
    final cy = faceRect.center.dy;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return w > 30 && h > 30 &&
        cx > 0 && cx < screenWidth &&
        cy > 50 && cy < (screenHeight - 80);
  }

  void _detectBlinking(Face face) {
    final leftProb = face.leftEyeOpenProbability;
    final rightProb = face.rightEyeOpenProbability;

    if (leftProb == null || rightProb == null) return;

    const double openThreshold = 0.4;
    final eyesOpen = (leftProb > openThreshold) && (rightProb > openThreshold);

    if (!_previousEyesOpen && eyesOpen) {
      setState(() {
        _blinkCount++;
        if (_blinkCount == 1) {
          _instructionText = "Great! Blink 2 more times";
        } else if (_blinkCount == 2) {
          _instructionText = "Almost there! One more blink";
        }
      });

      if (_blinkCount >= 3) {
        _completeVerification();
      }
    }

    _previousEyesOpen = eyesOpen;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));

      final XFile image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
      });

      debugPrint("✅ Image captured: ${image.path}");
    } catch (e) {
      debugPrint('❌ Error capturing image: $e');
    }
  }

  void _completeVerification() async {
    if (_livenessVerified) return;

    setState(() {
      _livenessVerified = true;
      _instructionText = "Verification Complete!";
      _isCapturingImage = true;
    });

    _successController.forward();

    try {
      await _cameraController?.stopImageStream();
    } catch (e) {
      debugPrint('⚠️ Stream stop error: $e');
    }

    await Future.delayed(Duration(milliseconds: 300));
    await _captureImage();

    // Upload image in background
    if (_capturedImage != null) {
      UploadService.uploadImage(
        File(_capturedImage!.path),
        "user123",
      ).then((success) {
        debugPrint(success ? "✅ Upload success" : "❌ Upload failed");
      });
    }

    // Show success immediately
    await Future.delayed(Duration(milliseconds: 400));
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _successAnimation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Verified!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Face liveness verified successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  widget.onVerificationComplete?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Dark overlay for better contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Animated Face Oval Guide
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _faceFittedInFrame ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 280,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _livenessVerified
                            ? Colors.green
                            : _faceFittedInFrame
                            ? Colors.green
                            : Colors.white.withOpacity(0.6),
                        width: _faceFittedInFrame ? 4 : 3,
                      ),
                      boxShadow: _faceFittedInFrame
                          ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          // Green overlay when verified
          if (_livenessVerified)
            Center(
              child: Container(
                width: 280,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.2),
                ),
              ),
            ),

          // Status Pills
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: _buildStatusRow(),
          ),

          // Instruction Box
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: _buildInstructionBox(),
          ),

          // Capturing overlay
          if (_isCapturingImage && !_livenessVerified)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Capturing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionBox() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _livenessVerified
              ? [Colors.green.shade600, Colors.green.shade700]
              : [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _livenessVerified
                ? Colors.green.withOpacity(0.5)
                : Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_livenessVerified)
            Icon(Icons.check_circle, color: Colors.white, size: 24),
          if (_livenessVerified) SizedBox(width: 12),
          Flexible(
            child: Text(
              _instructionText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatusPill(
          icon: Icons.face,
          label: "Face",
          isActive: _faceDetected,
        ),
        SizedBox(width: 12),
        _StatusPill(
          icon: Icons.center_focus_strong,
          label: "Aligned",
          isActive: _faceFittedInFrame,
        ),
        SizedBox(width: 12),
        _StatusPill(
          icon: Icons.remove_red_eye,
          label: "$_blinkCount/3",
          isActive: _blinkCount >= 3,
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        )
            : null,
        color: isActive ? null : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : icon,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}