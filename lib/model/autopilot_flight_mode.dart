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
  PX4FlightMode("Position",       PX4CustomMainMode.px4CustomMainModePosctl.index,     PX4CustomSubModePosctl.px4CutomSubModePosctlPosctl.index,    true,     true, true),
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

class ArdupilotFlightMode {
  final String     modeName;
  final CopterMode customMode;
  final bool       settable;

  ArdupilotFlightMode(this.modeName, this.customMode, this.settable);
}

List<ArdupilotFlightMode> ardupilotFlightModes = [
  ArdupilotFlightMode("STABILIZE",    copterModeStabilize,   true),
  ArdupilotFlightMode("ACRO",         copterModeAcro,        true),
  ArdupilotFlightMode("ALT_HOLD",     copterModeAltHold,     true),
  ArdupilotFlightMode("AUTO",         copterModeAuto,        true),
  ArdupilotFlightMode("GUIDED",       copterModeGuided,      true),
  ArdupilotFlightMode("LOITER",       copterModeLoiter,      true),
  ArdupilotFlightMode("RTL",          copterModeRtl,         true),
  ArdupilotFlightMode("CIRCLE",       copterModeCircle,      true),
  ArdupilotFlightMode("LAND",         copterModeLand,        true),
  ArdupilotFlightMode("DRIFT",        copterModeDrift,       true),
  ArdupilotFlightMode("SPORT",        copterModeSport,       true),
  ArdupilotFlightMode("FLIP",         copterModeFlip,        true),
  ArdupilotFlightMode("AUTOTUNE",     copterModeAutotune,    true),
  ArdupilotFlightMode("POS_HOLD",     copterModePoshold,     true),
  ArdupilotFlightMode("BRAKE",        copterModeBrake,       true),
  ArdupilotFlightMode("THROW",        copterModeThrow,       true),
  ArdupilotFlightMode("AVOID_ADSB",   copterModeAvoidAdsb,   true),
  ArdupilotFlightMode("GUIDED_NOGPS", copterModeGuidedNogps, true),
  ArdupilotFlightMode("SMART_RTL",    copterModeSmartRtl,    true),
  ArdupilotFlightMode("FLOWHOLD",     copterModeFlowhold,    true),
  ArdupilotFlightMode("FOLLOW",       copterModeFollow,      true),
  ArdupilotFlightMode("ZIGZAG",       copterModeZigzag,      true),
  ArdupilotFlightMode("SYSTEMID",     copterModeSystemid,    true),
  ArdupilotFlightMode("AUTOROTATE",   copterModeAutorotate,  true),
  ArdupilotFlightMode("AUTO_RTL",     copterModeAutoRtl,     true),
];

String apmGetFlightModeName(CopterMode customMode) {
  String name = 'Unknown';

  for(ArdupilotFlightMode mode in ardupilotFlightModes) {
    if(customMode == mode.customMode) {
      name = mode.modeName;
      break;
    }
  }

  return name;
}