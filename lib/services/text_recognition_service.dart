import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractTextFromImages(List<String> imagePaths) async {
    StringBuffer extractedText = StringBuffer();

    try {
      for (int i = 0; i < imagePaths.length; i++) {
        final inputImage = InputImage.fromFilePath(imagePaths[i]);
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
        
        if (i > 0) {
          extractedText.writeln('\n--- Trang ${i + 1} ---\n');
        } else if (imagePaths.length > 1) {
          extractedText.writeln('--- Trang 1 ---\n');
        }
        
        extractedText.writeln(recognizedText.text);
      }
    } catch (e) {
      print('Error during text recognition: $e');
      return 'Lỗi trích xuất văn bản: $e';
    }

    return extractedText.toString();
  }

  void dispose() {
    _textRecognizer.close();
  }
}
