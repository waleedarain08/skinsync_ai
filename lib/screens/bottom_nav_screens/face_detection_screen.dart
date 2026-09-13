import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vibration/vibration.dart';

import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/face_detection_utils.dart';
import '../../utils/image_utills.dart';
import '../../utils/secure_storage_service.dart';
import '../../utils/tts_utils.dart';
import '../../utils/volume_button_service.dart';
import '../../view_models/treatment_view_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/bottom_sheets/medical_disclaimer_bottomsheet.dart';
import '../../widgets/custom_button.dart';

class FaceDetectionScreen extends ConsumerStatefulWidget {
  final String pose;
  const FaceDetectionScreen({super.key, this.pose = 'front'});

  static const String routeName = '/FaceDetectionScreen';

  @override
  ConsumerState<FaceDetectionScreen> createState() =>
      _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends ConsumerState<FaceDetectionScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  XFile? _capturedImage;

  bool _isCapturing = false;
  bool _isPoseCorrect = false;
  double? _currentYaw;
  bool _isSoundOn = true;
  bool _isAutomaticMode = false;
  bool _isStarted = false;

  int _countdown = 3;
  Timer? _timer;
  bool _isCountingDown = false;

  Timer? _manualCaptureTimer;
  bool _showManualCaptureUI = false;

  Timer? _incorrectPoseDebounceTimer;
  bool _hasSpokenHoldStill = false;

  final VolumeButtonService _volumeButtonService = VolumeButtonService();

  // Store ref for use in callbacks
  WidgetRef? _storedRef;

  FaceDetector? _faceDetector;
  bool _isFaceDetectorError = false;
  bool _isProcessingFrame = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _storedRef = ref;
    _initFaceDetector();
    _initCamera(ref);
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _startManualCaptureTimer();
    _initVolumeButtonService();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Use saved preference or show dialog for all poses
      final savedMode = await SecureStorage().getCaptureMode();
      if (savedMode != null) {
        setState(() {
          _isAutomaticMode = savedMode;
          _isStarted = true;
        });
        _speakInstruction();
      } else if (mounted) {
        _showModeSelectionDialog();
      }

