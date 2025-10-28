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
  static const int FRAME_SKIP = 2; // Back to 2 for better responsiveness

  XFile? _capturedImage;
  bool _isCapturingImage = false;
  bool _isStreamActive = false;

  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  DateTime? _lastBlinkTime;
  int _closedFrameCount = 0;
  int _openFrameCount = 0;

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
          enableClassification: true, // Critical for eye detection
          enableLandmarks: true, // Enable for better face detection
          enableTracking: true, // Enable tracking for smoother detection
          minFaceSize: 0.1, // Even smaller for easier detection
          performanceMode: FaceDetectorMode.accurate, // Changed to accurate
        ),
      );
      debugPrint("✅ Face detector initialized successfully");
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
        ResolutionPreset.low, // Back to low for faster processing
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        debugPrint("✅ Camera initialized - Starting stream in 1 second...");

        // Delay stream start to ensure camera is fully ready
        await Future.delayed(Duration(milliseconds: 1000));
        if (mounted) {
          _startImageStream();
        }
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

    if (_isStreamActive) {
      debugPrint("⚠️ Stream already active");
      return;
    }

    debugPrint("🎥 Starting image stream NOW...");
    _isStreamActive = true;

    try {
      _cameraController!.startImageStream((CameraImage image) {
        _frameSkipCounter++;
        if (_frameSkipCounter < FRAME_SKIP) return;
        _frameSkipCounter = 0;

        if (_isProcessing || _livenessVerified || !mounted || !_isStreamActive) {
          return;
        }

        _isProcessing = true;
        _detectFaces(image).whenComplete(() {
          _isProcessing = false;
        });
      });
      debugPrint("✅ Image stream started successfully!");
    } catch (e) {
      debugPrint("❌ Failed to start image stream: $e");
      _isStreamActive = false;
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        debugPrint("❌ Failed to convert image");
        return;
      }

      final detectedFaces = await _faceDetector!.processImage(inputImage);

      if (detectedFaces.isNotEmpty) {
        debugPrint("✅ Detected ${detectedFaces.length} face(s)");
      }

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
        debugPrint("⚠️ Face lost");
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
    debugPrint("📏 Face rect: ${faceRect.width.toInt()}x${faceRect.height.toInt()} at (${faceRect.left.toInt()}, ${faceRect.top.toInt()})");

    if (_isFaceInOvalFrame(faceRect)) {
      if (!_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = true;
          _instructionText = "Perfect! Now blink 3 times";
        });
        debugPrint("✅ Face fitted in frame!");
      }

      if (_faceFittedInFrame && !_livenessVerified) {
        _detectBlinking(face);
      }
    } else {
      if (_faceFittedInFrame) {
        setState(() {
          _faceFittedInFrame = false;
          _instructionText = "Move face back to oval";
        });
        debugPrint("⚠️ Face moved out of frame");
      }
    }
  }

  bool _isFaceInOvalFrame(Rect faceRect) {
    final w = faceRect.width;
    final h = faceRect.height;

    // Very lenient - just check if face is reasonably sized
    bool inFrame = w > 50 && h > 50; // Minimum size only

    debugPrint("📐 Face size check: ${w.toInt()}x${h.toInt()} -> ${inFrame ? 'IN' : 'OUT'}");
    return inFrame;
  }

  void _detectBlinking(Face face) {
    final leftProb = face.leftEyeOpenProbability;
    final rightProb = face.rightEyeOpenProbability;

    if (leftProb == null || rightProb == null) {
      debugPrint("⚠️ Eye probabilities not available - check enableClassification!");
      return;
    }

    const double openThreshold = 0.3; // Lower threshold
    const double closedThreshold = 0.15; // Clear closed state

    final leftOpen = leftProb > openThreshold;
    final rightOpen = rightProb > openThreshold;
    final leftClosed = leftProb < closedThreshold;
    final rightClosed = rightProb < closedThreshold;

    final eyesOpen = leftOpen && rightOpen;
    final eyesClosed = leftClosed && rightClosed;

    debugPrint("👁️ L:${leftProb.toStringAsFixed(2)} R:${rightProb.toStringAsFixed(2)} | Open:$eyesOpen Closed:$eyesClosed");

    // Count consecutive frames
    if (eyesClosed) {
      _closedFrameCount++;
      _openFrameCount = 0;
      debugPrint("😑 Eyes closed for $_closedFrameCount frames");
    } else if (eyesOpen) {
      _openFrameCount++;

      // Blink detected: had closed frames, now open
      if (_closedFrameCount >= 2 && _openFrameCount >= 2) {
        // Check if enough time passed since last blink
        final now = DateTime.now();
        if (_lastBlinkTime == null ||
            now.difference(_lastBlinkTime!).inMilliseconds > 500) {

          _lastBlinkTime = now;
          _closedFrameCount = 0;

          setState(() {
            _blinkCount++;
            if (_blinkCount == 1) {
              _instructionText = "Great! Blink 2 more times ($_blinkCount/3)";
            } else if (_blinkCount == 2) {
              _instructionText = "Almost there! One more ($_blinkCount/3)";
            } else if (_blinkCount >= 3) {
              _instructionText = "Perfect! Processing...";
            }
          });

          debugPrint("✅✅✅ BLINK #$_blinkCount DETECTED! ✅✅✅");

          if (_blinkCount >= 3) {
            debugPrint("🎉🎉🎉 All 3 blinks complete!");
            _completeVerification();
          }
        }
      } else {
        _closedFrameCount = 0;
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
      // Stop stream completely
      if (_isStreamActive) {
        debugPrint("📸 Stopping stream for capture...");
        await _cameraController!.stopImageStream();
        _isStreamActive = false;
        await Future.delayed(Duration(milliseconds: 1000)); // Longer wait
      }

      debugPrint("📸 Capturing image...");
      final XFile image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
      });

      final fileSize = await File(image.path).length();
      debugPrint("✅ Image captured! Path: ${image.path}");
      debugPrint("📦 File size: ${(fileSize / 1024).toStringAsFixed(1)} KB");

    } catch (e) {
      debugPrint('❌ Capture error: $e');
      setState(() {
        _isCapturingImage = false;
      });
    }
  }

  void _completeVerification() async {
    if (_livenessVerified) return;

    debugPrint("🎉 ===== VERIFICATION COMPLETE =====");

    setState(() {
      _livenessVerified = true;
      _instructionText = "Verification Complete!";
      _isCapturingImage = true;
    });

    _successController.forward();

    await _captureImage();

    if (_capturedImage != null) {
      debugPrint("✅ Starting upload...");
      UploadService.uploadImage(
        File(_capturedImage!.path),
        "user123",
      ).then((success) {
        debugPrint(success ? "✅ Upload successful" : "❌ Upload failed");
      }).catchError((error) {
        debugPrint("❌ Upload error: $error");
      });
    } else {
      debugPrint("❌ No image to upload!");
    }

    await Future.delayed(Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isCapturingImage = false;
      });
      _showSuccessDialog();
    }
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
      final sensorOrientation = camera.sensorOrientation;

      InputImageRotation rotation;
      if (Platform.isIOS) {
        rotation = InputImageRotation.rotation0deg;
      } else {
        // Android rotation
        rotation = InputImageRotation.rotation90deg;
      }

      final format = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

      final plane = image.planes.first;

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: metadata,
      );

    } catch (e) {
      debugPrint('❌ Image conversion error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    debugPrint("🔴 Disposing...");
    _pulseController.dispose();
    _successController.dispose();

    _isStreamActive = false;
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
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
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
                      borderRadius: BorderRadius.circular(180),
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
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: _buildStatusRow(),
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: _buildInstructionBox(),
          ),
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