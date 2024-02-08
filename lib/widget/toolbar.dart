import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToolBar extends StatelessWidget implements PreferredSizeWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey,
      title: Row(
        children: [
          // 로고 이미지
          SvgPicture.asset(
            'assets/svg/PeachLogo.svg',
            width: 40,
            height: 40,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          color: Colors.black,
          onPressed: () {
            // 버튼 1의 기능 설정
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: Colors.black,
          onPressed: () {
            // 버튼 2의 기능 설정
          },
        ),
      ],
    );
  }
}