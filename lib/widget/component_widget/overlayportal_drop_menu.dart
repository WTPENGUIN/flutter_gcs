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
    super.key,
    required this.controller,
    required this.buttonBuilder,
    required this.menuBuilder,
    this.menuPosition = MenuPosition.bottom,
  });

  final OverlayPortalController controller;

  final ButtonBuilder buttonBuilder;
  final MenuBuilder menuBuilder;
  final MenuPosition menuPosition;

  @override
  State<OverlayFlexDropDown> createState() => _OverlayFlexDropDownState();
}

class _OverlayFlexDropDownState extends State<OverlayFlexDropDown> {
  final _link = LayerLink();

  /// width of the button after the widget rendered
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
        child: widget.buttonBuilder(context, onTap),
      ),
    );
  }

  void onTap() {
    _buttonWidth = context.size?.width;

    widget.controller.toggle();
  }
}