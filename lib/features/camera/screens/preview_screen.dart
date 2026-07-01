import 'dart:io';
import 'package:flutter/material.dart';
import '../../enhancement/screens/text_result_screen.dart';
import '../../../services/pdf_service.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> imagePaths;

  const PreviewScreen({Key? key, required this.imagePaths}) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final PdfService _pdfService = PdfService();
  bool _isExporting = false;

  void _onExtractText() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TextResultScreen(imagePaths: widget.imagePaths, isCloudOcr: false),
      ),
    );
  }

  void _onExtractCloudText() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TextResultScreen(imagePaths: widget.imagePaths, isCloudOcr: true),
      ),
    );
  }

  Future<void> _onExportImagePdf() async {
    String fileName = "TaiLieu_CauTruc";
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController(text: fileName);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Lưu PDF Hình ảnh', style: TextStyle(fontWeight: FontWeight.bold)),
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
      final pdfFile = await _pdfService.generatePdfFromImages(widget.imagePaths, result.trim());
      await _pdfService.shareFile(pdfFile, text: 'Tài liệu cấu trúc gốc từ Document Scanner');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xuất PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isPremium 
          ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)])
          : const LinearGradient(colors: [Colors.white, Colors.white]),
        boxShadow: [
          BoxShadow(
            color: isPremium ? const Color(0xFF8B5CF6).withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPremium ? Colors.white.withOpacity(0.2) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon, 
                    size: 32, 
                    color: isPremium ? Colors.white : const Color(0xFF475569)
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPremium ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isPremium ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isPremium ? Colors.white.withOpacity(0.7) : const Color(0xFFCBD5E1),
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn định dạng xuất',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imagePaths.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                          image: DecorationImage(
                            image: FileImage(File(widget.imagePaths[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Cách xử lý tài liệu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                
                _buildOptionCard(
                  title: 'Trích xuất Chữ (Nhanh)',
                  subtitle: 'Đọc chữ tự động không cần mạng. Dùng cho đoạn văn ngắn.',
                  icon: Icons.bolt_rounded,
                  onTap: _onExtractText,
                ),
                
                _buildOptionCard(
                  title: 'Trích xuất Siêu Tốc (AI)',
                  subtitle: 'Sử dụng AI OCR.space cực mạnh. Nhận diện cực chuẩn.',
                  icon: Icons.auto_awesome_rounded,
                  isPremium: true,
                  onTap: _onExtractCloudText,
                ),
                
                _buildOptionCard(
                  title: 'PDF Hình ảnh Gốc',
                  subtitle: 'Giữ nguyên 100% bố cục bảng biểu, màu sắc của tài liệu.',
                  icon: Icons.grid_view_rounded,
                  onTap: _onExportImagePdf,
                ),
              ],
            ),
          ),
          
          if (_isExporting)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
        ],
      ),
    );
  }
}
