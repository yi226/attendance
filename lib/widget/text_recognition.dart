import 'dart:io';

import 'package:attendance/config/data.dart';
import 'package:attendance/platform/platform.dart';
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
  GlobalKey formKey = GlobalKey<FormState>();
  late File image;
  RecognizedText? recognizedText;
  final List<TextBox> textBoxes = [];

  processImage(InputImage inputImage) async {
    recognizedText = await textRecognizer.processImage(inputImage);
    textBoxes.clear();
    for (TextBlock block in recognizedText!.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          Rect rect = element.boundingBox;
          String text = element.text;
          textBoxes.add(TextBox(rect: rect, text: text));
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    image = File(widget.path);
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
          title: const StText.big('OCR')),
      body: recognizedText == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StText.big('处理中'),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    children: [
                      Image.file(image, width: width),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: TextBoxWidget(
                          textBoxes: textBoxes,
                          path: widget.path,
                          width: width,
                        ),
                      ),
                    ],
                  );
                }),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '表名',
                            ),
                            validator: (v) {
                              String? result;
                              if (v!.trim().isEmpty) {
                                result = "表名不能为空";
                              } else if (Data().sheets.contains(v)) {
                                result = "表名已存在";
                              }
                              return result;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: const Center(child: Text('Save')),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
    );
  }
}

class TextBox extends ChangeNotifier {
  final Rect rect;
  final String text;
  String? editText;
  String get name => editText ?? text;
  bool _selected = false;
  bool get selected => _selected;
  set selected(bool s) {
    _selected = s;
    notifyListeners();
  }

  TextBox({required this.rect, required this.text});
}

class TextBoxWidget extends StatefulWidget {
  final String path;
  final List<TextBox> textBoxes;
  final double width;
  const TextBoxWidget(
      {super.key,
      required this.textBoxes,
      required this.path,
      required this.width});

  @override
  State<TextBoxWidget> createState() => _TextBoxWidgetState();
}

class _TextBoxWidgetState extends State<TextBoxWidget> {
  Size? originSize;

  double get radio => widget.width / originSize!.width;

  @override
  void initState() {
    getImageInfo();
    super.initState();
  }

  getImageInfo() async {
    final (width, height) = await IntegratePlatform.getImageInfo(widget.path);
    originSize = Size(width.toDouble(), height.toDouble());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (originSize == null) {
      return Container();
    } else {
      return SizedBox(
        width: widget.width,
        height: originSize!.height * radio,
        child: Stack(
          children: [
            for (var textBox in widget.textBoxes)
              Positioned(
                left: textBox.rect.left * radio,
                top: textBox.rect.top * radio,
                width: textBox.rect.width * radio,
                height: textBox.rect.height * radio,
                child: Listener(
                  onPointerHover: (event) {
                    textBox.selected = !textBox.selected;
                  },
                  child: ListenableBuilder(
                      listenable: textBox,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            color: textBox.selected
                                ? Colors.green.withAlpha(100)
                                : null,
                          ),
                        );
                      }),
                ),
              ),
          ],
        ),
      );
    }
  }
}
