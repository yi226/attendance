import 'package:attendance/config/data.dart';
import 'package:attendance/config/item.dart';
import 'package:attendance/platform/platform.dart';
import 'package:attendance/style/style.dart';
import 'package:attendance/widget/window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'dart:ui' as ui;

class TextRecWidget extends StatefulWidget {
  final String path;
  const TextRecWidget({super.key, required this.path});

  @override
  State<TextRecWidget> createState() => _TextRecWidgetState();
}

class _TextRecWidgetState extends State<TextRecWidget> {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  GlobalKey formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  RecognizedText? recognizedText;
  final List<TextBox> textBoxes = [];
  final List<Offset> points = [];
  ui.Image? image;

  processImage(InputImage inputImage) async {
    if (kDebugMode) {
      print('process image');
    }
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
    image = await IntegratePlatform.getImage(widget.path);
    setState(() {});
  }

  onPan(Offset localPosition) {
    for (var textBox in textBoxes) {
      if (textBox.relRect?.contains(localPosition) == true) {
        if (!textBox.pan) {
          textBox.pan = true;
          textBox.selected = !textBox.selected;
        }
      } else {
        textBox.pan = false;
      }
    }
    points.add(localPosition);
    if (points.length > 20) {
      points.removeAt(0);
    }
    setState(() {});
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
    nameController.dispose();
    image?.dispose();
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
        title: const StText.big('OCR'),
      ),
      body: recognizedText == null || image == null
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
                Expanded(
                  child: LayoutBuilder(builder: (context, constrains) {
                    return GestureDetector(
                      onPanStart: (e) => onPan(e.localPosition),
                      onPanUpdate: (e) => onPan(e.localPosition),
                      onPanEnd: (e) {
                        points.clear();
                        setState(() {});
                      },
                      child: CustomPaint(
                        painter: ImageTextBoxPainter(image!, textBoxes, points),
                        size: Size(constrains.maxWidth, constrains.maxHeight),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: const Center(child: Text('Save')),
                    onPressed: () async {
                      nameController.text = textBoxes
                          .takeWhile((v) => v.selected)
                          .map((e) => e.name)
                          .join('\n');
                      String name = "";
                      int count = 0;
                      String? lastName;
                      final navState = Navigator.of(context);
                      final result = await MyDialog.alertModal(
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Form(
                                key: formKey,
                                autovalidateMode: AutovalidateMode.always,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        labelText: '表名',
                                      ),
                                      validator: (v) {
                                        return v!.trim().isNotEmpty
                                            ? null
                                            : "表名不能为空";
                                      },
                                      onChanged: (v) {
                                        name = v;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: '人名',
                                        hintText: '每行一个人名',
                                      ),
                                      validator: (v) {
                                        return v!.trim().isNotEmpty
                                            ? null
                                            : "人名不能为空";
                                      },
                                      maxLines: 9,
                                      controller: nameController,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              child: const Center(child: Text('Save')),
                              onPressed: () {
                                final data = Data();
                                if ((formKey.currentState as FormState)
                                    .validate()) {
                                  if (data.sheets.contains(name) &&
                                      count == 0 &&
                                      lastName != name) {
                                    MyDialog.toast(
                                      '$name已存在, 若继续将覆盖原表',
                                      style: MyDialog.theme.toastStyle?.top(),
                                    );
                                    lastName = name;
                                    count++;
                                    return;
                                  }
                                  final nameListData = nameController.text
                                      .split('\n')
                                    ..removeWhere((element) => element.isEmpty);
                                  final sh =
                                      Sheet.fromNameList(name, nameListData);
                                  if (sh == null) {
                                    return;
                                  }
                                  data.addSheet(sh);
                                  Navigator.of(context).pop(true);
                                }
                              },
                            ),
                          ],
                        ),
                        [],
                        barrierDismissible: true,
                      );
                      if (result == true) navState.pop();
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class TextBox {
  final Rect rect;
  Rect? relRect;
  final String text;
  String? editText;
  String get name => editText ?? text;
  bool selected = false;
  bool pan = false;

  TextBox({required this.rect, required this.text});
}

class ImageTextBoxPainter extends CustomPainter {
  final ui.Image _image;
  final List<TextBox> textBoxes;
  final List<Offset> points;
  ImageTextBoxPainter(this._image, this.textBoxes, this.points) : super();

  Paint boxPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Paint selectedBoxPaint = Paint()
    ..color = Colors.blue.withAlpha(100)
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  Paint linePaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  late Size origin;
  late double radio;
  late Size bias;

  (Rect, Rect) initTrans(Size size) {
    origin = Size(_image.width.toDouble(), _image.height.toDouble());
    final src = Rect.fromLTWH(0, 0, origin.width, origin.height);
    radio = size.width / origin.width;
    double dstHeight = origin.height * radio;
    Rect dst = Rect.zero;
    if (dstHeight > size.height) {
      radio = size.height / origin.height;
      final left = (size.width - origin.width * radio) / 2;
      bias = Size(left, 0);
      dst = Rect.fromLTWH(0, 0, origin.width * radio, size.height);
    } else {
      final top = (size.height - dstHeight) / 2;
      bias = Size(0, top);
      dst = Rect.fromLTWH(0, top, size.width, dstHeight);
    }
    return (src, dst);
  }

  Rect trans(Rect src) {
    return Rect.fromLTWH(src.left * radio + bias.width,
        src.top * radio + bias.height, src.width * radio, src.height * radio);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (src, dst) = initTrans(size);
    canvas.drawImageRect(_image, src, dst, Paint());
    for (var textBox in textBoxes) {
      textBox.relRect = trans(textBox.rect);
      if (textBox.selected) {
        canvas.drawRect(textBox.relRect!, selectedBoxPaint);
      } else {
        canvas.drawRect(textBox.relRect!, boxPaint);
      }
    }
    if (points.isEmpty) return;
    var path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
