import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  const ToolButton({
    Key? key,
    required this.icon,
    required this.submit,
    required this.color,
    this.title
  }) : super(key: key);

  final IconData    icon;
  final Function()? submit;
  final Color       color;
  final String?     title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: color
          ),
          child: IconButton(
            onPressed: submit,
            icon: Icon(icon, color: Colors.white),
          ),
        ),
        if(title != null)
        const SizedBox(width: 5),
        if(title != null)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: color
          ),
          padding: const EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
          child: Text(
            '$title',
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.white
            ),
          ),
        )
      ],
    );
  }
}
