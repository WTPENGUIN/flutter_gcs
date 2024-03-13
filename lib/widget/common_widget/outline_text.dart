import 'package:flutter/material.dart';

class OutlineText extends StatelessWidget {
  const OutlineText({
    Key? key,
    required this.child,
    this.strokeWidth = 2,
    this.strokeColor,
    this.overflow
  }) : super(key: key);

  final Text          child;
  final double        strokeWidth;
  final Color?        strokeColor;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          textScaler: child.textScaler,
          child.data!,
          style: TextStyle(
            fontSize: child.style?.fontSize,
            fontWeight: child.style?.fontWeight,
            foreground: Paint()
              ..color = strokeColor ?? Theme.of(context).shadowColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth,
          ),
          overflow: overflow,
        ),
        child
      ],
    );
  }
}