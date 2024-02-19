import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peachgs_flutter/model/vehicle.dart';
import 'package:peachgs_flutter/model/multi_vehicle_manage.dart';
import 'package:dart_mavlink/dialects/ardupilotmega.dart';
import 'package:peachgs_flutter/model/ardupilot.dart';
import 'package:peachgs_flutter/model/px4.dart';

class FlightModeMenu extends StatefulWidget {
  const FlightModeMenu({Key? key}) : super(key: key);

  @override
  State<FlightModeMenu> createState() => _FlightModeMenuState();
}

class _FlightModeMenuState extends State<FlightModeMenu> {
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return RawFlexDropDown(
      controller: _controller,
      buttonBuilder:(BuildContext context, Function() onTap) {
        return Selector<MultiVehicle, String?>(
          selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.flightMode,
          builder: (context, flightMode, _) {
            // 현재 선택된 기체의 비행 모드를 가져와서 위젯을 빌드
            return FlightButtonWidget(
              width: 130,
              onTap: onTap,
              modeName: (flightMode != null) ? flightMode : "Not Connected"
            );
          },
        );
      },
      menuBuilder:(BuildContext context, double? width) {
        return Selector<MultiVehicle, int?>(
          selector: (context, multiVehicle) => multiVehicle.activeVehicle()?.autopilotType,
          builder: (context, currentType, _) {
            // 현재 선택된 기체의 비행 모드를 가져와서 위젯을 빌드
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FlightModeButton(
                  autopilotType: (currentType != null) ? currentType : -1, // TODO : 기체가 연결되어 있지 않으면 반응 없도록
                  width: width,
                  onItemTap: () {
                    _controller.hide();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FlightButtonWidget extends StatelessWidget {
  const FlightButtonWidget({
    super.key,
    required this.modeName,
    this.height = 48,
    this.width,
    this.onTap,
    this.child,
  });

  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final Widget? child;
  final String modeName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.airplanemode_active,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 2,
                    child: Text(
                    modeName,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}

class FlightModeButton extends StatelessWidget {
  const FlightModeButton({
    super.key,
    this.width,
    required this.onItemTap,
    required this.autopilotType
  });

  final double? width;
  final VoidCallback onItemTap;
  final MavAutopilot autopilotType;

  List<Widget> createMenu(MavAutopilot pilot) {
    List<Widget> list = [];

    switch (pilot) {
      // Ardupilot
      case mavAutopilotArdupilotmega:
        for(var flightmode in ardupilotFlightModes) {
          if(!flightmode.settable) continue;
          list.add(
            ItemHolder(
              text: flightmode.modeName,
              onTap: () {
                Vehicle? activeArduVehicle = MultiVehicle().activeVehicle();
                if(activeArduVehicle != null) {
                  activeArduVehicle.setFlightMode(flightmode.modeName);
                }

                // 메뉴 닫기
                onItemTap();
              }
            )
          );
        }
        break;
      // PX4
      case mavAutopilotPx4:
        for(var flightmode in px4FlightModes) {
          if(!flightmode.canBeAuto) continue;
          list.add(
            ItemHolder(
              text: flightmode.modeName,
              onTap: () {
                Vehicle? activePX4Vehicle = MultiVehicle().activeVehicle();
                if(activePX4Vehicle != null) {
                  activePX4Vehicle.setFlightMode(flightmode.modeName);
                }

                // 메뉴 닫기
                onItemTap();
              }
            )
          );
        }
        break;
      // TODO : 지원하지 않는 펌웨어 및 연결되어 있지 않을 때 처리
      default:
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.5,
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 32,
            offset: Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: createMenu(autopilotType)
      ),
    );
  }
}

class ItemHolder extends StatelessWidget {
  const ItemHolder({
    required this.text,
    required this.onTap,
    Key? key
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10
              )
            )
          ),
        ),
      ),
    );
  }
}

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

class RawFlexDropDown extends StatefulWidget {
  const RawFlexDropDown({
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
  State<RawFlexDropDown> createState() => _RawFlexDropDownState();
}

class _RawFlexDropDownState extends State<RawFlexDropDown> {
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