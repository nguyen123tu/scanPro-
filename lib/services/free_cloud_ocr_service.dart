import 'dart:convert';
import 'package:http/http.dart' as http;

class FreeCloudOcrService {
  // Mã API mặc định miễn phí (có thể bị chậm nếu nhiều người dùng)
  // Bạn có thể đăng ký mã riêng tại ocr.space miễn phí bằng Email.
  static const String _apiKey = 'helloworld';
  static const String _apiUrl = 'https://api.ocr.space/parse/image';

  Future<String> extractTextFromImages(List<String> imagePaths) async {
    StringBuffer extractedText = StringBuffer();

    try {
      for (int i = 0; i < imagePaths.length; i++) {
        var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
        
        // Cấu hình tham số
        request.fields['apikey'] = _apiKey;
        request.fields['language'] = 'vnm'; // 'vnm' là mã bắt buộc cho Tiếng Việt của OCR.space
        request.fields['OCREngine'] = '2'; // Đổi sang Engine 2 (bắt buộc cho Tiếng Việt)
        
        // Đính kèm file ảnh
        request.files.add(await http.MultipartFile.fromPath('file', imagePaths[i]));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          if (data['IsErroredOnProcessing'] == false) {
            final parsedResults = data['ParsedResults'] as List;
            if (parsedResults.isNotEmpty) {
              final text = parsedResults[0]['ParsedText'];
              
              if (i > 0) {
                extractedText.writeln('\n--- Trang ${i + 1} ---\n');
              } else if (imagePaths.length > 1) {
                extractedText.writeln('--- Trang 1 ---\n');
              }
              extractedText.writeln(text);
            }
          } else {
            extractedText.writeln('\n[Lỗi xử lý ảnh: ${data['ErrorMessage']}]');
          }
        } else {
          print('OCR.space API Error: ${response.body}');
          return "Lỗi từ Server OCR.space: Mã ${response.statusCode}";
        }
      }
    } catch (e) {
      print('Network Error: $e');
      return 'Lỗi kết nối mạng: Vui lòng kiểm tra Wifi/4G của bạn.';
    }

    return extractedText.toString();
  }
}
