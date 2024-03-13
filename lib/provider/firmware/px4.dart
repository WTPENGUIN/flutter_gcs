import "dart:typed_data";
import 'package:dart_mavlink/dialects/ardupilotmega.dart';

enum PX4CustomMainMode {
  px4CustomMainModeNotUseIndex,
	px4CustomMainModeManual,
	px4CustomMainModeAltctl,
	px4CustomMainModePosctl,
	px4CustomMainModeAuto,
	px4CustomMainModeAcro,
	px4CustomMainModeOffBoard,
	px4CustomMainModeStabilized,
	px4CustomMainModeRattitude,
	px4CustomMainModeSimple /* unused, but reserved for future use */
}

enum PX4CustomSubModeAuto {
  px4CustomSubModeAutoNotUseIndex,
	px4CustomSubModeAutoReady,
	px4CustomSubModeAutoTakeoff,
	px4CustomSubModeAutoLoiter,
	px4CustomSubModeAutoMission,
	px4CustomSubModeAutoRtl,
	px4CustomSubModeAutoLand,
	px4CustomSubModeAutoRtgs,
	px4CustomSubModeAutoFollowTarget,
	px4CustomSubModeAutoPrecland
}

enum PX4CustomSubModePosctl {
  px4CutomSubModePosctlPosctl,
  px4CustomSubModePosctlOrbit
}

class PX4FlightMode {
  final String modeName;
  final int    mainMode;
  final int    subMode;
  final bool   isArmed;
  final bool   canBeFlown;
  final bool   canBeAuto;

  PX4FlightMode(this.modeName, this.mainMode, this.subMode, this.isArmed, this.canBeFlown, this.canBeAuto);
}

List<PX4FlightMode> px4FlightModes = [
  //mode_name                     main_mode                                            sub_mode                                                     canBeSet  FW     MC
  PX4FlightMode("Manual",         PX4CustomMainMode.px4CustomMainModeManual.index,     0,                                                           true,     true,  true),
  PX4FlightMode("Stabilized",     PX4CustomMainMode.px4CustomMainModeStabilized.index, 0,                                                           true,     true,  true),
  PX4FlightMode("Acro",           PX4CustomMainMode.px4CustomMainModeAcro.index,       0,                                                           true,     true,  true),
  PX4FlightMode("Rattitude",      PX4CustomMainMode.px4CustomMainModeRattitude.index,  0,                                                           true,     true,  true),
  PX4FlightMode("Altitude",       PX4CustomMainMode.px4CustomMainModeAltctl.index,     0,                                                           true,     true,  true),
  PX4FlightMode("Position",       PX4CustomMainMode.px4CustomMainModePosctl.index,     PX4CustomSubModePosctl.px4CutomSubModePosctlPosctl.index,    true,     true,  true),
  PX4FlightMode("Offboard",       PX4CustomMainMode.px4CustomMainModeOffBoard.index,   0,                                                           true,     false, true),
  PX4FlightMode("Ready",          PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoReady.index,        false,    true,  true),
  PX4FlightMode("Takeoff",        PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoTakeoff.index,      false,    true,  true),
  PX4FlightMode("Hold",           PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoLoiter.index,       true,     true,  true),
  PX4FlightMode("Mission",        PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoMission.index,      true,     true,  true),
  PX4FlightMode("Return",         PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoRtl.index,          true,     true,  true),
  PX4FlightMode("Land",           PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoLand.index,         false,    true,  true),
  PX4FlightMode("Precision Land", PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoPrecland.index,     true,     false, true),
  PX4FlightMode("Return to GCS",  PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoRtgs.index,         false,    true,  true),
  PX4FlightMode("Follow Me",      PX4CustomMainMode.px4CustomMainModeAuto.index,       PX4CustomSubModeAuto.px4CustomSubModeAutoFollowTarget.index, true,     false, true),
  PX4FlightMode("Simple",         PX4CustomMainMode.px4CustomMainModeSimple.index,     0,                                                           false,    false, true),
  PX4FlightMode("Orbit",          PX4CustomMainMode.px4CustomMainModePosctl.index,     PX4CustomSubModePosctl.px4CustomSubModePosctlOrbit.index,    false,    false, false),
];

// 참고 : QGroundControl에서 비행 모드 union
// struct {
// 	uint16_t reserved; // 1,2바이트
// 	uint8_t main_mode; // 3바이트
// 	uint8_t sub_mode;  // 4바이트
// };

String px4GetFlightModeName(CopterMode customMode) {
  String name = 'Unknown';

  for(PX4FlightMode mode in px4FlightModes) {
    Uint32List list = Uint32List.fromList([customMode]);
    Uint8List byteData = list.buffer.asUint8List();

    var mainMode = byteData[2];
    var subMode = byteData[3];

    if(mainMode == mode.mainMode && subMode == mode.subMode) {
      name = mode.modeName;
      break;
    }
  }

  return name;
}

// 전환 가능한 비행 모드인지 탐색
PX4FlightMode? findPX4FlightMode(String flightMode) {
  PX4FlightMode? returnMode;
  bool found = false;

  for(PX4FlightMode mode in px4FlightModes) {
    if(flightMode.compareTo(mode.modeName) == 0) {
      returnMode = mode;
      found = true;
      break;
    }
  }

  if(found) {
    return returnMode;
  } else {
    return null;
  }
}