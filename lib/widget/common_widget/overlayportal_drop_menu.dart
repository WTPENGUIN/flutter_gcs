import 'package:flutter/material.dart';

typedef ButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onTap,
);

typedef MenuBuilder = Widget Function(
  BuildContext context,
  double? width,
);

enum MenuPosition {
  top,
  bottom,
}

class OverlayFlexDropDown extends StatefulWidget {
  const OverlayFlexDropDown({
    Key? key,
    required this.controller,
    required this.buttonBuilder,
    required this.menuBuilder,
    this.menuPosition = MenuPosition.bottom,
  }) : super(key: key);

  final OverlayPortalController controller;
  final ButtonBuilder           buttonBuilder;
  final MenuBuilder             menuBuilder;
  final MenuPosition            menuPosition;

  @override
  State<OverlayFlexDropDown> createState() => _OverlayFlexDropDownState();
}

class _OverlayFlexDropDownState extends State<OverlayFlexDropDown> {
  final _link = LayerLink();

  /// 버튼의 너비
  double? _buttonWidth;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: widget.controller,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            showWhenUnlinked: false,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: widget.menuBuilder(context, _buttonWidth),
            ),
          );
        },
        child: widget.buttonBuilder(context, _onTap),
      ),
    );
  }

  void _onTap() {
    _buttonWidth = context.size?.width;

    widget.controller.toggle();
  }
}