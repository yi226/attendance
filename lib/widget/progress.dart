import 'package:flutter/material.dart';
import 'package:attendance/style/__init__.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color color;
  final bool reversed;

  const ProgressBar({
    Key? key,
    this.progress = 1.0,
    this.height = 8,
    this.color = ColorPlate.primaryPink,
    this.reversed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              color: ColorPlate.lightGray,
            ),
            SizedBox(
              width: double.infinity,
              child: FractionallySizedBox(
                alignment:
                    !reversed ? Alignment.centerLeft : Alignment.centerRight,
                heightFactor: 1,
                widthFactor: progress,
                child: Container(
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
