import 'package:attendance/style/__init__.dart';
import 'package:attendance/widget/window.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecWidget extends StatefulWidget {
  final String path;
  const TextRecWidget({super.key, required this.path});

  @override
  State<TextRecWidget> createState() => _TextRecWidgetState();
}

class _TextRecWidgetState extends State<TextRecWidget> {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  RecognizedText? recognizedText;

  processImage(InputImage inputImage) async {
    recognizedText = await textRecognizer.processImage(inputImage);
    print(recognizedText);
  }

  @override
  void initState() {
    super.initState();
    final InputImage inputImage = InputImage.fromFilePath(widget.path);
    processImage(inputImage);
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindowBar(
          logo: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: const StText.big('Update')),
      body: Container(),
    );
  }
}
