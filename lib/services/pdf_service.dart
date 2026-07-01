import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

class PdfService {
  Future<File> generatePdfFromText(String textContent, String fileName) async {
    final pdf = pw.Document();

    // Tự động tải phông chữ tiếng Việt (Roboto) từ Google Fonts
    final ttf = await PdfGoogleFonts.robotoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              textContent,
              style: pw.TextStyle(font: ttf, fontSize: 14, lineSpacing: 2),
            ),
          ];
        },
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final file = File('${outputDir.path}/$fileName.pdf');
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> generatePdfFromImages(List<String> imagePaths, String fileName) async {
    final pdf = pw.Document();

    for (var path in imagePaths) {
      final imageBytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    final outputDir = await getTemporaryDirectory();
    final file = File('${outputDir.path}/$fileName.pdf');
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> shareFile(File file, {String text = 'Tài liệu được trích xuất từ Document Scanner'}) async {
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: text
      );
    }
  }

  Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
