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
  String _instructionText = "Position your face in the oval frame";

  List<Face> _faces = [];
  bool _previousEyesOpen = true;

  bool _isProcessing = false;
  int _frameSkipCounter = 0;
  static const int FRAME_SKIP = 2; // Process every 2nd frame

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
          enableClassification: true, // MUST be true for eye detection
          enableLandmarks: false,
          enableTracking: false,
          minFaceSize: 0.2,
          performanceMode: FaceDetectorMode.fast, // Use accurate mode
        ),
      );
      debugPrint("✅ Face detector initialized with classification");
    } catch (e) {
      debugPrint('❌ Face detector init error: $e');
    }
  }

  int _getFrontCameraIndex() {
    for (int i = 0; i < widget.cameras.length; i++) {
      if (widget.cameras[i].lensDirection == CameraLensDirection.front) {
        debugPrint("✅ Front camera found at index $i");
        return i;
      }
    }
    debugPrint("⚠️ No front camera found, using camera 0");
    return 0;
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      debugPrint("❌ No cameras available");
      return;
    }

    try {
      _cameraController = CameraController(
        widget.cameras[_currentCameraIndex],
        ResolutionPreset.low, // Higher resolution for better detection
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888// Better for Android
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        debugPrint("✅ Camera initialized successfully");
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("❌ Cannot start stream - camera not initialized");
      return;
    }

    debugPrint("🎥 Starting image stream...");

    _cameraController!.startImageStream((CameraImage image) {
      _frameSkipCounter++;
      if (_frameSkipCounter < FRAME_SKIP) return;
      _frameSkipCounter = 0;

      if (_isProcessing || _livenessVerified || !mounted) return;

      _isProcessing = true;

      _detectFaces(image).then((_) {
        _isProcessing = false;
      }).catchError((e) {
        debugPrint('❌ Detection error: $e');
        _isProcessing = false;
      });
    });
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        debugPrint("❌ Failed to convert camera image");
        return;
      }

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
      if (_faceDetected) {
        setState(() {
          _faceDetected = false;
          _faceFittedInFrame = false;
          _instructionText = "Position your face in the oval frame";
        });
      }
      return;
    }

    final face = detectedFaces.first;

    if (!_faceDetected) {
      setState(() {
        _faceDetected = true;
      });
      debugPrint("✅ Face detected!");
    }

    final faceRect = face.boundingBox;
    final screenSize = MediaQuery.of(context).size;

    if (_isFaceInOvalFrame(faceRect, screenSize)) {
      if (!_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = true;
          _instructionText = "Perfect! Now blink 3 times slowly";
        });
        debugPrint("✅ Face fitted in oval frame!");
      }

      if (_faceFittedInFrame && !_livenessVerified) {
        // Update instruction based on blink progress
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
      if (_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = false;
          _instructionText = "Move face to fit in the oval";
        });
      }
    }
  }

  bool _isFaceInOvalFrame(Rect faceRect, Size screenSize) {
    final w = faceRect.width;
    final h = faceRect.height;
    final cx = faceRect.center.dx;
    final cy = faceRect.center.dy;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // OPTIMIZED: Much more lenient conditions
    bool inFrame = w > 30 && h > 30 &&  // Smaller minimum size
        cx > 0 && cx < screenWidth &&     // Just needs to be on screen
        cy > 50 && cy < (screenHeight - 80); // Generous margins

    return inFrame;
  }

  void _detectBlinking(Face face) {
    final leftProb = face.leftEyeOpenProbability;
    final rightProb = face.rightEyeOpenProbability;

    if (leftProb == null || rightProb == null) {
      debugPrint("⚠️ Eye probabilities not available");
      return;
    }

    // Lower threshold for better detection
    const double openThreshold = 0.4;
    final eyesOpen = (leftProb > openThreshold) && (rightProb > openThreshold);

    debugPrint("👁️ Eyes - Left: ${leftProb.toStringAsFixed(2)}, Right: ${rightProb.toStringAsFixed(2)}, Open: $eyesOpen");

    // Detect blink: eyes were open, now closed, then open again
    if (_previousEyesOpen && !eyesOpen) {
      debugPrint("👁️ Eyes CLOSED detected");
    } else if (!_previousEyesOpen && eyesOpen) {
      // Blink completed!
      setState(() {
        _blinkCount++;
        if (_blinkCount == 1) {
          _instructionText = "Great! Blink 2 more times";
        } else if (_blinkCount == 2) {
          _instructionText = "Almost there! One more blink";
        }
      });

      debugPrint("✅ BLINK #$_blinkCount detected!");

      if (_blinkCount >= 3) {
        debugPrint("🎉 All 3 blinks detected! Starting verification...");
        _completeVerification();
      }
    }

    _previousEyesOpen = eyesOpen;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("❌ Camera not ready for capture");
      return;
    }

    try {
      debugPrint("📸 Stopping image stream...");
      await _cameraController!.stopImageStream();

      // Wait for stream to fully stop
      await Future.delayed(Duration(milliseconds: 500));

      debugPrint("📸 Taking picture...");
      final XFile image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
      });

      debugPrint("✅ Image captured successfully!");
      debugPrint("📁 Path: ${image.path}");

      final fileSize = await File(image.path).length();
      debugPrint("📦 Size: ${fileSize} bytes");

    } catch (e) {
      debugPrint('❌ Error capturing image: $e');
      setState(() {
        _isCapturingImage = false;
      });
    }
  }

  void _completeVerification() async {
    if (_livenessVerified) return;

    debugPrint("🎉 ===== STARTING VERIFICATION COMPLETION =====");

    setState(() {
      _livenessVerified = true;
      _instructionText = "Verification Complete!";
      _isCapturingImage = true;
    });

    _successController.forward();

    // Capture image
    debugPrint("📸 Capturing image...");
    await _captureImage();

    if (_capturedImage != null) {
      debugPrint("✅ Image captured: ${_capturedImage!.path}");

      // Upload image in background
      debugPrint("🌐 Starting upload...");
      UploadService.uploadImage(
        File(_capturedImage!.path),
        "user123",
      ).then((success) {
        if (success) {
          debugPrint("✅ Image uploaded successfully!");
        } else {
          debugPrint("❌ Image upload failed");
        }
      }).catchError((error) {
        debugPrint("❌ Upload error: $error");
      });
    } else {
      debugPrint("❌ ERROR: No image was captured!");
    }

    // Show success dialog after short delay
    await Future.delayed(Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isCapturingImage = false;
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    debugPrint("✅ Showing success dialog");

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
                  debugPrint("✅ User clicked Continue");
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close screen
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
        // OPTIMIZED: Direct bytes copy for NV21
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
    debugPrint("🔴 Disposing face detection screen");
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

          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // OVAL Frame Guide (not circle)
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
                      // Use borderRadius for OVAL shape, not shape: BoxShape.circle
                      borderRadius: BorderRadius.circular(180), // Creates oval
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
                  borderRadius: BorderRadius.circular(180),
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
          if (_isCapturingImage)
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
                      'Capturing Photo...',
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
          label: "Fitted",
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