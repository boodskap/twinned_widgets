
import 'package:flutter/material.dart';

class CylinderTank extends StatelessWidget {
  final String label;
  final double height;
  final double width;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final Color fontColor;

  const CylinderTank(
      {super.key,
      this.height = 200,
      this.width = 200,
      required this.liquidLevel,
      this.liquidColor = Colors.lightBlue,
      this.bottleColor = Colors.black,
      this.shouldAnimate = false,
      this.fontSize = 12,
      this.fontColor = Colors.black,
      required this.label});

  @override
  Widget build(BuildContext context) {
    double liqlvl() {
      double lq = liquidLevel >= 100
          ? 100
          : liquidLevel <= 0
              ? 0
              : liquidLevel;
      return lq;
    }

    var top = EyeShapeContainer.opened;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: fontColor, fontSize: fontSize),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          height: height,
          width: width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: (liqlvl() / 100) * (height - top),
                color: liquidColor,
              ),
              Positioned(
                  bottom: height - (top + top / 2),
                  child: EyeShapeContainer(
                    width: width,
                    topColor: bottleColor,
                  )),
              Container(
                height: height - top,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: bottleColor,
                      width: 1.0,
                    ),
                    left: BorderSide(
                      color: bottleColor,
                      width: 1.0,
                    ),
                    right: BorderSide(
                      color: bottleColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: height / 2 - top,
                child: Text(
                  '${liqlvl()}%',
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class EyeShapeContainer extends StatelessWidget {
  static double opened = 15;
  final double width;
  final Color topColor;
  const EyeShapeContainer(
      {super.key, required this.width, this.topColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: EyeShapeBorderPainter(topColor),
      child: ClipPath(
        clipper: EyeShapeClipper(),
        child: SizedBox(
          height: opened,
          width: width,
        ),
      ),
    );
  }
}

class EyeShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height / 2);

    path.quadraticBezierTo(
      size.width / 4,
      0,
      size.width / 2,
      0,
    );

    path.quadraticBezierTo(
      size.width * 3 / 4,
      0,
      size.width,
      size.height / 2,
    );

    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height,
      size.width / 2,
      size.height,
    );

    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      0,
      size.height / 2,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class EyeShapeBorderPainter extends CustomPainter {
  final Color topColor;

  EyeShapeBorderPainter(this.topColor);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = topColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    var path = Path();

    path.moveTo(0, size.height / 2);

    path.quadraticBezierTo(
      size.width / 4,
      0,
      size.width / 2,
      0,
    );

    path.quadraticBezierTo(
      size.width * 3 / 4,
      0,
      size.width,
      size.height / 2,
    );

    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height,
      size.width / 2,
      size.height,
    );

    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      0,
      size.height / 2,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
