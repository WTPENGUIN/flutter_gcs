import 'package:flutter/material.dart';

//const ballDiameter = 30.0;

enum HandlePosition {
  positionUpperLeft,
  positionUpperRight
}

class ResizebleContainerWidget extends StatefulWidget {
  const ResizebleContainerWidget({
    Key? key,
    required this.child,
    required this.size,
    this.boxColor = Colors.black54,
    required this.position
  }) : super(key: key);

  final Widget         child;
  final Size           size;
  final Color          boxColor;
  final HandlePosition position;

  @override
  State<ResizebleContainerWidget> createState() => _ResizebleContainerWidgetState();
}

class _ResizebleContainerWidgetState extends State<ResizebleContainerWidget> {
  late double _height;
  late double _width;

  final double _top = 0;
  final double _left = 0;

  final double _ballDiameter = 30.0;

  @override
  void initState() {
    _height = widget.size.height;
    _width = widget.size.width;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 화면이 큰 상태에서 작아질 때, 위젯 크기를 조절
    if(_height > MediaQuery.of(context).size.height * 0.75) { _height = MediaQuery.of(context).size.height * 0.75; }
    if(_width  > MediaQuery.of(context).size.width  * 0.75) { _width  = MediaQuery.of(context).size.width  * 0.75; }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      color: widget.boxColor,
      child: Stack(
        children: [
          Positioned(
            top: _top,
            left: _left,
            child: SizedBox(
              height: _height,
              width: _width,
              child: widget.child,
            )
          ),
          // 왼쪽 상단에 위치하는 크기조정 핸들
          Visibility(
            visible: (widget.position == HandlePosition.positionUpperLeft),
            child: Positioned(
              top: _top,
              left: _left,
              child: _ManipulatePoint(
                onDrag: (dx, dy) {
                  var mid = (dx + dy) / 2;
                  var newHeight = _height - mid;
                  var newWidth = _width - mid;

                  if(newHeight > MediaQuery.of(context).size.height * 0.75) return;
                  if(newWidth  > MediaQuery.of(context).size.width  * 0.75) return;

                  setState(() {
                    _height = newHeight > widget.size.height ? newHeight : widget.size.height;
                    _width  = newWidth  > widget.size.width  ? newWidth  : widget.size.width;
                  });
                },
              ),
            ),
          ),
          // 오른쪽 상단에 위치하는 크기조정 핸들
          Visibility(
            visible: (widget.position == HandlePosition.positionUpperRight),
            child: Positioned(
              top: _top,
              left: _left + _width - _ballDiameter,
              child: _ManipulatePoint(
                onDrag: (dx, dy) {
                  var newHeight = _height - dy;
                  var newWidth = _width + dx;

                  if(newHeight > MediaQuery.of(context).size.height * 0.75) return;
                  if(newWidth > MediaQuery.of(context).size.width * 0.75) return;

                  setState(() {
                    _height = newHeight > widget.size.height ? newHeight : widget.size.height;
                    _width  = newWidth  > widget.size.width  ? newWidth  : widget.size.width;
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

class _ManipulatePoint extends StatefulWidget {
  const _ManipulatePoint({
    Key? key,
    required this.onDrag,
  }) : super(key: key);

  final Function onDrag;

  @override
  State<_ManipulatePoint> createState() => _ManipulatePointState();
}

class _ManipulatePointState extends State<_ManipulatePoint> {
  double _initX = 0.0;
  double _initY = 0.0;

  final double _ballDiameter = 30.0;

  _handleDrag(details) {
    setState(() {
      _initX = details.globalPosition.dx;
      _initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - _initX;
    var dy = details.globalPosition.dy - _initY;
    _initX = details.globalPosition.dx;
    _initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      // TODO : 아이콘으로 대체
      child: Container(
        width:  _ballDiameter,
        height: _ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }
}