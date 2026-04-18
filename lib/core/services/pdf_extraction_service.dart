import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractionService {
  /// Extracts text from a PDF file using the file bytes (works on Web and Mobile/Desktop)
  Future<String> extractTextFromBytes(PlatformFile file) async {
    try {
      if (file.bytes == null) {
        throw Exception("File bytes are null. Make sure to pick the file with withData: true");
      }

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: file.bytes!);
      
      // Extract text
      final String extractedText = PdfTextExtractor(document).extractText();
      
      // Dispose the document
      document.dispose();
      
      return extractedText;
    } catch (e) {
      debugPrint("Error extracting PDF text: $e");
      return "ERROR_EXTRACTING_TEXT: $e";
    }
  }
}