      final show = await SecureStorage().getMedicalDisclaimer();
      if (show) {
        MedicalDisclaimerBottomSheet.show(context);
      }
    });
  }

  void _initVolumeButtonService() {
    _volumeButtonService.enableInterception();
    _volumeButtonService.startListening((event) {
      if (!mounted || !_isStarted) return;
      // Allow volume button to capture in both modes
      if (!_isCapturing && _capturedImage == null) {
        _handleCaptureTrigger();
      }
    });
  }

  Future<void> _initTts() async {
    await TtsUtils.init();
  }

  void _speakInstruction() {
    if (!_isSoundOn) return;
    final isFrontCamera =
        _cameraController?.description.lensDirection ==
        CameraLensDirection.front;

    String ttsText = "";
    if (widget.pose == 'front') {
      ttsText = "Please look straight and keep your face inside the circle.";
    } else if (isFrontCamera) {
      if (widget.pose == 'left') {
        ttsText =
            "Please turn your head to the right to capture your left profile.";
      } else {
        ttsText =
            "Please turn your head to the left to capture your right profile.";
      }
    } else {
      if (widget.pose == 'left') {
        ttsText =
            "Please turn your head to the left to capture your left profile.";
      } else {
        ttsText =
            "Please turn your head to the right to capture your right profile.";
      }
    }

    // Add specific instructions for auto/manual mode
    if (_isAutomaticMode) {
      ttsText +=
          " You can also tap anywhere on the screen or press the volume button to capture the image.";
    } else {
      ttsText +=
          " Click the capture button, or tap anywhere on the screen, or press the volume button to take the image.";
    }

    TtsUtils.speak(ttsText);
  }

  Future<void> _initFaceDetector() async {
    setState(() {
      _isFaceDetectorError = false;
    });

    try {
      bool shouldPreferCpu = false;

      if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        final model = iosInfo.utsname.machine;
        if (model.contains('iPhone8,') || model.contains('iPhone9,')) {
          shouldPreferCpu = true;
        }
      } else if (Platform.isAndroid) {
        shouldPreferCpu = true;
      }

      if (shouldPreferCpu) {
        _faceDetector = await FaceDetector.create(
          minScore: 0.35,
          minFaceSize: 0.05,
          performanceConfig: const PerformanceConfig.xnnpack(),
        );
      } else {
        _faceDetector = await FaceDetector.create(
          minScore: 0.35,
          minFaceSize: 0.05,
          performanceConfig: const PerformanceConfig.gpu(),
        );
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log('Face detector init failed: $e');
      try {
        _faceDetector = await FaceDetector.create(
          minScore: 0.35,
          minFaceSize: 0.05,
          performanceConfig: const PerformanceConfig.xnnpack(),
        );
        if (mounted) setState(() {});
      } catch (e2) {
        if (mounted) {
          setState(() {
            _isFaceDetectorError = true;
          });
        }
      }
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _faceDetector == null) {
        setState(() {
          _isFaceDetectorError = true;
        });
      }
    });
  }

  void _showModeSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Go back to previous screen
        },
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(context.w(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.r(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24), // Spacer for balance
                        Text(
                          "Choose Capture Mode",
                          style: CustomFonts.black22w600,
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(
                              context,
                            ); // Go back to previous screen
                          },
                          child: const Icon(
                            Iconsax.close_circle,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(10)),
                    Text(
                      "Select how you want to capture your photos",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: context.sp(14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.h(24)),
                    _buildModeOption(
                      icon: Iconsax.camera,
                      title: "Manual Capture",
                      subtitle: "You control the capture button",
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _isAutomaticMode = false;
                          _isStarted = true;
                        });
                        SecureStorage().saveCaptureMode(false);
                        _speakInstruction();
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: context.h(12)),
                    _buildModeOption(
                      icon: Iconsax.magicpen,
                      title: "Automatic Capture",
                      subtitle: "Captures automatically when aligned",
                      isSelected: false,
                      onTap: () {
                        setState(() {
                          _isAutomaticMode = true;
                          _isStarted = true;
                        });
                        SecureStorage().saveCaptureMode(true);
                        _speakInstruction();
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: context.h(20)),
                    const Divider(),
                    SizedBox(height: context.h(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isSoundOn
                                  ? Iconsax.volume_high
                                  : Iconsax.volume_cross,
                              color: CustomColors.purpleColor,
                              size: 24,
                            ),
                            SizedBox(width: context.w(12)),
                            Text(
                              "Voice Assistant",
                              style: CustomFonts.black16w600,
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _isSoundOn,
                          activeThumbColor: CustomColors.purpleColor,
                          onChanged: (val) {
                            setDialogState(() {
                              _isSoundOn = val;
                            });
                            setState(() {
                              _isSoundOn = val;
                            });
                            if (!val) {
                              TtsUtils.stop();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.w(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? CustomColors.purpleColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: isSelected ? CustomColors.purpleColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? CustomColors.purpleColor : Colors.grey,
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomFonts.black16w600.copyWith(
                      color: isSelected
                          ? CustomColors.purpleColor
                          : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: context.sp(12),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: CustomColors.purpleColor),
          ],
        ),
      ),
    );
  }

  CameraFrameRotation? _getRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return CameraFrameRotation.cw90;
      case 180:
        return CameraFrameRotation.cw180;
      case 270:
        return CameraFrameRotation.cw270;
      default:
        return null;
    }
  }

  void _onFrameAvailable(CameraImage image) async {
    if (!_isStarted ||
        _faceDetector == null ||
        _isProcessingFrame ||
        _isCapturing ||
        _capturedImage != null) {
      return;
    }

    _isProcessingFrame = true;

    try {
      final rotation = _getRotation(
        _cameraController!.description.sensorOrientation,
      );

      final faces = await _faceDetector!.detectFacesFromCameraImage(
        image,
        rotation: rotation,
      );

      bool isPoseCorrect = false;
      double? currentYaw;
      if (faces.isNotEmpty) {
        final face = faces.first;
        currentYaw = face.headEulerAngles?.y;
        isPoseCorrect = face.isCorrectPose(
          widget.pose,
          isFrontCamera:
              _cameraController?.description.lensDirection ==
              CameraLensDirection.front,
          previousCorrect: _isPoseCorrect,
        );

        if (isPoseCorrect && _showManualCaptureUI) {
          setState(() {
            _showManualCaptureUI = false;
          });
          _startManualCaptureTimer();
        }
      }

      if (_isPoseCorrect != isPoseCorrect || _currentYaw != currentYaw) {
        setState(() {
          _isPoseCorrect = isPoseCorrect;
          _currentYaw = currentYaw;
        });
      }

      if (isPoseCorrect) {
        _incorrectPoseDebounceTimer?.cancel();
        _incorrectPoseDebounceTimer = null;

        if (_isAutomaticMode &&
            !_hasSpokenHoldStill &&
            !_isCountingDown &&
            !_isCapturing) {
          _hasSpokenHoldStill = true;

          if (Platform.isAndroid) {
            try {
              Vibration.vibrate(duration: 200);
            } catch (e) {
              log("Android vibration error: $e");
            }
          } else {
            try {
              HapticFeedback.vibrate();
              HapticFeedback.mediumImpact();
            } catch (e) {
              log("iOS haptic feedback error: $e");
            }
          }

          if (_isSoundOn) {
            TtsUtils.speak("Hold still");
          }

          _startCountdown();
        }
      } else {
        if (_isAutomaticMode &&
            _incorrectPoseDebounceTimer == null &&
            (_isCountingDown || _hasSpokenHoldStill)) {
          _incorrectPoseDebounceTimer = Timer(const Duration(milliseconds: 700), () {
            if (mounted && !_isPoseCorrect) {
              _stopCountdown();
            }
          });
        }
      }
    } catch (e) {
      log('Face detection error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _startCountdown() {
    if (_isCountingDown || _isCapturing || _capturedImage != null) return;

    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    if (_isSoundOn) {
      TtsUtils.speak("$_countdown");
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
        if (_isSoundOn) {
          TtsUtils.speak("$_countdown");
        }
      } else {
        if (_isPoseCorrect && _storedRef != null) {
          _captureAndNavigate(_storedRef!);
        } else {
          _stopCountdown();
        }
      }
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    _timer = null;
    _incorrectPoseDebounceTimer?.cancel();
    _incorrectPoseDebounceTimer = null;
    _hasSpokenHoldStill = false;
    if (mounted) {
      setState(() {
        _isCountingDown = false;
        _countdown = 3;
      });
      _startManualCaptureTimer();
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameraController == null || _isCapturing || _capturedImage != null) {
      return;
    }

    final cameras = await availableCameras();
    if (cameras.length < 2) return;

    final newDescription = cameras.firstWhere(
      (camera) =>
          camera.lensDirection != _cameraController!.description.lensDirection,
      orElse: () => cameras.first,
    );

    final oldController = _cameraController;
    setState(() {
      _cameraController = null;
      _isPoseCorrect = false;
    });

    if (oldController != null) {
      if (oldController.value.isStreamingImages) {
        await oldController.stopImageStream();
      }
      await oldController.dispose();
    }

    if (!mounted) return;

    _initCamera(_storedRef!, description: newDescription);
  }

  Future<void> _initCamera(
    WidgetRef ref, {
    CameraDescription? description,
  }) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          _showError('No cameras available');
        }
        return;
      }

      final target =
          description ??
          cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );

      final controller = CameraController(
        target,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.startImageStream(_onFrameAvailable);

      setState(() {
        _cameraController = controller;
      });

      if (_isStarted) {
        _speakInstruction();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to initialize camera: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _captureAndNavigate(WidgetRef ref) async {
    if (_cameraController == null || _isCapturing) return;

    _stopCountdown();

    setState(() {
      _isCapturing = true;
      _isPoseCorrect = false;
    });

    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      log("Error stopping image stream: $e");
    }

    if (!mounted || _cameraController == null) return;

    try {
      final image = await _cameraController!.takePicture();

      final finalImage = await cropImageToCircle(
        image,
        centerXPercent: 0.5,
        centerYPercent: 0.50,
        radiusPercent: 0.42,
        flipHorizontally:
            _cameraController!.description.lensDirection ==
            CameraLensDirection.front,
      );

      if (!mounted) return;

      if (_isSoundOn) {
        TtsUtils.speak("Perfect");
      }

      setState(() {
        _capturedImage = finalImage;
        _isCapturing = false;
      });

      if (mounted) {
        _showImageVerificationDialog(ref, finalImage);
      }
    } catch (e) {
      log("Capture error: $e");
      setState(() {
        _isCapturing = false;
      });
      if (_cameraController != null &&
          !_cameraController!.value.isStreamingImages) {
        _cameraController!.startImageStream(_onFrameAvailable);
      }
    }
  }

  void _showImageVerificationDialog(WidgetRef ref, XFile capturedImage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(context.w(20)),
                child: Text(
                  "Verify your image",
                  style: CustomFonts.black24w600,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: context.w(20)),
                height: context.h(300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(15)),
                  border: Border.all(
                    color: CustomColors.lightPurpleColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.r(13)),
                  child: Image.file(
                    File(capturedImage.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              SizedBox(height: context.h(30)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(20),
                  vertical: context.h(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        isBorder: true,
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _capturedImage = null;
                            _isCapturing = false;
                          });
                          if (_cameraController != null &&
                              !_cameraController!.value.isStreamingImages) {
                            _cameraController!.startImageStream(
                              _onFrameAvailable,
                            );
                          }
                        },
                        text: "Recapture",
                      ),
                    ),
                    SizedBox(width: context.w(16)),
                    Expanded(
                      child: CustomButton(
                        onPressed: () async {
                          ref
                              .read(treatmentViewModel.notifier)
                              .setCapturedImage(
                                capturedImage,
                                pose: widget.pose,
                              );

                          Navigator.pop(context);
                          if (mounted) {
                            Navigator.pop(context, capturedImage);
                          }
                        },
                        text: "Submit",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startManualCaptureTimer() {
    _manualCaptureTimer?.cancel();
    if (_showManualCaptureUI) return;

    _manualCaptureTimer = Timer(const Duration(seconds: 5), () {
      if (mounted &&
          !_isCountingDown &&
          !_isCapturing &&
          _capturedImage == null) {
        setState(() {
          _showManualCaptureUI = true;
        });
      }
    });
  }

  void _handleCaptureTrigger() {
    _captureAndNavigate(_storedRef!);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _incorrectPoseDebounceTimer?.cancel();
    _manualCaptureTimer?.cancel();
    _volumeButtonService.dispose();
    _cameraController?.dispose();
    _faceDetector?.dispose();
    _pulseController.dispose();
    TtsUtils.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(treatmentViewModel.select((s) => s));

    return Scaffold(
      backgroundColor: Colors.black,
      body: _cameraController != null && _cameraController!.value.isInitialized
          ? _buildCameraView()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCameraView() {
    if (_capturedImage != null) {
      return SizedBox.expand(
        child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
      );
    }

    final previewSize = _cameraController?.value.previewSize;
    if (previewSize == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final aspectRatio = previewSize.height / previewSize.width;
    const circleRadiusPercent = 0.35;
    const circleCenterYPercent = 0.50;

    return GestureDetector(
      onTap: () {
        if (_isStarted && !_isCapturing && _capturedImage == null) {
          _handleCaptureTrigger();
        }
      },
      child: SizedBox.expand(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasWidth = constraints.maxWidth;
                    final canvasHeight = constraints.maxHeight;
                    final circleRadius = canvasWidth * circleRadiusPercent;
                    final circleCenterY = canvasHeight * circleCenterYPercent;
                    return Stack(
                      children: [
                        CameraPreview(_cameraController!),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: TintOverlayPainter(
                                centerRadius: circleRadius,
                                centerY: circleCenterY,
                                isPoseCorrect: _isPoseCorrect,
                                pulseValue: _pulseController.value,
                              ),
                              child: const SizedBox.expand(),
                            );
                          },
                        ),
                        if (_isCountingDown)
                          Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                              child: Text(
                                '$_countdown',
                                key: ValueKey<int>(_countdown),
                                style: TextStyle(
                                  fontSize: context.sp(120),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black54,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + context.h(10),
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        if (_isStarted) _buildPoseIndicator(),
                        if (_isStarted)
                          Row(
                            children: [
                              _buildHeaderButton(
                                icon: _isSoundOn
                                    ? Iconsax.volume_high
                                    : Iconsax.volume_cross,
                                onTap: () {
                                  setState(() {
                                    _isSoundOn = !_isSoundOn;
                                  });
                                  if (!_isSoundOn) {
                                    TtsUtils.stop();
                                  } else {
                                    _speakInstruction();
                                  }
                                },
                              ),
                              SizedBox(width: context.w(10)),
                              _buildHeaderButton(
                                icon: Icons.flip_camera_ios_outlined,
                                onTap: _toggleCamera,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildInstructionOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.w(10)),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: context.sp(20)),
      ),
    );
  }

  Widget _buildPoseIndicator() {
    final poses = ['front', 'left', 'right'];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(8),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: poses.map((p) {
          final isCurrent = widget.pose == p;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: context.w(4)),
            width: context.w(8),
            height: context.w(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? CustomColors.purpleColor
                  : Colors.white.withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionOverlay() {
    if (!_isStarted) return const SizedBox();
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24),
          vertical: context.h(12),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.9),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(16),
                    vertical: context.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: _isPoseCorrect
                        ? CustomColors.purpleColor.withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(context.r(12)),
                    border: Border.all(
                      color: _isPoseCorrect
                          ? CustomColors.purpleColor
                          : Colors.white24,
                    ),
                  ),
                  child: Text(
                    _isFaceDetectorError || _showManualCaptureUI
                        ? "MANUAL CAPTURE MODE"
                        : (_isAutomaticMode
                              ? "AUTOMATIC CAPTURE MODE"
                              : "MANUAL CAPTURE MODE"),
                    style: TextStyle(
                      color:
                          _isPoseCorrect ||
                              _isFaceDetectorError ||
                              _showManualCaptureUI
                          ? CustomColors.purpleColor
                          : Colors.white70,
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                // if (_currentYaw != null) ...[
                //   SizedBox(width: context.w(8)),
                //   Container(
                //     padding: EdgeInsets.symmetric(
                //       horizontal: context.w(12),
                //       vertical: context.h(6),
                //     ),
                //     decoration: BoxDecoration(
                //       color: _isPoseCorrect
                //           ? CustomColors.purpleColor.withValues(alpha: 0.2)
                //           : Colors.black45,
                //       borderRadius: BorderRadius.circular(context.r(12)),
                //       border: Border.all(
                //         color: _isPoseCorrect
                //             ? CustomColors.purpleColor
                //             : Colors.white24,
                //       ),
                //     ),
                //     child: Text(
                //       "Yaw: ${_currentYaw!.toStringAsFixed(1)}°",
                //       style: TextStyle(
                //         color: _isPoseCorrect
                //             ? CustomColors.purpleColor
                //             : Colors.white,
                //         fontSize: context.sp(12),
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
            SizedBox(height: context.h(12)),
            Text(
              _getInstructionText(),
              style: CustomFonts.white22w600.copyWith(fontSize: context.sp(26)),
            ),
            SizedBox(height: context.h(4)),
            Text(
              _isAutomaticMode
                  ? "Keep your face within the frame for auto-capture"
                  : "Position your face and capture",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: context.sp(14)),
            ),
            if (!_isAutomaticMode || _showManualCaptureUI)
              Padding(
                padding: EdgeInsets.only(top: context.h(8)),
                child: Text(
                  "Tip: You can also tap anywhere or press the Volume button to capture",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomColors.purpleColor,
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(height: context.h(16)),
            _buildProfessionalTips(),
            SizedBox(height: context.h(16)),
            if (_isCapturing)
              const AppLoader()
            else
              Padding(
                padding: EdgeInsets.only(bottom: context.h(8)),
                child: Column(
                  children: [
                    if (!_isAutomaticMode)
                      CustomButton(
                        onPressed: () => _handleCaptureTrigger(),
                        text: "Capture Image",
                      ),
                    SizedBox(height: context.h(8)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAutomaticMode = !_isAutomaticMode;
                          SecureStorage().saveCaptureMode(_isAutomaticMode);
                          if (!_isAutomaticMode) {
                            _stopCountdown();
                          }
                        });
                        _speakInstruction();
                      },
                      child: Text(
                        "Switch to ${_isAutomaticMode ? "Manual" : "Automatic"} Mode",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(14),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTips() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSmallTip(Iconsax.camera, "Clean lens")),
            SizedBox(width: context.w(12)),
            Expanded(child: _buildSmallTip(Iconsax.flash, "Bright light")),
          ],
        ),
        SizedBox(height: context.h(8)),
        Row(
          children: [
            Expanded(child: _buildSmallTip(Iconsax.frame_1, "Steady hand")),
            SizedBox(width: context.w(12)),
            Expanded(child: _buildSmallTip(Iconsax.user_square, "Clear face")),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallTip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.sp(16), color: CustomColors.purpleColor),
          SizedBox(width: context.w(8)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: context.sp(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionText() {
    final isFrontCamera =
        _cameraController?.description.lensDirection ==
        CameraLensDirection.front;

    if (widget.pose == 'front') return "Look Straight";

    if (isFrontCamera) {
      return widget.pose == 'left' ? "Turn Right" : "Turn Left";
    } else {
      return widget.pose == 'left' ? "Turn Left" : "Turn Right";
    }
  }
}

class TintOverlayPainter extends CustomPainter {
  final double centerRadius;
  final double? centerY;
  final bool isPoseCorrect;
  final double pulseValue;

  TintOverlayPainter({
    required this.centerRadius,
    this.centerY,
    required this.isPoseCorrect,
    this.pulseValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, centerY ?? size.height / 2);

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7);
    final cutoutPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: centerRadius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(cutoutPath, backgroundPaint);

    final guideColor = isPoseCorrect
        ? CustomColors.purpleColor
        : Colors.white.withValues(alpha: 0.6);

    final borderPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, centerRadius, borderPaint);

    if (isPoseCorrect) {
      final pulsePaint = Paint()
        ..color = guideColor.withValues(alpha: 0.3 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (10 * pulseValue);

      canvas.drawCircle(center, centerRadius + (20 * pulseValue), pulsePaint);
    }

    final bracketPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const bracketPadding = 10.0;
    const bracketWidth = 0.5;
    final r = centerRadius + bracketPadding;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14159 + 0.2,
      bracketWidth,
      false,
      bracketPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -0.7,
      bracketWidth,
      false,
      bracketPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14159 / 2 + 0.2,
      bracketWidth,
      false,
      bracketPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      0.2,
      bracketWidth,
      false,
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(TintOverlayPainter oldDelegate) {
    return oldDelegate.centerRadius != centerRadius ||
        oldDelegate.centerY != centerY ||
        oldDelegate.isPoseCorrect != isPoseCorrect ||
        oldDelegate.pulseValue != pulseValue;
  }
}
