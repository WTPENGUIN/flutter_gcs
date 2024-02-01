import 'package:flutter/material.dart';

const ballDiameter = 30.0;

class ResizebleContainerWidget extends StatefulWidget {
  const ResizebleContainerWidget({
    required this.size,
    required this.child,
    this.boxColor = Colors.black54,
    Key? key
  }) : super(key: key);

  final Widget child;
  final Size   size;
  final Color  boxColor;

  @override
  State<ResizebleContainerWidget> createState() => _ResizebleContainerWidgetState();
}

class _ResizebleContainerWidgetState extends State<ResizebleContainerWidget> {
  late double height;
  late double width;

  double top = 0;
  double left = 0;

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
  }

  @override
  void initState() {
    super.initState();
    
    height = widget.size.height;
    width = widget.size.width;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: widget.boxColor,
      child: Stack(
        children: [
          Positioned(
            top: top,
            left: left,
            child: SizedBox(
              height: height,
              width: width,
              child: widget.child,
            )
          ),
          // Top Right Handle
          Positioned(
            //top: top - ballDiameter / 2,
            top: top,
            left: left + width - ballDiameter,
            child: ManipulatePoint(
              onDrag: (dx, dy) {
                var newHeight = height - dy;
                var newWidth = width + dx;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  width = newWidth > 0 ? newWidth : 0;
                });
              }
            ),
          )
        ],
      ),
    );
    // return Stack(
    //   children: <Widget>[
    //     Positioned(
    //       top: top,
    //       left: left,
    //       child: Container(
    //         height: height,
    //         width: width,
    //         color: Colors.red[100],
    //         child: widget.child,
    //       ),
    //     ),
    //     // Top Right Handle
    //     Positioned(
    //       top: top - ballDiameter / 2,
    //       left: left + width - ballDiameter / 2,
    //       child: ManipulatingBall(
    //         onDrag: (dx, dy) {
    //           var newHeight = height - dy;
    //           var newWidth = width + dx;

    //           setState(() {
    //             height = newHeight > 0 ? newHeight : 0;
    //             width = newWidth > 0 ? newWidth : 0;
		// 		        top = top + dy;
    //           });
    //         },
    //       ),
    //     ),
    //   ],
    // );
  }
}

class ManipulatePoint extends StatefulWidget {
  const ManipulatePoint({
    required this.onDrag,
    Key? key,
  }) : super(key: key);

  final Function onDrag;

  @override
  State<ManipulatePoint> createState() => _ManipulatePointState();
}

class _ManipulatePointState extends State<ManipulatePoint> {
  double initX = 0.0;
  double initY = 0.0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }
}