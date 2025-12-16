import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(_cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview or Manual Input
          if (_isInitialized && _controller != null)
            _buildCameraPreview()
          else
            _buildManualInput(),

          // Overlay
          _buildOverlay(),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: kBlack.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, color: kWhite, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Position the barcode within the frame',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Or enter barcode manually below',
                    style: TextStyle(color: kMediumGray, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Flash Toggle (only if camera is available)
          if (_isInitialized && _controller != null)
            Positioned(
              bottom: 40,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  if (_controller != null) {
                    try {
                      await _controller!.setFlashMode(
                        _isFlashOn ? FlashMode.off : FlashMode.torch,
                      );
                      setState(() {
                        _isFlashOn = !_isFlashOn;
                      });
                    } catch (e) {
                      debugPrint('Error toggling flash: $e');
                    }
                  }
                },
                backgroundColor: kWhite,
                child: Icon(
                  _isFlashOn ? Icons.flash_off : Icons.flash_on,
                  color: kBlack,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox.expand(child: CameraPreview(_controller!));
  }

  Widget _buildManualInput() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, color: kWhite, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Camera not available',
              style: TextStyle(
                color: kWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter barcode manually',
              style: TextStyle(color: kMediumGray, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _barcodeController,
              style: const TextStyle(color: kWhite, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Enter barcode number',
                hintStyle: const TextStyle(color: kMediumGray),
                filled: true,
                fillColor: kDarkGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_barcodeController.text.isNotEmpty) {
                  Navigator.pop(context, _barcodeController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kWhite,
                foregroundColor: kBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(painter: ScannerOverlayPainter(), child: Container());
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kBlack.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width * 0.7,
            height: size.width * 0.7,
          ),
          const Radius.circular(20),
        ),
      );

    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      cutoutPath,
    );

    canvas.drawPath(combinedPath, paint);

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = kWhite
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLength = 30.0;
    final cornerWidth = size.width * 0.7;
    final cornerHeight = size.width * 0.7;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Top-left
    canvas.drawLine(
      Offset(centerX - cornerWidth / 2, centerY - cornerHeight / 2),
      Offset(
        centerX - cornerWidth / 2 + cornerLength,
        centerY - cornerHeight / 2,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cornerWidth / 2, centerY - cornerHeight / 2),
      Offset(
        centerX - cornerWidth / 2,
        centerY - cornerHeight / 2 + cornerLength,
      ),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(centerX + cornerWidth / 2, centerY - cornerHeight / 2),
      Offset(
        centerX + cornerWidth / 2 - cornerLength,
        centerY - cornerHeight / 2,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cornerWidth / 2, centerY - cornerHeight / 2),
      Offset(
        centerX + cornerWidth / 2,
        centerY - cornerHeight / 2 + cornerLength,
      ),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(centerX - cornerWidth / 2, centerY + cornerHeight / 2),
      Offset(
        centerX - cornerWidth / 2 + cornerLength,
        centerY + cornerHeight / 2,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cornerWidth / 2, centerY + cornerHeight / 2),
      Offset(
        centerX - cornerWidth / 2,
        centerY + cornerHeight / 2 - cornerLength,
      ),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(centerX + cornerWidth / 2, centerY + cornerHeight / 2),
      Offset(
        centerX + cornerWidth / 2 - cornerLength,
        centerY + cornerHeight / 2,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cornerWidth / 2, centerY + cornerHeight / 2),
      Offset(
        centerX + cornerWidth / 2,
        centerY + cornerHeight / 2 - cornerLength,
      ),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
