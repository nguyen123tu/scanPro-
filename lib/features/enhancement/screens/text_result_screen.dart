import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/text_recognition_service.dart';
import '../../../services/free_cloud_ocr_service.dart';
import '../../../services/pdf_service.dart';

class TextResultScreen extends StatefulWidget {
  final List<String> imagePaths;
  final bool isCloudOcr;

  const TextResultScreen({Key? key, required this.imagePaths, this.isCloudOcr = false}) : super(key: key);

  @override
  _TextResultScreenState createState() => _TextResultScreenState();
}

class _TextResultScreenState extends State<TextResultScreen> {
  final TextRecognitionService _textService = TextRecognitionService();
  final FreeCloudOcrService _freeCloudOcrService = FreeCloudOcrService();
  final PdfService _pdfService = PdfService();
  final TextEditingController _textController = TextEditingController();
  
  bool _isProcessing = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _processImages();
  }

  Future<void> _processImages() async {
    String text;
    if (widget.isCloudOcr) {
      text = await _freeCloudOcrService.extractTextFromImages(widget.imagePaths);
    } else {
      text = await _textService.extractTextFromImages(widget.imagePaths);
    }
    
    if (mounted) {
      setState(() {
        _textController.text = text;
        _isProcessing = false;
      });
    }
  }

  Future<void> _exportPdf() async {
    String fileName = "TaiLieu_VanBan";
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController(text: fileName);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Lưu PDF Văn bản', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              suffixText: '.pdf',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text('Xuất file'),
            ),
          ],
        );
      }
    );

    if (result == null || result.trim().isEmpty) return;

    setState(() => _isExporting = true);
    try {
      final pdfFile = await _pdfService.generatePdfFromText(_textController.text, result.trim());
      await _pdfService.shareFile(pdfFile, text: 'Văn bản từ Document Scanner');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã chép vào khay nhớ tạm'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isCloudOcr ? 'Kết quả Online' : 'Kết quả Offline',
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  SizedBox(height: 16),
                  Text('Đang dùng AI bóc tách chữ...', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    // Nửa trên: Ảnh Preview
                    Container(
                      height: 140,
                      color: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              image: DecorationImage(
                                image: FileImage(File(widget.imagePaths[index])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    // Nửa dưới: Text Editor
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // padding bottom cho toolbar
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF334155)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Chưa tìm thấy chữ nào...',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Floating Toolbar
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildToolButton(Icons.copy_rounded, 'Chép', _copyToClipboard),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _buildToolButton(Icons.picture_as_pdf_rounded, 'Xuất PDF', _exportPdf),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _buildToolButton(Icons.share_rounded, 'Chia sẻ', () {
                           // Implement later if needed, or just rely on exportPdf's share
                           _exportPdf(); 
                        }),
                      ],
                    ),
                  ),
                ),
                
                if (_isExporting)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
              ],
            ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
