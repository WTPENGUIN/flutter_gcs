import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// flutter_svg 패키지를 이용해 svg 이미지를 가져온다.
class SVGImage extends StatelessWidget {
  final String route;
  final Size   size;
  final double radians;

  const SVGImage({
    required this.route,
    required this.size,
    required this.radians,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: radians,
      child: SvgPicture.asset(
        route,
        height: size.height,
        width:  size.width,
      ),
    );
  }
}