import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class ScannerService {
  late DocumentScanner _documentScanner;

  ScannerService() {
    final DocumentScannerOptions options = DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg},
      mode: ScannerMode.filter,
      pageLimit: 100,
      isGalleryImport: true,
    );
    _documentScanner = DocumentScanner(options: options);
  }

  Future<List<String>?> scanDocuments() async {
    try {
      final DocumentScanningResult result = await _documentScanner.scanDocument();
      return result.images;
    } catch (e) {
      print('Error scanning document: $e');
      return null;
    }
  }

  void dispose() {
    _documentScanner.close();
  }
}
