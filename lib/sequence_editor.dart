import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'circular-button.dart';
import 'colors.dart';
import 'providers/providers.dart';

class SequenceEditor extends StatefulWidget {
  const SequenceEditor({super.key});

  @override
  State<SequenceEditor> createState() => _SequenceEditorState();
}

class _SequenceEditorState extends State<SequenceEditor> {
  static const double _size = 300;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        panUpdate(details);
      },
      onTapUp: (details) {
        tapUp(details);
      },
      child: Container(
        height: _size,
        width: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration:
                  const BoxDecoration(color: COLOR_ONE, shape: BoxShape.circle),
              height: _size * 0.9,
              width: _size * 0.9,
            ),
            Positioned(
              top: _size / 3.4,
              left: _size / 6,
              width: _size * 4 / 6,
              child: Slider(
                thumbColor: COLOR_THREE,
                activeColor: COLOR_THREE,
                value: Provider.of<SequenceData>(context).getBrightness(),
                onChanged: (double d) {
                  Provider.of<SequenceData>(context, listen: false)
                      .setBrightness(d);
                },
              ),
            ),
            Positioned(
              top: _size / 1.9,
              left: _size / 6,
              width: _size * 4 / 6,
              child: Slider(
                thumbColor: COLOR_THREE,
                activeColor: COLOR_THREE,
                value: Provider.of<SequenceData>(context).getSmoothness(),
                onChanged: (double d) {
                  Provider.of<SequenceData>(context, listen: false)
                      .setSmoothness(d);
                },
              ),
            ),
            const Positioned(
              top: _size / 5,
              left: _size / 3,
              child: Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: _size / 12,
              ),
            ),
            const Positioned(
              top: _size * 0.7,
              left: _size / 3,
              child: Icon(
                Icons.iron,
                color: Colors.white,
                size: _size / 12,
              ),
            ),
            Positioned(
              top: _size / 5,
              right: _size / 3,
              child: Text(
                "${(Provider.of<SequenceData>(context).getBrightness() * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: _size / 14,
                ),
              ),
            ),
            Positioned(
              top: _size * 0.7,
              right: _size / 3,
              child: Text(
                "${(Provider.of<SequenceData>(context).getSmoothness() * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: _size / 14,
                ),
              ),
            ),
            for (int i = 0; i < 24; i++)
              CircularButton(
                top: _size / 2 -
                    cos(2 * 3.1415 * (i + 0.5) / 24) * (_size / 2.5),
                left: _size / 2 +
                    sin(2 * 3.1415 * (i + 0.5) / 24) * (_size / 2.5),
                color: Provider.of<SequenceData>(context).getSequence(i)
                    ? COLOR_THREE
                    : COLOR_TWO,
                size: _size / 10,
              ),
          ],
        ),
      ),
    );
  }

  panUpdate(DragUpdateDetails details) {
    double dx = details.localPosition.dx - _size / 2;
    double dy = details.localPosition.dy - _size / 2;
    if (dx > 2 || dx < -2) {
      Provider.of<SequenceData>(context, listen: false).setSequence(
          getButtonFromAngle(dx, dy),
          setOrDelete(dx, dy, details.delta.dx, details.delta.dy));
    }
  }

  tapUp(TapUpDetails details) {
    double dx = details.localPosition.dx - _size / 2;
    double dy = details.localPosition.dy - _size / 2;
    if (dx > 2 || dx < -2) {
      int i = getButtonFromAngle(dx, dy);
      Provider.of<SequenceData>(context, listen: false).setSequence(i,
          !(Provider.of<SequenceData>(context, listen: false).getSequence(i)));
    }
  }

  int getButtonFromAngle(double x, double y) {
    int i;
    if (x > 0) {
      i = ((6 + atan(y / x) * 6 / (3.1415 / 2)).toInt());
    } else {
      i = ((18 + atan(y / x) * 6 / (3.1415 / 2)).toInt());
    }
    if (i > 23) i = 23;
    return i;
  }

  bool setOrDelete(double x, double y, double dx, double dy) {
    if (x > 0 && y < 0 && dx + dy > 0) {
      return true;
    } else if (x > 0 && y > 0 && dx - dy < 0) {
      return true;
    } else if (x < 0 && y > 0 && dx + dy < 0) {
      return true;
    } else if (x < 0 && y < 0 && dx - dy > 0) {
      return true;
    }
    return false;
  }
}
