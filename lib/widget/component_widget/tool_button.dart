import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  final IconData icon;
  final Function()? submit;
  final Color color;

  const ToolButton({
    required this.icon,
    required this.submit,
    required this.color,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: color
      ),
      child: IconButton(
        onPressed: submit,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
