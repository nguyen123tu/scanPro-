import 'package:flutter/material.dart';
import '../../../services/scanner_service.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  final ScannerService _scannerService = ScannerService();
  bool _isScanning = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    try {
      final images = await _scannerService.scanDocuments();
      if (images != null && images.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewScreen(imagePaths: images),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40.0, bottom: 20),
              child: Center(
                child: Text(
                  'ScanApp Pro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            const Text(
              'Số hóa tài liệu của bạn trong chớp mắt',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            Expanded(
              child: Center(
                child: _isScanning
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 3),
                          SizedBox(height: 24),
                          Text('Đang xử lý máy ảnh...', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                        ],
                      )
                    : GestureDetector(
                        onTap: _startScan,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.4 + (_animationController.value * 0.2)),
                                    blurRadius: 30 + (_animationController.value * 20),
                                    spreadRadius: 5 + (_animationController.value * 10),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.document_scanner_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Text(
                'Nhấn để bắt đầu quét',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
