import 'package:flutter/material.dart';
import 'package:peachgs_flutter/utils/utils.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageStete();
}

class _VideoPageStete extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200 * scaleSmallDevice(context),
      width: 350 * scaleSmallDevice(context),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: const Color(0x99808080)
      ),
    );
  }
}