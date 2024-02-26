import 'package:flutter/material.dart';

const ballDiameter = 30.0;

enum ResizeHandlePosition {
  positionUpperLeft,
  positionUpperRight
}

class ResizebleContainerWidget extends StatefulWidget {
  const ResizebleContainerWidget({
    required this.size,
    required this.child,
    required this.position,
    this.boxColor = Colors.black54,
    Key? key
  }) : super(key: key);

  final Widget child;
  final Size   size;
  final Color  boxColor;
  final ResizeHandlePosition position;

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
    height = widget.size.height;
    width = widget.size.width;

    super.initState();
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
          // 왼쪽 상단에 위치하는 크기조정 핸들
          Visibility(
            visible: (widget.position == ResizeHandlePosition.positionUpperLeft),
            child: Positioned(
              top: top,
              left: left,
              child: ManipulatePoint(
                onDrag: (dx, dy) {
                  var mid = (dx + dy) / 2;
                  var newHeight = height - mid;
                  var newWidth = width - mid;

                  if(newHeight > MediaQuery.of(context).size.height * 0.75) return;
                  if(newWidth > MediaQuery.of(context).size.width * 0.75) return;

                  setState(() {
                    height = newHeight > widget.size.height ? newHeight : widget.size.height;
                    width  = newWidth  > widget.size.width  ? newWidth  : widget.size.width;
                  });
                },
              ),
            ),
          ),
          // 오른쪽 상단에 위치하는 크기조정 핸들
          Visibility(
            visible: (widget.position == ResizeHandlePosition.positionUpperRight),
            child: Positioned(
              top: top,
              left: left + width - ballDiameter,
              child: ManipulatePoint(
                onDrag: (dx, dy) {
                  var newHeight = height - dy;
                  var newWidth = width + dx;

                  if(newHeight > MediaQuery.of(context).size.height * 0.75) return;
                  if(newWidth > MediaQuery.of(context).size.width * 0.75) return;

                  setState(() {
                    height = newHeight > widget.size.height ? newHeight : widget.size.height;
                    width  = newWidth  > widget.size.width  ? newWidth  : widget.size.width;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
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