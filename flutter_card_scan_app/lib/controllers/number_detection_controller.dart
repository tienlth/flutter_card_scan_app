import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class NumberDetectionController {
  Future<String?> recognizeNumber(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

      String numbers = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final String lineText = line.text;
          final String digits = RegExp(r'\d+').stringMatch(lineText) ?? '';
          numbers += '$digits ';
        }
      }

      return numbers.trim();
    } catch (e) {
      print('Error recognizing text: $e');
      return null;
    } finally {
      textRecognizer.close();
    }
  }

  Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return pickedFile.path;
    }

    return null;
  }
}